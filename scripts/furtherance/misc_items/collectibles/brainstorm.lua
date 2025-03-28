local Mod = Furtherance
local game = Game()

local Braincell = Isaac.GetEntityVariantByName("Braincell")

function Mod:WellInit(Cell)
	Cell:AddToOrbit(2)
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, Mod.WellInit, Braincell)

function Mod:CellCollide(Cell, collider)
	local player = Cell.SpawnerEntity and Cell.SpawnerEntity:ToPlayer()
	if player and collider.Variant == Braincell then
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_BRAINSTORM)
		SFXManager():Play(SoundEffect.SOUND_EDEN_GLITCH)
		player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0,
			Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
		Cell:Die()
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, Mod.CellCollide, Braincell)

function Mod:CellUpdate(Cell)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BRAINSTORM)
		Cell.OrbitDistance = Vector(33, 33)
		Cell.OrbitSpeed = 0.005
		Cell.Velocity = Cell:GetOrbitPosition(player.Position + player.Velocity) - Cell.Position
	end
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Mod.CellUpdate, Braincell)

function Mod:CellCache(player, flag)
	if flag == CacheFlag.CACHE_FAMILIARS then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BRAINSTORM) then
			player:CheckFamiliar(Braincell, 2, player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BRAINSTORM))
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.CellCache)
