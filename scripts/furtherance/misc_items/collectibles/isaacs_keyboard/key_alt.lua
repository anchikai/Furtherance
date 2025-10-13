local Mod = Furtherance
local game = Mod.Game

local ALT_KEY = {}

Furtherance.Item.KEY_ALT = ALT_KEY

ALT_KEY.ID = Isaac.GetItemIdByName("Alt Key")
ALT_KEY.MAX_CHARGES = Mod.ItemConfig:GetCollectible(ALT_KEY.ID).MaxCharges

---@param rng RNG
---@param player EntityPlayer
function ALT_KEY:OnUse(_, rng, player)
	if game:IsGreedMode() then
		return
	end
	local level = game:GetLevel()
	if level:IsAscent() then
		player:AnimateSad()
		return
	end
	local stage = level:GetStage()
	local stageList = Mod.Item.ALTERNATE_REALITY:GetAvailableStages(stage)
	local stageType = level:GetStageType()
	if #stageList == 0 then
		player:AnimateSad()
		return false
	end
	local useRepentance = false
	if stage <= LevelStage.STAGE4_2 and stageType < StageType.STAGETYPE_REPENTANCE then
		useRepentance = true
	end
	for i = #stageList, 1, -1 do
		local stageTable = stageList[i]
		if useRepentance and stageTable[2] < StageType.STAGETYPE_REPENTANCE
			or not useRepentance and stageTable[2] >= StageType.STAGETYPE_REPENTANCE
		then
			table.remove(stageList, i)
		end
	end
	if #stageList <= 1 then
		player:AnimateSad()
		return false
	end
	local newStage = stageList[rng:RandomInt(#stageList) + 1]
	Mod.Insert(newStage, true)
	local player_floor_save = Mod:FloorSave(player)
	player_floor_save.SkipFloorRecharge = true
	Mod.Item.ALTERNATE_REALITY:QueueNewStage(newStage[1], newStage[2], false)
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, ALT_KEY.OnUse, ALT_KEY.ID)

---Runs before POST_NEW_LEVEL when floor save data gets reset :P
---@param player EntityPlayer
function ALT_KEY:PreNewLevel(player)
	if player.FrameCount == 0 then return end
	local player_floor_save = Mod:FloorSave(player)
	local slots = Mod:GetActiveItemSlots(player, ALT_KEY.ID)
	if player_floor_save.SkipFloorRecharge then return end
	local maxCharge = ALT_KEY.MAX_CHARGES
	local hasBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
		maxCharge = maxCharge * 2
	end
	for _, slot in ipairs(slots) do
		if player:GetActiveCharge(slot) + player:GetBatteryCharge(ActiveSlot.SLOT_POCKET) < maxCharge then
			player:AddActiveCharge(1, slot, true, hasBattery, true)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, ALT_KEY.PreNewLevel)

--[[
function ALT_KEY:UseAlt(_, _, player)
	local level = game:GetLevel()
	local stage = level:GetStage()
	local stageType = level:GetStageType()
	local rng = player:GetCollectibleRNG(ALT_KEY.ID)
	local randomAB = rng:RandomInt(3) + 1
	local randomREP = rng:RandomInt(2) + 1
	local data = Mod:GetData(player)
	data.NoChargeAlt = true

	--if the stage is Blue Womb, Sheol, Cathedral, Dark Room, Chest, The Void, or Home
	if (stage == LevelStage.STAGE4_3) or (stage == LevelStage.STAGE5) or (stage == LevelStage.STAGE6) or (stage == LevelStage.STAGE7) or (stage == LevelStage.STAGE8) then
		Mod:playFailSound()
		player:AnimateSad()
		return false
		--if alt floor, change to normal floor
	elseif stageType == StageType.STAGETYPE_REPENTANCE or stageType == StageType.STAGETYPE_REPENTANCE_B then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false, false, true, false, 0)
		if randomAB == 1 then
			level:SetStage(stage, (StageType.STAGETYPE_ORIGINAL))
		elseif randomAB == 2 then
			level:SetStage(stage, (StageType.STAGETYPE_WOTL))
		elseif randomAB == 3 then
			level:SetStage(stage, (StageType.STAGETYPE_AFTERBIRTH))
		end
		--if the stage is Womb I or II
	elseif stageType == StageType.STAGETYPE_ORIGINAL or stageType == StageType.STAGETYPE_WOTL or stageType == StageType.STAGETYPE_AFTERBIRTH and (stage == LevelStage.STAGE4_1) or (LevelStage.STAGE4_2) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false, false, true, false, 0)
		level:SetStage(stage, (StageType.STAGETYPE_REPENTANCE))
		--if normal floor, change to alt floor
	elseif stageType == StageType.STAGETYPE_ORIGINAL or stageType == StageType.STAGETYPE_WOTL or stageType == StageType.STAGETYPE_AFTERBIRTH then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false, false, true, false, 0)
		if randomREP == 1 then
			level:SetStage(stage, (StageType.STAGETYPE_REPENTANCE))
		elseif randomREP == 2 then
			level:SetStage(stage, (StageType.STAGETYPE_REPENTANCE_B))
		end
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, ALT_KEY.UseAlt, CollectibleType.COLLECTIBLE_ALT_KEY)

function ALT_KEY:ChargeAlt()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)
		local AltSlot
		if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_ALT_KEY then
			AltSlot = ActiveSlot.SLOT_PRIMARY
		elseif player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == CollectibleType.COLLECTIBLE_ALT_KEY then
			AltSlot = ActiveSlot.SLOT_SECONDARY
		elseif player:GetActiveItem(ActiveSlot.SLOT_POCKET) == CollectibleType.COLLECTIBLE_ALT_KEY then
			AltSlot = ActiveSlot.SLOT_POCKET
		end
		if data.NoChargeAlt == false and player:HasCollectible(CollectibleType.COLLECTIBLE_ALT_KEY) then
			if player:GetActiveCharge(AltSlot) < 2 then
				player:SetActiveCharge(player:GetActiveCharge(AltSlot) + 1, AltSlot)
			end
			game:GetHUD():FlashChargeBar(player, AltSlot)
			if player:GetActiveCharge(AltSlot) < 2 then
				SFXManager():Play(SoundEffect.SOUND_BEEP)
			else
				SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
				SFXManager():Play(SoundEffect.SOUND_ITEMRECHARGE)
			end
		end
		data.NoChargeAlt = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ALT_KEY.ChargeAlt)
 ]]
