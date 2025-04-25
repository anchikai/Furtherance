---Will attempt to find the player using the attached Entity, EntityRef, or EntityPtr.
---Will return if its a player, the player's familiar, or loop again if it has a SpawnerEntity
---@param ent Entity | EntityRef | EntityPtr
---@param weaponOwner? boolean #If specified, and it finds a familiar, will only pass the player if that familiar is a weapon-copying familiar
---@return EntityPlayer?
function Furtherance:TryGetPlayer(ent, weaponOwner)
	if not ent then return end
	if string.match(getmetatable(ent).__type, "EntityPtr") then
		if ent.Ref then
			return Furtherance:TryGetPlayer(ent.Ref)
		end
	elseif string.match(getmetatable(ent).__type, "EntityRef") then
		if ent.Entity then
			return Furtherance:TryGetPlayer(ent.Entity)
		end
	elseif ent:ToPlayer() then
		return ent:ToPlayer()
	elseif ent:ToFamiliar() and ent:ToFamiliar().Player then
		if weaponOwner then
			return ent:ToFamiliar():GetWeapon() and ent:ToFamiliar().Player
		else
			return ent:ToFamiliar().Player
		end
	elseif ent.SpawnerEntity then
		return Furtherance:TryGetPlayer(ent.SpawnerEntity)
	end
end

---I ideally want to deprecate this function because it just feels weird to compare colors when there are other options.
---Function to compare two colours and get if they are the same one
--[[ ---@param col1 Color
---@param col2 Color
---@return boolean|nil
function Furtherance:CompareColors(col1, col2)
	if col1 and col2 then
		return col1.R == col2.R
			and col1.G == col2.G
			and col1.B == col2.B
			and col1.A == col2.A
			and col1.RO == col2.RO
			and col1.GO == col2.GO
			and col1.BO == col2.BO
	else
		return nil
	end
end ]]

---@return EntityPlayer[]
function Furtherance:GetAllMainPlayers()
	local players = PlayerManager.GetPlayers()
	local mainPlayers = {}
	for _, player in ipairs(players) do
		if player:GetMainTwin():GetPlayerType() == player:GetPlayerType()	--Is the main twin of 2 players
			and not player.Parent											--Not a strawmann-like spawned-in player.
		then
			Furtherance:Insert(mainPlayers, player)
		end
	end
	return mainPlayers
end

---Executes given function for every player
---Return anything to end the loop early
---@param func fun(player: EntityPlayer, playerIndex: integer): any?
function Furtherance:ForEachPlayer(func)
	for i, player in ipairs(PlayerManager.GetPlayers()) do
		if func(player, player:GetPlayerIndex()) then
			return true
		end
	end
end

---@param func fun(player: EntityPlayer, playerIndex: integer): any?
function Furtherance:ForEachMainPlayer(func)
	local players = Furtherance:GetAllMainPlayers()
	for _, player in ipairs(players) do
		if func(player, player:GetPlayerIndex()) then
			return true
		end
	end
end

---@param player EntityPlayer
---@return boolean canControl
function Furtherance:PlayerCanControl(player)
	local canControl = false

	if not Furtherance.Game:IsPaused()
		and not player:IsDead()
		and player.ControlsEnabled
	then
		canControl = true
	end

	return canControl
end

---@param player EntityPlayer
function Furtherance:IsNotUsingMoveControls(player)
	if not Furtherance.Game:IsPaused() and not player:IsDead() and player.ControlsEnabled and
		not (Input.IsActionPressed(ButtonAction.ACTION_LEFT, player.ControllerIndex)
			or Input.IsActionPressed(ButtonAction.ACTION_RIGHT, player.ControllerIndex)
			or Input.IsActionPressed(ButtonAction.ACTION_UP, player.ControllerIndex)
			or Input.IsActionPressed(ButtonAction.ACTION_DOWN, player.ControllerIndex)) then
		return true
	else
		return false
	end
end

---Credit to Epiphany
---Returns the actual amount of soul hearts the player has, subtracting black hearts.
---@param player EntityPlayer
---@function
function Furtherance:GetTrueSoulHearts(player)
	local blackCount = 0
	local soulHearts = player:GetSoulHearts()
	local blackMask = player:GetBlackHearts()

	for i = 1, soulHearts do
		local bit = 2 ^ math.floor((i - 1) / 2)
		if blackMask | bit == blackMask then
			blackCount = blackCount + 1
		end
	end

	return soulHearts - blackCount
end

