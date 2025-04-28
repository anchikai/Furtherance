local Mod = Furtherance
local game = Mod.Game

local ALTERNATE_REALITY = {}

Furtherance.Item.ALTERNATE_REALITY = ALTERNATE_REALITY

ALTERNATE_REALITY.ID = Isaac.GetItemIdByName("Alternate Reality")

---Returns a table in order from Stage 1 (Basement I) to Stage 6 (Sheol/Cathedral) of all available stages and stage variants
---
---This goes by achievements, not specifically if the stage will be encountered in a run.
---@param stage? LevelStage @Will provide available stage variants on the provided LevelStage.
---@return {[1]: LevelStage, [2]: StageType}[]
function ALTERNATE_REALITY:GetAvailableStages(stage)
	local level = Mod.Level()
	local stageList = {}
	local stageStart, stageEnd
	if stage == nil then
		stageStart = LevelStage.STAGE1_1
		stageEnd = LevelStage.STAGE6
	else
		stageStart = stage
		stageEnd = stage
	end
	for levelStage = stageStart, stageEnd do
		local maxVariant = StageType.STAGETYPE_REPENTANCE_B
		if levelStage == LevelStage.STAGE5 or levelStage == LevelStage.STAGE6 then
			maxVariant = StageType.STAGETYPE_WOTL
		elseif levelStage == LevelStage.STAGE4_3 then
			maxVariant = StageType.STAGETYPE_ORIGINAL
		end
		for stageType = 0, maxVariant do
			if stageType == StageType.STAGETYPE_GREEDMODE then goto skipGreed end
			if level:IsStageAvailable(levelStage, stageType) then
				Mod:Insert(stageList, {levelStage, stageType})
			end

			::skipGreed::
		end
	end
	return stageList
end

---@param levelStage LevelStage
---@param stageType StageType
---@param sameStage? boolean
function ALTERNATE_REALITY:QueueNewStage(levelStage, stageType, sameStage)
	local floor_save = Mod:FloorSave()
	floor_save.AlternateRealityNewStage = {levelStage, stageType}
	Mod.Game:StartStageTransition(sameStage or false, 0, nil)
	Mod:ForEachPlayer(function (player)
		player:GetSprite():SetFrame("Appear", 7)
		player:GetSprite():Stop()
	end)
end

---@param rng RNG
---@param player EntityPlayer
function ALTERNATE_REALITY:OnUse(_, rng, player)
	local level = game:GetLevel()
	if level:IsAscent() then player:AnimateSad() return end
	local stageList = ALTERNATE_REALITY:GetAvailableStages()
	local randomStage = stageList[rng:RandomInt(#stageList) + 1]
	ALTERNATE_REALITY:QueueNewStage(randomStage[1], randomStage[2], false)
	return {Discharge = true, Remove = true, ShowAnim = false}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, ALTERNATE_REALITY.OnUse, ALTERNATE_REALITY.ID)

function ALTERNATE_REALITY:SelectNewLevel()
	local floor_save = Mod:FloorSave()
	if floor_save.QueueNewStage then
		local stage, stageType = floor_save.QueueNewStage[1], floor_save.QueueNewStage[2]
		StageTransition.SetSameStage(floor_save.QueueNewStage[3] or false)
		floor_save.QueueNewStage = nil
		return { stage, stageType }
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_LEVEL_SELECT, ALTERNATE_REALITY.SelectNewLevel)

--POST_NEW_LEVEL but before the floor data is reset
function ALTERNATE_REALITY:NewReality()
	local floor_save = Mod:FloorSave()
	local room = game:GetRoom()
	if floor_save.AlternateRealityNewStage then
		local level = Mod.Level()
		game:ChangeRoom(level:GetRandomRoomIndex(false, room:GetSpawnSeed()))
		level:ShowMap()
		level:ApplyBlueMapEffect()
		level:ApplyCompassEffect(true)
		level:ApplyMapEffect()
		level.LeaveDoor = -1
		floor_save.AlternateRealityNewStage = nil
	end
end

Mod:AddCallback(Mod.SaveManager.SaveCallbacks.PRE_FLOOR_DATA_RESET, ALTERNATE_REALITY.NewReality)
