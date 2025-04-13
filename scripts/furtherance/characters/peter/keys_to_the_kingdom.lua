--#region Variables

local Mod = Furtherance
local SEL = StatusEffectLibrary

local KEYS_TO_THE_KINGDOM = {}

Furtherance.Item.KEYS_TO_THE_KINGDOM = KEYS_TO_THE_KINGDOM

KEYS_TO_THE_KINGDOM.ID = Isaac.GetItemIdByName("Keys to the Kingdom")
KEYS_TO_THE_KINGDOM.EFFECT = Isaac.GetEntityVariantByName("Keys to the Kingdom Effects")
KEYS_TO_THE_KINGDOM.DEVIL_NULL_ID = Isaac.GetNullItemIdByName("kttk denied deals")

--SubTypes of the Effect
KEYS_TO_THE_KINGDOM.SOUL = 1
KEYS_TO_THE_KINGDOM.SOUL_BOSS = 3
KEYS_TO_THE_KINGDOM.SPARED_SOUL = 100
KEYS_TO_THE_KINGDOM.SPARED_SOUL_BOSS = 101
KEYS_TO_THE_KINGDOM.SPOTLIGHT = 200

KEYS_TO_THE_KINGDOM.STORY_BOSS_IDS = Mod:Set({
	BossType.MOM,
	BossType.MOMS_HEART,
	BossType.MOM_MAUSOLEUM,
	BossType.MOMS_HEART_MAUSOLEUM,
	BossType.SATAN,
	BossType.IT_LIVES,
	BossType.ISAAC,
	BossType.BLUE_BABY,
	BossType.THE_LAMB,
	BossType.MEGA_SATAN,
	BossType.ULTRA_GREED,
	BossType.HUSH,
	BossType.DELIRIUM,
	BossType.ULTRA_GREEDIER,
	BossType.DOGMA,
	BossType.BEAST
})
KEYS_TO_THE_KINGDOM.ENEMY_DEATH_EFFECTS = Mod:Set({
	EffectVariant.FLY_EXPLOSION,
	EffectVariant.MAGGOT_EXPLOSION,
	EffectVariant.ROCK_EXPLOSION,
	EffectVariant.POOP_EXPLOSION,
	EffectVariant.BIG_ROCK_EXPLOSION,
	EffectVariant.BLOOD_EXPLOSION,
	EffectVariant.BLOOD_GUSH,
	EffectVariant.BLOOD_PARTICLE,
	EffectVariant.BLOOD_SPLAT,
	EffectVariant.DUST_CLOUD
})
KEYS_TO_THE_KINGDOM.ENEMY_DEATH_SOUNDS = {
	SoundEffect.SOUND_ROCKET_BLAST_DEATH,
	SoundEffect.SOUND_DEATH_BURST_BONE,
	SoundEffect.SOUND_DEATH_BURST_LARGE,
	SoundEffect.SOUND_DEATH_BURST_SMALL,
	SoundEffect.SOUND_MEAT_JUMPS
}

--30fps * 30 = 30 seconds
KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN = 30 * 30
KEYS_TO_THE_KINGDOM.BOSS_FORGIVE_ATTEMPTS = 3
KEYS_TO_THE_KINGDOM.BOSS_FORGIVE_COOLDOWN = 60
KEYS_TO_THE_KINGDOM.MAX_CHARGES = Mod.ItemConfig:GetCollectible(KEYS_TO_THE_KINGDOM.ID).MaxCharges
KEYS_TO_THE_KINGDOM.COLLECTION_DISTANCE = 20 ^ 2
KEYS_TO_THE_KINGDOM.SPARE_TIMER = {
	[EntityType.ENTITY_BABY_PLUM] = KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN * 0.5
}

KEYS_TO_THE_KINGDOM.StatTable = {
	{ Name = "Damage",       Flag = CacheFlag.CACHE_DAMAGE,    Buff = 0.5,                       TempBuff = 0.1 },
	{ Name = "MaxFireDelay", Flag = CacheFlag.CACHE_FIREDELAY, Buff = -0.5 * 5,                  TempBuff = -0.1 * 5 }, -- MaxFireDelay buffs should be negative!
	{ Name = "TearRange",    Flag = CacheFlag.CACHE_RANGE,     Buff = 0.5 * Mod.RANGE_BASE_MULT, TempBuff = 0.1 * Mod.RANGE_BASE_MULT },
	{ Name = "ShotSpeed",    Flag = CacheFlag.CACHE_SHOTSPEED, Buff = 0.125,                     TempBuff = 0.025 },
	{ Name = "MoveSpeed",    Flag = CacheFlag.CACHE_SPEED,     Buff = 0.5,                       TempBuff = 0.1 },
	{ Name = "Luck",         Flag = CacheFlag.CACHE_LUCK,      Buff = 0.5,                       TempBuff = 0.1 }
}

