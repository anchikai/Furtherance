local Mod = Furtherance
local game = Game()

Mod:ShelvePlayerData({
	EpitaphStage = Mod.SaveNil,
	EpitaphFirstPassiveItem = Mod.SaveNil,
	EpitaphLastPassiveItem = Mod.SaveNil,
	RunCount = Mod.SaveNil
})

Mod:SavePlayerData({
	EpitaphRoom = Mod.SaveNil,
	EpitaphTombstonePosition = Mod:Serialize(Vector, Mod.SaveNil),
	EpitaphTombstoneDestroyed = Mod.SaveNil,
	OldCollectibles = function() return {} end
})

local TombstoneVariant = Isaac.GetEntityVariantByName("Epitaph Tombstone")

local Tombstone = include("lua.items.trinkets.Epitaph.Tombstone")

local function pickTombstoneRoom(player, roomsList)
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_EPITAPH)

	local NormalRooms = {}
	for i = 0, #roomsList - 1 do
		local roomDesc = roomsList:Get(i)
		if roomDesc.Data.Type == RoomType.ROOM_DEFAULT then
			table.insert(NormalRooms, roomDesc)
		end
	end

	if #NormalRooms > 0 then
		local choice = rng:RandomInt(#NormalRooms) + 1
		return NormalRooms[choice].GridIndex
	end
end

function Mod:PickupItem(player)
	local data = Mod:GetData(player)
	if data.OldCollectibles == nil then
		data.OldCollectibles = {}
	end

	if data.NewEpitaphFirstPassiveItem == nil then
		local oldItem
		local itemConfig = Isaac.GetItemConfig()
		for i = 1, Isaac.GetItemConfig():GetCollectibles().Size do
			local key = tostring(i) -- so data.OldCollectibles it can be saved
			local itemConfigItem = itemConfig:GetCollectible(i)
			if itemConfigItem and itemConfigItem.Type == ItemType.ITEM_PASSIVE then
				local oldItemCount = data.OldCollectibles[key] or 0
				local itemCount = player:GetCollectibleNum(i, false)
				if itemCount > oldItemCount then
					oldItem = i
					break
				end
			end
		end

		if oldItem then
			data.NewEpitaphFirstPassiveItem = oldItem
		end
	end

	if data.OldCollectibleCount == player:GetCollectibleCount() then return end
	data.OldCollectibleCount = player:GetCollectibleCount()

	local newItem
	for i = 1, Isaac.GetItemConfig():GetCollectibles().Size do
		local key = tostring(i) -- so data.OldCollectibles it can be saved
		local itemConfig = Isaac.GetItemConfig():GetCollectible(i)
		if itemConfig and itemConfig.Type == ItemType.ITEM_PASSIVE then
			local oldItemCount = data.OldCollectibles[key] or 0
			local itemCount = player:GetCollectibleNum(i, false)
			if itemCount > oldItemCount then
				newItem = i
			end
			data.OldCollectibles[key] = itemCount
		end
	end

	if newItem then
		data.NewEpitaphLastPassiveItem = newItem
	end
	if data.RunCount == nil then
		data.RunCount = 0
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.PickupItem)

function Mod:EpitaphLevel()
	local level = game:GetLevel()
	local roomsList = level:GetRooms()
	for p = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(p)
		local data = Mod:GetData(player)
		if data.EpitaphRoom == nil then
			data.EpitaphRoom = pickTombstoneRoom(player, roomsList)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Mod.EpitaphLevel)

function Mod:EpitaphRoom()
	local level = game:GetLevel()
	local room = game:GetRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)
		if level:GetStage() == data.EpitaphStage and level:GetCurrentRoomDesc().GridIndex == data.EpitaphRoom then
			if data.EpitaphTombstonePosition == nil then
				data.EpitaphTombstonePosition = room:FindFreeTilePosition(Isaac.GetRandomPosition(), 0)
			end

			local tombstone = Tombstone.new(player, data.EpitaphTombstonePosition)
			if data.EpitaphTombstoneDestroyed then
				tombstone.Health = 0
				tombstone.Instance:GetSprite():Play("Destroyed", true)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.EpitaphRoom)

function Mod:EpitaphDied(entity)
	local player = entity:ToPlayer()
	if player then
		local data = Mod:GetData(player)
		if player:HasTrinket(TrinketType.TRINKET_EPITAPH) then
			local level = game:GetLevel()
			data.EpitaphStage = level:GetStage()
			data.RunCount = 0
			data.EpitaphFirstPassiveItem = data.NewEpitaphFirstPassiveItem
			data.EpitaphLastPassiveItem = data.NewEpitaphLastPassiveItem
		else
			data.EpitaphStage = nil
			data.EpitaphFirstPassiveItem = nil
			data.EpitaphLastPassiveItem = nil
		end
		data.EpitaphRoom = nil
		data.EpitaphTombstonePosition = nil
		data.EpitaphTombstoneDestroyed = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Mod.EpitaphDied, EntityType.ENTITY_PLAYER)

function Mod:DetectExplosion(bomb)
	local sprite = bomb:GetSprite()
	if not sprite:IsPlaying("Explode") then return end

	for _, tombstone in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, TombstoneVariant)) do
		tombstone = tombstone:ToEffect()
		local distance = bomb.Position:Distance(tombstone.Position)
		if distance <= 100 then
			Mod:GetData(tombstone):TakeDamage()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, Mod.DetectExplosion)

function Mod:ResetEpitaph(continued)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)
		if continued == false then
			if data.RunCount == nil then
				data.RunCount = 0
			elseif data.EpitaphStage ~= nil then
				data.RunCount = data.RunCount + 1
			end
			if data.RunCount >= 2 and data.EpitaphStage ~= nil then
				data.RunCount = 0
				data.EpitaphStage = nil
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.ResetEpitaph)
