local mod = Furtherance
local game = Game()

function mod:Mandrake()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_TREASURE and room:IsFirstVisit() then
		for p = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(p)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MANDRAKE) then
				for i, entity in ipairs(Isaac.GetRoomEntities()) do
					if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
						entity.Position = entity.Position - Vector(40, 0)
						entity:ToPickup().OptionsPickupIndex = 1
					end
				end

				local pos = 68
				local option = 1
				if player:HasCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS) then
					pos = 69
					option = 2
				end

				local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MANDRAKE)
				local ID = game:GetItemPool():GetCollectible(ItemPoolType.POOL_BABY_SHOP, true, rng:GetSeed())
				rng:Next()

				local babee = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ID, room:GetGridPosition(pos), Vector.Zero, player):ToPickup()
				babee.OptionsPickupIndex = option
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.Mandrake)