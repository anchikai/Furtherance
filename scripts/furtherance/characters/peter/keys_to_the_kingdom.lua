--#region Variables

local Mod = Furtherance
local SEL = StatusEffectLibrary
local PETER = Mod.Character.PETER

local KEYS_TO_THE_KINGDOM = {}

Furtherance.Item.KEYS_TO_THE_KINGDOM = KEYS_TO_THE_KINGDOM

KEYS_TO_THE_KINGDOM.ID = Isaac.GetItemIdByName("Keys to the Kingdom")
KEYS_TO_THE_KINGDOM.EFFECT = Isaac.GetEntityVariantByName("Keys to the Kingdom Effects")

--SubTypes of the Effect
KEYS_TO_THE_KINGDOM.SOUL = 1
KEYS_TO_THE_KINGDOM.SOUL_MINIBOSS = 2
KEYS_TO_THE_KINGDOM.SOUL_BOSS = 3
KEYS_TO_THE_KINGDOM.SPARED_SOUL = 100
KEYS_TO_THE_KINGDOM.SPARED_SOUL_BOSS = 101
KEYS_TO_THE_KINGDOM.SPOTLIGHT = 200

local raptureHits = 0
local raptureHitCooldown = 0

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
	EffectVariant.DUST_CLOUD,
	EffectVariant.FART
})
KEYS_TO_THE_KINGDOM.ENEMY_DEATH_SOUNDS = {
	SoundEffect.SOUND_ROCKET_BLAST_DEATH,
	SoundEffect.SOUND_DEATH_BURST_BONE,
	SoundEffect.SOUND_DEATH_BURST_LARGE,
	SoundEffect.SOUND_DEATH_BURST_SMALL,
	SoundEffect.SOUND_MEAT_JUMPS,
	SoundEffect.SOUND_FART_GURG,
	SoundEffect.SOUND_FART
}
KEYS_TO_THE_KINGDOM.MINIBOSS = Mod:Set({
	tostring(EntityType.ENTITY_SLOTH) .. ".0.0",
	tostring(EntityType.ENTITY_LUST) .. ".0.0",
	tostring(EntityType.ENTITY_WRATH) .. ".0.0",
	tostring(EntityType.ENTITY_GLUTTONY) .. ".0.0",
	tostring(EntityType.ENTITY_GREED) .. ".0.0",
	tostring(EntityType.ENTITY_ENVY) .. ".0.0",
	tostring(EntityType.ENTITY_PRIDE) .. ".0.0",
})
KEYS_TO_THE_KINGDOM.ENTITY_BLACKLIST = {}

--30fps * 30 = 30 seconds
KEYS_TO_THE_KINGDOM.MINIBOSS_RAPTURE_COUNTDOWN = 30 * 20
KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN = 30 * 30
KEYS_TO_THE_KINGDOM.DEBUG_SPARE = false
KEYS_TO_THE_KINGDOM.BOSS_FORGIVE_ATTEMPTS = 3
KEYS_TO_THE_KINGDOM.BOSS_FORGIVE_COOLDOWN = 60
KEYS_TO_THE_KINGDOM.MAX_CHARGES = Mod.ItemConfig:GetCollectible(KEYS_TO_THE_KINGDOM.ID).MaxCharges
KEYS_TO_THE_KINGDOM.COLLECTION_DISTANCE = 20 ^ 2
KEYS_TO_THE_KINGDOM.SPARE_TIMER = {
	[EntityType.ENTITY_BABY_PLUM] = KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN * 0.5
}

