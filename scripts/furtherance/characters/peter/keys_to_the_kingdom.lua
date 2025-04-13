--#region Variables

local Mod = Furtherance
local SEL = StatusEffectLibrary

local KEYS_TO_THE_KINGDOM = {}

Furtherance.Item.KEYS_TO_THE_KINGDOM = KEYS_TO_THE_KINGDOM

KEYS_TO_THE_KINGDOM.ID = Isaac.GetItemIdByName("Keys to the Kingdom")
KEYS_TO_THE_KINGDOM.EFFECT = Isaac.GetEntityVariantByName("Keys to the Kingdom Effects")

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

--30fps * 30 = 30 seconds
KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN = 30 * 30
KEYS_TO_THE_KINGDOM.MAX_CHARGES = Mod.ItemConfig:GetCollectible(KEYS_TO_THE_KINGDOM.ID).MaxCharges
KEYS_TO_THE_KINGDOM.COLLECTION_DISTANCE = 20 ^ 2
KEYS_TO_THE_KINGDOM.SPARE_TIMER = {
	[EntityType.ENTITY_BABY_PLUM] = KEYS_TO_THE_KINGDOM.BOSS_RAPTURE_COUNTDOWN * 0.5
}

KEYS_TO_THE_KINGDOM.StatTable = {
	{ Name = "Damage",       Flag = CacheFlag.CACHE_DAMAGE,    Buff = 0.5,      TempBuff = 0.1 },
	{ Name = "MaxFireDelay", Flag = CacheFlag.CACHE_FIREDELAY, Buff = -0.5 * 5, TempBuff = -0.1 * 5 }, -- MaxFireDelay buffs should be negative!
	{ Name = "TearRange",    Flag = CacheFlag.CACHE_RANGE,     Buff = 0.5 * Mod.RANGE_BASE_MULT, TempBuff = 0.1 * Mod.RANGE_BASE_MULT },
	{ Name = "ShotSpeed",    Flag = CacheFlag.CACHE_SHOTSPEED, Buff = 0.125,    TempBuff = 0.025 },
	{ Name = "MoveSpeed",    Flag = CacheFlag.CACHE_SPEED,     Buff = 0.5,      TempBuff = 0.1 },
	{ Name = "Luck",         Flag = CacheFlag.CACHE_LUCK,      Buff = 0.5,      TempBuff = 0.1 }
}

local identifier = "FR_RAPTURE"
SEL.RegisterStatusEffect(identifier, nil, nil, nil, true)
KEYS_TO_THE_KINGDOM.RAPTURE_STATUS = SEL.StatusFlag[identifier]

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
		and not SEL:HasStatusEffect(ent, KEYS_TO_THE_KINGDOM.RAPTURE_STATUS)
		and not (Mod:TryGetData(ent) and Mod:GetData(ent).Raptured)
end

---@param ent EntityNPC | EntityPlayer
function KEYS_TO_THE_KINGDOM:OnStatusEffectAdd(ent)
	if not (ent:IsActiveEnemy(false) and ent:IsVulnerableEnemy() and ent:IsBoss()) then
		return true
	end
	local statusConfig = SEL:GetStatusEffectData(ent, KEYS_TO_THE_KINGDOM.RAPTURE_STATUS)
	if statusConfig then
		--Don't both reapplying it so the timer won't get reset
		return true
	end
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT,
	KEYS_TO_THE_KINGDOM.OnStatusEffectAdd, KEYS_TO_THE_KINGDOM.RAPTURE_STATUS)

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

---Raptures the enemy, spawning a spared soul and grants stats to the player who raptured it corresponding to whether or not it's a boss
---
---Will spawn the soul at the parent head if it happens to be a segmented enemy and remove the rest
---@param ent Entity
function KEYS_TO_THE_KINGDOM:RaptureEnemy(ent)
	local parent = ent:GetLastParent() --Returns the first parent in the chain or itself
	local glow = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GROUND_GLOW, 0, parent.Position, Vector.Zero, nil)
	glow:GetSprite().PlaybackSpeed = 0.1
	local subtype = ent:IsBoss() and KEYS_TO_THE_KINGDOM.SPARED_SOUL_BOSS or KEYS_TO_THE_KINGDOM.SPARED_SOUL
	Isaac.Spawn(EntityType.ENTITY_EFFECT, KEYS_TO_THE_KINGDOM.EFFECT, subtype,
		parent.Position, Vector.Zero, nil)
	local currentEnt = parent
	local attempt = 0
	--Clear up segmented enemies
	while currentEnt:Exists() and currentEnt.Child and currentEnt.Child:Exists() and not currentEnt.Child:IsBoss() do
		local child = currentEnt.Child
		currentEnt:Remove()
		currentEnt = child
		attempt = attempt + 1
		--You can never be too safe around while loops...
		if attempt == 50 then
			break
		end
	end
	if ent:IsBoss() then
		Mod:GetData(ent).Raptured = true
		currentEnt:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH)
		currentEnt:Die()
		currentEnt:GetSprite():Play("Death")
		currentEnt:GetSprite():SetLastFrame()
		currentEnt.Visible = false
	else
		currentEnt:Remove()
	end
end

