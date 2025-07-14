--#region Variables

local Mod = Furtherance
local sin = Mod.math.sin
local ceil = Mod.math.ceil
local min = Mod.math.min
local floor = Mod.math.floor

local LEAH_B = {}

Furtherance.Character.LEAH_B = LEAH_B

Mod.Include("scripts.furtherance.characters.leah_b.shattered_heart")

LEAH_B.HEART_DECAY_TIMER = 600
LEAH_B.HEART_LIMIT = 48
---There's some sort of "invisible" cap on broken hearts, not allowing you to add more depending on the heart cap as it goes into higher numbers.
---
---We're allowed to add 23 broken hearts at a limit of 66. Tainted Leah manages removing hearts that exceed the expected 24
---
-- !This is now unused due to adding CustomHealthAPI but keeping it here as an important note I guess?
LEAH_B.TECHNICAL_HEART_LIMIT = 66

LEAH_B.HEART_ADD_CHECK = Mod:Set({
	AddHealthType.MAX,
	AddHealthType.SOUL,
	AddHealthType.BLACK,
	AddHealthType.BONE,
	AddHealthType.BROKEN
})

LEAH_B.BIRTHRIGHT_HEART_UPGRADE_CHANCE = 0.2

LEAH_B.STAT_TABLE = {
	{ Name = "Damage",       Flag = CacheFlag.CACHE_DAMAGE,    Buff = 0.05 },
	{ Name = "MaxFireDelay", Flag = CacheFlag.CACHE_FIREDELAY, Buff = 0.025}, --Set for tears, not firedelay.
	{ Name = "TearRange",    Flag = CacheFlag.CACHE_RANGE,     Buff = 0.125 * Mod.RANGE_BASE_MULT },
	{ Name = "ShotSpeed",    Flag = CacheFlag.CACHE_SHOTSPEED, Buff = 0.01 },
	{ Name = "MoveSpeed",    Flag = CacheFlag.CACHE_SPEED,     Buff = 0.01 },
}

local leahHeartHUD = Sprite(Mod:GetHealthPath(), true)

--#endregion

--#region Helpers

---@param player EntityPlayer
function LEAH_B:IsLeahB(player)
	return player:GetPlayerType() == Mod.PlayerType.LEAH_B
end

---@param player? EntityPlayer
function LEAH_B:LeahBHasBirthright(player)
	if not player then
		return PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.LEAH_B)
	else
		return LEAH_B:IsLeahB(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	end
end

---@param player EntityPlayer
function LEAH_B:GetMaxHeartSlots(player)
	return ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts()) / 2)
end

---@param player EntityPlayer
function LEAH_B:GetMaxHeartAmount(player)
	return player:GetEffectiveMaxHearts() + player:GetSoulHearts() + (player:GetBrokenHearts() * 2)
end

function LEAH_B:GetDamageRequirement()
	return 55 + 15 * Mod.Level():GetAbsoluteStage()
end

--#endregion

--#region Heart limit

---Broken hearts, because of the weird heart limit, may or may not replace a container in the process of being added
---
---Disabled because CustomHealthAPI fixes this for us

---@param player EntityPlayer
function LEAH_B:ReplaceHeartsIfAboveCap(player)
	local maxHearts = LEAH_B:GetMaxHeartAmount(player)
	if maxHearts > LEAH_B.HEART_LIMIT then
		local brokenHearts = player:GetBrokenHearts() * 2
		local maxHeartsNoBroken = maxHearts - brokenHearts
		local numToRemove = -(brokenHearts - (LEAH_B.HEART_LIMIT - maxHeartsNoBroken))

		if player:GetMaxHearts() > 0 then
			player:AddMaxHearts(numToRemove)
		elseif player:GetSoulHearts() > 0 then
			player:AddSoulHearts(numToRemove)
		end
	end
end

---@param player EntityPlayer
---@param amount integer
---@param addHealthType AddHealthType
function LEAH_B:StopHeartsBeyondCap(player, amount, addHealthType)
	if LEAH_B:IsLeahB(player)
		and LEAH_B.HEART_ADD_CHECK[addHealthType]
	then
		local currentHearts = LEAH_B:GetMaxHeartAmount(player)
		local heartWorth = addHealthType == AddHealthType.BONE and amount * 2 or amount
		if currentHearts + heartWorth > LEAH_B.HEART_LIMIT then
			local remainingToCap = LEAH_B.HEART_LIMIT - currentHearts
			if addHealthType == AddHealthType.BONE then
				remainingToCap = (LEAH_B.HEART_LIMIT / 2) - ceil(currentHearts / 2)
			end
			if addHealthType ~= AddHealthType.BROKEN then
				return remainingToCap
			else
				Mod:DelayOneFrame(function ()
					LEAH_B:ReplaceHeartsIfAboveCap(player)
				end)
			end
		end
	end
end

--Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, LEAH_B.StopHeartsBeyondCap)

