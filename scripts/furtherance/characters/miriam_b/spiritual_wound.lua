local Mod = Furtherance

local SPIRITUAL_WOUND = {}

Furtherance.Item.SPIRITUAL_WOUND = SPIRITUAL_WOUND

SPIRITUAL_WOUND.ID = Isaac.GetItemIdByName("Spiritual Wound")

SPIRITUAL_WOUND.SFX_START = Isaac.GetSoundIdByName("Spiritual Wound Start")
SPIRITUAL_WOUND.SFX_DEATH_FIELD_START = Isaac.GetSoundIdByName("Death Field Start")
SPIRITUAL_WOUND.SFX_LOOP = Isaac.GetSoundIdByName("Spiritual Wound Loop")
SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_START = Isaac.GetSoundIdByName("Chain Lightning Start")
SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_LOOP = Isaac.GetSoundIdByName("Chain Lightning Loop")

SPIRITUAL_WOUND.SPIRITUAL_WOUND_COLOR = Color(1, 1, 1, 1, 0, 0, 0, 5, 2, 1, 1)
SPIRITUAL_WOUND.CHAIN_LIGHTNING_COLOR = Color(1, 1, 1, 1, 0, 0, 0, 5, 2, 1, 1)
SPIRITUAL_WOUND.DEATH_FIELD_COLOR = Color(1, 1, 1, 1, 0, 0, 0, 5, 2, 1, 1)

SPIRITUAL_WOUND.IS_FIRING = false

local INNATE_COLLECTIBLES = {
	CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
	CollectibleType.COLLECTIBLE_TECHNOLOGY,
	CollectibleType.COLLECTIBLE_SOY_MILK
}

---@param player EntityPlayer
function SPIRITUAL_WOUND:GetAttackInitSound(player)
	if player:HasCollectible(Mod.Item.POLARITY_SHIFT.ID_2) then
		return SPIRITUAL_WOUND.SFX_CHAIN_LIGHTNING_START
	elseif Mod.Character.MIRIAM_B:MiriamBHasBirthright(player) then
		return SPIRITUAL_WOUND.SFX_DEATH_FIELD_START
	else
		return SPIRITUAL_WOUND.SFX_START
	end
end

---@param player EntityPlayer
function SPIRITUAL_WOUND:GetAttackLoopSound(player)
	if player:HasCollectible(Mod.Item.POLARITY_SHIFT.ID_2) then
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
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SPIRITUAL_WOUND.SpiritualWoundCache)

---@param player EntityPlayer
function SPIRITUAL_WOUND:OnPeffectUpdate(player)
	local weapon = player:GetWeapon(1)
	local data = Mod:GetData(player)
	if weapon and player:GetFireDirection() ~= Direction.NO_DIRECTION and player:HasCollectible(SPIRITUAL_WOUND.ID) then
		weapon:SetCharge(999)
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
		local startSFX = SPIRITUAL_WOUND:GetAttackInitSound(player)
		local loopSFX = SPIRITUAL_WOUND:GetAttackLoopSound(player)
		local stopStart = true
		local stopLoop = true
		local someoneStillFiring = false
		Mod:ForEachPlayer(function(_player)
			if Mod:GetData(_player).FiringSpiritualWound then
				if startSFX == SPIRITUAL_WOUND:GetAttackInitSound(_player) then
					stopStart = false
				elseif loopSFX == SPIRITUAL_WOUND:GetAttackLoopSound(_player) then
					stopLoop = false
				end
				someoneStillFiring = true
			end
		end)
		if stopStart then
			Mod.SFXMan:Stop(SPIRITUAL_WOUND:GetAttackInitSound(player))
		end
		if stopLoop then
			Mod.SFXMan:Stop(SPIRITUAL_WOUND:GetAttackLoopSound(player))
		end
		SPIRITUAL_WOUND.IS_FIRING = someoneStillFiring
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SPIRITUAL_WOUND.OnPeffectUpdate)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function SPIRITUAL_WOUND:EntityTakeDmg(ent, amount, flags, source, countdown)
	local player = Mod:TryGetPlayer(ent, true)
	if player
		and player:HasCollectible(SPIRITUAL_WOUND.ID)
		and Mod:HasBitFlags(flags, DamageFlag.DAMAGE_LASER)
		and ent:ToNPC()
	then
		return { DamageFlags = flags | DamageFlag.DAMAGE_COUNTDOWN, DamageCountdown = 2 }
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SPIRITUAL_WOUND.EntityTakeDmg)

function SPIRITUAL_WOUND:StopSFX(id, volume, framedelay, loop, pitch, pan)
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

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, SPIRITUAL_WOUND.OnCollectibleRemove, SPIRITUAL_WOUND.ID)

---@param player EntityPlayer
function SPIRITUAL_WOUND:TryAddInnateItems(player)
	if player:HasCollectible(SPIRITUAL_WOUND.ID) and Mod.Room():GetFrameCount() == 0 then
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

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SPIRITUAL_WOUND.TryAddInnateItems)
