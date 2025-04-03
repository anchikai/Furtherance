
local MOD = Furtherance

local ZZZZOPTIONSZZZZ = {}

Furtherance.Item.ZZZZOPTIONSZZZZ = ZZZZOPTIONSZZZZ

ZZZZOPTIONSZZZZ.ID = Isaac.GetItemIdByName("ZZZZoptionsZZZZ")

function ZZZZOPTIONSZZZZ:ZZZZ()
	local ROOM = MOD.Game:GetRoom()
	if ROOM:GetType() == RoomType.ROOM_TREASURE and ROOM:IsFirstVisit() then
		if PlayerManager.AnyoneHasCollectible(ZZZZOPTIONSZZZZ.ID) then
			for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
				local pickup = ent:ToPickup()
				---@cast pickup EntityPickup
				local optionIndex = pickup.OptionsPickupIndex
				if optionIndex == 0 then
					optionIndex = pickup:SetNewOptionsPickupIndex()
					pickup.OptionsPickupIndex = optionIndex
				end
				local AAAAAAAAAAAAAA = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0,
					ROOM:FindFreePickupSpawnPosition(pickup.Position + Vector(40, 0)), Vector.Zero, nil):ToPickup()
				---@cast AAAAAAAAAAAAAA EntityPickup
				AAAAAAAAAAAAAA.OptionsPickupIndex = optionIndex
				AAAAAAAAAAAAAA:AddEntityFlags(EntityFlag.FLAG_GLITCH)
				if pickup:IsShopItem() then
					Isaac.CreateTimer(function() AAAAAAAAAAAAAA.Price = pickup.Price
						AAAAAAAAAAAAAA.ShopItemId = -1
					end, 1, 1, true)
				end
			end
		end
	end
end
MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ZZZZOPTIONSZZZZ.ZZZZ)