local Mod = Furtherance

local BACKSPACE_KEY = {}

Furtherance.Item.KEY_BACKSPACE = BACKSPACE_KEY

BACKSPACE_KEY.ID = Isaac.GetItemIdByName("Backspace Key")

local backspaceKey = Sprite("gfx/ui/ui_backspace_key.anm2")
backspaceKey:SetFrame("Idle", 2)

---@param player EntityPlayer
function BACKSPACE_KEY:UseBackspace(_, _, player, _, slot)
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
		player:RemoveCollectible(itemTable[1])
		player:GetHistory():RemoveItemByIndex(itemTable[2])
	end
	local stage_types = Mod:RunSave().BackspaceStageTypes
	if stage == LevelStage.STAGE1_1 then
		Mod.Item.ALTERNATE_REALITY:QueueNewStage(LevelStage.STAGE8, StageType.STAGETYPE_ORIGINAL)
	else
		local stageType = stage_types and stage_types[tostring(stage - 1)] or StageType.STAGETYPE_ORIGINAL
		Mod.Item.ALTERNATE_REALITY:QueueNewStage(stage - 1, stageType)
	end
	return {Discharge = true, Remove = itemDesc.VarData >= 3, ShowAnim = false}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BACKSPACE_KEY.UseBackspace, BACKSPACE_KEY.ID)

function BACKSPACE_KEY:RememberStageType()
	local run_save = Mod:RunSave()
	run_save.BackspaceStageTypes = run_save.BackspaceStageTypes or {}
	local level = Mod.Level()
	run_save.BackspaceStageTypes[tostring(level:GetStage())] = level:GetStageType()
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