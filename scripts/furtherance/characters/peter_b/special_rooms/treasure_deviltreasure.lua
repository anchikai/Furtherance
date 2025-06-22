local Mod = Furtherance
local MUDDLED_CROSS = Mod.Item.MUDDLED_CROSS

local function treasureRoomFlip()
	local level = Mod.Level()
	local curIndex = Mod.Level():GetCurrentRoomIndex()
	local roomDesc = level:GetRoomByIdx(curIndex)
	--Doing backdrop and door sprite manually as the devil treasure flag does the work for us
	if Mod:HasBitFlags(roomDesc.Flags, RoomDescriptor.FLAG_DEVIL_TREASURE) then
		roomDesc.Flags = Mod:RemoveBitFlags(roomDesc.Flags, RoomDescriptor.FLAG_DEVIL_TREASURE)
		return true
	else
		roomDesc.Flags = Mod:AddBitFlags(roomDesc.Flags, RoomDescriptor.FLAG_DEVIL_TREASURE)
		return true
	end
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, treasureRoomFlip, RoomType.ROOM_TREASURE)

local function provideFlippedBackdrop()
	local roomDesc = Mod:GetRoomDesc()
	if Mod:HasBitFlags(roomDesc.Flags, RoomDescriptor.FLAG_DEVIL_TREASURE) then
		local backdropType = RoomConfig.GetStage(Isaac.GetCurrentStageConfigId()):GetBackdrop()
		local backdropSprite = "gfx/backdrop/" .. XMLData.GetEntryById(XMLNode.BACKDROP, backdropType)
		return backdropSprite
	else
		return MUDDLED_CROSS.SPECIAL_ROOM_FLIP.ROOM_BACKDROPS[RoomType.ROOM_DEVIL]
	end
end

Mod:AddCallback(Mod.ModCallbacks.GET_MUDDLED_CROSS_PUDDLE_BACKDROP, provideFlippedBackdrop, RoomType.ROOM_TREASURE)

local function updateCollectibles()
	local roomDesc = Mod.Level():GetCurrentRoomDesc()

	Mod.Foreach.Pickup(function (pickup, index)
		pickup:Morph(pickup.Type, pickup.Variant, 0, true, true, false)
		if Mod:HasBitFlags(roomDesc.Flags, RoomDescriptor.FLAG_DEVIL_TREASURE) then
			pickup:MakeShopItem(-1)
		elseif pickup:IsShopItem() then
			pickup.Price = 0
		end
	end, PickupVariant.PICKUP_COLLECTIBLE)

	if not MUDDLED_CROSS:CanUseUpgradedRoomFlip() then return end

	Mod:DelayOneFrame(function()
		local room = Mod.Room()
		Mod.Foreach.Pickup(function (pickup, index)
			if Mod:GetData(pickup).PeterBBirthrightTreasure then return end
			local optionIndex = pickup.OptionsPickupIndex
			if optionIndex == 0 then
				optionIndex = pickup:SetNewOptionsPickupIndex()
				pickup.OptionsPickupIndex = optionIndex
			end
			local pickupSpawn = Mod.Spawn.Collectible(NullPickupSubType.ANY, room:FindFreePickupSpawnPosition(pickup.Position, 80))
			pickupSpawn.OptionsPickupIndex = optionIndex
			Mod:GetData(pickupSpawn).PeterBBirthrightTreasure = true
			if pickup:IsShopItem() then
				pickupSpawn:MakeShopItem(-1)
			end
		end, PickupVariant.PICKUP_COLLECTIBLE)
	end)
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, updateCollectibles, RoomType.ROOM_TREASURE)