KEYS_TO_THE_KINGDOM.StatTable = {
	{ Name = "Damage",       Flag = CacheFlag.CACHE_DAMAGE,    Buff = 0.25,                       TempBuff = 0.1 },
	{ Name = "MaxFireDelay", Flag = CacheFlag.CACHE_FIREDELAY, Buff = -0.25,                  TempBuff = -0.1 }, -- MaxFireDelay buffs should be negative!
	{ Name = "TearRange",    Flag = CacheFlag.CACHE_RANGE,     Buff = 0.5 * Mod.RANGE_BASE_MULT, TempBuff = 0.1 * Mod.RANGE_BASE_MULT },
	{ Name = "ShotSpeed",    Flag = CacheFlag.CACHE_SHOTSPEED, Buff = 0.125,                     TempBuff = 0.025 },
	{ Name = "MoveSpeed",    Flag = CacheFlag.CACHE_SPEED,     Buff = 0.2,                       TempBuff = 0.1 },
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
		and not ent:IsInvincible()
		and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		and ent:ToNPC().CanShutDoors
		and not SEL:HasStatusEffect(ent, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
		and not (Mod:TryGetData(ent) and Mod:GetData(ent).Raptured)
		and not KEYS_TO_THE_KINGDOM.ENTITY_BLACKLIST[Mod:GetTypeVarSubFromEnt(ent, true)]
end

---@param ent EntityNPC | EntityPlayer
function KEYS_TO_THE_KINGDOM:OnStatusEffectAdd(ent)
	if not ent:IsActiveEnemy(false) or ent:IsInvincible() or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		return true
	end
	if SEL:HasStatusEffect(ent, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE) then
		--Don't reapply it so the timer won't get reset
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
	if KEYS_TO_THE_KINGDOM.DEBUG_SPARE then
		return 30 * 3
	end
	local raptureCountdown = KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN
	if KEYS_TO_THE_KINGDOM.MINIBOSS[Mod:GetTypeVarSubFromEnt(ent, true)] then
		raptureCountdown = KEYS_TO_THE_KINGDOM.MINIBOSS_RAPTURE_COUNTDOWN
	elseif KEYS_TO_THE_KINGDOM.SPARE_TIMER[ent.Type] then
		raptureCountdown = KEYS_TO_THE_KINGDOM.SPARE_TIMER[ent.Type]
	end
	if PETER:IsPeter(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		raptureCountdown = raptureCountdown * 0.5
	end
	return raptureCountdown
end

local function cease(npc)
	Mod.Foreach.EffectInRadius(npc.Position, npc.Size + 40,
		function(effect, index)
			if KEYS_TO_THE_KINGDOM.ENEMY_DEATH_EFFECTS[effect.Variant]
				and (not Mod:TryGetData(effect) or not Mod:GetData(effect).RaptureCloud)
			then
				effect:Remove()
			end
		end, nil, nil, { Inverse = true })
	for _, soundID in ipairs(KEYS_TO_THE_KINGDOM.ENEMY_DEATH_SOUNDS) do
		Mod.SFXMan:Stop(soundID)
	end
	Mod.Foreach.Projectile(function(projectile, index)
		if projectile.SpawnerType == npc.Type and projectile.FrameCount < 2 then
			projectile:Remove()
		end
	end, nil, nil, { Inverse = true })
end

---Cannot remove a boss outright as it can cause unintended effects, such as the room continuing to play the boss fight music
---@param npc Entity
function KEYS_TO_THE_KINGDOM:RemoveBoss(npc)
	--Does just about nothing anyways
	npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
	npc:ClearEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
	npc:Kill()
	npc:ToNPC().State = NpcState.STATE_DEATH
	npc:Update()
	npc:GetSprite():SetLastFrame()
	npc:Update()
	cease(npc)
	Mod:DelayOneFrame(function()
		npc:GetSprite():SetLastFrame()
		cease(npc)
		if not npc:IsDead() then
			npc.Visible = true
		end
		Mod:DelayOneFrame(function()
			cease(npc)
		end)
	end)
	npc.Visible = false
	Mod.SFXMan:StopLoopingSounds()
end

---Raptures the enemy, spawning a spared soul and grants stats to the player who raptured it corresponding to whether or not it's a boss
---
---Will spawn the soul at the parent head if it happens to be a segmented enemy and remove the rest
---@param ent Entity
function KEYS_TO_THE_KINGDOM:RaptureEnemy(ent)
	local parent = SEL.Utils.GetLastParent(ent)
	local subtype = ent:IsBoss() and KEYS_TO_THE_KINGDOM.SPARED_SOUL_BOSS or KEYS_TO_THE_KINGDOM.SPARED_SOUL
	Isaac.Spawn(EntityType.ENTITY_EFFECT, KEYS_TO_THE_KINGDOM.EFFECT, subtype,
		parent.Position, Vector.Zero, nil)
	local currentEnt = parent.Child
	local loopedEntities = {}

	--Clear up segmented enemies
	while currentEnt and not loopedEntities[GetPtrHash(currentEnt)] and SEL.Utils.IsInParentChildChain(currentEnt) do
		local child = currentEnt.Child
		currentEnt:Remove()
		currentEnt = child
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
	player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
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
		or PETER:IsPeter(player)
		and (room:GetType() == RoomType.ROOM_BOSSRUSH
			or room:GetType() == RoomType.ROOM_CHALLENGE)
	then
		player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true)
		return true
	else
		local source = EntityRef(player)
		Mod.Foreach.NPC(function(npc)
			npc = SEL.Utils.GetLastParent(npc)
			local canSpare = KEYS_TO_THE_KINGDOM:CanSpare(npc)
			local data = Mod:TryGetData(npc)
			if canSpare and npc:IsBoss() and npc and (not data or not data.FailedRapture) then
				local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.PRE_START_RAPTURE_BOSS, npc.Type, npc, player, rng, flags, slot)
				if result then
					return
				end
				local raptureCountdown = KEYS_TO_THE_KINGDOM:GetMaxRaptureCountdown(player, npc)
				local dataTable = { FailedAttempts = 0, FailedAttemptsCooldown = 0, MaxCountdown = raptureCountdown }
				local addedStatus = SEL:AddStatusEffect(npc, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE, raptureCountdown, source, nil, dataTable)
				if addedStatus then
					local spotlight = Mod.Spawn.Effect(KEYS_TO_THE_KINGDOM.EFFECT, KEYS_TO_THE_KINGDOM.SPOTLIGHT, npc.Position, nil, npc)
					spotlight.Parent = npc
					spotlight:FollowParent(npc)
					spotlight:GetSprite().Scale = Vector(1.25, 1.25)
					dataTable.Spotlight = EntityPtr(spotlight)
				end
			elseif canSpare and npc:Exists() then
				KEYS_TO_THE_KINGDOM:RaptureEnemy(npc)
				if npc.SpawnerType == EntityType.ENTITY_NULL then
					KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, rng, 1, true)
				end
			end
		end, nil, nil, nil, { Inverse = true })
	end
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
---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:SpawnBossSoulCharge(npc, player)
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, KEYS_TO_THE_KINGDOM.EFFECT,
		KEYS_TO_THE_KINGDOM.SOUL_BOSS,
		npc.Position, RandomVector():Resized(5), npc)
	effect.Target = player
