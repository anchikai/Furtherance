
local Mod = Furtherance

local ZZZZOPTIONSZZZZ = {}

Furtherance.Item.ZZZZOPTIONSZZZZ = ZZZZOPTIONSZZZZ

ZZZZOPTIONSZZZZ.ID = Isaac.GetItemIdByName("ZZZZoptionsZZZZ")

function ZZZZOPTIONSZZZZ:ZZZZ()
	local room = Mod.Game:GetRoom()
	if room:GetType() == RoomType.ROOM_TREASURE
		and room:IsFirstVisit()
		and PlayerManager.AnyoneHasCollectible(ZZZZOPTIONSZZZZ.ID)
	then
		Mod.Foreach.Pickup(function (pickup, index)
			local optionIndex = pickup.OptionsPickupIndex
			if optionIndex == 0 then
				optionIndex = pickup:SetNewOptionsPickupIndex()
				pickup.OptionsPickupIndex = optionIndex
			end
			local glitchPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0,
				room:FindFreePickupSpawnPosition(pickup.Position + Vector(40, 0)), Vector.Zero, nil):ToPickup()
			---@cast glitchPickup EntityPickup
			glitchPickup.OptionsPickupIndex = optionIndex
			glitchPickup:AddEntityFlags(EntityFlag.FLAG_GLITCH)
			if pickup:IsShopItem() then
				Isaac.CreateTimer(function() glitchPickup.Price = pickup.Price
					glitchPickup.ShopItemId = -1
				end, 1, 1, true)
			end
		end, PickupVariant.PICKUP_COLLECTIBLE)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ZZZZOPTIONSZZZZ.ZZZZ)