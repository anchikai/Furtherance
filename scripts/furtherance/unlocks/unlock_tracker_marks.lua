---@param playerType PlayerType
---@param completionType CompletionType
---@return boolean @Returns if unlock was successful.
function Furtherance:TryUpdateCompletionMark(playerType, completionType)
	if Furtherance.Game:AchievementUnlocksDisallowed() then return false end
	local entityConfigPlayer = EntityConfig.GetPlayer(playerType)
	if not entityConfigPlayer then return false end
	local completionTable = Furtherance.PlayerTypeToCompletionTable[playerType]
	if entityConfigPlayer:IsTainted() then
		if (completionType == CompletionType.ISAAC
				or completionType == CompletionType.SATAN
				or completionType == CompletionType.LAMB
				or completionType == CompletionType.BLUE_BABY)
			and Isaac.AllTaintedCompletion(playerType, TaintedMarksGroup.POLAROID_NEGATIVE)
		then
			return Furtherance.PersistGameData:TryUnlock(completionTable[TaintedMarksGroup.POLAROID_NEGATIVE])
		elseif (completionType == CompletionType.BOSS_RUSH or completionType == CompletionType.HUSH)
			and Isaac.AllTaintedCompletion(playerType, TaintedMarksGroup.SOULSTONE)
		then
			return Furtherance.PersistGameData:TryUnlock(completionTable[TaintedMarksGroup.SOULSTONE])
		elseif completionTable[completionType] then
			return Furtherance.PersistGameData:TryUnlock(completionTable[completionType])
		end
	elseif completionTable[completionType] then
		return Furtherance.PersistGameData:TryUnlock(completionTable[completionType])
	end
	if Isaac.AllMarksFilled(playerType) then
		return Furtherance.PersistGameData:TryUnlock(completionTable[Furtherance.CompletionType.ALL])
	end
	return false
end

---@param completionType CompletionType
local function onCompletionEvent(_, completionType)
	if Furtherance.Game:AchievementUnlocksDisallowed() then return end
	Furtherance:ForEachMainPlayer(function(player)
		local playerType = player:GetPlayerType()
		if Furtherance.PlayerTypeToCompletionTable[playerType] then
			Furtherance:TryUpdateCompletionMark(playerType, completionType)
		end
	end)
end

Furtherance:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, onCompletionEvent)
