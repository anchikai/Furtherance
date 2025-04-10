local Mod = Furtherance

local SPECIAL_ROOM_FLIP = {}

Furtherance.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP = SPECIAL_ROOM_FLIP

local roomPath = "scripts.furtherance.characters.peter_b.special_rooms"

local specialRooms = {
	"treasure_deviltreasure",
	"shop_library",
	"devil_angel",
	"planetarium_ultrasecret"
}

Mod.LoopInclude(specialRooms, roomPath)

SPECIAL_ROOM_FLIP.ALLOWED_SPECIAL_ROOMS = Mod:Set({
	RoomType.ROOM_TREASURE,
	RoomType.ROOM_SHOP,
	RoomType.ROOM_LIBRARY,
	RoomType.ROOM_DEVIL,
	RoomType.ROOM_ANGEL,
	RoomType.ROOM_PLANETARIUM,
	RoomType.ROOM_ULTRASECRET,
})
SPECIAL_ROOM_FLIP.TEMP_KEEP_DOORS_SHUT_DURATION = 45
local tempCloseDoors = 0

---@param idx integer
function SPECIAL_ROOM_FLIP:IsFlippedRoom(idx)
	local room_save = Mod:RoomSave()
	return room_save.MuddledCrossFlippedRoom
		and room_save.MuddledCrossFlippedRoom[tostring(idx)]
end

local roomToLoad

function SPECIAL_ROOM_FLIP:TryFlipSpecialRoom()
	local room = Mod.Room()
	local roomType = room:GetType()
	local curIndex = Mod.Level():GetCurrentRoomIndex()
	local roomConfigRoom = Isaac.RunCallbackWithParam(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, roomType)
	if not roomConfigRoom then return false end
	local room_save = Mod:RoomSave()
	if curIndex ~= GridRooms.ROOM_DEBUG_IDX then
		room_save.MuddledCrossFlippedRoom = room_save.MuddledCrossFlippedRoom or {}
		room_save.MuddledCrossFlippedRoom[tostring(curIndex)] = true
	end
	--Replace current room's data with newly received blank room, if applicable
	if type(roomConfigRoom) ~= "boolean" then
		roomToLoad = roomConfigRoom
	end

	return true
end

function SPECIAL_ROOM_FLIP:UpdateRoom()
	local curIndex = Mod.Level():GetCurrentRoomIndex()
	local room = Mod.Room()
	local roomType = room:GetType()
	if roomToLoad then
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
		Mod.SFXMan:Play(SoundEffect.SOUND_1UP)
		local currentRoom = Mod.Level():GetRoomByIdx(curIndex)
		currentRoom.Data = roomToLoad
		roomToLoad = nil
	end
	Mod.Game:ChangeRoom(curIndex)
	Mod.Room():PlayMusic()
	Isaac.RunCallbackWithParam(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, roomType, room:GetType())
	tempCloseDoors = SPECIAL_ROOM_FLIP.TEMP_KEEP_DOORS_SHUT_DURATION
end

---Keeping doors shut for a second so you don't accidentally walk out from disorientation
function SPECIAL_ROOM_FLIP:TempCloseDoors()
	local room = Mod.Room()
	if tempCloseDoors > 0 then
		tempCloseDoors = tempCloseDoors - 1
		for doorSlot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
			local door = room:GetDoor(doorSlot)
			if door and not door:IsOpen() and tempCloseDoors == 0 then
				door:Open()
			elseif door
				and door:IsOpen()
				and door:GetSprite():GetAnimation() ~= door.CloseAnimation
				and tempCloseDoors > 0
			then
				door:Close(true)
				door:GetSprite():Play(door.CloseAnimation, true)
				door:GetSprite():SetLastFrame()
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, SPECIAL_ROOM_FLIP.TempCloseDoors)

local function resetDoorsNewRoom()
	tempCloseDoors = 0
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, resetDoorsNewRoom)