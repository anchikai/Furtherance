local Mod = Furtherance

local PETER_B = {}

Furtherance.Character.PETER_B = PETER_B

PETER_B.WATER_COLOR = KColor(2, 0, 0, 0.5)

---@param player EntityPlayer
function PETER_B:IsPeterB(player)
	return player:GetPlayerType() == Mod.PlayerType.PETER_B
end

function PETER_B:UsePeterFlipRoomEffects()
	return PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.PETER_B)
		and Mod.Room():GetType() ~= RoomType.ROOM_DUNGEON
end

function PETER_B:BloodTears(tear)
	local player = Mod:TryGetPlayer(tear)
	if player and PETER_B:IsPeterB(player) then
		Mod:TryChangeTearToBloodVariant(tear)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, PETER_B.BloodTears)

function PETER_B:OnFirstPlayerInit()
	PETER_B:OnNewRoom()
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, PETER_B.OnFirstPlayerInit, Mod.PlayerType.PETER_B)

function PETER_B:OnNewRoom()
	local room = Mod.Room()
	if PETER_B:UsePeterFlipRoomEffects() and not room:HasWater() then
		room:SetWaterAmount(0.5)
		room:GetFXParams().UseWaterV2 = true
		room:SetWaterColor(PETER_B.WATER_COLOR)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, PETER_B.OnNewRoom)

Mod.Include("scripts.furtherance.characters.peter_b.muddled_cross")
Mod.Include("scripts.furtherance.characters.peter_b.flip_modifier.flip_main")