local identifier = "FR_RAPTURE"
SEL.RegisterStatusEffect(identifier, nil, nil, nil, true)
KEYS_TO_THE_KINGDOM.STATUS_RAPTURE = SEL.StatusFlag[identifier]

local min = math.min

--#endregion

--#region Helpers

---@param ent Entity
---@param allowDead? boolean
function KEYS_TO_THE_KINGDOM:CanSpare(ent, allowDead)
	allowDead = allowDead or false
	return ent:ToNPC()
		and ent:IsActiveEnemy(allowDead)
		and (allowDead and not ent:IsInvincible() or ent:IsVulnerableEnemy())
		and not ent:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY)
		and ent:ToNPC().CanShutDoors
		and not SEL:HasStatusEffect(ent, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
		and not (Mod:TryGetData(ent) and Mod:GetData(ent).Raptured)
end

---@param ent EntityNPC | EntityPlayer
function KEYS_TO_THE_KINGDOM:OnStatusEffectAdd(ent)
	if not (ent:IsActiveEnemy(false) and ent:IsVulnerableEnemy() and ent:IsBoss()) then
		return true
	end
	local statusConfig = SEL:GetStatusEffectData(ent, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
	if statusConfig then
		--Don't both reapplying it so the timer won't get reset
		return true
	end
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT,
	KEYS_TO_THE_KINGDOM.OnStatusEffectAdd, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)

---@param player EntityPlayer
---@param ent Entity
function KEYS_TO_THE_KINGDOM:GetMaxRaptureCountdown(player, ent)
	if not ent:IsBoss() then
		return 0
	end
	local raptureCountdown = KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN
	if KEYS_TO_THE_KINGDOM.SPARE_TIMER[ent.Type] then
		raptureCountdown = KEYS_TO_THE_KINGDOM.SPARE_TIMER[ent.Type]
	end
	if player:GetPlayerType() == Mod.PlayerType.PETER and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		raptureCountdown = raptureCountdown * 0.5
	end
	return raptureCountdown
end

---Cannot remove a boss outright as it can cause unintended effects, such as the room continuing to play the boss fight music
---@param npc Entity
function KEYS_TO_THE_KINGDOM:RemoveBoss(npc)
	--Does just about nothing anyways
	npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
	npc:ClearEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
	npc:Die()
	Mod:DelayOneFrame(function()
		npc:GetSprite():SetLastFrame()
		Mod:DelayOneFrame(function()
			for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
				if KEYS_TO_THE_KINGDOM.ENEMY_DEATH_EFFECTS[effect.Variant]
					and effect.Position:DistanceSquared(npc.Position) <= (effect.Size + npc.Size + 25) ^ 2
				then
					effect:Remove()
				end
			end
			for _, soundID in ipairs(KEYS_TO_THE_KINGDOM.ENEMY_DEATH_SOUNDS) do
				Mod.SFXMan:Stop(soundID)
			end
		end)
	end)
	npc.Visible = false
end

---Raptures the enemy, spawning a spared soul and grants stats to the player who raptured it corresponding to whether or not it's a boss
---
---Will spawn the soul at the parent head if it happens to be a segmented enemy and remove the rest
---@param ent Entity
function KEYS_TO_THE_KINGDOM:RaptureEnemy(ent)
	local parent = SEL.Utils.GetLastParent(ent)
	local glow = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GROUND_GLOW, 0, parent.Position, Vector.Zero, nil)
	glow:GetSprite().PlaybackSpeed = 0.1
	local subtype = ent:IsBoss() and KEYS_TO_THE_KINGDOM.SPARED_SOUL_BOSS or KEYS_TO_THE_KINGDOM.SPARED_SOUL
	Isaac.Spawn(EntityType.ENTITY_EFFECT, KEYS_TO_THE_KINGDOM.EFFECT, subtype,
		parent.Position, Vector.Zero, nil)
	local currentEnt = parent
	local ptrHash = GetPtrHash(currentEnt)
	local loopedEntities = {
		[ptrHash] = true
	}

	if currentEnt.Child then
		currentEnt = currentEnt.Child
		ptrHash = GetPtrHash(currentEnt)
		--Clear up segmented enemies
		while not loopedEntities[ptrHash] and SEL.Utils.IsInParentChildChain(currentEnt) do
			local child = currentEnt.Child
			currentEnt:Remove()
			currentEnt = child
			ptrHash = GetPtrHash(currentEnt)
		end
	end
	if ent:IsBoss() then
		Mod:GetData(ent).Raptured = true
		KEYS_TO_THE_KINGDOM:RemoveBoss(parent)
	else
		parent:Remove()
	end
