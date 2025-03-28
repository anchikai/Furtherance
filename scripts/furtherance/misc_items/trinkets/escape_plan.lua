local Mod = Furtherance
local game = Game()

function Mod:Escape(entity)
	local player = entity:ToPlayer()
	if player and player:HasTrinket(TrinketType.TRINKET_ESCAPE_PLAN) then
		local rng = player:GetTrinketRNG(TrinketType.TRINKET_ESCAPE_PLAN)
		if rng:RandomFloat() <= 0.1 then
			local level = game:GetLevel()
			level.LeaveDoor = -1
			game:StartRoomTransition(level:GetStartingRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT,
				player, -1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.Escape, EntityType.ENTITY_PLAYER)
