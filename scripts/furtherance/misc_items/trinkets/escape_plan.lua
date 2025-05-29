local Mod = Furtherance

local ESCAPE_PLAN = {}

Furtherance.Trinket.ESCAPE_PLAN = ESCAPE_PLAN

ESCAPE_PLAN.ID = Isaac.GetTrinketIdByName("Escape Plan")

ESCAPE_PLAN.PROC_CHANCE = 0.1

---@param ent Entity
function ESCAPE_PLAN:Escape(ent)
	local player = ent:ToPlayer()
	if player and player:HasTrinket(ESCAPE_PLAN.ID) then
		local rng = player:GetTrinketRNG(ESCAPE_PLAN.ID)
		local trinketMult = player:GetTrinketMultiplier(ESCAPE_PLAN.ID)

		if rng:RandomFloat() <= ESCAPE_PLAN.PROC_CHANCE * trinketMult then
			local level = Mod.Level()
			level.LeaveDoor = -1
			Mod.Game:StartRoomTransition(level:GetStartingRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, ESCAPE_PLAN.Escape, EntityType.ENTITY_PLAYER)