end

---@param npc EntityNPC
---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:SpawnEnemySoulCharge(npc, player)
	local rng = player:GetCollectibleRNG(KEYS_TO_THE_KINGDOM.ID)
	local chance = rng:RandomFloat()
	local maxChance = (npc.MaxHitPoints * 2.5) / 100
	if chance <= maxChance then
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, KEYS_TO_THE_KINGDOM.EFFECT,
			KEYS_TO_THE_KINGDOM.SOUL,
			npc.Position, RandomVector():Resized(5), npc)
		effect.Target = player
	end
end

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:OnDeath(npc)
	if not PlayerManager.AnyoneHasCollectible(KEYS_TO_THE_KINGDOM.ID) or not KEYS_TO_THE_KINGDOM:CanSpare(npc, true) then return end
	Mod.Foreach.Player(function(player)
		local slots = Mod:GetActiveItemCharges(player, KEYS_TO_THE_KINGDOM.ID)
		if #slots == 0 then return end
		for _, slotData in ipairs(slots) do
			if slotData.Charge < KEYS_TO_THE_KINGDOM.MAX_CHARGES then
				if npc:IsBoss() and not (Mod:GetData(npc) and Mod:GetData(npc).Raptured) then
					KEYS_TO_THE_KINGDOM:SpawnBossSoulCharge(npc, player)
				else
					KEYS_TO_THE_KINGDOM:SpawnEnemySoulCharge(npc, player)
				end
				break
			end
		end
	end)
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

	effect:Remove()
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
	if ((effect.Parent and not SEL:HasStatusEffect(effect.Parent, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE))
			or (not effect.Parent and effect.Timeout <= 0))
		and not sprite:IsPlaying("LightDisappear")
	then
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
	if effect.SubType >= KEYS_TO_THE_KINGDOM.SOUL
		and effect.SubType <= KEYS_TO_THE_KINGDOM.SOUL_BOSS
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
	if effect.SubType == KEYS_TO_THE_KINGDOM.SOUL_MINIBOSS
		or effect.SubType == KEYS_TO_THE_KINGDOM.SOUL_BOSS
	then
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
	if effect.SubType == KEYS_TO_THE_KINGDOM.SPARED_SOUL_BOSS then
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
	if effect.SubType >= KEYS_TO_THE_KINGDOM.SOUL
		and effect.SubType <= KEYS_TO_THE_KINGDOM.SOUL_BOSS
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
	---@type EntityPtr
	local ptr = customData.Spotlight
	local spotlight = ptr and ptr.Ref

	if spotlight then
		local whiteColor = 0.45 - (countdown / 2000)
		spotlight:GetSprite().Scale = Vector(0.25 + (countdown / customData.MaxCountdown), 1.25)
		spotlight:SetColor(Color(1, 1, 1, 1, whiteColor, whiteColor, whiteColor), 1, 2, true, false)
	end

	if raptureHitCooldown > 0 then
		raptureHitCooldown = raptureHitCooldown - 1
	end

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

	Mod.SFXMan:Play(SoundEffect.SOUND_ANGEL_WING, 2, 2, false, 0.75)

	KEYS_TO_THE_KINGDOM:RaptureEnemy(npc)

	for _ = 1, 15 do
		local effect = Mod.Spawn.Effect(EffectVariant.DUST_CLOUD, 0, npc.Position, RandomVector():Resized(5))
		Mod:GetData(effect).RaptureCloud = true
		effect.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.5)
		effect:SetTimeout(30)
		effect.PositionOffset = Vector(Mod:RandomNum(-npc.Size / 2, npc.Size / 2), Mod:RandomNum(-npc.Size, 0))
	end

	---@type EntityPtr
	local ptr = statusData.CustomData.Spotlight
	local spotlight = ptr and ptr.Ref
	if spotlight then
		spotlight:ToEffect().Timeout = 60
	end

	Mod.Foreach.Player(function(player)
		if player:HasCollectible(KEYS_TO_THE_KINGDOM.ID) then
			local numStats = KEYS_TO_THE_KINGDOM.MINIBOSS[npc.Type] and 1 or 2
			if PETER:IsPeter(player) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				numStats = numStats + 1
			end
			local data = Mod:GetData(player)
			if not data.BossClearRaptureStats then
				data.BossClearRaptureStats = numStats
			else
				data.BossClearRaptureStats = data.BossClearRaptureStats + 1
			end
		end
	end)
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.PRE_REMOVE_ENTITY_STATUS_EFFECT, KEYS_TO_THE_KINGDOM.RaptureBoss,
	KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)

