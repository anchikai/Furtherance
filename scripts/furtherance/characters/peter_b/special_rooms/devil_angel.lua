local Mod = Furtherance

---Number 6 Devil Rooms (SubType 1)
local function devilRoomMorph()
	local seed = Mod:GetAndAdvanceGenericRNGSeed()
	return RoomConfigHolder.GetRandomRoom(seed, true, StbType.SPECIAL_ROOMS, RoomType.ROOM_ANGEL, Furtherance.Room():GetRoomShape(), -1, -1, 1, 10, 1, 1)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, devilRoomMorph, RoomType.ROOM_DEVIL)

---Stairway Angel Rooms (SubType 1)
local function angelRoomMorph()
	local seed = Mod:GetAndAdvanceGenericRNGSeed()
	return RoomConfigHolder.GetRandomRoom(seed, true, StbType.SPECIAL_ROOMS, RoomType.ROOM_DEVIL, Furtherance.Room():GetRoomShape(), -1, -1, 1, 10, 1, 1)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, angelRoomMorph, RoomType.ROOM_ANGEL)

---Normal Angel Room effect w/Birthright
local function updateAngelItems(_, newRoomType)
	if not PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B) then return end
	if newRoomType == RoomType.ROOM_ANGEL then
		local pickupIndex
		for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
			local pickup = ent:ToPickup()
			---@cast pickup EntityPickup
			if not pickupIndex then
				pickup:SetNewOptionsPickupIndex()
				pickupIndex = pickup.OptionsPickupIndex
			else
				pickup.OptionsPickupIndex = pickupIndex
			end
			if pickup:IsShopItem() then
				pickup.Price = 0
			end
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, updateAngelItems, RoomType.ROOM_DEVIL)

---Lost-style Devil Deals
local function updateDevilItems(_, newRoomType)
	if PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B) then return end
	if newRoomType == RoomType.ROOM_DEVIL then
		local pickupIndex
		for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
			local pickup = ent:ToPickup()
			---@cast pickup EntityPickup
			if not pickupIndex then
				pickup:SetNewOptionsPickupIndex()
				pickupIndex = pickup.OptionsPickupIndex
			else
				pickup.OptionsPickupIndex = pickupIndex
			end
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, updateDevilItems, RoomType.ROOM_ANGEL)
