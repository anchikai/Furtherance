local Mod = Furtherance
local POLARITY_SHIFT = Mod.Item.POLARITY_SHIFT

local SPIRITUAL_WOUND = {}

Furtherance.Item.SPIRITUAL_WOUND = SPIRITUAL_WOUND

SPIRITUAL_WOUND.ID = Isaac.GetItemIdByName("Spiritual Wound")

SPIRITUAL_WOUND.SFX_START = Isaac.GetSoundIdByName("Spiritual Wound Start")
SPIRITUAL_WOUND.SFX_DEATH_FIELD_START = Isaac.GetSoundIdByName("Death Field Start")
SPIRITUAL_WOUND.SFX_LOOP = Isaac.GetSoundIdByName("Spiritual Wound Loop")
SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_START = Isaac.GetSoundIdByName("Chain Lightning Start")
SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_LOOP = Isaac.GetSoundIdByName("Chain Lightning Loop")

SPIRITUAL_WOUND.SPIRITUAL_WOUND_COLOR = Color(1, 1, 1, 1, 0, 0, 0, 5, 2, 1, 1)
SPIRITUAL_WOUND.CHAIN_LIGHTNING_COLOR = Color(1, 1, 1, 1, 0.1, 0.1, 0.1, 3.8, 4.9, 6, 1)
SPIRITUAL_WOUND.DEATH_FIELD_COLOR = Color(1, 1, 1, 1, 0, 0, 0, 2.5, 0, 2.5, 1)

SPIRITUAL_WOUND.IS_FIRING = false

local INNATE_COLLECTIBLES = {
	CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
	CollectibleType.COLLECTIBLE_TECHNOLOGY,
	CollectibleType.COLLECTIBLE_SOY_MILK
}

---@param player EntityPlayer
function SPIRITUAL_WOUND:GetAttackInitSound(player)
	if POLARITY_SHIFT:IsChainLightningActive(player) then
		return SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_START
	elseif Mod.Character.MIRIAM_B:MiriamBHasBirthright(player) then
		return SPIRITUAL_WOUND.SFX_DEATH_FIELD_START
	else
		return SPIRITUAL_WOUND.SFX_START
	end
end

---@param player EntityPlayer
function SPIRITUAL_WOUND:GetAttackLoopSound(player)
	if POLARITY_SHIFT:IsChainLightningActive(player) then
		return SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_LOOP
	else
		return SPIRITUAL_WOUND.SFX_LOOP
	end
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function SPIRITUAL_WOUND:SpiritualWoundCache(player, cacheFlag)
	if not player:HasCollectible(SPIRITUAL_WOUND.ID) then return end
	if cacheFlag == CacheFlag.CACHE_TEARFLAG then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
	elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
		local color = SPIRITUAL_WOUND.SPIRITUAL_WOUND_COLOR
		if player:HasCollectible(Mod.Item.POLARITY_SHIFT.ID_2) then
			color = SPIRITUAL_WOUND.CHAIN_LIGHTNING_COLOR
		elseif Mod.Character.MIRIAM_B:MiriamBHasBirthright(player) then
			color = SPIRITUAL_WOUND.DEATH_FIELD_COLOR
		end
		player.LaserColor = color
	elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage - 0.3
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SPIRITUAL_WOUND.SpiritualWoundCache)

---Looks at the current attack SFX being played by the SW player and loops through the other players
---
---Will always stop the starting SFX, but will look to see if any players are currently firing their own appropriate looping SFX
---to determine whether or not to stop the looping sound
---@param player EntityPlayer
function SPIRITUAL_WOUND:TryStopAttackSFX(player)
	local loopSFX = SPIRITUAL_WOUND:GetAttackLoopSound(player)
	local stopLoop = true
	local someoneStillFiring = false
	Mod.Foreach.Player(function(_player)
		if Mod:GetData(_player).FiringSpiritualWound
			and GetPtrHash(player) ~= GetPtrHash(_player)
			and loopSFX == SPIRITUAL_WOUND:GetAttackLoopSound(_player)
		then
			stopLoop = false
			someoneStillFiring = true
		end
	end)
	Mod.SFXMan:Stop(SPIRITUAL_WOUND:GetAttackInitSound(player))
	if stopLoop then
		Mod.SFXMan:Stop(loopSFX)
	end
	return someoneStillFiring
end

