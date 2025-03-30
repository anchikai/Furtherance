local Mod = Furtherance

local SUNSCREEN = {}

Furtherance.Item.SUNSCREEN = SUNSCREEN

SUNSCREEN.ID = Isaac.GetItemIdByName("Sunscreen")

---@param ent Entity
---@param flags DamageFlag
function SUNSCREEN:SunscreenDamage(ent, _, flags)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(SUNSCREEN.ID) and Mod:HasBitFlags(flags, DamageFlag.DAMAGE_FIRE) then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SUNSCREEN.SunscreenDamage, EntityType.ENTITY_PLAYER)