-- !BUG: PRE/POST_PLAYER_ADD_HEARTS doesn't trigger for bone hearts, so we gotta do this instead
-- ...CustomHealthAPI fixes this issue, so its now disabled
---@param player EntityPlayer
function LEAH_B:RemoveBoneHeartsAboveCap(player)
	local maxHearts = LEAH_B:GetMaxHeartAmount(player)
	local boneHearts = player:GetBoneHearts() * 2
	local maxHeartsNoBone = maxHearts - boneHearts

	if maxHeartsNoBone + boneHearts > LEAH_B.HEART_LIMIT then
		player:AddBoneHearts(-ceil((boneHearts - (LEAH_B.HEART_LIMIT - maxHeartsNoBone)) / 2))
	end
end

local function heartLimit(player)
	if LEAH_B:IsLeahB(player) then
		return LEAH_B.HEART_LIMIT
	end
end

CustomHealthAPI.Library.AddCallback("Furtherance", CustomHealthAPI.Enums.Callbacks.GET_MAX_HP_CAP, CustomHealthAPI.Enums.CallbackPriorities.FIRST, heartLimit)

---@param player EntityPlayer
function LEAH_B:UpdateRedHealthStats(player)
	local redHearts = player:GetHearts() + player:GetRottenHearts()
	local data = Mod:GetData(player)

	data.LeahBTrackRed = data.LeahBTrackRed or redHearts
	if data.LeahBTrackRed ~= redHearts then
		data.LeahBTrackRed = redHearts
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end

---@param player EntityPlayer
function LEAH_B:OnPeffectUpdate(player)
	--LEAH_B:RemoveBoneHeartsAboveCap(player)
	LEAH_B:UpdateRedHealthStats(player)
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LEAH_B.OnPeffectUpdate, Mod.PlayerType.LEAH_B)

--#endregion

--#region Stats from red health

local heartCache = Mod:Set({
	CacheFlag.CACHE_DAMAGE,
	CacheFlag.CACHE_FIREDELAY,
	CacheFlag.CACHE_RANGE,
	CacheFlag.CACHE_SHOTSPEED,
	CacheFlag.CACHE_SPEED
})

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function LEAH_B:HealthyStatUp(player, cacheFlag)
	if not LEAH_B:IsLeahB(player) then return end
	local hearts = player:GetHearts() + (player:GetRottenHearts() * 2) - 2
	if heartCache[cacheFlag] then
		for _, stat in ipairs(LEAH_B.STAT_TABLE) do
			if stat.Flag == cacheFlag then
				if cacheFlag == CacheFlag.CACHE_FIREDELAY then
					player[stat.Name] = Mod:TearsUp(player[stat.Name], hearts * stat.Buff)
				else
					player[stat.Name] = player[stat.Name] + hearts * stat.Buff
				end
				break
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LEAH_B.HealthyStatUp)

--#endregion

--#region Gain/remove broken hearts

---@param pos Vector
function LEAH_B:SpawnEmptyHeartUpNotification(pos)
	local effect = Mod.Spawn.Notification(pos, 0)
	effect:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_notify_furtherance.png", true)
end

---@param player EntityPlayer
function LEAH_B:HeartDecay(player)
	local data = Mod:GetData(player)
	local damageNeeded = LEAH_B:GetDamageRequirement()
	while (data.LeahBBrokenDamage or 0) > damageNeeded do
		data.LeahBBrokenDamage = data.LeahBBrokenDamage - damageNeeded
		player:AddBrokenHearts(-1)
		player:AddMaxHearts(2)
		LEAH_B:SpawnEmptyHeartUpNotification(player.Position)
	end
	local numBrokens = player:GetBrokenHearts()
	--23
	if numBrokens < (LEAH_B.HEART_LIMIT / 2) - 1 then
		data.LeahBHeartDecayCountdown = data.LeahBHeartDecayCountdown or LEAH_B.HEART_DECAY_TIMER
		data.LeahBHeartDecayCountdown = data.LeahBHeartDecayCountdown - 1
		if data.LeahBHeartDecayCountdown == 0 then
			player:AddBrokenHearts(1)
			data.LeahBHeartDecayCountdown = LEAH_B.HEART_DECAY_TIMER
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LEAH_B.HeartDecay, Mod.PlayerType.LEAH_B)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function LEAH_B:HealBrokenHearts(ent, amount, flags, source, countdown)
	local player = Mod:TryGetPlayer(source)
	if player and LEAH_B:IsLeahB(player) and Mod:IsValidEnemyTarget(ent) then
		local data = Mod:GetData(player)
		local damageDealt = min(ent.HitPoints, amount)
		data.LeahBBrokenDamage = (data.LeahBBrokenDamage or 0) + damageDealt
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, LEAH_B.HealBrokenHearts)

--#endregion

--#region Render incoming broken heart

