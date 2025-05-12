local Mod = Furtherance

local BACKSPACE_KEY = {}

Furtherance.Item.KEY_BACKSPACE = BACKSPACE_KEY

BACKSPACE_KEY.ID = Isaac.GetItemIdByName("Backspace Key")
BACKSPACE_KEY.NULL_ID = Isaac.GetNullItemIdByName("backspace penalty")

---@param player EntityPlayer
function BACKSPACE_KEY:UseBackSpace(_, _, player)
	local level = Mod.Level()
	local stage = level:GetStage()
	if Mod.Game:IsGreedMode() and stage == LevelStage.STAGE1_GREED then
		Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		return true
	end
	if stage == LevelStage.STAGE8 then
		Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		return true
	end
	local effects = player:GetEffects()
	effects:AddNullEffect(BACKSPACE_KEY.NULL_ID, false, 2)
	--Doesn't actually take immediate effect, so gotta add the +2 ourselves
	local numEffects = effects:GetNullEffectNum(BACKSPACE_KEY.NULL_ID) + 2
	local inventory = player:GetHistory():GetCollectiblesHistory()
	local itemsToRemove = {}
	for i = 1, numEffects do
		local historyItem = inventory[i]
		if historyItem and Mod.Item.EPITAPH:IsValidPassive(historyItem) then
			Mod.Insert(itemsToRemove, {historyItem:GetItemID(), i})
		elseif not historyItem then
			player:Die()
			return
		end
	end
	for _, itemTable in ipairs(itemsToRemove) do
		player:RemoveCollectible(itemTable[1])
		player:GetHistory():RemoveItemByIndex(itemTable[2])
	end
	local stage_types = Mod:RunSave().BackspaceStageTypes
	if stage == LevelStage.STAGE1_1 then
		Mod.Item.ALTERNATE_REALITY:QueueNewStage(LevelStage.STAGE8, StageType.STAGETYPE_ORIGINAL)
	else
		local stageType = stage_types and stage_types[stage - 1] or StageType.STAGETYPE_ORIGINAL
		Mod.Item.ALTERNATE_REALITY:QueueNewStage(stage - 1, stageType)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BACKSPACE_KEY.UseBackSpace, BACKSPACE_KEY.ID)

function BACKSPACE_KEY:RememberStageType()
	local run_save = Mod:RunSave()
	run_save.BackspaceStageTypes = run_save.BackspaceStageTypes or {}
	local level = Mod.Level()
	run_save.BackspaceStageTypes[tostring(level:GetStage())] = level:GetStageType()
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BACKSPACE_KEY.RememberStageType)
