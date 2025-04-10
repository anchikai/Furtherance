local Mod = Furtherance

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

local function updateCollectibles()
	local roomDesc = Mod.Level():GetCurrentRoomDesc()
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
		local pickup = ent:ToPickup()
		---@cast pickup EntityPickup
		if Mod:HasBitFlags(roomDesc.Flags, RoomDescriptor.FLAG_DEVIL_TREASURE) and not PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B) then
			pickup:MakeShopItem(-1)
		elseif pickup:IsShopItem() then
			pickup.Price = 0
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, updateCollectibles, RoomType.ROOM_TREASURE)