local Mod = Furtherance
local game = Game()

function Mod:ButterflyDamage(entity)
	local player = entity:ToPlayer()
	local data = Mod:GetData(player)
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BUTTERFLY) then
		data.ButterflyTears = 60
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.ButterflyDamage, EntityType.ENTITY_PLAYER)

function Mod:FireTears(player)
	local data = Mod:GetData(player)
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BUTTERFLY) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BUTTERFLY)
		if data.ButterflyTears == nil then
			data.ButterflyTears = 0
		elseif data.ButterflyTears > 0 then
			data.ButterflyTears = data.ButterflyTears - 1
			local speed = 10
			if game:GetFrameCount() % 2 == 0 then
				player:FireTear(player.Position, Vector(math.random(-speed, speed), math.random(-speed, speed)), true,
					true, true, player, 0.5)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.FireTears)
