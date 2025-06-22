local Mod = Furtherance
local game = Game()

local MANDRAKE = {}

Furtherance.Item.MANDRAKE = MANDRAKE

MANDRAKE.ID = Isaac.GetItemIdByName("Mandrake")

function MANDRAKE:SpawnFamiliarItem()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_TREASURE and room:IsFirstVisit() then
		if PlayerManager.AnyoneHasCollectible(MANDRAKE.ID) then
			Mod.Foreach.Pickup(function (pickup, index)
				if Mod:GetData(pickup).MandrakeItem then return end
				local optionIndex = pickup.OptionsPickupIndex
				if optionIndex == 0 then
					optionIndex = pickup:SetNewOptionsPickupIndex()
					pickup.OptionsPickupIndex = optionIndex
				end
				local player = PlayerManager.FirstCollectibleOwner(MANDRAKE.ID, true)
				---@cast player EntityPlayer

				local rng = player:GetCollectibleRNG(MANDRAKE.ID)
				local itemID = game:GetItemPool():GetCollectible(ItemPoolType.POOL_BABY_SHOP, true, rng:GetSeed())
				rng:Next()

				local mandrakeSpawn = Mod.Spawn.Collectible(itemID, room:FindFreePickupSpawnPosition(pickup.Position, 80))
				mandrakeSpawn.OptionsPickupIndex = optionIndex
				Mod:GetData(mandrakeSpawn).MandrakeItem = true
				if pickup:IsShopItem() then
					mandrakeSpawn:MakeShopItem(-1)
				end
			end, PickupVariant.PICKUP_COLLECTIBLE)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MANDRAKE.SpawnFamiliarItem)