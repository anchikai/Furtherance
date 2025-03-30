local Mod = Furtherance
local game = Game()

local MANDRAKE = {}

Furtherance.Item.MANDRAKE = MANDRAKE

MANDRAKE.ID = Isaac.GetItemIdByName("Mandrake")

--TODO: Move pedestals around depending on how many there are in the room I guess? Mandrakes included.
function MANDRAKE:SpawnFamiliarItem()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_TREASURE and room:IsFirstVisit() then
		if PlayerManager.AnyoneHasCollectible(MANDRAKE.ID) then
			for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
				local pickup = ent:ToPickup()
				---@cast pickup EntityPickup
				if Mod:GetData(pickup).MandrakeItem then return end
				local optionIndex = pickup.OptionsPickupIndex
				if optionIndex == 0 then
					optionIndex = pickup:SetNewOptionsPickupIndex()
					pickup.OptionsPickupIndex = optionIndex
				end
				local player = PlayerManager.FirstCollectibleOwner(MANDRAKE.ID, true)
				---@cast player EntityPlayer

				local rng = player:GetCollectibleRNG(MANDRAKE.ID)
				local ID = game:GetItemPool():GetCollectible(ItemPoolType.POOL_BABY_SHOP, true, rng:GetSeed())
				rng:Next()

				local mandrakeSpawn = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ID,
					room:FindFreePickupSpawnPosition(pickup.Position + Vector(40, 0)), Vector.Zero, nil):ToPickup()
				---@cast mandrakeSpawn EntityPickup
				mandrakeSpawn.OptionsPickupIndex = optionIndex
				Mod:GetData(mandrakeSpawn).MandrakeItem = true
				if pickup:IsShopItem() then
					Isaac.CreateTimer(function() mandrakeSpawn.Price = pickup.Price
						mandrakeSpawn.ShopItemId = -1
					end, 1, 1, true)
				end
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MANDRAKE.SpawnFamiliarItem)