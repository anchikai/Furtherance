--#region Variables

local Mod = Furtherance

local FIRSTBORN_SON = {}

Furtherance.Item.FIRSTBORN_SON = FIRSTBORN_SON

FIRSTBORN_SON.ID = Isaac.GetItemIdByName("Firstborn Son")
FIRSTBORN_SON.FAMILIAR = Isaac.GetEntityVariantByName("Firstborn Son")

FIRSTBORN_SON.PURGATORY_DELAY = 60
FIRSTBORN_SON.COLOR_FLASH = Color(1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1)
FIRSTBORN_SON.PURGATORY_COLORIZE = {0, 0.5, 0.5, 1}
FIRSTBORN_SON.EXPLOSION_RADIUS = 75

--#endregion

--#region Firstborn Son

function FIRSTBORN_SON:ColorizeEffect(effect)
	local color = effect.Color
	local cz = FIRSTBORN_SON.PURGATORY_COLORIZE
	color:SetColorize(cz[1], cz[2], cz[3], cz[4])
	effect.Color = color
end

---@param familiar EntityFamiliar
function FIRSTBORN_SON:OnFamiliarUpdate(familiar)
	local room = Mod.Room()
	if familiar.State == 0 and not room:IsClear() then
		if familiar.FireCooldown > 0 then
			familiar.FireCooldown = familiar.FireCooldown - 1
		else
			local player = familiar.Player
			familiar.State = 1
			familiar:RemoveFromFollowers()
			familiar.Velocity = Vector.Zero
			familiar:SetColor(Color(1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1), -1, 1, false, true)
			familiar:SetColor(FIRSTBORN_SON.COLOR_FLASH, 15, 2, true, true)
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, familiar.Position, Vector.Zero, familiar):ToEffect()
			---@cast effect EntityEffect
			FIRSTBORN_SON:ColorizeEffect(effect)
			local scale = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 1.25 or 1
			effect.SpriteOffset = Vector(0, -15 * scale)
			effect.SpriteScale = Vector(scale, scale)
			effect.CollisionDamage = player.Damage * FIRSTBORN_SON:GetMuliplier(player)
			Mod:DelayOneFrame(function() Mod:GetData(effect).FirstbornPurgatory = true end)
			Isaac.CreateTimer(function() familiar.Visible = false end, 15, 1, false)
		end
	end

	if familiar.State == 0 or (familiar.State == 1 and not familiar.Visible) then
		familiar:FollowParent()
	end
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, FIRSTBORN_SON.OnFamiliarUpdate, FIRSTBORN_SON.FAMILIAR)

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FIRSTBORN_SON.FAMILIAR)) do
		local familiar = ent:ToFamiliar()
		---@cast familiar EntityFamiliar
		familiar.State = 0
		familiar.FireCooldown = FIRSTBORN_SON.PURGATORY_DELAY
		familiar:SetColor(Color.Default, -1, 1, false, true)
		familiar.Visible = true
	end
end)

--#endregion

--#region Purgatory Ghost

---@param player EntityPlayer
function FIRSTBORN_SON:GetMuliplier(player)
	return player:GetCollectibleNum(FIRSTBORN_SON.ID)
		+ player:GetEffects():GetCollectibleEffectNum(FIRSTBORN_SON.ID)
		+ (player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 1 or 0)
end

--- Gives back an entity with these attributes:
--- 1. Preferred non-boss
--- 2. Has the highest HP in the room
--- 3. is the closest enemy to the `source` argument
---@param source Vector
---@return EntityNPC? Target
function FIRSTBORN_SON:TryFindValidTarget(source)
	---@type EntityNPC[]
	local allValidTargets = {}
	local foundNonBoss = true

	--Gather all valid enemies to target. If a non-boss is found, clear out the table and only insert non-bosses
	Mod:ForEachEnemy(function(npc)
		if not Mod:IsValidEnemyTarget(npc) then return end
		if npc:IsBoss() and not foundNonBoss then
			Mod:Insert(allValidTargets, npc)
		elseif not npc:IsBoss() then
			if not foundNonBoss then
				allValidTargets = {}
				foundNonBoss = true
			end
			Mod:Insert(allValidTargets, npc)
		end
	end)

	--Find the highest HP enemy
	local highestHP
	for _, npc in ipairs(allValidTargets) do
		if npc.HitPoints > (highestHP or 0) then
			highestHP = npc.HitPoints
		end
	end

	--Of that enemy with the highest HP, in case of multiple, find the closest
	---@type EntityNPC | nil
	local closestEnemy
	local closestDistance
	for _, npc in ipairs(allValidTargets) do
		local npcDistance = npc.Position:DistanceSquared(source)

		if npc.HitPoints == highestHP and (not closestEnemy or npcDistance < closestDistance) then
			closestEnemy = npc
			closestDistance = npcDistance
		end
	end

	return closestEnemy
end

---@param effect EntityEffect
function FIRSTBORN_SON:OnEffectUpdate(effect)
	if effect.SubType ~= 1 then return end

	local data = Mod:TryGetData(effect)
	if data
		and data.FirstbornPurgatory
	then
		local sprite = effect:GetSprite()
		if sprite:IsPlaying("Appear")
			and sprite:GetFrame() >= 18
			and effect.SpriteOffset.Y < 0
		then
			effect.SpriteOffset = Vector(0, Mod:Lerp(effect.SpriteOffset.Y, 0, 0.1))
		end
		if sprite:GetAnimation() == "Charge" and sprite:GetFrame() == 1 then
			local target = FIRSTBORN_SON:TryFindValidTarget(effect.Position)
			if target then
				effect.Target = target
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, FIRSTBORN_SON.OnEffectUpdate, EffectVariant.PURGATORY)

