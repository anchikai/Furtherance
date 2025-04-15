local Mod = Furtherance

local UNSTABLE_CORE = {}

Furtherance.Item.UNSTABLE_CORE = UNSTABLE_CORE

UNSTABLE_CORE.ID = Isaac.GetItemIdByName("Unstable Core")

UNSTABLE_CORE.RADIUS = 66
UNSTABLE_CORE.DEFAULT_DURATION = 90
local TECH_SWORD_TEAR_POOF_SUBTYPE = 23
local ceil = math.ceil
local max = math.max

---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
function UNSTABLE_CORE:OnUse(itemID, _, player, flags, slot)
	--So that internal usage of using actives doesn't trigger this
	if not player:HasCollectible(UNSTABLE_CORE.ID)
		or not Mod:HasBitFlags(flags, UseFlag.USE_OWNED)
		or slot ~= ActiveSlot.SLOT_PRIMARY
	then
		return
	end
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, TECH_SWORD_TEAR_POOF_SUBTYPE, player.Position, Vector.Zero, nil)
	Mod.SFXMan:Play(SoundEffect.SOUND_LASERRING_WEAK)
	local source = EntityRef(player)
	local charges = player:GetActiveCharge(slot)
	local chargeBuff = max(1, ceil(charges / 2))
	if charges > 12 then
		chargeBuff = 1
	elseif charges == 0 then
		return
	end
	local carBattery = Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) and 2 or 1
	Mod:ForEachEnemy(function(npc)
		npc:AddBurn(source, UNSTABLE_CORE.DEFAULT_DURATION, 5 * carBattery)
		npc:SetBurnCountdown(UNSTABLE_CORE.DEFAULT_DURATION * chargeBuff * carBattery)
	end, true, player.Position, UNSTABLE_CORE.RADIUS)
end

Mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.EARLY, UNSTABLE_CORE.OnUse)