HudHelper.RegisterHUDElement({
	Name = "Leah B Heart Decay",
	Priority = HudHelper.Priority.NORMAL,
	Condition = function (player, playerHUDIndex, hudLayout)
		return LEAH_B:IsLeahB(player)
			and player:GetBrokenHearts() < (LEAH_B.HEART_LIMIT / 2) - 1
			and not Mod:HasBitFlags(Mod.Level():GetCurses(), LevelCurse.CURSE_OF_THE_UNKNOWN)
	end,
	OnRender = function (player, playerHUDIndex, hudLayout, position, maxColumns, _, numPlayers)
		local alpha = (sin(Mod.Game:GetFrameCount() * 4 * 1.5 * math.pi / 180) + 1) / 2
		local allHearts = LEAH_B:GetMaxHeartAmount(player)
		local offset = 0
		if allHearts == LEAH_B.HEART_LIMIT then
			offset = LEAH_B:GetMaxHeartSlots(player) - 1
		else
			offset = ceil(allHearts / 2)
		end
		local pos = Vector(position.X + (offset % maxColumns) * 12,
			position.Y + floor(offset / maxColumns) * 10)
		leahHeartHUD:SetFrame("BrokenHeart", 0)
		leahHeartHUD.Color = Color(0, 0, 0, alpha / 2 + 0.25, 0.5, 0, 0)
		leahHeartHUD:Render(pos)
	end
}, HudHelper.HUDType.HEALTH)

HudHelper.RegisterHUDElement({
	Name = "Leah B Heart Gain",
	Priority = HudHelper.Priority.NORMAL,
	Condition = function (player, playerHUDIndex, hudLayout)
		return LEAH_B:IsLeahB(player)
			and (Mod:GetData(player).LeahBBrokenDamage or 0) > 0
			and player:GetBrokenHearts() > 0
			and not Mod:HasBitFlags(Mod.Level():GetCurses(), LevelCurse.CURSE_OF_THE_UNKNOWN)
	end,
	OnRender = function (player, playerHUDIndex, hudLayout, position, maxColumns)
		local allHearts = LEAH_B:GetMaxHeartAmount(player)
		local offset = 0
		if allHearts == LEAH_B.HEART_LIMIT then
			offset = LEAH_B:GetMaxHeartSlots(player)
		else
			offset = ceil(allHearts / 2) - 1
		end
		local pos = Vector(position.X + (offset % maxColumns) * 12,
			position.Y + floor(offset / maxColumns) * 10)
		leahHeartHUD:SetFrame("EmptyHeart", 0)
		leahHeartHUD.Color = Color(1, 1, 1, 1, 0.25)
		local amountTillHeal = (Mod:GetData(player).LeahBBrokenDamage / LEAH_B:GetDamageRequirement()) * 16
		leahHeartHUD:Render(pos, Vector(0, 16 - amountTillHeal))
	end
}, HudHelper.HUDType.HEALTH)

function LEAH_B:Render()
	local player = Isaac.GetPlayer()
	local data = Mod:GetData(player)
	if data.LeahBHeartDecayCountdown then
		Isaac.RenderText(data.LeahBHeartDecayCountdown, 50, 50, 1, 1, 1, 1)
	end
	if data.LeahBBrokenDamage then
		Isaac.RenderText(data.LeahBBrokenDamage .. "/" .. LEAH_B:GetDamageRequirement(), 50, 70, 1, 1, 1, 1)
	end
end

--Mod:AddCallback(ModCallbacks.MC_POST_RENDER, LEAH_B.Render)

--#endregion

--#region Replace Soul hearts

---@param entType EntityType
---@param variant PickupVariant
---@param subtype integer
---@param spawner Entity
---@param seed integer
function LEAH_B:ReplaceHearts(entType, variant, subtype, pos, vel, spawner, seed)
	if entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_HEART
		and PlayerManager.AnyoneIsPlayerType(Mod.PlayerType.LEAH_B)
		and (Mod.HeartGroups.Soul[subtype] or Mod.HeartGroups.Black[subtype])
	then
		local anyoneNotLeahB = Mod.Foreach.Player(function (player, index)
			if not LEAH_B:IsLeahB(player) and not Mod.Character.MIRIAM_B:IsMiriamB(player) then
				return true
			end
		end)
		if anyoneNotLeahB then return end
		local heartSubtype = (Mod.HeartAmount[subtype] or 0) == 1 and HeartSubType.HEART_HALF or HeartSubType.HEART_FULL
		if LEAH_B:LeahBHasBirthright() and RNG(seed):RandomFloat() <= LEAH_B.BIRTHRIGHT_HEART_UPGRADE_CHANCE then
			local floor_save = Mod:FloorSave()
			floor_save.LeahBBirthrightHeartUpgrade = floor_save.LeahBBirthrightHeartUpgrade or {}
			if floor_save.LeahBBirthrightHeartUpgrade[tostring(seed)] then
				floor_save.LeahBBirthrightHeartUpgrade[tostring(seed)] = true
				heartSubtype = Mod.HeartValueIncrease[heartSubtype] or heartSubtype
			end
		end
		Mod:DebugLog(entType, variant, heartSubtype, seed)
		return {entType, variant, heartSubtype, seed}
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, CallbackPriority.IMPORTANT, LEAH_B.ReplaceHearts)

--#endregion