function FIRSTBORN_SON:OnRoomClear()
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FIRSTBORN_SON.FAMILIAR)) do
		local familiar = ent:ToFamiliar()
		---@cast familiar EntityFamiliar
		FIRSTBORN_SON:OnFamiliarInit(familiar)
		if familiar.State == 1 then
			familiar:SetColor(Color.Default, -1, 1, false, true)
			familiar:SetColor(FIRSTBORN_SON.COLOR_FLASH, 15, 2, true, true)
			familiar.State = 0
			familiar.Visible = true
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, FIRSTBORN_SON.OnRoomClear)

---@param effect EntityEffect
---@param target Entity
---@param isSplash boolean
function FIRSTBORN_SON:DamageTarget(effect, target, isSplash)
	local familiar = effect.SpawnerEntity:ToFamiliar()
	if not familiar then return end
	local player = familiar.Player
	local mult = FIRSTBORN_SON:GetMuliplier(player)
	if target and target:Exists() then
		if target:IsBoss() then
			local damage = effect.CollisionDamage + (target.MaxHitPoints * 0.1)
			target:TakeDamage(damage, 0, EntityRef(effect.SpawnerEntity), 0)
		elseif isSplash then
			target:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect.SpawnerEntity), 0)
		else
			target:Kill()
		end
	end
	if not isSplash and mult > 1 then
		for _, ent in ipairs(Isaac.FindInRadius(target.Position, FIRSTBORN_SON.EXPLOSION_RADIUS, EntityPartition.ENEMY)) do
			if Mod:IsValidEnemyTarget(ent) then
				FIRSTBORN_SON:DamageTarget(effect, ent, true)
			end
		end
	end
end

--#endregion

--#region Purgatory Explosion

---@param effect EntityEffect
function FIRSTBORN_SON:OverridePurgatoryExplosion(effect)
	if effect.SubType == 1
		and effect.TargetPosition
		and effect.Position:DistanceSquared(effect.TargetPosition) <= 50 ^ 2
	then
		local data = Mod:TryGetData(effect)
		if data and data.FirstbornPurgatory then
			effect:Remove()
			local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 2,
				effect.TargetPosition, Vector.Zero, effect)
			Mod:GetData(explosion).FirstbornPurgatoryExplosion = true
			Mod.SFXMan:Play(SoundEffect.SOUND_DEMON_HIT)
			FIRSTBORN_SON:ColorizeEffect(explosion)
			FIRSTBORN_SON:DamageTarget(effect, effect.Target, false)
			return true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, FIRSTBORN_SON.OverridePurgatoryExplosion, EffectVariant.PURGATORY)

---@param explosion EntityEffect
function FIRSTBORN_SON:SpawnPurgatoryEffects(explosion)
	if explosion.SubType ~= 2 then return end
	local data = Mod:TryGetData(explosion)

	if data
		and data.FirstbornPurgatoryExplosion
		and explosion:GetSprite():IsPlaying("Explosion")
		and explosion:GetSprite():GetFrame() == 4
	then
		local effects = {
			EffectVariant.POOF01,
			EffectVariant.BLOOD_EXPLOSION,
			EffectVariant.BLOOD_SPLAT
		}
		for _, variant in ipairs(effects) do
			for _, poof in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, variant)) do
				if poof.Position:DistanceSquared(explosion.Position) <= 0 then
					poof:Remove()
					break
				end
			end
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, variant, 0, explosion.Position, Vector.Zero, explosion.SpawnerEntity)
			FIRSTBORN_SON:ColorizeEffect(effect)
			if variant == EffectVariant.POOF01 then
				effect:GetSprite():Load("gfx/1000.034_fart.anm2")
				effect:GetSprite():Play("Explode")
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, FIRSTBORN_SON.SpawnPurgatoryEffects, EffectVariant.ENEMY_GHOST)

---@param trail EntityEffect
function FIRSTBORN_SON:UpdateTrailColor(trail)
	if not trail.SpawnerEntity then return end
	local data = Mod:TryGetData(trail.SpawnerEntity)
	if data
		and data.FirstbornPurgatory
	then
		if trail.FrameCount == 0 then
			trail:SetColor(Color(0, 0, 0, 1, 0, 1, 1), -1, 1, false, false)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, FIRSTBORN_SON.UpdateTrailColor, EffectVariant.SPRITE_TRAIL)

--#endregion

--#region Basic familiar stuff

---@param familiar EntityFamiliar
function FIRSTBORN_SON:OnFamiliarInit(familiar)
	familiar:AddToFollowers()
	familiar.FireCooldown = FIRSTBORN_SON.PURGATORY_DELAY
	familiar:GetSprite():Play("FloatDown")
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FIRSTBORN_SON.OnFamiliarInit, FIRSTBORN_SON.FAMILIAR)

---@param player EntityPlayer
function FIRSTBORN_SON:OnFamiliarCache(player)
	local rng = player:GetCollectibleRNG(FIRSTBORN_SON.ID)
	rng:Next()
	local numFamiliars = math.min(1, player:GetCollectibleNum(FIRSTBORN_SON.ID) + player:GetEffects():GetCollectibleEffectNum(FIRSTBORN_SON.ID))
	player:CheckFamiliar(FIRSTBORN_SON.FAMILIAR, numFamiliars, rng, Mod.ItemConfig:GetCollectible(FIRSTBORN_SON.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, FIRSTBORN_SON.OnFamiliarCache, CacheFlag.CACHE_FAMILIARS)

--#endregion
