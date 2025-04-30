local Mod = Furtherance

local C_KEY = {}

Furtherance.Item.KEY_C = C_KEY

C_KEY.ID = Isaac.GetItemIdByName("C Key")

local cKeyLibrary = false

function C_KEY:Onuse(_, _, player)
	Isaac.ExecuteCommand("goto s.library.5")
	Mod.Game:StartRoomTransition(GridRooms.ROOM_DEBUG_IDX, -1, RoomTransitionAnim.TELEPORT, player)
	cKeyLibrary = true
	return {Discharge = true, Remove = true, ShowAnim = false}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, C_KEY.Onuse, C_KEY.ID)

function C_KEY:CKeyTeleported()
	local room = Mod.Room()
	local roomDesc = Mod:GetRoomDesc()
	if cKeyLibrary
		and roomDesc.GridIndex == GridRooms.ROOM_DEBUG_IDX
		and roomDesc.Data.Variant == 5
		and roomDesc.Data.Type == RoomType.ROOM_LIBRARY
	then
		Mod.Foreach.Grid(function (gridEnt, gridIndex)
			if not gridEnt:ToDoor() then
				room:RemoveGridEntity(gridIndex, 0, true)
			end
		end)
	end
	cKeyLibrary = false
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, C_KEY.CKeyTeleported)