---@param player EntityPlayer
function SPIRITUAL_WOUND:HandleFiringSFX(player)
	local weapon = player:GetWeapon(1)
	local data = Mod:GetData(player)
	if weapon and player:GetFireDirection() ~= Direction.NO_DIRECTION and player:HasCollectible(SPIRITUAL_WOUND.ID) then
		weapon:SetCharge(weapon:GetCharge() + 2)
		if not data.FiringSpiritualWound then
			data.FiringSpiritualWound = true
			SPIRITUAL_WOUND.IS_FIRING = true
			local startSFX = SPIRITUAL_WOUND:GetAttackInitSound(player)
			Mod.SFXMan:Play(startSFX)
		end
		if SPIRITUAL_WOUND.IS_FIRING then
			local loopSFX = SPIRITUAL_WOUND:GetAttackLoopSound(player)
			if not Mod.SFXMan:IsPlaying(loopSFX) then
				Mod.SFXMan:Play(loopSFX, 1, 2, true, 1, 0)
			end
		end
	elseif data.FiringSpiritualWound then
		data.FiringSpiritualWound = false
		SPIRITUAL_WOUND.IS_FIRING = SPIRITUAL_WOUND:TryStopAttackSFX(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SPIRITUAL_WOUND.HandleFiringSFX)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
function SPIRITUAL_WOUND:LaserDamage(ent, amount, flags, source)
	local player = Mod:TryGetPlayer(source.Entity, true)
	if player
		and player:HasCollectible(SPIRITUAL_WOUND.ID)
		and Mod:HasBitFlags(flags, DamageFlag.DAMAGE_LASER)
		and ent:ToNPC()
	then
		local hasBirthright = Mod.Character.MIRIAM_B:MiriamBHasBirthright(player)
		local isChainLightning = POLARITY_SHIFT:IsChainLightningActive(player)
		local countdown = 3
		local damageMultBonus = 1
		if hasBirthright or isChainLightning then
			countdown = 2
			if hasBirthright and isChainLightning and ent:HasEntityFlags(EntityFlag.FLAG_FEAR) then
				damageMultBonus = 1.5
			end
		end
		local dist = ent.Position:Distance(player.Position) / 80
		local dmgMult = dist <= 1 and 0 or Mod:Clamp(dist * 0.15, 0, 0.5)
		return { Damage = (amount - (amount * dmgMult) * damageMultBonus), DamageFlags = flags | DamageFlag.DAMAGE_COUNTDOWN, DamageCountdown =
		countdown }
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SPIRITUAL_WOUND.LaserDamage)

function SPIRITUAL_WOUND:StopSFX()
	if SPIRITUAL_WOUND.IS_FIRING then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, SPIRITUAL_WOUND.StopSFX, SoundEffect.SOUND_REDLIGHTNING_ZAP_WEAK)
Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, SPIRITUAL_WOUND.StopSFX, SoundEffect.SOUND_REDLIGHTNING_ZAP_BURST)

---@param player EntityPlayer
function SPIRITUAL_WOUND:OnCollectibleAdd(itemID, charge, firstTime, slot, varData, player)
	SPIRITUAL_WOUND:TryAddInnateItems(player)
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, SPIRITUAL_WOUND.OnCollectibleAdd, SPIRITUAL_WOUND.ID)

---@param player EntityPlayer
function SPIRITUAL_WOUND:OnCollectibleRemove(player)
	local INNATE_MAP = Mod:Set(INNATE_COLLECTIBLES)
	local spoofList = player:GetSpoofedCollectiblesList()

	for _, spoof in ipairs(spoofList) do
		local itemID = spoof.CollectibleID
		if INNATE_MAP[itemID] and spoof.AppendedCount > 0 then
			player:AddInnateCollectible(itemID, -1)
			local itemConfigItem = Mod.ItemConfig:GetCollectible(itemID)
			if not player:HasCollectible(itemID, true, true) then
				player:RemoveCostume(itemConfigItem)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, SPIRITUAL_WOUND.OnCollectibleRemove, SPIRITUAL_WOUND
.ID)

---@param player EntityPlayer
function SPIRITUAL_WOUND:TryAddInnateItems(player)
	if player:HasCollectible(SPIRITUAL_WOUND.ID) then
		for _, itemID in ipairs(INNATE_COLLECTIBLES) do
			if not player:HasCollectible(itemID, false, true) then
				player:AddInnateCollectible(itemID)
				local itemConfigItem = Mod.ItemConfig:GetCollectible(itemID)
				if not player:HasCollectible(itemID, true, true) then
					player:RemoveCostume(itemConfigItem)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SPIRITUAL_WOUND.TryAddInnateItems)
