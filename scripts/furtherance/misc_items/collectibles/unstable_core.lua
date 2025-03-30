local Mod = Furtherance

local UNSTABLE_CORE = {}

Furtherance.Item.UNSTABLE_CORE = UNSTABLE_CORE

UNSTABLE_CORE.ID = Isaac.GetItemIdByName("Unstable Core")

UNSTABLE_CORE.RADIUS = 66
local TECH_SWORD_TEAR_POOF_SUBTYPE = 23

---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
function UNSTABLE_CORE:OnUse(_, rng, player, flags)
	--So that internal usage of using actives doesn't trigger this
	if not player:HasCollectible(UNSTABLE_CORE.ID) or not Mod:HasBitFlags(flags, UseFlag.USE_OWNED) then return end
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, TECH_SWORD_TEAR_POOF_SUBTYPE, player.Position, Vector.Zero, nil)
	Mod.SFXMan:Play(SoundEffect.SOUND_LASERRING_WEAK)
	local source = EntityRef(player)
	Mod:ForEachEnemy(function(npc)
		if Mod:IsValidEnemyTarget(npc) then
			npc:AddBurn(source, 90, 5)
		end
	end, player.Position, UNSTABLE_CORE.RADIUS)
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, UNSTABLE_CORE.OnUse)
