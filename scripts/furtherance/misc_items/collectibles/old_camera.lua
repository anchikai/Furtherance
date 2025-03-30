local Mod = Furtherance

local OLD_CAMERA = {}

Furtherance.Item.OLD_CAMERA = OLD_CAMERA

OLD_CAMERA.ID = Isaac.GetItemIdByName("Old Camera")

--TODO: Revisit, this effect is trash

--[[ local game = Game()

Mod:SavePlayerData({
	CameraSaved = false,
	CurRoomID = Mod.SaveNil
})

function Mod:RespawnEnemies(player)
	local data = Mod:GetData(player)
	local room = game:GetRoom()
	if data.UsedOldCamera and game:IsPaused() == false then
		room:RespawnEnemies()
		data.UsedOldCamera = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.RespawnEnemies)

function Mod:UseCamera(_, _, player)
	local data = Mod:GetData(player)
	local level = game:GetLevel()
	if data.CameraSaved == false then
		data.CameraSaved = true
		data.CurRoomID = level:GetCurrentRoomIndex()
	elseif data.CameraSaved == true then
		level.LeaveDoor = -1
		game:StartRoomTransition(data.CurRoomID, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, -1)
		data.CameraSaved = false
		data.UsedOldCamera = true
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseCamera, CollectibleType.COLLECTIBLE_OLD_CAMERA)

local newGame = false
function Mod:NewGame()
	newGame = true
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Mod.NewGame)

function Mod:ForgetOnNewLevel()
	if newGame then
		newGame = false
		return
	end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)
		data.CameraSaved = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Mod.ForgetOnNewLevel)
 ]]