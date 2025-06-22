local Mod = Furtherance

local NIL_NUM = {}

Furtherance.Trinket.NIL_NUM = NIL_NUM

NIL_NUM.ID = Isaac.GetTrinketIdByName("Nil Num")

NIL_NUM.PROC_CHANCE = 0.02

---@param ent Entity
function NIL_NUM:Duplicate(ent)
	local player = ent:ToPlayer()
	if player and player:HasTrinket(NIL_NUM.ID) then
		local rng = player:GetTrinketRNG(NIL_NUM.ID)
		if rng:RandomFloat() <= NIL_NUM.PROC_CHANCE * player:GetTrinketMultiplier(NIL_NUM.ID) then
			local inventory = player:GetHistory():GetCollectiblesHistory()
			local itemIDs = {}
			for _, historyItem in ipairs(inventory) do
				if not historyItem:IsTrinket()
					and not Mod.ItemConfig:GetCollectible(historyItem:GetItemID()):HasTags(ItemConfig.TAG_QUEST)
				then
					Mod.Insert(itemIDs, historyItem:GetItemID())
				end
			end
			local itemID = itemIDs[rng:RandomInt(#itemIDs) + 1]
			Mod.Spawn.Collectible(itemID, Mod.Room():FindFreePickupSpawnPosition(player.Position, 40), player, player:GetTrinketRNG(NIL_NUM.ID):Next())
			player:TryRemoveTrinket(NIL_NUM.ID)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, NIL_NUM.Duplicate, EntityType.ENTITY_PLAYER)