---Credit to Epiphany
---Returns the actual amount of black hearts the player has.
---@param player EntityPlayer
---@function
function Furtherance:GetTrueBlackHearts(player)
	local blackCount = 0
	local soulHearts = player:GetSoulHearts()
	local blackMask = player:GetBlackHearts()

	for i = 1, soulHearts do
		local bit = 2 ^ math.floor((i - 1) / 2)
		if blackMask | bit == blackMask then
			blackCount = blackCount + 1
		end
	end

	return blackCount
end

---@param familiar EntityFamiliar
---@return boolean
function Furtherance:IsPlayerWeaponFamiliar(familiar)
	local isPlayerFamiliar = false
	if not familiar then return false end
	local validFamiliars = Furtherance:Set({
		FamiliarVariant.INCUBUS,
		FamiliarVariant.TWISTED_BABY,
		FamiliarVariant.BLOOD_BABY,
		FamiliarVariant.UMBILICAL_BABY,
		FamiliarVariant.CAINS_OTHER_EYE
	})
	if validFamiliars[familiar.Variant] then
		isPlayerFamiliar = true
	end
	return isPlayerFamiliar
end

---@param player EntityPlayer
---@param pngName string
function Furtherance:IsHoldingCollectibleSprite(player, pngName)
	local heldSprite = player:GetHeldSprite()
	local isHolding = false
	if not (heldSprite:IsLoaded()
			and heldSprite:IsPlaying("PlayerPickupSparkle")
			and string.match(player:GetSprite():GetAnimation(), "PickupWalk")
			and heldSprite:GetFilename() == "005.100_collectible.anm2"
		) then
		return isHolding
	end
	local spritesheetPath = heldSprite:GetLayer("head"):GetSpritesheetPath()

	if spritesheetPath == pngName then
		isHolding = true
	end
	return isHolding
end