end

---Grants a number of random stat buffs from the Keys to the Kingdom StatBuff table
---@param player EntityPlayer
---@param rng RNG
---@param numStats integer @How many stat buffs to provide. Any other than 1 will provide a different stat. Cannot be more than 6
---@param isTemp boolean @If set to true, will pull from the temporary stat pool and only last for the floor
function KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, rng, numStats, isTemp)
	numStats = min(6, numStats)
	local varName = "KeysToTheKingdomStatBonus"
	if isTemp then
		varName = varName .. "_Temp"
	end
	local selectedStats = {}
	for _ = 1, numStats do
		local randomStatIndex = Mod:GetDifferentRandomKey(selectedStats, KEYS_TO_THE_KINGDOM.StatTable, rng)
		selectedStats[randomStatIndex] = true
		local key = tostring(randomStatIndex)
		local player_save = isTemp and Mod:FloorSave(player) or Mod:RunSave(player)
		player_save[varName] = player_save[varName] or {}
		player_save[varName][key] = (player_save[varName][key] or 0) + 1
	end
end

--#endregion

--#region On use, spare enemies and start sparing bosses

---@param rng RNG
---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:OnUse(itemID, rng, player, flags, slot)
	local room = Mod.Room()

	if KEYS_TO_THE_KINGDOM:DenyHisOfferings(player) then
		return true
	elseif room:GetAliveEnemiesCount() == 0 then
		return { Discharge = false, ShowAnim = false, Remove = false }
	elseif KEYS_TO_THE_KINGDOM.STORY_BOSS_IDS[room:GetBossID()]
		or player:GetPlayerType() == Mod.PlayerType.PETER
		and (room:GetType() == RoomType.ROOM_BOSSRUSH
			or room:GetType() == RoomType.ROOM_CHALLENGE)
	then
		player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true)
		return true
	else
		local raptureCountdown = KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN
		if player:GetPlayerType() == Mod.PlayerType.PETER and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			raptureCountdown = raptureCountdown * 0.5
		end
		local source = EntityRef(player)
		Mod:inverseiforeach(Isaac.GetRoomEntities(), function(ent)
			local canSpare = KEYS_TO_THE_KINGDOM:CanSpare(ent)
			local npc = ent:ToNPC()
			local data = Mod:TryGetData(ent)
			if canSpare and ent:IsBoss() and npc and (not data or not data.FailedRapture) then
				local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.PRE_START_RAPTURE_BOSS, npc.Type, npc, player, rng, flags, slot)
				if result then
					return
				end
				local spotlight = Isaac.Spawn(EntityType.ENTITY_EFFECT, KEYS_TO_THE_KINGDOM.EFFECT,
					KEYS_TO_THE_KINGDOM.SPOTLIGHT,
					ent.Position, Vector.Zero, ent):ToEffect()
				---@cast spotlight EntityEffect
				spotlight.Parent = ent
				spotlight:FollowParent(ent)
				spotlight:GetSprite().Scale = Vector(1.25, 1.25)
				SEL:AddStatusEffect(ent, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE, raptureCountdown, source, nil,
					{ Spotlight = spotlight, FailedAttempts = 0, FailedAttemptsCooldown = 0 })
			elseif canSpare and ent:Exists() then
				KEYS_TO_THE_KINGDOM:RaptureEnemy(ent)
				KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, rng, 1, true)
			end
		end)
	end
	player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, KEYS_TO_THE_KINGDOM.OnUse, KEYS_TO_THE_KINGDOM.ID)

--#endregion