---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:GrantStatsOnBossClear(player)
	local data = Mod:GetData(player)
	if data.BossClearRaptureStats then
		KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, player:GetCollectibleRNG(KEYS_TO_THE_KINGDOM.ID), data.BossClearRaptureStats, false)
		data.BossClearRaptureStats = nil
		player:AnimateHappy()
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, KEYS_TO_THE_KINGDOM.GrantStatsOnBossClear)

---@param player EntityPlayer
---@param npc EntityNPC
---@param statusData StatusEffectData
function KEYS_TO_THE_KINGDOM:SkillIssue(player)
	if raptureHitCooldown > 0 then return end
	raptureHits = raptureHits + 1
	if raptureHits < KEYS_TO_THE_KINGDOM.BOSS_FORGIVE_ATTEMPTS then
		raptureHitCooldown = KEYS_TO_THE_KINGDOM.BOSS_FORGIVE_COOLDOWN
		Mod.Foreach.NPC(function (npc, index)
			local statusData = SEL:GetStatusEffectData(npc, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
			if statusData then
				local maxCountdown = KEYS_TO_THE_KINGDOM:GetMaxRaptureCountdown(player, npc)
				statusData.Countdown = min(maxCountdown, statusData.Countdown + (maxCountdown / 3))
				statusData.CustomData.MaxCountdown = maxCountdown
			end
		end)
		Mod.SFXMan:Play(SoundEffect.SOUND_THUMBS_DOWN)
	else
		Mod.Foreach.NPC(function (npc, index)
			local statusData = SEL:GetStatusEffectData(npc, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
			if statusData then
				SEL:RemoveStatusEffect(npc, KEYS_TO_THE_KINGDOM.STATUS_RAPTURE)
				statusData.CustomData.Spotlight:GetSprite():Play("LightDisappear")
			end
		end)
		Mod.SFXMan:Play(SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED)
		raptureHits = 0
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
			KEYS_TO_THE_KINGDOM:SkillIssue(player)
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
			KEYS_TO_THE_KINGDOM:SkillIssue(player)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, KEYS_TO_THE_KINGDOM.ResetRaptureStatusOnDamage,
	EntityType.ENTITY_PLAYER)

--#endregion

--#region Unique Rapture death interactions (basically just Krampus)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:PostRaptureDeath(npc)
	local data = Mod:TryGetData(npc)
	if data and data.Raptured then
		Isaac.RunCallbackWithParam(Mod.ModCallbacks.POST_RAPTURE_BOSS_DEATH, npc.Type, npc)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, KEYS_TO_THE_KINGDOM.PostRaptureDeath)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:PostKrampusRapture(npc)
	if npc.Variant ~= 1 then return end
	Mod.Foreach.Pickup(function(pickup, index)
		if pickup.FrameCount == 0
			and (pickup.SubType == CollectibleType.COLLECTIBLE_LUMP_OF_COAL
				or pickup.SubType == CollectibleType.COLLECTIBLE_HEAD_OF_KRAMPUS)
		then
			local itemPool = Mod.Game:GetItemPool()
			local newItem = itemPool:GetCollectible(ItemPoolType.POOL_DEVIL, true, npc.DropSeed,
				CollectibleType.COLLECTIBLE_LUMP_OF_COAL)
			pickup:Morph(pickup.Type, pickup.Variant, newItem)
			return true
		end
	end, PickupVariant.PICKUP_COLLECTIBLE)
