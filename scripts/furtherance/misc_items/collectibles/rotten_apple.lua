local Mod = Furtherance

local ROTTEN_APPLE = {}

Furtherance.Item.ROTTEN_APPLE = ROTTEN_APPLE

ROTTEN_APPLE.ID = Isaac.GetItemIdByName("Rotten Apple")

ROTTEN_APPLE.DAMAGE_UP = 1
ROTTEN_APPLE.Worms = {
	TrinketType.TRINKET_PULSE_WORM,
	TrinketType.TRINKET_WIGGLE_WORM,
	TrinketType.TRINKET_RING_WORM,
	TrinketType.TRINKET_FLAT_WORM,
	TrinketType.TRINKET_HOOK_WORM,
	TrinketType.TRINKET_WHIP_WORM,
	TrinketType.TRINKET_TAPE_WORM,
	TrinketType.TRINKET_LAZY_WORM,
	TrinketType.TRINKET_BRAIN_WORM
}

---@param itemID CollectibleType
---@param player EntityPlayer
function ROTTEN_APPLE:OnFirstPickup(itemID, charge, firstTime, slot, varData, player)
	if firstTime then
		local rng = player:GetCollectibleRNG(itemID)
		local chosenWorm = ROTTEN_APPLE.Worms[rng:RandomInt(#ROTTEN_APPLE.Worms) + 1]
		player:AddSmeltedTrinket(chosenWorm, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, ROTTEN_APPLE.OnFirstPickup, ROTTEN_APPLE.ID)

---@param player EntityPlayer
function ROTTEN_APPLE:DamageBuff(player)
	if player:HasCollectible(ROTTEN_APPLE.ID) then
		player.Damage = player.Damage + (ROTTEN_APPLE.DAMAGE_UP * player:GetCollectibleNum(ROTTEN_APPLE.ID))
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ROTTEN_APPLE.DamageBuff, CacheFlag.CACHE_DAMAGE)