--#region Spare stat buffs

---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:TempStatBuffs(player, flag)
	local player_floor_save = Mod:FloorSave(player)
	if not player_floor_save.KeysToTheKingdomStatBonus_Temp then return end

	for i, buffCount in pairs(player_floor_save.KeysToTheKingdomStatBonus_Temp) do
		local stat = KEYS_TO_THE_KINGDOM.StatTable[tonumber(i)]

		if stat.Flag == flag then
			player[stat.Name] = player[stat.Name] + buffCount * stat.TempBuff
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, KEYS_TO_THE_KINGDOM.TempStatBuffs)

---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:StatBuffs(player, flag)
	local player_run_save = Mod:RunSave(player)
	if not player_run_save.KeysToTheKingdomStatBonus then return end

	for i, buffCount in pairs(player_run_save.KeysToTheKingdomStatBonus) do
		local stat = KEYS_TO_THE_KINGDOM.StatTable[tonumber(i)]

		if stat.Flag == flag then
			player[stat.Name] = player[stat.Name] + buffCount * stat.Buff
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, KEYS_TO_THE_KINGDOM.StatBuffs)

---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:OnNewLevel(player)
	local player_floor_save = Mod.SaveManager.TryGetFloorSave(player)
	if player_floor_save
		and player_floor_save.KeysToTheKingdomStatBonus_Temp
	then
		player_floor_save.KeysToTheKingdomStatBonus_Temp = nil
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, KEYS_TO_THE_KINGDOM.OnNewLevel)

--#endregion

--#region Dropping soul charges on death

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:OnDeath(npc)
	if not KEYS_TO_THE_KINGDOM:CanSpare(npc, true) then return end
	if npc:IsBoss() then
		Mod:ForEachPlayer(function(player)
			local slots = Mod:GetActiveItemCharges(player, KEYS_TO_THE_KINGDOM.ID)
			if #slots == 0 then return end
			for _, slotData in ipairs(slots) do
				if slotData.Charge < KEYS_TO_THE_KINGDOM.MAX_CHARGES then
					local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, KEYS_TO_THE_KINGDOM.EFFECT,
						KEYS_TO_THE_KINGDOM.SOUL_BOSS,
						npc.Position, RandomVector():Resized(5), npc)
					effect.Target = player
					break
				end
			end
		end)
	else
		Mod:ForEachPlayer(function(player)
			local slots = Mod:GetActiveItemCharges(player, KEYS_TO_THE_KINGDOM.ID)
			if #slots == 0 then return end
			for _, slotData in ipairs(slots) do
				if slotData.Charge < KEYS_TO_THE_KINGDOM.MAX_CHARGES then
					local rng = player:GetCollectibleRNG(KEYS_TO_THE_KINGDOM.ID)
					local chance = rng:RandomFloat()
					local maxChance = (npc.MaxHitPoints * 2.5) / 100
					if chance <= maxChance then
						local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, KEYS_TO_THE_KINGDOM.EFFECT,
							KEYS_TO_THE_KINGDOM.SOUL,
							npc.Position, RandomVector():Resized(5), npc)
						effect.Target = player
					end
					break
				end
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, KEYS_TO_THE_KINGDOM.OnDeath)

--#endregion

--#region Keys to the Kingdom Effects

--#region On Update

---@param effect EntityEffect
function KEYS_TO_THE_KINGDOM:SoulUpdate(effect)
	local player = effect.Target and effect.Target:ToPlayer()
	if not player then
		effect:Remove()
		return
	end

	effect.Velocity = (effect.Velocity + (((player.Position - effect.Position):Normalized() * 20) - effect.Velocity) * 0.4)

	if effect.Position:DistanceSquared(player.Position) > KEYS_TO_THE_KINGDOM.COLLECTION_DISTANCE then return end

	effect:Remove()

	local slots = Mod:GetActiveItemCharges(player, KEYS_TO_THE_KINGDOM.ID)
	if #slots == 0 then return end
	for _, slotData in ipairs(slots) do
		if slotData.Charge < KEYS_TO_THE_KINGDOM.MAX_CHARGES then
			player:AddActiveCharge(effect.SubType, slotData.Slot, true, false, true)
			player:SetColor(Color(1, 1, 1, 1, 0.25, 0.25, 0.25), 5, 1, true, false)
			Mod.SFXMan:Play(SoundEffect.SOUND_SOUL_PICKUP)
			break
		end
	end