end

Mod:AddCallback(Mod.ModCallbacks.POST_RAPTURE_BOSS_DEATH, KEYS_TO_THE_KINGDOM.PostKrampusRapture, EntityType.ENTITY_FALLEN)

--#endregion

--#region Angel interaction

---@param npc EntityNPC
---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:SpareAngels(npc, player)
	if npc.Variant == 1 then return true end
	local data = Mod:GetData(npc)
	if not data.KTTKSparedAngel then
		Mod:GetData(npc).KTTKSparedAngel = true
	end
	return true
end

Mod:AddCallback(Mod.ModCallbacks.PRE_START_RAPTURE_BOSS, KEYS_TO_THE_KINGDOM.SpareAngels, EntityType.ENTITY_GABRIEL)
Mod:AddCallback(Mod.ModCallbacks.PRE_START_RAPTURE_BOSS, KEYS_TO_THE_KINGDOM.SpareAngels, EntityType.ENTITY_URIEL)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:ReverseAppear(npc)
	local data = Mod:TryGetData(npc)

	if data and data.KTTKSparedAngel and not npc:IsDead() then
		local sprite = npc:GetSprite()
		if not sprite:IsPlaying("Appear") then
			sprite.PlaybackSpeed = 0
			sprite:Play("Appear", true)
			sprite:SetLastFrame()
			npc.Friction = 0
			npc.Velocity = Vector.Zero
			Mod.SFXMan:Play(SoundEffect.SOUND_THUMBSUP)
		end
		npc.Velocity = Vector.Zero
		local previousFrame = sprite:GetFrame() - 1
		sprite:SetFrame(previousFrame)
		if previousFrame <= 0 then
			Mod.SFXMan:Play(SoundEffect.SOUND_HOLY)
			Mod:GetData(npc).Raptured = true
			sprite.PlaybackSpeed = 1
			KEYS_TO_THE_KINGDOM:RemoveBoss(npc)
		end
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.IMPORTANT, KEYS_TO_THE_KINGDOM.ReverseAppear,
	EntityType.ENTITY_GABRIEL)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.IMPORTANT, KEYS_TO_THE_KINGDOM.ReverseAppear,
	EntityType.ENTITY_URIEL)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:PostAngelSpare(npc)
	local data = Mod:TryGetData(npc)
	if data
		and data.KTTKSparedAngel
		and PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1)
		and PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2)
		and not PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_FILIGREE_FEATHERS)
	then
		local angelItem = Mod.Game:GetItemPool():GetCollectible(ItemPoolType.POOL_ANGEL, true,
			PlayerManager.FirstCollectibleOwner(KEYS_TO_THE_KINGDOM.ID):GetCollectibleRNG(KEYS_TO_THE_KINGDOM.ID)
			:Next(), nil)
		local pos = Mod.Room():FindFreePickupSpawnPosition(npc.Position)
		Mod.Spawn.Pickup(PickupVariant.PICKUP_COLLECTIBLE, angelItem, pos, nil, npc, npc:GetDropRNG():GetSeed())
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, KEYS_TO_THE_KINGDOM.PostAngelSpare, EntityType.ENTITY_GABRIEL)
Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, KEYS_TO_THE_KINGDOM.PostAngelSpare, EntityType.ENTITY_URIEL)

