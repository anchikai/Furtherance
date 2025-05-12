local Mod = Furtherance

local BI_84 = {}

Furtherance.Trinket.BI_84 = BI_84

BI_84.ID = Isaac.GetTrinketIdByName("BI-84")

BI_84.PROC_CHANCE = 0.25

---@param player EntityPlayer
---@param itemID CollectibleType
function BI_84:SpawnItemWisp(player, itemID)
	local data = Mod:GetData(player)
	local wisp = player:AddItemWisp(itemID, Vector.Zero, false)
	wisp:RemoveFromOrbit()
	wisp.Friction = 0
	wisp.Visible = false
	wisp:AddEntityFlags(EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_REWARD)
	wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	data.BI_84ItemWisp = wisp
end

---@param player EntityPlayer
function BI_84:TryRemoveTechWisp(player)
	local data = Mod:GetData(player)
	if data.BI_84ItemWisp and data.BI_84ItemWisp:Exists() then
		data.BI_84ItemWisp:Remove()
		data.BI_84ItemWisp:Kill()
		data.BI_84ItemWisp = nil
	end
end

---@param player EntityPlayer
function BI_84:RandomTechItem(player)
	BI_84:TryRemoveTechWisp(player)
	if player:HasTrinket(BI_84.ID) then
		local rng = RNG(Mod.Level():GetCurrentRoomDesc().SpawnSeed)
		local trinketMult = player:GetTrinketMultiplier(BI_84.ID)
		if rng:RandomFloat() <= trinketMult * BI_84.PROC_CHANCE then
			local techItemConfigs = Mod.ItemConfig:GetTaggedItems(ItemConfig.TAG_TECH)
			local techItemIDs = {}
			for _, itemConfig in ipairs(techItemConfigs) do
				if not itemConfig:HasTags(ItemConfig.TAG_QUEST)
					and Mod.PersistGameData:Unlocked(itemConfig.AchievementID)
					and itemConfig:IsCollectible()
				then
					Mod.Insert(techItemIDs, itemConfig.ID)
				end
			end
			local techItem = techItemIDs[rng:RandomInt(#techItemIDs) + 1]
			BI_84:SpawnItemWisp(player, techItem)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, BI_84.RandomTechItem)

function BI_84:RemoveTechWisps()
	Mod.Foreach.Player(function(player)
		BI_84:TryRemoveTechWisp(player)
	end)
end

Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, BI_84.RemoveTechWisps)

---@param player EntityPlayer
---@param trinketID TrinketType
function BI_84:RemoveWispOnTrinketRemove(player, trinketID)
	BI_84:TryRemoveTechWisp(player)
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, BI_84.RemoveWispOnTrinketRemove)