end

---@param effect EntityEffect
function KEYS_TO_THE_KINGDOM:SoulTrailUpdate(effect)
	local parent = effect.Parent and effect.Parent:ToEffect()
	if parent and parent.Variant == KEYS_TO_THE_KINGDOM.EFFECT then
		local sprite = parent:GetSprite()
		effect.Position = parent.Position + sprite:GetNullFrame("*Trail"):GetPos()
		if not parent:Exists() then
			effect:Remove()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, KEYS_TO_THE_KINGDOM.SoulTrailUpdate, EffectVariant.SPRITE_TRAIL)

---@param effect EntityEffect
function KEYS_TO_THE_KINGDOM:SparedSoulUpdate(effect)
	local sprite = effect:GetSprite()
	local anim = "Spared"
	local suffix = ""
	local soundID = SoundEffect.SOUND_HOLY
	if effect.SubType == KEYS_TO_THE_KINGDOM.SPARED_SOUL_BOSS then
		suffix = "Boss"
		soundID = SoundEffect.SOUND_DOGMA_ANGEL_TRANSFORM_END
	end
	local animation = anim .. suffix

	if not sprite:IsPlaying(animation) then
		sprite:Play(animation)
	end

	if sprite:IsEventTriggered("Sound") then
		Mod.SFXMan:Play(soundID, 1.2)
	end

	if sprite:IsFinished(animation) then
		effect:Remove()
	end
end

---@param effect EntityEffect
function KEYS_TO_THE_KINGDOM:SpotlightUpdate(effect)
	local sprite = effect:GetSprite()
	if not effect.Parent and not sprite:IsPlaying("LightDisappear") and effect.Timeout <= 0 then
		sprite:Play("LightDisappear")
	end
	if effect.Timeout > 0 then
		local scale = sprite.Scale
		scale:Lerp(Vector(1.25, 1.25), 0.05)
		sprite.Scale = scale
	end
	if sprite:IsFinished("LightDisappear") then
		effect:Remove()
	end
end

---@param effect EntityEffect
function KEYS_TO_THE_KINGDOM:OnEffectUpdate(effect)
	if effect.SubType == KEYS_TO_THE_KINGDOM.SOUL
		or effect.SubType == KEYS_TO_THE_KINGDOM.SOUL_BOSS
	then
		KEYS_TO_THE_KINGDOM:SoulUpdate(effect)
	elseif effect.SubType == KEYS_TO_THE_KINGDOM.SPARED_SOUL
		or effect.SubType == KEYS_TO_THE_KINGDOM.SPARED_SOUL_BOSS
	then
		KEYS_TO_THE_KINGDOM:SparedSoulUpdate(effect)
	elseif effect.SubType == KEYS_TO_THE_KINGDOM.SPOTLIGHT then
		KEYS_TO_THE_KINGDOM:SpotlightUpdate(effect)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, KEYS_TO_THE_KINGDOM.OnEffectUpdate, KEYS_TO_THE_KINGDOM.EFFECT)

--#endregion

--#region On Init

---@param effect EntityEffect
function KEYS_TO_THE_KINGDOM:SoulInit(effect)
	local sprite = effect:GetSprite()
	local spriteTrail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0,
		effect.Position, Vector.Zero, effect):ToEffect()
	---@cast spriteTrail EntityEffect
	spriteTrail.Parent = effect
	spriteTrail.MinRadius = 0.15
	spriteTrail.SpriteScale = Vector(1.15, 1.15)
	sprite:SetRenderFlags(AnimRenderFlags.ENABLE_NULL_LAYER_LIGHTING)
	local anim = "Move"
	local animType = ""
	effect.SpriteScale = Vector(1.1, 1.1)
	if effect.SubType == KEYS_TO_THE_KINGDOM.SOUL_BOSS then
		animType = "Boss"
		spriteTrail.Color = Color(1, 0.08, 0.15, 1)
	end
	sprite:Play(anim .. animType)
end

---@param effect EntityEffect
function KEYS_TO_THE_KINGDOM:SparedSoulInit(effect)
	local sprite = effect:GetSprite()
	sprite:SetRenderFlags(AnimRenderFlags.ENABLE_NULL_LAYER_LIGHTING)
	local anim = "Spared"
	local animType = ""
	if effect.SubType == KEYS_TO_THE_KINGDOM.SOUL_BOSS then
		animType = "Boss"
	end
	sprite:Play(anim .. animType)
