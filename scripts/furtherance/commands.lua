local Mod = Furtherance

local function executeCmd(_, cmd, params)
	if cmd == "furtherance"
		and (params == "unlockall"
		or params == "lockall")
	then
		local startAch = Mod.Item.SECRET_DIARY.ACHIEVEMENT
		local endAch = Isaac.GetAchievementIdByName("Furtherance 100%")
		local unlock = params == "unlockall"
		for i = startAch, endAch do
			if unlock then
				Mod.PersistGameData:TryUnlock(i, true)
			else
				Isaac.ExecuteCommand("lockachievement " .. i)
			end
		end
		if unlock then
			Mod:Log("Unlocked all mod achievemnts")
		else
			Mod:Log("Locked all mod achievemnts")
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, executeCmd)