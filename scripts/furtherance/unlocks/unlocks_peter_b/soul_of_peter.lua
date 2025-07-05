local Mod = Furtherance

local SOUL_OF_PETER = {}

Furtherance.Rune.SOUL_OF_PETER = SOUL_OF_PETER

SOUL_OF_PETER.ID = Isaac.GetCardIdByName("Soul of Peter")

SOUL_OF_PETER.ALLOWED_SPECIAL_ROOMS = {
	RoomType.ROOM_SHOP,
	RoomType.ROOM_TREASURE,
	RoomType.ROOM_MINIBOSS,
	RoomType.ROOM_SECRET,
	RoomType.ROOM_SUPERSECRET,
	RoomType.ROOM_ARCADE,
	RoomType.ROOM_CURSE,
	RoomType.ROOM_LIBRARY,
	RoomType.ROOM_SACRIFICE,
	RoomType.ROOM_DEVIL,
	RoomType.ROOM_ANGEL,
	RoomType.ROOM_ISAACS,
	RoomType.ROOM_BARREN,
	RoomType.ROOM_CHEST,
	RoomType.ROOM_DICE,
	RoomType.ROOM_PLANETARIUM,
}
SOUL_OF_PETER.BLACKLISTED_NEIGHBORS = Mod:Set({
	RoomType.ROOM_SECRET,
	RoomType.ROOM_SUPERSECRET,
	RoomType.ROOM_ULTRASECRET
})
SOUL_OF_PETER.SPECIAL_ROOM_CHANCE = 0.1
SOUL_OF_PETER.NUM_ROOMS = 5
SOUL_OF_PETER.REQUIRED_DOORS = 4

-- Essentially following the same rules as Red Key, more or less
---@param player EntityPlayer
function SOUL_OF_PETER:OnUse(_, player)
	local level = Mod.Level()

	local dimension = -1 -- current dimension
	local seed = level:GetDungeonPlacementSeed()
	local rng = RNG(seed)
	local createdRoom = false

	for _ = 1, SOUL_OF_PETER.NUM_ROOMS do
		local stbtype = Isaac.GetCurrentStageConfigId()
		local roomtype = RoomType.ROOM_DEFAULT
		if rng:RandomFloat() <= SOUL_OF_PETER.SPECIAL_ROOM_CHANCE then
			stbtype = StbType.SPECIAL_ROOMS
			roomtype = SOUL_OF_PETER.ALLOWED_SPECIAL_ROOMS[rng:RandomInt(#SOUL_OF_PETER.ALLOWED_SPECIAL_ROOMS) + 1]
		end

		-- Get a random 1x1 room that can accept a door on all sides
		local roomConfig = RoomConfigHolder.GetRandomRoom(rng:GetSeed(), true, stbtype, roomtype, RoomShape.ROOMSHAPE_1x1, -1, -1, 0, 10, SOUL_OF_PETER.REQUIRED_DOORS)
		rng:Next()
		local allowMultipleDoors = true
		local allowSpecialNeighbors = true

		-- Fetch all valid locations this room can be placed.
		local options = level:FindValidRoomPlacementLocations(roomConfig, dimension, allowMultipleDoors, allowSpecialNeighbors)
		-- Shuffle for wider variety in placement
		options = Mod:ShuffleTable(options, rng)

		-- Loop through options
		for _, gridIndex in ipairs(options) do
			local neighbors = level:GetNeighboringRooms(gridIndex, roomConfig.Shape)
			local connectsToBlacklistedRooms = false

			-- No undesired neighbors
			for _, neighborDesc in pairs(neighbors) do
				local neighborType = neighborDesc.Data.Type
				if SOUL_OF_PETER.BLACKLISTED_NEIGHBORS[neighborType] then
					connectsToBlacklistedRooms = true
				end
			end

			if not connectsToBlacklistedRooms then
				-- Try to place the room.
				local room = level:TryPlaceRoom(roomConfig, gridIndex, dimension, rng:GetSeed(), allowMultipleDoors,
					allowSpecialNeighbors)
				if room then
					createdRoom = true
					room.DisplayFlags = Mod.DisplayFlags.VISIBLE
					-- The room was placed successfully!
					break
				end
			end
		end
	end
	if createdRoom then
		Mod.SFXMan:Play(SoundEffect.SOUND_GOLDENKEY)
		Mod.Level():UpdateVisibility()
	else
		player:AnimateSad()
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_PETER.OnUse, SOUL_OF_PETER.ID)
