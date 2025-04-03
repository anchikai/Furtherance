local Mod = Furtherance

local GLITCHED_PENNY = {}

Furtherance.Item.GLITCHED_PENNY = GLITCHED_PENNY

GLITCHED_PENNY.ID = Isaac.GetTrinketIdByName("Glitched Penny")

GLITCHED_PENNY.PROC_CHANCE = 0.25

---@param coin EntityPickup
---@param collider Entity
function GLITCHED_PENNY:GlitchedPennyProc(coin, collider)
	local player = collider:ToPlayer()
	if player == nil or not player:HasTrinket(GLITCHED_PENNY.ID) then return end

	local rng = player:GetTrinketRNG(GLITCHED_PENNY.ID)
	if rng:RandomFloat() <= GLITCHED_PENNY.PROC_CHANCE and coin.SubType ~= CoinSubType.COIN_STICKYNICKEL then
		local ID
		local itemPool = Mod.Game:GetItemPool()
		repeat
			ID = itemPool:GetCollectible(ItemPoolType.POOL_TREASURE, false, rng:GetSeed(),
				CollectibleType.COLLECTIBLE_TAMMYS_HEAD,
				---@diagnostic disable-next-line: param-type-mismatch
				GetCollectibleFlag.BAN_PASSIVES | GetCollectibleFlag.IGNORE_MODIFIERS)
			rng:Next()
			local itemConfig = Isaac.GetItemConfig():GetCollectible(ID)
		until (not itemConfig:HasTags(ItemConfig.TAG_QUEST) and itemConfig.ChargeType ~= ItemConfig.CHARGE_SPECIAL and itemConfig.MaxCharges ~= 0)
		player:UseActiveItem(ID, true, false, false, false)
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, GLITCHED_PENNY.GlitchedPennyProc, PickupVariant.PICKUP_COIN)
