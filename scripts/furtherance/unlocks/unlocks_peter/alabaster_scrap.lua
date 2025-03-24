local Mod = Furtherance

local ALABASTER_SCRAP = {}

Furtherance.Trinket.ALABASTER_SCRAP = ALABASTER_SCRAP

ALABASTER_SCRAP.ID = Isaac.GetTrinketIdByName("Alabaster Scrap")
ALABASTER_SCRAP.DAMAGE_MULT_UP = 0.5

---@param itemID CollectibleType | TrinketType
---@param isTrinket boolean
---@param amount integer
---@param player EntityPlayer
function ALABASTER_SCRAP:UpdateAngelItemCount(itemID, isTrinket, amount, player)
	local itemConfig = isTrinket and Mod.ItemConfig:GetTrinket(itemID) or Mod.ItemConfig:GetCollectible(itemID)
	if itemConfig
		and itemConfig:HasTags(ItemConfig.TAG_ANGEL)
	then
		player:GetEffects():AddTrinketEffect(ALABASTER_SCRAP.ID, false, amount)
	end
end

---@param itemID CollectibleType
---@param player EntityPlayer
function ALABASTER_SCRAP:OnCollectibleAdd(itemID, _, _, _, _, player)
	ALABASTER_SCRAP:UpdateAngelItemCount(itemID, false, 1, player)
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, ALABASTER_SCRAP.OnCollectibleAdd)

function ALABASTER_SCRAP:OnCollectibleRemove(player, itemID)
	ALABASTER_SCRAP:UpdateAngelItemCount(itemID, false, -1, player)
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, ALABASTER_SCRAP.OnCollectibleRemove)

function ALABASTER_SCRAP:OnTrinketAdd(player, trinketID)
	local amount = Mod:HasBitFlags(trinketID, TrinketType.TRINKET_GOLDEN_FLAG) and 2 or 1
	ALABASTER_SCRAP:UpdateAngelItemCount(trinketID, true, amount, player)
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, ALABASTER_SCRAP.OnCollectibleRemove)

function ALABASTER_SCRAP:OnTrinketRemove(player, trinketID)
	local amount = Mod:HasBitFlags(trinketID, TrinketType.TRINKET_GOLDEN_FLAG) and 2 or 1
	ALABASTER_SCRAP:UpdateAngelItemCount(trinketID, true, -amount, player)
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, ALABASTER_SCRAP.OnCollectibleRemove)

---@param player EntityPlayer
function ALABASTER_SCRAP:DamageUp(player)
	if player:HasTrinket(ALABASTER_SCRAP.ID) then
		local mult = player:GetTrinketMultiplier(ALABASTER_SCRAP.ID)
		local numAngel = player:GetEffects():GetTrinketEffectNum(ALABASTER_SCRAP.ID)
		player.Damage = player.Damage + (numAngel * ALABASTER_SCRAP.DAMAGE_MULT_UP * mult)
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ALABASTER_SCRAP.DamageUp, CacheFlag.CACHE_DAMAGE)