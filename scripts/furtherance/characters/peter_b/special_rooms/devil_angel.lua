local Mod = Furtherance

---Number 6 Devil Rooms (SubType 1)
local function devilRoomFlip()
	return RoomConfigHolder.GetRandomRoom(Mod.GENERIC_RNG:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_ANGEL, Furtherance.Room():GetRoomShape(), -1, -1, 1, 10, 1, 1)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, devilRoomFlip, RoomType.ROOM_DEVIL)

---Stairway Angel Rooms (SubType 1)
local function angelRoomFlip()
	return RoomConfigHolder.GetRandomRoom(Mod.GENERIC_RNG:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_DEVIL, Furtherance.Room():GetRoomShape(), -1, -1, 1, 10, 1, 1)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, angelRoomFlip, RoomType.ROOM_ANGEL)

local function birthrightAngelSteamSale(_, count, player, itemID, onlyTrue)
	if itemID == CollectibleType.COLLECTIBLE_STEAM_SALE
		and Mod.Character.PETER_B:IsPeterB(player)
		and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	then
		local room_save = Mod:RoomSave()
		if room_save.MuddledCrossFlippedRoom
			and room_save.MuddledCrossFlippedRoom[tostring(Mod.Level():GetCurrentRoomIndex())]
			and Mod.Room():GetType() == RoomType.ROOM_ANGEL
		then
			return count + 1
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_APPLY_INNATE_COLLECTIBLE_NUM, birthrightAngelSteamSale)

---@param pickup EntityPickup
local function birthrightYourSoulPrice(_, pickup)
	if Mod.Room():GetType() == RoomType.ROOM_DEVIL
		and PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B)
	then
		local room_save = Mod:RoomSave()
		local data = Mod:GetData(pickup)
		if room_save.MuddledCrossFlippedRoom
			and room_save.MuddledCrossFlippedRoom[tostring(Mod.Level():GetCurrentRoomIndex())]
			and not room_save.PeterBBirthrightPurchasedDevil
			and not data.PeterBBirthrightIgnorePickup
			and pickup:IsShopItem()
		then
			if pickup.Price ~= PickupPrice.PRICE_SOUL then
				data.PeterBBirthrightFreePickup = true
				pickup.Price = PickupPrice.PRICE_SOUL
				pickup.AutoUpdatePrice = false
			end
		end
		--Was made free through some other means, presumably
		if data.PeterBBirthrightFreePickup and not pickup:IsShopItem() and not pickup.Touched then
			data.PeterBBirthrightFreePickup = nil
			data.PeterBBirthrightIgnorePickup = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, birthrightYourSoulPrice, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
local function birthrightOnShopPurchase(_, pickup, collider)
	local player = collider:ToPlayer()
	if not player then return end
	if Mod:GetData(pickup).PeterBBirthrightFreePickup then
		local room_save = Mod:RoomSave()
		room_save.PeterBBirthrightPurchasedDevil = true
		for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
			local data = Mod:GetData(ent)
			if data.PeterBBirthrightFreePickup then
				local _pickup = ent:ToPickup()
				---@cast _pickup EntityPickup
				_pickup.AutoUpdatePrice = true
				data.PeterBBirthrightFreePickup = nil
			end
		end
	elseif Mod:CanPlayerBuyShopItem(player, pickup) then
		Mod:KillDevilPedestals(pickup)
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, birthrightOnShopPurchase)