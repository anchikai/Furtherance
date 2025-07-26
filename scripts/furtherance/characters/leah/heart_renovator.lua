--#region Variables

local Mod = Furtherance

local HEART_RENOVATOR = {}

Furtherance.Item.HEART_RENOVATOR = HEART_RENOVATOR

HEART_RENOVATOR.ID = Isaac.GetItemIdByName("Heart Renovator")
HEART_RENOVATOR.SFX_HEARTBEAT = Isaac.GetSoundIdByName("Broken Heartbeat")
HEART_RENOVATOR.MAX_COUNTER = 99
HEART_RENOVATOR.DAMAGE_MULT = 0.1

local font = Mod.Font.Tempest
local counter = Sprite("gfx/ui/hudpickups.anm2", true)
counter:SetFrame("Idle", 15)
HEART_RENOVATOR.CounterSprite = counter

Mod.SaveManager.Utility.AddDefaultRunData(Mod.SaveManager.DefaultSaveKeys.PLAYER, {
	HeartRenovatorCounter = 0,
	HeartRenovatorDamage = 0
})

--#endregion

--#region Helpers

function HEART_RENOVATOR:GetMaxHeartCounter(player)
	return HEART_RENOVATOR.MAX_COUNTER
end

---@param player EntityPlayer
---@param amount integer
---@param isBlended? boolean
function HEART_RENOVATOR:GetOverflowAmount(player, amount, isBlended)
	local maxHearts = Mod:GetPlayerRealContainersCount(player, true)
	local emptyHealth = maxHearts - Mod:GetPlayerRealRedHeartsCount(player, true)

	if emptyHealth < amount
		and (not isBlended or maxHearts + Mod:GetPlayerRealSoulHeartsCount(player) + Mod:GetPlayerRealBlackHeartsCount(player) == CustomHealthAPI.Helper.GetTrueHeartLimit(player))
	then
		amount = amount - emptyHealth
		return true, amount
	end
	return false, 0
end

---Will determine if the heart collided with would normally be unable to be picked up or if the collected health would overflow
---
---If successful, will automatically handle removing the pickup and return the expected worth of the heart
---@param pickup EntityPickup
---@param player EntityPlayer
---@return number? HeartWorth
function HEART_RENOVATOR:CannotPickRedHeartsOrWillOverflow(pickup, player)
	local amount = Mod.HeartAmount[pickup.SubType]
	if not amount then return end
	local canOverflow = false
	local isBlended = Mod.HeartGroups.Blended[pickup.SubType]
	local redIsDoubled = player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW)
	local canJarRedHearts = player:HasCollectible(CollectibleType.COLLECTIBLE_THE_JAR) and player:GetJarHearts() < 8
	local canCollect = Mod:CanCollectHeart(player, pickup.SubType)
	local hasSodomApple = player:HasTrinket(TrinketType.TRINKET_APPLE_OF_SODOM)

	if canJarRedHearts or hasSodomApple then return end

	if redIsDoubled then
		amount = amount * 2
	end

	if canCollect then
		canOverflow, amount = HEART_RENOVATOR:GetOverflowAmount(player, amount, isBlended)
	end

	if (not canCollect and Mod:PricedPickup(player, pickup)) or canOverflow then
		if isBlended then
			Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2_BUBBLES)
		end
		return amount
	end
end

--#endregion

--#region On use

---@param player EntityPlayer
---@param flags UseFlag
function HEART_RENOVATOR:OnUse(_, _, player, flags)
	if player:GetBrokenHearts() > 0 then
		Mod.SFXMan:Play(SoundEffect.SOUND_HEARTBEAT)
		player:AddBrokenHearts(-1)
		local player_run_save = Mod:RunSave(player)
		player_run_save.HeartRenovatorDamage = player_run_save.HeartRenovatorDamage + 1
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, HEART_RENOVATOR.OnUse, HEART_RENOVATOR.ID)

---@param player EntityPlayer
function HEART_RENOVATOR:DamageUp(player)
	local player_run_save = Mod:RunSave(player)
	if player_run_save.HeartRenovatorDamage and player:HasCollectible(HEART_RENOVATOR.ID) then
		local addAmount = player_run_save.HeartRenovatorDamage * HEART_RENOVATOR.DAMAGE_MULT
		if Mod.Character.LEAH:LeahHasBirthright(player) then
			addAmount = addAmount * 2
		end
		player.Damage = player.Damage + addAmount * Mod:GetPlayerDamageMultiplier(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, HEART_RENOVATOR.DamageUp, CacheFlag.CACHE_DAMAGE)

