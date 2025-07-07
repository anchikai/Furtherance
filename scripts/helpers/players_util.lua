---Will attempt to find the player using the attached Entity, EntityRef, or EntityPtr.
---Will return if its a player, the player's familiar, or loop again if it has a SpawnerEntity
---@param ent Entity | EntityRef | EntityPtr
---@param weaponOwner? boolean #If specified, and it finds a familiar, will only pass the player if that familiar is a weapon-copying familiar
---@param weaponFamiliar? boolean #If this and `weaponOwner` are true, will return the familiar instead of the player. Recommended to use TryGetOwner instead of a Player|Famliiar return
---@return EntityPlayer?
function Furtherance:TryGetPlayer(ent, weaponOwner, weaponFamiliar)
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
		if weaponOwner and ent:ToFamiliar():GetWeapon() then
			local familiar = ent:ToFamiliar()
			if weaponFamiliar then
				---@diagnostic disable-next-line: return-type-mismatch
				return familiar
			elseif familiar then
				return familiar.Player
			end
		else
			return ent:ToFamiliar().Player
		end
	elseif ent.SpawnerEntity then
		return Furtherance:TryGetPlayer(ent.SpawnerEntity)
	end
end

---TryGetPlayer, but only returns a player or familiar if it has a Weapon object attached to them
---@param ent Entity | EntityRef | EntityPtr
---@return EntityPlayer | EntityFamiliar?
function Furtherance:TryGetOwner(ent)
	return Furtherance:TryGetPlayer(ent, true, true)
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

-- Returns the actual amount of red hearts the player has, subtracting bone hearts unless allowed.
---@param player EntityPlayer
---@param allowBone? boolean
---@param ignoreMods? boolean
---@function
function Furtherance:GetPlayerRealContainersCount(player, allowBone, ignoreMods)
	local hearts = player:GetEffectiveMaxHearts()
	if not ignoreMods and CustomHealthAPI then --Some modded hearts use red hearts behind the actual one.
		hearts = CustomHealthAPI.Library.GetHPOfKey(player, "EMPTY_HEART", false, true)
		if allowBone then
			hearts = hearts + CustomHealthAPI.Library.GetHPOfKey(player, "BONE_HEART", false, true) * 2
		end
	end
	if not allowBone and not CustomHealthAPI then
		hearts = hearts - player:GetBoneHearts() * 2
	end

	return player:GetEffectiveMaxHearts()
end

-- Returns the actual amount of red hearts the player has, subtracting rotten hearts unless allowed.
---@param player EntityPlayer
---@param allowRotten? boolean
---@param ignoreMods? boolean
---@function
function Furtherance:GetPlayerRealRedHeartsCount(player, allowRotten, ignoreMods)
	local hearts = player:GetHearts()
	if not ignoreMods and CustomHealthAPI then --Some modded hearts use red hearts behind the actual one.
		hearts = CustomHealthAPI.Library.GetHPOfKey(player, "RED_HEART", false, true)
		if allowRotten then
			hearts = hearts + CustomHealthAPI.Library.GetHPOfKey(player, "ROTTEN_HEART", false, true) * 2
		end
	end
	if not allowRotten and not CustomHealthAPI then
		hearts = hearts - player:GetRottenHearts() * 2
	end

	return hearts
end

-- Returns the actual amount of soul hearts the player has, subtracting black hearts.
---@param player EntityPlayer
---@param ignoreMods? boolean
---@function
function Furtherance:GetPlayerRealSoulHeartsCount(player, ignoreMods)
	if not ignoreMods and CustomHealthAPI then --Some modded hearts use soul hearts behind the actual one.
		return CustomHealthAPI.Library.GetHPOfKey(player, "SOUL_HEART", false, false)
	end

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

-- Returns the actual amount of black hearts the player has.
---@param player EntityPlayer
---@param ignoreMods? boolean
---@function
function Furtherance:GetPlayerRealBlackHeartsCount(player, ignoreMods)
	if not ignoreMods and CustomHealthAPI then --Some modded hearts use black hearts behind the actual one (?
		return CustomHealthAPI.Library.GetHPOfKey(player, "BLACK_HEART", false, false)
	end

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
			Furtherance.Insert(out, v)
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
		Furtherance.Insert(out, { Slot = slot, Charge = player:GetActiveCharge(slot) })
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

Furtherance.KeeperPlayers = Furtherance:Set({
	PlayerType.PLAYER_KEEPER,
	PlayerType.PLAYER_KEEPER_B
})

---@param player EntityPlayer
function Furtherance:IsAnyLost(player)
	return Furtherance.LostPlayers[player:GetPlayerType()]
end

function Furtherance:IsAnyKeeper(player)
	return Furtherance.KeeperPlayers[player:GetPlayerType()]
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
		score = (((30 / (player.MaxFireDelay + 1)) ^ 0.75) * 2.120391) - 2
	elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
		score = ((player.Damage ^ 0.56) * 2.231179) - 2
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

---@param player EntityPlayer
---@param layer PlayerSpriteLayer
function Furtherance:GetCostumeSpriteFromLayer(player, layer)
	local layerMap = player:GetCostumeLayerMap()[layer + 1]
	if not layerMap then return end
	local costumeIndex = layerMap.costumeIndex
	local costumeDescs = player:GetCostumeSpriteDescs()
	local costumeDesc = costumeDescs[costumeIndex + 1]
	return costumeDesc and costumeDesc:GetSprite()
end

---@param player EntityPlayer
---@param slot ActiveSlot
---@return boolean
function Furtherance:ActiveUsesCarBattery(player, slot)
	local useCarBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
	if Epiphany then
		if Epiphany.API.HasGoldenItem then
			useCarBattery = useCarBattery or Epiphany.API:HasGoldenItem(player:GetActiveItem(slot), player, slot)
		else
			useCarBattery = useCarBattery or Epiphany.API:IsGoldenItem(player:GetActiveItem(slot))
		end
	end
	return useCarBattery
end
