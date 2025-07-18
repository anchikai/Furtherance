local Mod = Furtherance

local BACKSPACE_KEY = {}

Furtherance.Item.KEY_BACKSPACE = BACKSPACE_KEY

BACKSPACE_KEY.ID = Isaac.GetItemIdByName("Backspace Key")

local backspaceKey = Sprite("gfx/ui/ui_backspace_key.anm2")
backspaceKey:SetFrame("Idle", 2)

Mod.SaveManager.Utility.AddDefaultRunData(Mod.SaveManager.DefaultSaveKeys.GLOBAL, {BackspaceStageTypes = {}})

---@param player EntityPlayer
function BACKSPACE_KEY:UseBackspace(_, _, player, _, slot)
	local level = Mod.Level()
	local curStage = level:GetStage()
	local curStageType = level:GetStageType()
	if Mod.Game:IsGreedMode() and curStage == LevelStage.STAGE1_GREED then
		Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		return true
	end
	if curStage == LevelStage.STAGE8 then
		Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		return true
	end
	local itemDesc = player:GetActiveItemDesc(slot)
	itemDesc.VarData = itemDesc.VarData + 1
	local inventory = player:GetHistory():GetCollectiblesHistory()
	local itemsToRemove = {}
	for i = 1, 2 do
		local historyItem = inventory[i]
		if historyItem and Mod.Item.EPITAPH:IsValidPassive(historyItem) then
			Mod.Insert(itemsToRemove, {historyItem:GetItemID(), i})
		end
	end
	for _, itemTable in ipairs(itemsToRemove) do
		player:GetHistory():RemoveHistoryItemByIndex(itemTable[2])
		player:RemoveCollectible(itemTable[1])
	end
	local stage_types = Mod:RunSave().BackspaceStageTypes
	if curStage == LevelStage.STAGE1_1 and curStageType < StageType.STAGETYPE_REPENTANCE then
		Mod.Item.ALTERNATE_REALITY:QueueNewStage(LevelStage.STAGE8, StageType.STAGETYPE_ORIGINAL)
	else
		local direction = -1
		if level:IsAscent() then
			direction = 1
		end
		local prevStageToCheck = curStage + direction
		if curStageType >= StageType.STAGETYPE_REPENTANCE then
			prevStageToCheck = curStage
		end
		local levelData = stage_types[tostring(prevStageToCheck)]
		if not levelData then
			local levelStage, stageType = curStage + direction, StageType.STAGETYPE_ORIGINAL
			if curStageType >= StageType.STAGETYPE_REPENTANCE then
				levelStage = curStage
			end
			Mod.Item.ALTERNATE_REALITY:QueueNewStage(levelStage, stageType)
		else
			local levelStage, stageType, isLabyrinth = levelData[1], levelData[2], levelData[3]
			if level:IsAscent() then
				stageType = stageType >= StageType.STAGETYPE_REPENTANCE and StageType.STAGETYPE_REPENTANCE or StageType.STAGETYPE_ORIGINAL
			elseif isLabyrinth then
				direction = direction * 2
			end
			Mod.Item.ALTERNATE_REALITY:QueueNewStage(levelStage, stageType)
		end
	end
	return {Discharge = true, Remove = itemDesc.VarData >= 3, ShowAnim = false}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BACKSPACE_KEY.UseBackspace, BACKSPACE_KEY.ID)

function BACKSPACE_KEY:RememberStageType()
	local run_save = Mod:RunSave()
	local level = Mod.Level()
	local curStage = level:GetStage()
	local levelKey = curStage
	local stageType = level:GetStageType()
	if stageType >= StageType.STAGETYPE_REPENTANCE then
		levelKey = levelKey + 1
	end
	if Mod:HasBitFlags(level:GetCurses(), LevelCurse.CURSE_OF_LABYRINTH) then
		run_save.BackspaceStageTypes[tostring(levelKey + 1)] = {curStage, stageType, true}
	end
	run_save.BackspaceStageTypes[tostring(levelKey)] = {curStage, stageType}
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BACKSPACE_KEY.RememberStageType)

HudHelper.RegisterHUDElement({
	ItemID = BACKSPACE_KEY.ID,
	OnRender = function (player, playerHUDIndex, hudLayout, position, alpha, scale, itemID, slot)
		if not slot then return end
		---@cast slot ActiveSlot
		local numUses = player:GetActiveItemDesc(slot).VarData
		backspaceKey:SetFrame("Idle", 2 - numUses)
		backspaceKey:Render(position)
	end
}, HudHelper.HUDType.ACTIVE_ID)