end

---@param effect EntityEffect
function KEYS_TO_THE_KINGDOM:SpotlightInit(effect)
	effect:GetSprite():Play("LightAppear")
end

---@param effect EntityEffect
function KEYS_TO_THE_KINGDOM:OnEffectInit(effect)
	if effect.SubType == KEYS_TO_THE_KINGDOM.SOUL
		or effect.SubType == KEYS_TO_THE_KINGDOM.SOUL_BOSS
	then
		KEYS_TO_THE_KINGDOM:SoulInit(effect)
	elseif effect.SubType == KEYS_TO_THE_KINGDOM.SPARED_SOUL
		or effect.SubType == KEYS_TO_THE_KINGDOM.SPARED_SOUL_BOSS
	then
		KEYS_TO_THE_KINGDOM:SparedSoulInit(effect)
	elseif effect.SubType == KEYS_TO_THE_KINGDOM.SPOTLIGHT then
		KEYS_TO_THE_KINGDOM:SpotlightInit(effect)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, KEYS_TO_THE_KINGDOM.OnEffectInit, KEYS_TO_THE_KINGDOM.EFFECT)

--#endregion

--#endregion

--#region Sparing bosses

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:RaptureBossUpdate(npc)
	local statusData = SEL:GetStatusEffectData(npc, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
	---@cast statusData StatusEffectData
	local customData = statusData.CustomData
	local countdown = statusData.Countdown
	---@type EntityEffect
	local spotlight = customData.Spotlight
	if customData.FailedAttemptsCooldown > 0 then
		customData.FailedAttemptsCooldown = customData.FailedAttemptsCooldown - 1
	end
	local whiteColor = 0.45 - (countdown / 2000)
	spotlight:GetSprite().Scale = Vector(0.25 + (countdown / KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN), 1.25)
	spotlight:SetColor(Color(1, 1, 1, 1, whiteColor, whiteColor, whiteColor), 1, 2, true, false)
	if countdown <= 30 then
		if countdown == 30 then
			Mod.SFXMan:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE)
		end
		local raptureOffset = 2 * (1 - (countdown / 30))
		local c = npc:GetColor()
		npc:SetColor(Color(c.R, c.G, c.B, c.A, raptureOffset, raptureOffset, raptureOffset), 2, 10, true, true)
	end
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.ENTITY_STATUS_EFFECT_UPDATE, KEYS_TO_THE_KINGDOM.RaptureBossUpdate,
	KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:RaptureBoss(npc)
	local statusData = SEL:GetStatusEffectData(npc, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
	---@cast statusData StatusEffectData
	if statusData.CustomData.FailRapture then return end
	Mod.SFXMan:Play(SoundEffect.SOUND_LIGHTBOLT, 2)
	--for i = 1, 30 do
	--local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, npc.Position, RandomVector():Resized(2), nil):ToEffect()
	--effect.Timeout = 30
	--effect.PositionOffset = Vector(Mod:RandomNum(-npc.Size/2, npc.Size/2), Mod:RandomNum(-npc.Size, 0))
	--end
	local spotlight = statusData.CustomData.Spotlight
	spotlight.Timeout = 60
	KEYS_TO_THE_KINGDOM:RaptureEnemy(npc)
	Mod:ForEachPlayer(function(player)
		if player:HasCollectible(KEYS_TO_THE_KINGDOM.ID) then
			local numStats = 2
			if player:GetPlayerType() == Mod.PlayerType.PETER and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				numStats = 3
			end
			KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, player:GetCollectibleRNG(KEYS_TO_THE_KINGDOM.ID), numStats, false)
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end
	end)
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.PRE_REMOVE_ENTITY_STATUS_EFFECT, KEYS_TO_THE_KINGDOM.RaptureBoss,
	KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)

