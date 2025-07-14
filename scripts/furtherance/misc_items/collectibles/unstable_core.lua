local Mod = Furtherance
local ceil = Mod.math.ceil
local max = Mod.math.max

local UNSTABLE_CORE = {}

Furtherance.Item.UNSTABLE_CORE = UNSTABLE_CORE

UNSTABLE_CORE.ID = Isaac.GetItemIdByName("Unstable Core")

UNSTABLE_CORE.RADIUS = 66
UNSTABLE_CORE.DEFAULT_DURATION = 90
local TECH_SWORD_TEAR_POOF_SUBTYPE = 23

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
	local source = EntityRef(player)
	local charges = player:GetActiveCharge(slot)
	local chargeBuff = max(1, ceil(charges / 2))
	local itemNum = player:GetCollectibleNum(UNSTABLE_CORE.ID)
	local itemMult = 1 + ((itemNum - 1) * 0.5)
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, TECH_SWORD_TEAR_POOF_SUBTYPE, player.Position, Vector.Zero, nil)
	effect.SpriteScale = Vector(2 * itemMult, 2 * itemMult)
	Mod.SFXMan:Play(SoundEffect.SOUND_LASERRING_WEAK)

	if charges > 12 then
		chargeBuff = 1
	elseif charges == 0 then
		return
	end

	local carBattery = Mod:ActiveUsesCarBattery(player, slot) and 2 or 1
	local radius = UNSTABLE_CORE.RADIUS * itemMult

	Mod.Foreach.NPCInRadius(player.Position, radius, function (npc, index)
		npc:AddBurn(source, UNSTABLE_CORE.DEFAULT_DURATION, 5 * carBattery)
		npc:SetBurnCountdown(UNSTABLE_CORE.DEFAULT_DURATION * chargeBuff * carBattery)
	end, nil, nil, {UseEnemySearchParams = true})
end

Mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.EARLY, UNSTABLE_CORE.OnUse)
