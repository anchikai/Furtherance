local Mod = Furtherance

local PETER = {}

Furtherance.Character.PETER = PETER

Mod.Include("scripts.furtherance.characters.peter.keys_to_the_kingdom")

local max = math.max

---@param player EntityPlayer
function PETER:IsPeter(player)
	return player:GetPlayerType() == Mod.PlayerType.PETER
end

---@param player EntityPlayer
function PETER:OnInit(player)
	player:AddTrinket(Mod.Trinket.ALABASTER_SCRAP.ID)
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, PETER.OnInit, Mod.PlayerType.PETER)

--#region Soul Hearts = KTTK charge

---@param player EntityPlayer
---@param amount integer
function PETER:DistributeSoulHeartsToPocket(player, amount)
	if PETER:IsPeter(player) and player.FrameCount > 0 and amount > 0 then
		local activeItem = player:GetActiveItem(ActiveSlot.SLOT_POCKET)
		if activeItem == Mod.Item.KEYS_TO_THE_KINGDOM.ID then
			local charge = player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
			local maxCharge = Mod.Item.KEYS_TO_THE_KINGDOM.MAX_CHARGES
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
				maxCharge = maxCharge * 2
			end
			if charge < maxCharge then
				local newAmount = charge + amount - maxCharge
				player:AddActiveCharge(amount, ActiveSlot.SLOT_POCKET, true, false, true)
				return max(0, newAmount)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, PETER.DistributeSoulHeartsToPocket, AddHealthType.SOUL)
Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, PETER.DistributeSoulHeartsToPocket, AddHealthType.BLACK)

---@param player EntityPlayer
---@param amount integer
---@param isBlended? boolean
function PETER:GetOverflowAmount(player, amount, isBlended, isBlack)
	local numSoul = Mod:GetPlayerRealSoulHeartsCount(player)
	local numBlack = Mod:GetPlayerRealBlackHeartsCount(player)
	local emptyHealth = CustomHealthAPI.Helper.GetRoomForOtherKeys(player) * 2
	if numSoul % 2 ~= 0 or numBlack % 2 == 0 then
		emptyHealth = emptyHealth + 1
	end
	if isBlended and CustomHealthAPI.Helper.CanPickRed(player, "RED_HEART") then
		local numContainer = Mod:GetPlayerRealContainersCount(player, true)
		local numRed = Mod:GetPlayerRealRedHeartsCount(player, true)
		if numContainer - numRed == 1 then
			return true, 1
		end
	end
	if not isBlack and emptyHealth > 0 and emptyHealth < amount then
		amount = amount - emptyHealth
		return true, amount
	elseif isBlack then
		if emptyHealth > 0 and emptyHealth < amount then
			amount = amount - emptyHealth
			return true, amount
		elseif numSoul > 0 and numSoul < amount then
			amount = amount - numSoul
			return true, amount
		end
	end
	return false, 0
end

---Will determine if the heart collided with would normally be unable to be picked up or if the collected health would overflow
---
---If successful, will automatically handle removing the pickup and return the expected worth of the heart
---@param pickup EntityPickup
---@param player EntityPlayer
---@return number? HeartWorth
function PETER:CannotPickSoulHeartsOrWillOverflow(pickup, player)
	local amount = Mod.HeartAmount[pickup.SubType]
	if not amount then return end
	local canOverflow = false
	local isBlended = Mod.HeartGroups.Blended[pickup.SubType]
	local isBlack = Mod.HeartGroups.Black[pickup.SubType]
	local canCollect = Mod:CanCollectHeart(player, pickup.SubType)

	if canCollect then
		canOverflow, amount = PETER:GetOverflowAmount(player, amount, isBlended, isBlack)
	end

	if (not canCollect and Mod:PricedPickup(player, pickup)) or canOverflow then
		if isBlended then
			if isBlack then
				Mod.SFXMan:Play(SoundEffect.SOUND_UNHOLY)
			else
				Mod.SFXMan:Play(SoundEffect.SOUND_HOLY)
			end
		end
		return amount
	end
end

---@param pickup EntityPickup
---@param collider Entity
function PETER:AddHeartPickupToKTTKCharge(pickup, collider)
	local player = collider:ToPlayer()
	if not (
			player
			and PETER:IsPeter(player)
			and (Mod.HeartGroups.Soul[pickup.SubType]
			or Mod.HeartGroups.Black[pickup.SubType])
		)
	then
		return
	end
	local charge = player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
	local maxCharge = Mod.Item.KEYS_TO_THE_KINGDOM.MAX_CHARGES
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
		maxCharge = maxCharge * 2
	end
	if charge == maxCharge then
		return
	end

	local amount = PETER:CannotPickSoulHeartsOrWillOverflow(pickup, player)

	if amount then
		player:AddActiveCharge(amount, ActiveSlot.SLOT_POCKET, true, false, true)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.EARLY, PETER.AddHeartPickupToKTTKCharge, PickupVariant.PICKUP_HEART)

--#endregion

--#region Book of Virtues-like effect

function PETER:ForceNewAngel()
	local level = Mod.Level()
	if PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.PETER)
		and (level:GetAbsoluteStage() >= LevelStage.STAGE1_2 or Mod:HasBitFlags(Mod.Level():GetCurses(), LevelCurse.CURSE_OF_LABYRINTH))
		and not Mod.Game:GetStateFlag(GameStateFlag.STATE_DEVILROOM_SPAWNED)
	then
		--Literally any angel room chance forces the 50/50, and if no angel room encountered, 100%
		--Which will essentially act just like Book of Virtues' effect minus the bonus chance
		level:AddAngelRoomChance(0.0000001)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PETER.ForceNewAngel)

--#endregion
