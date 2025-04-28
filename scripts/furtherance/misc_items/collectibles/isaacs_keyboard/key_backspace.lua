local Mod = Furtherance

local BACKSPACE_KEY = {}

Furtherance.Item.KEY_BACKSPACE = BACKSPACE_KEY

BACKSPACE_KEY.ID = Isaac.GetItemIdByName("Backspace Key")
BACKSPACE_KEY.NULL_ID = Isaac.GetItemIdByName("backspace penalty")

---@param player EntityPlayer
function BACKSPACE_KEY:UseBackSpace(_, _, player)
	local level = Mod.Level()
	local stage = level:GetStage()
	if stage == LevelStage.STAGE8 then
		Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		return true
	end
	local effects = player:GetEffects()
	effects:AddNullEffect(BACKSPACE_KEY.NULL_ID, false, 2)
	local inventory = player:GetHistory():GetCollectiblesHistory()
	for i = 1, effects:GetNullEffectNum(BACKSPACE_KEY.NULL_ID) do
		local historyItem = inventory[i]
		if historyItem and Mod.Item.EPITAPH:IsValidPassive(historyItem) then
			player:RemoveCollectible(historyItem:GetItemID())
			player:GetHistory():RemoveItemByIndex(i)
		elseif not historyItem then
			player:Die()
			return
		end
	end
	local stage_types = Mod:RunSave().BackspaceStageTypes
	local stageType = stage_types and stage_types[stage - 1] or StageType.STAGETYPE_ORIGINAL
	Mod.Item.ALTERNATE_REALITY:QueueNewStage(stage - 1, stageType)
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BACKSPACE_KEY.UseBackSpace, BACKSPACE_KEY.ID)

function BACKSPACE_KEY:RememberStageType()
	local run_save = Mod:RunSave()
	run_save.BackspaceStageTypes = run_save.BackspaceStageTypes or {}
	local level = Mod.Level()
	run_save.BackspaceStageTypes[tostring(level:GetStage())] = level:GetStageType()
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BACKSPACE_KEY.RememberStageType)
