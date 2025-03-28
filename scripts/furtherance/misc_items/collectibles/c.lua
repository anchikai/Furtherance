local Mod = Furtherance
local game = Game()

local cKeyLibrary = false

function Mod:UseC(_, _, player)
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_C_KEY)
	Isaac.ExecuteCommand("goto s.library.5")
	cKeyLibrary = true
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseC, CollectibleType.COLLECTIBLE_C_KEY)

function Mod:CKeyTeleported()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local roomDesc = level:GetCurrentRoomDesc()
	if cKeyLibrary
		and roomDesc.GridIndex == GridRooms.ROOM_DEBUG_IDX
		and roomDesc.Data.Variant == 5
		and roomDesc.Data.Type == RoomType.ROOM_LIBRARY
	then
		for i = 0, room:GetGridSize() - 1 do
			local grid = room:GetGridEntity(i)
			if grid and not grid:ToDoor() then
				room:RemoveGridEntity(i, 0, true)
			end
		end
	end
	cKeyLibrary = false
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.CKeyTeleported)
