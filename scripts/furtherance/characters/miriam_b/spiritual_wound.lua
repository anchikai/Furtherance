local Mod = Furtherance

local SPIRITUAL_WOUND = {}

Furtherance.Item.SPIRITUAL_WOUND = SPIRITUAL_WOUND

SPIRITUAL_WOUND.ID = Isaac.GetItemIdByName("Spiritual Wound")

SPIRITUAL_WOUND.SFX_START = Isaac.GetSoundIdByName("SpiritualWoundStart")
SPIRITUAL_WOUND.SFX_LOOP = Isaac.GetSoundIdByName("SpiritualWoundLoop")

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function SPIRITUAL_WOUND:SpiritualWoundCache(player, cacheFlag)
	if not player:HasCollectible(SPIRITUAL_WOUND.ID) then return end
	if cacheFlag == CacheFlag.CACHE_TEARFLAG then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
	elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
		player.LaserColor = Color(1, 1, 1, 1, 0, 0, 0, 5, 2, 1, 1)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SPIRITUAL_WOUND.SpiritualWoundCache)

---@param player EntityPlayer
function SPIRITUAL_WOUND:OnPeffectUpdate(player)
	local weapon = player:GetWeapon(1)
	local data = Mod:GetData(player)
	if weapon and player:GetFireDirection() ~= Direction.NO_DIRECTION and player:HasCollectible(SPIRITUAL_WOUND.ID) then
		weapon:SetCharge(999)
		if not data.StartedSpiritualWound then
			data.StartedSpiritualWound = true
			Mod.SFXMan:Play(SPIRITUAL_WOUND.SFX_START, 1, 2, false, 1, 0)
			Mod.SFXMan:Play(SPIRITUAL_WOUND.SFX_LOOP, 1, 2, true, 1, 0)
		end
	elseif data.StartedSpiritualWound then
		Mod.SFXMan:Stop(SPIRITUAL_WOUND.SFX_START)
		Mod.SFXMan:Stop(SPIRITUAL_WOUND.SFX_LOOP)
		data.StartedSpiritualWound = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SPIRITUAL_WOUND.OnPeffectUpdate)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function SPIRITUAL_WOUND:EntityTakeDmg(ent, amount, flags, source, countdown)
	if Mod:TryGetPlayer(ent, true)
		and Mod:HasBitFlags(flags, DamageFlag.DAMAGE_LASER)
		and ent:ToNPC()
	then
		return {DamageFlags = flags | DamageFlag.DAMAGE_COUNTDOWN, DamageCountdown = 2}
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SPIRITUAL_WOUND.EntityTakeDmg)

function SPIRITUAL_WOUND:StopSFX(id, volume, framedelay, loop, pitch, pan)
	return false
end

Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, SPIRITUAL_WOUND.StopSFX, SoundEffect.SOUND_REDLIGHTNING_ZAP_WEAK)
Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, SPIRITUAL_WOUND.StopSFX, SoundEffect.SOUND_REDLIGHTNING_ZAP_BURST)