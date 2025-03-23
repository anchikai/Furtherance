local mod = Furtherance
local game = Game()

local ChallengeDirection = Direction.NO_DIRECTION
function mod:FuckYouStupidAssDoor(player)
	local level = game:GetLevel()
	local room = game:GetRoom()
	for i = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(i)
		if player:HasTrinket(TrinketType.TRINKET_KEY_TO_THE_PIT)
			and room:IsClear()
			and door
			and door.TargetRoomType == RoomType.ROOM_CHALLENGE
			and not door:IsOpen()
		then
			local ChallengeDoor = room:GetDoorSlotPosition(i)
			if ChallengeDoor.X == 40 and (ChallengeDoor.Y == 280 or ChallengeDoor.Y == 560) then
				ChallengeDirection = Direction.LEFT
			elseif ChallengeDoor.Y == 120 and (ChallengeDoor.X == 320 or ChallengeDoor.X == 840) then
				ChallengeDirection = Direction.UP
			elseif (ChallengeDoor.Y == 280 and (ChallengeDoor.X == 600 or ChallengeDoor.X == 1120)) or ChallengeDoor.X == 1120 and ChallengeDoor.Y == 560 then
				ChallengeDirection = Direction.RIGHT
			elseif (ChallengeDoor.X == 320 and (ChallengeDoor.Y == 440 or ChallengeDoor.Y == 720)) or ChallengeDoor.X == 840 and ChallengeDoor.Y == 720 then
				ChallengeDirection = Direction.DOWN
			end
			if player.Position:DistanceSquared(ChallengeDoor) < 30 ^ 2 and room:GetDoor(i):IsOpen() == false then
				level.LeaveDoor = -1
				game:StartRoomTransition(door.TargetRoomIndex, ChallengeDirection, RoomTransitionAnim.WALK)
			end
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.FuckYouStupidAssDoor)