--#endregion

--#region Devil interaction

---@param player EntityPlayer
function KEYS_TO_THE_KINGDOM:DenyHisOfferings(player)
	if Mod.Room():GetType() == RoomType.ROOM_DEVIL then
		local numPickups = 0

		Mod.Foreach.Pickup(function(pickup, index)
			if pickup:IsShopItem() then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 10, pickup.Position, Vector.Zero, nil)
				Mod.SFXMan:Play(SoundEffect.SOUND_LIGHTBOLT)
				pickup:Remove()
				numPickups = numPickups + 1
			end
		end, PickupVariant.PICKUP_COLLECTIBLE, nil, { Inverse = true })

		if numPickups > 0 then
			KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, player:GetCollectibleRNG(KEYS_TO_THE_KINGDOM.ID), numPickups, false)
			Mod.SFXMan:Play(SoundEffect.SOUND_HOLY)
		end
		return true
	end
end

--#endregion

--#region Commands!

Mod.ConsoleCommandHelper:Create("fastspare", "Enemies spared with Keys to the Kingdom are spared in 3 seconds.",
	{Mod.ConsoleCommandHelper:MakeArgument("toggle", "Enemies spared with Keys to the Kingdom are spared in 3 seconds.", Mod.ConsoleCommandHelper.ArgumentTypes.Boolean, false)},
function (arguments)
	KEYS_TO_THE_KINGDOM.DEBUG_SPARE = arguments[1]
end)
Mod.ConsoleCommandHelper:SetParent("fastspare", "debug")

--#endregion
