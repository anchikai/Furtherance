local Mod = Furtherance
local MIRIAM_B = Mod.Character.MIRIAM_B
local POLARITY_SHIFT = Mod.Item.POLARITY_SHIFT

local SPIRITUAL_WOUND = {}

Furtherance.Character.MIRIAM_B.SPIRITUAL_WOUND = SPIRITUAL_WOUND

SPIRITUAL_WOUND.SFX_START = Isaac.GetSoundIdByName("Spiritual Wound Start")
SPIRITUAL_WOUND.SFX_DEATH_FIELD_START = Isaac.GetSoundIdByName("Death Field Start")
SPIRITUAL_WOUND.SFX_LOOP = Isaac.GetSoundIdByName("Spiritual Wound Loop")
SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_START = Isaac.GetSoundIdByName("Chain Lightning Start")
SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_LOOP = Isaac.GetSoundIdByName("Chain Lightning Loop")

SPIRITUAL_WOUND.ATTACK_SFX = {
	SPIRITUAL_WOUND.SFX_START,
	SPIRITUAL_WOUND.SFX_DEATH_FIELD_START,
	SPIRITUAL_WOUND.SFX_LOOP,
	SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_START,
	SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_LOOP,
}

SPIRITUAL_WOUND.SPIRITUAL_WOUND_COLOR = Color(1, 1, 1, 1, 0, 0, 0, 5, 2, 1, 1)
SPIRITUAL_WOUND.CHAIN_LIGHTNING_COLOR = Color(1, 1, 1, 1, 0.1, 0.1, 0.1, 3.8, 4.9, 6, 1)
SPIRITUAL_WOUND.DEATH_FIELD_COLOR = Color(1, 1, 1, 1, 0, 0, 0, 2.5, 0, 2.5, 1)

SPIRITUAL_WOUND.IS_FIRING = false

SPIRITUAL_WOUND.INNATE_COLLECTIBLES = {
	CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
	CollectibleType.COLLECTIBLE_TECHNOLOGY,
	CollectibleType.COLLECTIBLE_SOY_MILK
}

---@param player EntityPlayer
function SPIRITUAL_WOUND:ShouldUseSpiritualWound(player)
	return MIRIAM_B:IsMiriamB(player) or player:GetEffects():HasCollectibleEffect(Mod.Item.POLARITY_SHIFT.ID_1)
end

---@param player EntityPlayer
function SPIRITUAL_WOUND:GetAttackInitSound(player)
	if POLARITY_SHIFT:IsChainLightningActive(player) then
		return SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_START
	elseif MIRIAM_B:MiriamBHasBirthright(player) then
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
	if not SPIRITUAL_WOUND:ShouldUseSpiritualWound(player) then return end

	if cacheFlag == CacheFlag.CACHE_TEARFLAG then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
	elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
		local color = SPIRITUAL_WOUND.SPIRITUAL_WOUND_COLOR
		if POLARITY_SHIFT:IsChainLightningActive(player) then
			color = SPIRITUAL_WOUND.CHAIN_LIGHTNING_COLOR
		elseif MIRIAM_B:MiriamBHasBirthright(player) then
			color = SPIRITUAL_WOUND.DEATH_FIELD_COLOR
		end
		player.LaserColor = color
	elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = 0
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, SPIRITUAL_WOUND.SpiritualWoundCache)

---Looks at the current attack SFX being played by the SW player and loops through the other players
---
---Will always stop the starting SFX, but will look to see if any players are currently firing their own appropriate looping SFX
---to determine whether or not to stop the looping sound
---@param player EntityPlayer
function SPIRITUAL_WOUND:TryStopAttackSFX(player)
	local shouldSFXPlay = {}
	local someoneStillFiring
	Mod.Foreach.Player(function(_player)
		if Mod:GetData(player).FiringSpiritualWound then
			someoneStillFiring = true
			shouldSFXPlay[SPIRITUAL_WOUND:GetAttackInitSound(player)] = true
			shouldSFXPlay[SPIRITUAL_WOUND:GetAttackLoopSound(player)] = true
		end
	end)
	for _, sfx in ipairs(SPIRITUAL_WOUND.ATTACK_SFX) do
		if not shouldSFXPlay[sfx] then
			Mod.SFXMan:Stop(sfx)
		end
	end

	return someoneStillFiring
end

---@param player EntityPlayer
function SPIRITUAL_WOUND:HandleFiringSFX(player)
	local weapon = player:GetWeapon(1)
	local data = Mod:GetData(player)
	if weapon
		and player:GetFireDirection() ~= Direction.NO_DIRECTION
		and SPIRITUAL_WOUND:ShouldUseSpiritualWound(player)
	then
		if not data.FiringSpiritualWound then
			data.FiringSpiritualWound = true
			Isaac.CreateTimer(function ()
				if player:GetFireDirection() ~= Direction.NO_DIRECTION then
					SPIRITUAL_WOUND.IS_FIRING = true
					local startSFX = SPIRITUAL_WOUND:GetAttackInitSound(player)
					Mod.SFXMan:Play(startSFX)
				end
			end, 2, 1, true)
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

---@param player EntityPlayer
function SPIRITUAL_WOUND:RemoveInnateItems(player)
	local data = Mod:GetData(player)
	if data.IsMiriamB and not MIRIAM_B:IsMiriamB(player) then
		local spoofList = player:GetSpoofedCollectiblesList()

		for _, itemID in pairs(SPIRITUAL_WOUND.INNATE_COLLECTIBLES) do
			if spoofList[itemID] and spoofList[itemID].AppendedCount > 0 then
				player:AddInnateCollectible(itemID, -1)
				local itemConfigItem = Mod.ItemConfig:GetCollectible(itemID)
				if not player:HasCollectible(itemID, true, true) then
					player:RemoveCostume(itemConfigItem)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SPIRITUAL_WOUND.RemoveInnateItems)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
function SPIRITUAL_WOUND:LaserDamage(ent, amount, flags, source)
	local player = Mod:TryGetPlayer(source.Entity, true)
	if player
		and SPIRITUAL_WOUND:ShouldUseSpiritualWound(player)
		and Mod:HasBitFlags(flags, DamageFlag.DAMAGE_LASER)
		and ent:ToNPC()
	then
		local hasBirthright = Mod.Character.MIRIAM_B:MiriamBHasBirthright(player)
		local isChainLightning = POLARITY_SHIFT:IsChainLightningActive(player)
		local countdown = 3
		local damageMultBonus = 1
		if hasBirthright or isChainLightning then
			countdown = 1
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
function SPIRITUAL_WOUND:TryAddInnateItems(player)
	if SPIRITUAL_WOUND:ShouldUseSpiritualWound(player) then
		if MIRIAM_B:IsMiriamB(player) then
			Mod:GetData(player).IsMiriamB = true
		end
		for _, itemID in ipairs(SPIRITUAL_WOUND.INNATE_COLLECTIBLES) do
			if not player:HasCollectible(itemID, false, false) then
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
