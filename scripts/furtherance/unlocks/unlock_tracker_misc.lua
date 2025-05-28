local Mod = Furtherance

local ACHIEVEMENT_START = Mod.Item.SECRET_DIARY.ACHIEVEMENT
local ACHIEVEMENT_END = Mod.ACHIEVEMENT_COMPLETION - 1

local function onAchievementUnlock()
	if Mod.PersistGameData:Unlocked(Mod.ACHIEVEMENT_COMPLETION) then return end

	for achievement = ACHIEVEMENT_START, ACHIEVEMENT_END do
		if not Mod.PersistGameData:Unlocked(achievement) then
			return
		end
	end

	Mod.PersistGameData:TryUnlock(Mod.ACHIEVEMENT_COMPLETION)
end

Mod:AddCallback(ModCallbacks.MC_POST_ACHIEVEMENT_UNLOCK, onAchievementUnlock)
