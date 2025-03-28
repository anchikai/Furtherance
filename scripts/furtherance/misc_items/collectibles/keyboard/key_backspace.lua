local Mod = Furtherance

local BACKSPACE_KEY = {}

Furtherance.Item.KEY_BACKSPACE = BACKSPACE_KEY

BACKSPACE_KEY.ID = Isaac.GetItemIdByName("Backspace Key")

function BACKSPACE_KEY:UseBackSpace(_, _, player)
	local level = Mod.Level()
	local room = Mod.Room()
	local doorSlot = level.EnterDoor
	if doorSlot == -1 then return true end
	local door = room:GetDoor(doorSlot)

	if door and not door:IsOpen() then
		door:TryUnlock(player, true)
		if door:IsOpen() then
			Mod.SFXMan:Play(SoundEffect.SOUND_UNLOCK00)
		end
	end
	if not door or not door:IsOpen() then
		player:AnimateSad()
		return false
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BACKSPACE_KEY.UseBackSpace, BACKSPACE_KEY.ID)