---@param player EntityPlayer
---@param npc EntityNPC
---@param statusData StatusEffectData
function KEYS_TO_THE_KINGDOM:SkillIssue(player, npc, statusData)
	local customData = statusData.CustomData
	if customData.FailedAttemptsCooldown > 0 then return end
	customData.FailedAttempts = customData.FailedAttempts + 1
	if customData.FailedAttempts < KEYS_TO_THE_KINGDOM.BOSS_FORGIVE_ATTEMPTS then
		customData.FailedAttemptsCooldown = KEYS_TO_THE_KINGDOM.BOSS_FORGIVE_COOLDOWN
		local maxCountdown = KEYS_TO_THE_KINGDOM:GetMaxRaptureCountdown(player, npc)
		statusData.Countdown = min(maxCountdown, statusData.Countdown + (maxCountdown / 3))
		Mod.SFXMan:Play(SoundEffect.SOUND_THUMBS_DOWN)
	else
		customData.FailRapture = true
		Mod:GetData(npc).FailedRapture = true
		customData.Spotlight:GetSprite():Play("LightDisappear")
		Mod.SFXMan:Play(SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED)
		SEL:RemoveStatusEffect(npc, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
	end
end

---@param ent Entity
---@param source EntityRef
function KEYS_TO_THE_KINGDOM:ResetRaptureStatusOnHit(ent, _, _, source, _)
	local statusData = SEL:GetStatusEffectData(ent, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
	local npc = ent:ToNPC()
	if statusData
		and npc
		and source.Entity
		--Ignore friendly enemies and familiars since you don't really control them
		and not source.Entity:ToNPC()
		and not source.Entity:ToFamiliar()
	then
		local player = source.Entity:ToPlayer() or source.Entity.SpawnerEntity and source.Entity.SpawnerEntity:ToPlayer()
		if player then
			KEYS_TO_THE_KINGDOM:SkillIssue(player, npc, statusData)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, KEYS_TO_THE_KINGDOM.ResetRaptureStatusOnHit)

---@param ent Entity
---@param source EntityRef
function KEYS_TO_THE_KINGDOM:ResetRaptureStatusOnDamage(ent, _, _, source, _)
	local player = ent:ToPlayer()
	if player and source.Entity then
		local npc = source.Entity:ToNPC() or source.Entity.SpawnerEntity and source.Entity.SpawnerEntity:ToNPC()
		local statusData = npc and SEL:GetStatusEffectData(npc, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
		if statusData and npc then
			KEYS_TO_THE_KINGDOM:SkillIssue(player, npc, statusData)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, KEYS_TO_THE_KINGDOM.ResetRaptureStatusOnDamage,
	EntityType.ENTITY_PLAYER)

--#endregion

--#region Unique Rapture death interactions (basically just Krampus)

local raptureDeathQueue = {}

---Apparently POST_NPC_DEATH runs A F T E R POST_ENTITY_REMOVE which is when I remove my custom data. Awesome.
function KEYS_TO_THE_KINGDOM:RaptureBossDeath(ent)
	if ent:IsBoss() then
		local data = Mod:TryGetData(ent)
		if data and data.Raptured then
			raptureDeathQueue[GetPtrHash(ent)] = true
			Mod:DelayOneFrame(function() raptureDeathQueue[GetPtrHash(ent)] = false end)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, KEYS_TO_THE_KINGDOM.RaptureBossDeath)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:PostRaptureDeath(npc)
	if raptureDeathQueue[GetPtrHash(npc)] then
		Isaac.RunCallbackWithParam(Mod.ModCallbacks.POST_RAPTURE_BOSS_DEATH, npc.Type, npc)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, KEYS_TO_THE_KINGDOM.PostRaptureDeath, EntityType.ENTITY_FALLEN)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:PostKrampusRapture(npc)
	if npc.Variant ~= 1 then return end
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
		if ent.FrameCount == 0
			and (ent.SubType == CollectibleType.COLLECTIBLE_LUMP_OF_COAL
				or ent.SubType == CollectibleType.COLLECTIBLE_HEAD_OF_KRAMPUS)
		then
			local itemPool = Mod.Game:GetItemPool()
			local pickup = ent:ToPickup()
			---@cast pickup EntityPickup
			local newItem = itemPool:GetCollectible(ItemPoolType.POOL_DEVIL, true, npc.DropSeed,
				CollectibleType.COLLECTIBLE_LUMP_OF_COAL)
			pickup:Morph(ent.Type, ent.Variant, newItem)
			break
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, KEYS_TO_THE_KINGDOM.PostKrampusRapture, EntityType.ENTITY_FALLEN)

--#endregion

--#region Alabaster Scrap + Angel interaction

