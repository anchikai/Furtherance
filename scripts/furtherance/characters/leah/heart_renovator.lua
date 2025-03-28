local Mod = Furtherance

local HEART_RENOVATOR = {}

Furtherance.Item.HEART_RENOVATOR = HEART_RENOVATOR

HEART_RENOVATOR.ID = Isaac.GetItemIdByName("Heart Renovator")
HEART_RENOVATOR.SFX_HEARTBEAT = Isaac.GetSoundIdByName("BrokenHeartbeat")
HEART_RENOVATOR.MAX_COUNTER = 99
HEART_RENOVATOR.DAMAGE_MULT = 0.1
HEART_RENOVATOR.SCARED_HEART_CHANCE = 0.16

local font = Mod.Font.Tempest
local counter = Sprite()
counter:Load("gfx/ui_heartcounter.anm2", true)
counter:Play("Idle", true)
HEART_RENOVATOR.CounterSprite = counter

HEART_RENOVATOR.HeartAmount = {
	[HeartSubType.HEART_FULL] = 2,
	[HeartSubType.HEART_SCARED] = 2,
	[HeartSubType.HEART_DOUBLEPACK] = 4,
	[HeartSubType.HEART_HALF] = 1,
	[HeartSubType.HEART_BLENDED] = 2,
}

--TODO: We can just save this for Leah's file probably
--[[ function Mod:LeahHeartCount(isContinued)
	if isContinued then return end
	for i = 0, Mod.Game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == PlayerType.PLAYER_LEAH then
			Mod:GetData(player).HeartCount = 2
		end
	end
end

Mod:AddCallback(Mod.CustomCallbacks.MC_POST_LOADED, Mod.LeahHeartCount) ]]

function HEART_RENOVATOR:GetMaxHeartCounter(player)
	local maxCount = HEART_RENOVATOR.MAX_COUNTER

	if player:GetPlayerType() == Mod.PlayerType.LEAH and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		maxCount = 999
	end
	return maxCount
end

---@param player EntityPlayer
---@param flags UseFlag
function HEART_RENOVATOR:OnUse(_, _, player, flags)
	if player:GetBrokenHearts() > 0 then
		Mod.SFXMan:Play(SoundEffect.SOUND_HEARTBEAT)
		player:AddBrokenHearts(-1)
		local player_run_save = Mod:RunSave(player)
		player_run_save.HeartRenovatorDamage = (player_run_save.HeartRenovatorDamage or 0) + 1
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, HEART_RENOVATOR.OnUse, HEART_RENOVATOR.ID)

---Will determine if the heart collided with would normally be unable to be picked up or if the collected health would overflow
---
---If successful, will automatically handle removing the pickup and return the expected worth of the heart
---@param pickup EntityPickup
---@param player EntityPlayer
---@return number? HeartWorth
function HEART_RENOVATOR:CannotPickRedHeartsOrWillOverflow(pickup, player)
	local amount = HEART_RENOVATOR.HeartAmount[pickup.SubType]
	local canCollect = player:CanPickRedHearts()
	local canOverflow = false
	if pickup.SubType == HeartSubType.HEART_BLENDED then
		canCollect = canCollect or player:CanPickSoulHearts()
	end

	if canCollect then
		local emptyHealth = player:GetEffectiveMaxHearts() - player:GetHearts() - (player:GetRottenHearts() * 2)
		if emptyHealth < amount and emptyHealth >= 0 then
			amount = amount - emptyHealth
			canOverflow = true
		end
	end

	if (not canCollect and Mod:PricedPickup(player, pickup)) or canOverflow then
		return amount
	end
end

