local Mod = Furtherance

local SPECIAL_ROOM_FLIP = {}

Furtherance.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP = SPECIAL_ROOM_FLIP

local roomPath = "scripts.furtherance.characters.peter_b.special_rooms"

local specialRooms = {
	"treasure_deviltreasure",
	"shop_library",
	--"devil_angel"
}

Mod.LoopInclude(specialRooms, roomPath)

SPECIAL_ROOM_FLIP.ALLOWED_SPECIAL_ROOMS = Mod:Set({
	RoomType.ROOM_TREASURE,
	RoomType.ROOM_SHOP,
	RoomType.ROOM_LIBRARY,
	--[[ RoomType.ROOM_DEVIL,
	RoomType.ROOM_ANGEL,
	RoomType.ROOM_PLANETARIUM,
	RoomType.ROOM_ULTRASECRET, ]]
})
SPECIAL_ROOM_FLIP.ROOM_VARIANT = 5900

---@param idx integer
function SPECIAL_ROOM_FLIP:IsFlippedRoom(idx)
	local room_save = Mod:RoomSave()
	return room_save.MuddledCrossFlippedRoom
		and room_save.MuddledCrossFlippedRoom[tostring(idx)]
end

function SPECIAL_ROOM_FLIP:TryFlipSpecialRoom()
	local room = Mod.Room()
	local roomType = room:GetType()
	local level = Mod.Level()
	local curIndex = Mod.Level():GetCurrentRoomIndex()
	local roomConfigRoom = Isaac.RunCallbackWithParam(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, roomType)
	if not roomConfigRoom then return false end
	local room_save = Mod:RoomSave()
	room_save.MuddledCrossFlippedRoom = room_save.MuddledCrossFlippedRoom or {}
	room_save.MuddledCrossFlippedRoom[tostring(curIndex)] = true
	--Replace current room's data with newly received blank room, if applicable
	if type(roomConfigRoom) ~= "boolean" then
		--Completely empty out the room as new room data will fill it with its own data
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if not ent:ToPlayer() and not ent:ToFamiliar() then
				ent:Remove()
			end
		end
		for index = room:GetGridSize() - 1, 0, -1 do
			local gridEnt = room:GetGridEntity(index)
			if gridEnt then
				room:RemoveGridEntityImmediate(index, 0, false)
			end
		end
		local currentRoom = level:GetRoomByIdx(curIndex)
		currentRoom.Data = roomConfigRoom
	end
	--Update room by instantly re-entering the same room
	Mod.Game:ChangeRoom(curIndex)
	Mod.Room():PlayMusic()
	Isaac.RunCallbackWithParam(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, roomType, room:GetType())
	return true
end