---@param npc EntityNPC
---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:SpareAngels(npc, player)
	if player:HasTrinket(Mod.Trinket.ALABASTER_SCRAP.ID) then
		local data = Mod:GetData(npc)
		if not data.KTTKSparedAngel then
			Mod:GetData(npc).KTTKSparedAngel = true
			npc:GetSprite():Play("Appear")
			npc:GetSprite():SetLastFrame()
			npc.Friction = 0
			npc.Velocity = Vector.Zero
			Mod.SFXMan:Play(SoundEffect.SOUND_THUMBSUP)
		end
		return true
	end
end

Mod:AddCallback(Mod.ModCallbacks.PRE_START_RAPTURE_BOSS, KEYS_TO_THE_KINGDOM.SpareAngels, EntityType.ENTITY_GABRIEL)
Mod:AddCallback(Mod.ModCallbacks.PRE_START_RAPTURE_BOSS, KEYS_TO_THE_KINGDOM.SpareAngels, EntityType.ENTITY_URIEL)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:ReverseAppear(npc)
	local data = Mod:TryGetData(npc)
	if data and data.KTTKSparedAngel then
		npc.Velocity = Vector.Zero
		local sprite = npc:GetSprite()
		local previousFrame = sprite:GetFrame() - 2
		sprite:SetFrame(previousFrame)
		if previousFrame == 0 then
			local angelKey = npc.Type == EntityType.ENTITY_URIEL and CollectibleType.COLLECTIBLE_KEY_PIECE_1 or
			CollectibleType.COLLECTIBLE_KEY_PIECE_2
			local otherKey = npc.Type == EntityType.ENTITY_URIEL and CollectibleType.COLLECTIBLE_KEY_PIECE_2 or
			CollectibleType.COLLECTIBLE_KEY_PIECE_1
			local itemID
			if not PlayerManager.AnyoneHasCollectible(angelKey) then
				itemID = angelKey
			elseif not PlayerManager.AnyoneHasCollectible(otherKey) then
				itemID = otherKey
			else
				itemID = Mod.Game:GetItemPool():GetCollectible(ItemPoolType.POOL_ANGEL, true,
					PlayerManager.FirstCollectibleOwner(KEYS_TO_THE_KINGDOM.ID):GetCollectibleRNG(KEYS_TO_THE_KINGDOM.ID)
					:Next(), nil)
			end
			Mod.SFXMan:Play(SoundEffect.SOUND_HOLY)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemID,
				Mod.Room():FindFreePickupSpawnPosition(npc.Position), Vector.Zero, npc)
			KEYS_TO_THE_KINGDOM:RemoveBoss(npc)
		end
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.IMPORTANT, KEYS_TO_THE_KINGDOM.ReverseAppear,
	EntityType.ENTITY_GABRIEL)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.IMPORTANT, KEYS_TO_THE_KINGDOM.ReverseAppear,
	EntityType.ENTITY_URIEL)

--#endregion

--#region Alabaster Scrap + Devil interaction

---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:DenyHisOfferings(player)
	if Mod.Room():GetType() == RoomType.ROOM_DEVIL
		and player:HasTrinket(Mod.Trinket.ALABASTER_SCRAP.ID)
	then
		Mod:inverseiforeach(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE), function(ent)
			local pickup = ent:ToPickup()
			---@cast pickup EntityPickup
			if pickup:IsShopItem() then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 10, pickup.Position, Vector.Zero, nil)
				Mod.SFXMan:Play(SoundEffect.SOUND_LIGHTBOLT)
				pickup:Remove()
				player:AddNullItemEffect(KEYS_TO_THE_KINGDOM.DEVIL_NULL_ID, false)
			end
		end)
		return true
	end
end

---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:StatsOnNextFloor(player)
	local effectNum = player:GetEffects():GetNullEffectNum(KEYS_TO_THE_KINGDOM.DEVIL_NULL_ID)
	if effectNum > 0 then
		Mod:DelayOneFrame(function()
			KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, player:GetCollectibleRNG(KEYS_TO_THE_KINGDOM.ID), effectNum, false)
			Mod.SFXMan:Play(SoundEffect.SOUND_HOLY)
		end)
		player:GetEffects():RemoveNullEffect(KEYS_TO_THE_KINGDOM.DEVIL_NULL_ID, -1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, KEYS_TO_THE_KINGDOM.StatsOnNextFloor)

--#endregion
