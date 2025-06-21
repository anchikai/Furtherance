local Mod = Furtherance

---@param playerType PlayerType
---@param completionType CompletionType
---@return boolean @Returns if unlock was successful.
function Furtherance:TryUpdateCompletionMark(playerType, completionType)
	if Mod.Game:AchievementUnlocksDisallowed() then return false end
	local entityConfigPlayer = EntityConfig.GetPlayer(playerType)
	if not entityConfigPlayer then return false end
	local completionTable = Mod.PlayerTypeToCompletionTable[playerType]
	if entityConfigPlayer:IsTainted() then
		if (completionType == CompletionType.ISAAC
				or completionType == CompletionType.SATAN
				or completionType == CompletionType.LAMB
				or completionType == CompletionType.BLUE_BABY)
			and Isaac.AllTaintedCompletion(playerType, TaintedMarksGroup.POLAROID_NEGATIVE)
		then
			return Mod.PersistGameData:TryUnlock(completionTable[TaintedMarksGroup.POLAROID_NEGATIVE])
		elseif (completionType == CompletionType.BOSS_RUSH or completionType == CompletionType.HUSH)
			and Isaac.AllTaintedCompletion(playerType, TaintedMarksGroup.SOULSTONE)
		then
			return Mod.PersistGameData:TryUnlock(completionTable[TaintedMarksGroup.SOULSTONE])
		elseif completionTable[completionType] then
			return Mod.PersistGameData:TryUnlock(completionTable[completionType])
		end
	elseif completionTable[completionType] then
		return Mod.PersistGameData:TryUnlock(completionTable[completionType])
	end
	if Isaac.AllMarksFilled(playerType) == 2 then
		return Mod.PersistGameData:TryUnlock(completionTable[Mod.CompletionType.ALL])
	end
	return false
end

---@param completionType CompletionType
local function onCompletionEvent(_, completionType)
	if Mod.Game:AchievementUnlocksDisallowed() then return end
	Mod.Foreach.Player(function (player, index)
		local playerType = player:GetPlayerType()
		if not player.Parent and Mod.PlayerTypeToCompletionTable[playerType] then
			Mod:TryUpdateCompletionMark(playerType, completionType)
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, onCompletionEvent)
