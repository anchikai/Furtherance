local Mod = Furtherance

local BI_84 = {}

Furtherance.Trinket.BI_84 = BI_84

BI_84.ID = Isaac.GetTrinketIdByName("BI-84")

BI_84.PROC_CHANCE = 0.25

--TODO: Doesn't...work? player:AddInnateCollectible is fine, but not this. weird.

---@param player EntityPlayer
function BI_84:RandomTechItem(player)
	if player:HasTrinket(BI_84.ID) then
		local rng = player:GetTrinketRNG(BI_84.ID)
		local trinketMult = player:GetTrinketMultiplier(BI_84.ID)
		if rng:RandomFloat() <= trinketMult * BI_84.PROC_CHANCE then
			local tehcItemConfigs = Mod.ItemConfig:GetTaggedItems(ItemConfig.TAG_TECH)
			local techItemIDs = {}
			for _, itemConfig in ipairs(tehcItemConfigs) do
				if not itemConfig:HasTags(ItemConfig.TAG_QUEST) then
					Mod:Insert(techItemIDs, itemConfig.ID)
				end
			end
			local techItem = techItemIDs[rng:RandomInt(#techItemIDs) + 1]
			player:GetEffects():AddTrinketEffect(BI_84.ID, false, techItem)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, BI_84.RandomTechItem)

---@param count integer
---@param player EntityPlayer
---@param itemID CollectibleType
---@param onlyTrue boolean
function BI_84:GrantTechItem(count, player, itemID, onlyTrue)
	if not onlyTrue and itemID ~= 0 then
		local effects = player:GetEffects()
		if itemID == effects:GetTrinketEffectNum(BI_84.ID) then
			return count + 1
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_APPLY_INNATE_COLLECTIBLE_NUM, BI_84.GrantTechItem)