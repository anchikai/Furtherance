local Mod = Furtherance

local function devilRoomFlip()
	return RoomConfigHolder.GetRandomRoom(Mod.GENERIC_RNG:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_ANGEL, Furtherance.Room():GetRoomShape(), -1, -1, 1, 10, 1, 0)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, devilRoomFlip, RoomType.ROOM_DEVIL)

local function angelRoomFlip()
	return RoomConfigHolder.GetRandomRoom(Mod.GENERIC_RNG:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_DEVIL, Furtherance.Room():GetRoomShape(), -1, -1, 1, 10, 1, 0)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, angelRoomFlip, RoomType.ROOM_ANGEL)

local function devilRoomBackdrop()
	return Mod.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP.ROOM_BACKDROPS[RoomType.ROOM_DEVIL]
end

Mod:AddCallback(Mod.ModCallbacks.GET_MUDDLED_CROSS_PUDDLE_BACKDROP, devilRoomBackdrop, RoomType.ROOM_ANGEL)

local function angelRoomBackdrop()
	return Mod.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP.ROOM_BACKDROPS[RoomType.ROOM_ANGEL]
end

Mod:AddCallback(Mod.ModCallbacks.GET_MUDDLED_CROSS_PUDDLE_BACKDROP, angelRoomBackdrop, RoomType.ROOM_DEVIL)

local function angelRoomShop()
	Mod.Foreach.Pickup(Mod.Card.REVERSE_CHARITY.MakeBalancedShopItem, PickupVariant.PICKUP_COLLECTIBLE)
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, angelRoomShop, RoomType.ROOM_ANGEL)

local function birthrightAngelSteamSale(_, count, player, itemID, onlyTrue)
	if itemID == CollectibleType.COLLECTIBLE_STEAM_SALE
		and Mod.Character.PETER_B:IsPeterB(player)
		and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	then
		if Mod.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP:IsFlippedRoom()
			and Mod.Room():GetType() == RoomType.ROOM_ANGEL
		then
			return count + 1
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_APPLY_INNATE_COLLECTIBLE_NUM, birthrightAngelSteamSale)

---@param pickup EntityPickup
local function birthrightYourSoulPrice(_, pickup)
	if not Mod.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP:IsFlippedRoom() then return end
	if Mod.Room():GetType() == RoomType.ROOM_DEVIL
		and PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B)
	then
		local room_save = Mod:RoomSave()
		local data = Mod:GetData(pickup)
		if not room_save.PeterBBirthrightPurchasedDevil
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
	if not Mod.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP:IsFlippedRoom() then return end
	local player = collider:ToPlayer()
	if not player then return end
	if Mod:GetData(pickup).PeterBBirthrightFreePickup then
		local room_save = Mod:RoomSave()
		room_save.PeterBBirthrightPurchasedDevil = true
		Mod.Foreach.Pickup(function (_pickup, index)
			local data = Mod:GetData(_pickup)
			if data.PeterBBirthrightFreePickup then
				_pickup.AutoUpdatePrice = true
				data.PeterBBirthrightFreePickup = nil
			end
		end, PickupVariant.PICKUP_COLLECTIBLE)
	elseif Mod:CanPlayerBuyShopItem(player, pickup) then
		Mod:KillDevilPedestals(pickup)
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, birthrightOnShopPurchase, PickupVariant.PICKUP_COLLECTIBLE)