--#endregion

--#region Add to counter

---@param player EntityPlayer
---@param amount integer
function HEART_RENOVATOR:AddToCounter(player, amount)
	local player_run_save = Mod:RunSave(player)
	local maxCount = HEART_RENOVATOR:GetMaxHeartCounter(player)
	player_run_save.HeartRenovatorCounter = Mod:Clamp(player_run_save.HeartRenovatorCounter + amount, 0, maxCount)
end

---@param pickup EntityPickup
---@param collider Entity
function HEART_RENOVATOR:AddHeartPickupToCounter(pickup, collider)
	local player = collider:ToPlayer()
	if not (player
			and player:HasCollectible(HEART_RENOVATOR.ID)
			and Mod.HeartGroups.Red[pickup.SubType])
	then
		return
	end
	local player_run_save = Mod:RunSave(player)
	local maxCount = HEART_RENOVATOR:GetMaxHeartCounter(player)

	if player_run_save.HeartRenovatorCounter >= maxCount then return end

	local amount = HEART_RENOVATOR:CannotPickRedHeartsOrWillOverflow(pickup, player)

	if amount then
		HEART_RENOVATOR:AddToCounter(player, amount)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.EARLY, HEART_RENOVATOR.AddHeartPickupToCounter, PickupVariant.PICKUP_HEART)

---@param player EntityPlayer
function HEART_RENOVATOR:ConsumeHeartCounter(player)
	if not player:HasCollectible(HEART_RENOVATOR.ID) then return end
	local player_run_save = Mod:RunSave(player)
	if (player_run_save.HeartRenovatorCounter or 0) >= 2
		and player:GetBrokenHearts() <= 11
	then
		local data = Mod:GetData(player)
		local dropTriggered = Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)
		local doubleTapWindow = Mod.GetSetting(Mod.Setting.HeartRenovatorDoubleTap)

		if dropTriggered then
			if not data.HeartRenovatorTapped then
				data.HeartRenovatorFrameWindow = doubleTapWindow
				data.HeartRenovatorTapped = true
			else
				player_run_save.HeartRenovatorCounter = Mod:Clamp(player_run_save.HeartRenovatorCounter - 2, 0, HEART_RENOVATOR:GetMaxHeartCounter(player))
				player:AddBrokenHearts(1)
				Mod.SFXMan:Play(HEART_RENOVATOR.SFX_HEARTBEAT)
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
		elseif (data.HeartRenovatorFrameWindow or 0) > 0 then
			data.HeartRenovatorFrameWindow = data.HeartRenovatorFrameWindow - 1
		elseif data.HeartRenovatorFrameWindow == 0 and data.HeartRenovatorTapped then
			data.HeartRenovatorTapped = false
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, HEART_RENOVATOR.ConsumeHeartCounter)

---@param player EntityPlayer
---@param amount integer
function HEART_RENOVATOR:AddExtraRedHealth(player, amount)
	if player:HasCollectible(HEART_RENOVATOR.ID) and amount > 0 and player.FrameCount > 0 then
		local willOverflow, newAmount = HEART_RENOVATOR:GetOverflowAmount(player, amount, false)

		if willOverflow then
			--Situations that would induce a full heal push an amount of 99.
			if amount > 48 then
				newAmount = player:GetHearts() + player:GetRottenHearts() * 2
			end
			HEART_RENOVATOR:AddToCounter(player, newAmount)
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, CallbackPriority.LATE, HEART_RENOVATOR.AddExtraRedHealth, AddHealthType.RED)

HudHelper.RegisterHUDElement({
	Name = "Heart Renovator Counter",
	Priority = HudHelper.Priority.NORMAL,
	XPadding = {
		-5,
		0,
		0,
		0
	},
	YPadding = 6,
	Condition = function(player)
		return player:HasCollectible(HEART_RENOVATOR.ID)
	end,
	OnRender = function(player, _, _, position)
		local player_run_save = Mod:RunSave(player)
		local heartCounter = player_run_save.HeartRenovatorCounter
		local maxCounter = HEART_RENOVATOR:GetMaxHeartCounter(player)
		local formatLength = "%0" .. string.len(tostring(maxCounter)) .. "d"
		local counterStr = string.format(formatLength, heartCounter)
		font:DrawString(counterStr, position.X, position.Y, KColor.White, 0, false)
		HEART_RENOVATOR.CounterSprite:Render(position - Vector(16, 0))
	end
}, HudHelper.HUDType.EXTRA)
