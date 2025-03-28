local Mod = Furtherance
local game = Game()
local sfx = SFXManager()

function Mod:UseBackSpace(_, _, player)
	local level = game:GetLevel()
	local door = game:GetRoom():GetDoor(level.EnterDoor)
	if door and not door:IsOpen() then
		game:GetRoom():GetDoor(level.EnterDoor):Open()
		if not door:IsOpen() then
			door:TryUnlock(player, true)
		end
		if door:IsOpen() then
			sfx:Play(SoundEffect.SOUND_GOLDENKEY)
		end
	elseif door and door:IsOpen() then
		sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
	end
	if not door or not door:IsOpen() then
		sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseBackSpace, CollectibleType.COLLECTIBLE_BACKSPACE_KEY)