---Credit to Epiphany
---checks if the player is dying, returns true if true, false if not
---@param player EntityPlayer
---@return boolean
---@function
function Furtherance:IsPlayerDying(player)
	return player:GetSprite():GetAnimation():sub(- #"Death") == "Death" --does their current animation end with "Death"?
end

---Credit to Epiphany
---@param itemId CollectibleType
function Furtherance:GetMaxCharges(itemId)
	return Furtherance.ItemConfig:GetCollectible(itemId).MaxCharges
end

---Credit to Epiphany
---Removes player hp like normal damage would, without animation or invicibility frames
---@param player EntityPlayer
---@param heartsToRemove integer
---@param Inverse boolean
---@function
function Furtherance:RemoveHearts(player, heartsToRemove, Inverse)
	if Inverse or player:HasTrinket(TrinketType.TRINKET_CROW_HEART) then
		local souldamage = heartsToRemove - player:GetHearts()
		player:AddHearts(-heartsToRemove)
		if souldamage > 0 then
			player:AddSoulHearts(-souldamage)
		end
	else
		local redDamage = heartsToRemove - player:GetSoulHearts()
		player:AddSoulHearts(-heartsToRemove)
		if redDamage > 0 then
			player:AddSoulHearts(-redDamage)
		end
	end
end

---Credit to Epiphany
---Returns true if the player is found soul
---@param player EntityPlayer
function Furtherance:IsFoundSoul(player)
	if player.Variant == PlayerVariant.FOUND_SOUL
		and player:GetBabySkin() == BabySubType.BABY_FOUND_SOUL then
		return true
	end
end

---Returns a list of all active slots that contain given item.
---@param player EntityPlayer
---@param item CollectibleType
---@return ActiveSlot[]
---@function
function Furtherance:GetActiveItemSlots(player, item)
	local out = {}
	for _, v in pairs(ActiveSlot) do
		if player:GetActiveItem(v) == item then
			Furtherance:Insert(out, v)
		end
	end
	return out
end

---@param player EntityPlayer
---@param itemID CollectibleType
---@return {Slot: ActiveSlot, Charge: integer}[]
function Furtherance:GetActiveItemCharges(player, itemID)
	local slots = Furtherance:GetActiveItemSlots(player, itemID)
	local out = {}
	for i, slot in ipairs(slots) do
		Furtherance:Insert(out, { Slot = slot, Charge = player:GetActiveCharge(slot) })
	end
	return out
end

---@param player EntityPlayer
---@return boolean
function Furtherance:IsJudasBirthrightActive(player)
	local playerType = player:GetPlayerType()
	return (playerType == PlayerType.PLAYER_JUDAS or playerType == PlayerType.PLAYER_BLACKJUDAS) and
		player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

---Takes an EntityPlayer and returns how many hits they should be able to sustain
---@param player EntityPlayer
function Furtherance:GetEffectiveHitPoints(player)
	return player:GetHearts()      --Red health you have
		+ player:GetBoneHearts()   --Extra hit from bone hearts
		+ player:GetSoulHearts()   --Soul hearts, including black hearts
		+ player:GetEternalHearts() --Eternal Hearts can tank a hit by themselves
		- (player:GetRottenHearts() * 2) --Rotten Hearts take a full heart while not replacing red health
end

Furtherance.LostPlayers = Furtherance:Set({
	PlayerType.PLAYER_THELOST,
	PlayerType.PLAYER_THELOST_B
})

---@param player EntityPlayer
function Furtherance:IsAnyLost(player)
	return Furtherance.LostPlayers[player:GetPlayerType()]
end

---returns true if the player can pickup the item, false if they cannot (not being able to pickup due animation is included)
---@param player EntityPlayer
---@param pickup EntityPickup
---@return boolean
function Furtherance:CanPlayerBuyShopItem(player, pickup)
	if player:CanPickupItem() then
		local isItem = (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_TRINKET)
		local hasToHold = isItem or pickup.Price ~= 0

		-- if you have to hold the item, you can't be on animation cooldown
		if hasToHold then
			if not player:IsExtraAnimationFinished() then
				return false
			end
		end

		if pickup.Price < 0 then
			if not Furtherance:IsAnyLost(player) then
				if pickup.Price == PickupPrice.PRICE_ONE_HEART and player:GetMaxHearts() < 2 then
					return false
				end
				if pickup.Price == PickupPrice.PRICE_TWO_HEARTS and player:GetMaxHearts() < 2 then
					return false
				end
				if pickup.Price == PickupPrice.PRICE_THREE_SOULHEARTS and player:GetSoulHearts() < 1 then
					return false
				end
				if pickup.Price == PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS and ((player:GetMaxHearts() < 2 or player:GetSoulHearts() < 1) and player:GetMaxHearts() < 4) then
					return false
				end
			end
			return true
		end

		if pickup.Price == 0
			or pickup.Price == PickupPrice.PRICE_FREE
			or pickup.Price > 0 and player:GetNumCoins() >= pickup.Price then
			return true
		end
	end
	return false
end

---Aquired from EID who reverse engineerd the decomp code for Consolation Prize
---@param player EntityPlayer
---@param cacheFlag CacheFlag
function Furtherance:GetStatScore(player, cacheFlag)
	local score = 0
	if cacheFlag == CacheFlag.CACHE_SPEED then
		score = (player.MoveSpeed * 4.5) - 2
	elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
		score = (((30/(player.MaxFireDelay + 1))^0.75) * 2.120391) - 2
	elseif cacheFlag ==CacheFlag.CACHE_DAMAGE then
		score = ((player.Damage^0.56)*2.231179) - 2
	elseif cacheFlag == CacheFlag.CACHE_RANGE then
		score = ((player.TearRange - 230) / 60) + 2
	--Shotspeed and Luck are custom. Default should be 2.5
	elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
		score = (player.ShotSpeed * 6.5) - 4
	elseif cacheFlag == CacheFlag.CACHE_LUCK then
		score = player.Luck + 2.5
	end
	return Furtherance:Round(score)
end

---Attempts to return the Marked target used by the player. Returns nil if none are found
---@param player EntityPlayer
---@return Vector?
function Furtherance:TryGetMarkedTargetAimVector(player)
	local aimVector
	if REPENTOGON then
		local target = player:GetMarkedTarget()
		if target then
			aimVector = (target.Position - player.Position):Normalized()
		end
	else
		local markedVariants = {
			EffectVariant.TARGET,
			EffectVariant.OCCULT_TARGET
		}
		for _, variant in ipairs(markedVariants) do
			for _, mark in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, variant)) do
				local spawnEnt = mark.SpawnerEntity and mark.SpawnerEntity:ToPlayer()
				if spawnEnt and GetPtrHash(spawnEnt) == GetPtrHash(player) then
					aimVector = (mark.Position - player.Position):Normalized()
					break
				end
			end
		end
	end
	return aimVector
end

---@param player EntityPlayer
function Furtherance:GetLaserRange(player)
	return 60 + math.max(0, player.TearRange - 112) * 0.25
end