---Grants 1 random stat buff from the Keys to the Kingdom StatBuff table
---@param player EntityPlayer
---@param rng RNG
---@param isBoss boolean @If set to true, will grant 2 different stats, or 3 if you're Peter with Birthright
function KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, rng, isBoss)
	local varName = "KeysToTheKingdomStatBonus"
	if not isBoss then
		varName = varName .. "_Temp"
	end
	local selectedStats = {}
	if isBoss then
		local numStats = 2
		if player:GetPlayerType() == Mod.PlayerType.PETER and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			numStats = 3
		end
		for _ = 1, numStats do
			local randomStatIndex = Mod:GetDifferentRandomKey(selectedStats, KEYS_TO_THE_KINGDOM.StatTable, rng)
			selectedStats[randomStatIndex] = true
		end
	else
		selectedStats[rng:RandomInt(#KEYS_TO_THE_KINGDOM.StatTable) + 1] = true
	end
	for statIndex, _ in pairs(selectedStats) do
		local key = tostring(statIndex)
		local player_save = isBoss and Mod:RunSave(player) or Mod:FloorSave(player)
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
	local roomType = room:GetType()

	room:GetEffects():AddCollectibleEffect(KEYS_TO_THE_KINGDOM.ID)

	if roomType == RoomType.ROOM_ANGEL
		and not (
			player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1)
			and player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2)
		)
	then
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,
				CollectibleType.COLLECTIBLE_KEY_PIECE_1,
				room:FindFreePickupSpawnPosition(player.Position, 40), Vector.Zero, player)
		elseif not player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE,
				CollectibleType.COLLECTIBLE_KEY_PIECE_2,
				room:FindFreePickupSpawnPosition(player.Position, 40), Vector.Zero, player)
		end
	elseif room:GetAliveEnemiesCount() == 0 then
		return { Discharge = false, ShowAnim = false, Remove = false }
	elseif KEYS_TO_THE_KINGDOM.STORY_BOSS_IDS[room:GetBossID()] then
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
			if canSpare and ent:IsBoss() then
				local spotlight = Isaac.Spawn(EntityType.ENTITY_EFFECT, KEYS_TO_THE_KINGDOM.EFFECT,
					KEYS_TO_THE_KINGDOM.SPOTLIGHT,
					ent.Position, Vector.Zero, ent):ToEffect()
				---@cast spotlight EntityEffect
				spotlight.Parent = ent
				spotlight:FollowParent(ent)
				SEL:AddStatusEffect(ent, KEYS_TO_THE_KINGDOM.RAPTURE_STATUS, raptureCountdown, source, nil,
					{ Spotlight = spotlight })
			elseif canSpare and ent:Exists() then
				KEYS_TO_THE_KINGDOM:RaptureEnemy(ent)
				KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, rng, false)
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
	local statusData = SEL:GetStatusEffectData(npc, KEYS_TO_THE_KINGDOM.RAPTURE_STATUS)
	---@cast statusData StatusEffectData
	local countdown = statusData.Countdown
	---@type EntityEffect
	local spotlight = statusData.CustomData.Spotlight
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
	KEYS_TO_THE_KINGDOM.RAPTURE_STATUS)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:RaptureBoss(npc)
	local statusData = SEL:GetStatusEffectData(npc, KEYS_TO_THE_KINGDOM.RAPTURE_STATUS)
	---@cast statusData StatusEffectData
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
			KEYS_TO_THE_KINGDOM:GrantRaptureStats(player, player:GetCollectibleRNG(KEYS_TO_THE_KINGDOM.ID), true)
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end
	end)
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.PRE_REMOVE_ENTITY_STATUS_EFFECT, KEYS_TO_THE_KINGDOM.RaptureBoss,
	KEYS_TO_THE_KINGDOM.RAPTURE_STATUS)

---@param ent Entity
---@param source EntityRef
function KEYS_TO_THE_KINGDOM:ResetRaptureStatusOnHit(ent, _, _, source, _)
	local statusData = SEL:GetStatusEffectData(ent, KEYS_TO_THE_KINGDOM.RAPTURE_STATUS)
	--So long as the enemy was damage by something that isn't an enemy
	if statusData and source.Entity and not source.Entity:ToNPC() then
		--If the damage source came from the player in any way
		local player = Mod:TryGetPlayer(source)
		if player then
			statusData.Countdown = KEYS_TO_THE_KINGDOM:GetMaxRaptureCountdown(player, ent)
			player:AnimateSad()
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
		local statusData = npc and SEL:GetStatusEffectData(npc, KEYS_TO_THE_KINGDOM.RAPTURE_STATUS)
		if statusData and npc then
			statusData.Countdown = KEYS_TO_THE_KINGDOM:GetMaxRaptureCountdown(player, npc)
			Mod.SFXMan:Play(SoundEffect.SOUND_THUMBS_DOWN)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, KEYS_TO_THE_KINGDOM.ResetRaptureStatusOnDamage,
	EntityType.ENTITY_PLAYER)

--#endregion

--#region Krampoos

local krampusLineup = {}

---Apparently POST_NPC_DEATH runs A F T ER POST_ENTITY_REMOVE which is when I remove my custom data. Awesome.
function KEYS_TO_THE_KINGDOM:Ugh(ent)
	if ent.Variant == 1 then
		local data = Mod:TryGetData(ent)
		if data and data.Raptured then
			krampusLineup[GetPtrHash(ent)] = true
			Mod:DelayOneFrame(function() krampusLineup[GetPtrHash(ent)] = false end)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, KEYS_TO_THE_KINGDOM.Ugh, EntityType.ENTITY_FALLEN)

---@param npc EntityNPC
function KEYS_TO_THE_KINGDOM:KrampusRapture(npc)
	if krampusLineup[GetPtrHash(npc)] and npc.Variant == 1 then
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
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, KEYS_TO_THE_KINGDOM.KrampusRapture, EntityType.ENTITY_FALLEN)

--#endregion