---@param pickup EntityPickup
---@param collider Entity
function HEART_RENOVATOR:AddToHeartCounter(pickup, collider)
	local player = collider:ToPlayer()
	if not player or not player:HasCollectible(HEART_RENOVATOR.ID) then return end
	local player_run_save = Mod:RunSave(player)
	local maxCount = HEART_RENOVATOR:GetMaxHeartCounter(player)

	if player_run_save.HeartRenovatorCounter >= maxCount then return end

	local amount = HEART_RENOVATOR:CannotPickRedHeartsOrWillOverflow(pickup, player)
	if amount then
		player_run_save.HeartRenovatorCounter = Mod:Clamp(player_run_save.HeartRenovatorCounter + amount, 0, HEART_RENOVATOR:GetMaxHeartCounter(player))
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, HEART_RENOVATOR.AddToHeartCounter, PickupVariant.PICKUP_HEART)

---@param player EntityPlayer
function HEART_RENOVATOR:DamageUp(player)
	local player_run_save = Mod:RunSave(player)
	if player_run_save.HeartRenovatorDamage and player:HasCollectible(HEART_RENOVATOR.ID) then
		local addAmount = player_run_save.HeartRenovatorDamage * HEART_RENOVATOR.DAMAGE_MULT
		if player:GetPlayerType() == Mod.PlayerType.LEAH and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			addAmount = addAmount * 2
		end
		player.Damage = player.Damage + player_run_save.HeartRenovatorDamage * HEART_RENOVATOR.DAMAGE_MULT
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, HEART_RENOVATOR.DamageUp, CacheFlag.CACHE_DAMAGE)

---@param npc EntityNPC
function HEART_RENOVATOR:ScaredHeartOnDeath(npc)
	local player = PlayerManager.FirstCollectibleOwner(HEART_RENOVATOR.ID)
	if player then
		local hrRNG = player:GetCollectibleRNG(HEART_RENOVATOR.ID)
		if npc:IsActiveEnemy(true) then
			if hrRNG:RandomFloat() <= HEART_RENOVATOR.SCARED_HEART_CHANCE then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED,
				npc.Position, Vector.Zero, player)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, HEART_RENOVATOR.ScaredHeartOnDeath)

---@param player EntityPlayer
function HEART_RENOVATOR:ConsumeHeartCounter(player)
	if not player:HasCollectible(HEART_RENOVATOR.ID) then return end
	local player_run_save = Mod:RunSave(player)
	if player_run_save.HeartRenovatorCounter >= 2 and player:GetBrokenHearts() <= 11 then
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
				player:AddCacheFlags(CacheFlag.CACHE_RANGE)
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

function HEART_RENOVATOR:TwoOfHearts(_, player)
	if player:HasCollectible(HEART_RENOVATOR.ID) then
		local player_run_save = Mod:RunSave(player)
		player_run_save.HeartRenovatorCounter = player_run_save.HeartRenovatorCounter * 2
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, HEART_RENOVATOR.TwoOfHearts, Card.CARD_HEARTS_2)


HudHelper.RegisterHUDElement({
	Name = "Heart Renovator Counter",
	Priority = HudHelper.Priority.NORMAL,
	XPadding = -20,
	YPadding = 8,
	Condition = function (player, playerHUDIndex, hudLayout)
		return player:HasCollectible(HEART_RENOVATOR.ID)
	end,
	OnRender = function (player, playerHUDIndex, hudLayout, position)
		local player_run_save = Mod:RunSave(player)
		player_run_save.HeartRenovatorCounter = player_run_save.HeartRenovatorCounter or 0
		local heartCounter = player_run_save.HeartRenovatorCounter
		local alpha = 1
		local color = KColor.White
		counter.Color = Color(1, 1, 1, alpha)
		counter:Render(position)
		local maxCounter = HEART_RENOVATOR:GetMaxHeartCounter(player)
		local formatLength = "%0" .. string.len(tostring(maxCounter)) .. "d"
		local counterStr = string.format(formatLength, heartCounter)
		font:DrawString(counterStr, position.X + 16, position.Y, color, 0, false)
	end
}, HudHelper.HUDType.EXTRA)
