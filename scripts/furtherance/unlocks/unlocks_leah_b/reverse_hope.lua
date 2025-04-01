local Mod = Furtherance

local REVERSE_HOPE = {}

Furtherance.Card.REVERSE_HOPE = REVERSE_HOPE

REVERSE_HOPE.ID = Isaac.GetCardIdByName("ReverseHope")

local MINES_MIN = 25
local MINES_MAX = 32

---@param player EntityPlayer
function REVERSE_HOPE:OnUse(card, player, flag)
	local rng = player:GetCardRNG(REVERSE_HOPE.ID)
	local level = Mod.Level()
	local isMines = (level:GetStage() == LevelStage.STAGE2_2 or level:GetStage() == LevelStage.STAGE2_2) and level:GetStageType() >= StageType.STAGETYPE_REPENTANCE
	local roomVariant = 0
	-- Attempt to find a valid challenge room. Done this way to avoid choosing the literal ambush wave rooms and mines-specific rooms
	for _ = 1, 100 do
		local challengeRoom = RoomConfigHolder.GetRandomRoom(rng:GetSeed(), false, StbType.SPECIAL_ROOMS, RoomType.ROOM_CHALLENGE, RoomShape.ROOMSHAPE_1x1,
			-1, -1, 0, 10, 1, -1, Mod:GetRoomMode())
		rng:Next()
		if challengeRoom.Subtype ~= 10
			and (isMines or not isMines and (challengeRoom.Variant > MINES_MAX or challengeRoom.Variant < MINES_MIN))
		then
			roomVariant = challengeRoom.Variant
			break
		end
	end
	Isaac.ExecuteCommand("goto s.challenge." .. roomVariant)
	local game = Mod.Game
	level.LeaveDoor = -1
	game:StartRoomTransition(GridRooms.ROOM_DEBUG_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
	-- If a challenge room was completed on the floor, or in a previous debug room, it will still be marked as done. Reset state when entering room
	Mod:DelayOneFrame(function() level:GetCurrentRoomDesc().ChallengeDone = false end)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, REVERSE_HOPE.OnUse, REVERSE_HOPE.ID)
