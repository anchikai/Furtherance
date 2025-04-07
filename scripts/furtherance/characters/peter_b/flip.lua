--#region Variables

local Mod = Furtherance

local FLIP = {}

local PETER_B = Mod.Character.PETER_B
local MUDDLED_CROSS = Mod.Item.MUDDLED_CROSS
Furtherance.Item.MUDDLED_CROSS.FLIP = FLIP

FLIP.FLIP_FACTOR = 0
FLIP.PAUSE_MENU_STOP_FLIP = false
FLIP.PAUSE_ENEMIES_DURING_FLIP = false

--#endregion

--#region Helpers

---@param inverse? boolean
function FLIP:GetIgnoredRenderMode(inverse)
	local renderMode = inverse and RenderMode.RENDER_WATER_REFLECT or RenderMode.RENDER_WATER_ABOVE
	if MUDDLED_CROSS:IsRoomEffectActive() then
		renderMode = inverse and RenderMode.RENDER_WATER_ABOVE or RenderMode.RENDER_WATER_REFLECT
	end
	return renderMode
end

---@param ent Entity
function FLIP:GetEnemyIgnoredRenderMode(ent)
	local npc = ent:ToNPC() or ent.SpawnerEntity
	if not npc then return RenderMode.RENDER_NULL end
	local data = Mod:TryGetData(npc)
	local wasFlipped = data and data.PeterFlipped
	local renderMode = FLIP:GetIgnoredRenderMode(true)
	if wasFlipped then
		renderMode = FLIP:GetIgnoredRenderMode(false)
	end
	return renderMode
end

---@param ent Entity
function FLIP:OriginatesFromEnemy(ent)
	return ent:ToNPC()
		or ent.SpawnerEntity and ent.SpawnerEntity:ToNPC()
end

--#endregion

--#region Handle rendering

---@param entity Entity
function FLIP:Reflection(entity)
	local renderMode = Mod.Room():GetRenderMode()
	local player = Mod:TryGetPlayer(entity)
	if player then
		if PETER_B:IsPeterB(player)
			and renderMode == FLIP:GetIgnoredRenderMode()
		then
			return false
		elseif not PETER_B:IsPeterB(player) and renderMode == RenderMode.RENDER_WATER_REFLECT then
			return false
		end
	end
	if FLIP:OriginatesFromEnemy(entity)
		and renderMode == FLIP:GetEnemyIgnoredRenderMode(entity)
	then
		return false
	end
end

local validEffects = Mod:Set({
	EffectVariant.TEAR_POOF_A,
	EffectVariant.TEAR_POOF_B,
	EffectVariant.TEAR_POOF_SMALL,
	EffectVariant.TEAR_POOF_VERYSMALL,
	EffectVariant.BOMB_EXPLOSION,
	EffectVariant.BLOOD_EXPLOSION,
	EffectVariant.BULLET_POOF
})

function FLIP:TearSplash(tear)
	if not PETER_B:UsePeterFlipRoomEffects() then return end
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
		if ent.Position:DistanceSquared(tear.Position) <= 1
			and validEffects[ent.Variant]
		then
			local player = Mod:TryGetPlayer(tear)
			if player and PETER_B:IsPeterB(player) then
				Mod:GetData(ent).PeterBReflection = true
			elseif player and not PETER_B:IsPeterB(player) then
				Mod:GetData(ent).NonPeterBReflection = true
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, FLIP.TearSplash)

function FLIP:PostBombExplode(bomb)
	if not PETER_B:UsePeterFlipRoomEffects() then return end
	local player = Mod:TryGetPlayer(bomb)
	if player
		and player:GetPlayerType() == Mod.PlayerType.PETER_B
		and bomb:GetSprite():IsPlaying("Explode")
	then
		for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
			if ent.Position:DistanceSquared(bomb.Position) <= 1 and validEffects[ent.Variant] then
				Mod:GetData(ent).PeterBReflection = true
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, FLIP.PostBombExplode)

function FLIP:HideEffects(effect)
	local data = Mod:TryGetData(effect)
	if data
		and data.PeterBReflection
		and Mod.Room():GetRenderMode() == FLIP:GetIgnoredRenderMode()
	then
		return false
	elseif data
		and data.NonPeterBReflection
		and Mod.Room():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT
	then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, FLIP.HideEffects)

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_RENDER, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_PRE_BOMB_RENDER, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, FLIP.Reflection)

function FLIP:HideEnemies(npcOrProj)
	if PETER_B:UsePeterFlipRoomEffects()
		and Mod.Room():GetRenderMode() == FLIP:GetEnemyIgnoredRenderMode(npcOrProj)
	then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, FLIP.HideEnemies)
Mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_RENDER, FLIP.HideEnemies)

--#endregion

--#region Handle collision/damage

---@param ent Entity
function FLIP:BringEnemyToFlipside(ent)
	local data = Mod:GetData(ent)
	data.PeterFlipped = true
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, ent.Position, Vector.Zero, nil)
	effect.Color = Color(1, 0.3, 0.3, 0.75)
	local size = ent.Size / 25
	effect.SpriteScale = Vector(size, size)
	Mod.SFXMan:Play(SoundEffect.SOUND_WAR_LAVA_SPLASH, 0.5, 5, false, 0.8)
	ent:AddEntityFlags(EntityFlag.FLAG_FREEZE)
	local oldCollision = ent.EntityCollisionClass
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	Mod:GetData(ent).JustPeterFlipped = true
	Isaac.CreateTimer(function()
		ent.EntityCollisionClass = oldCollision
		ent:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
		Mod:GetData(ent).JustPeterFlipped = nil
	end, 30, 1, false)
end

---@param ent Entity
---@param collider Entity
function FLIP:CollisionMode(ent, collider)
	if not PETER_B:UsePeterFlipRoomEffects() then return end
	local damageSource
	local enemyTarget
	local oppositeTarget
	if FLIP:OriginatesFromEnemy(ent) then
		enemyTarget = FLIP:OriginatesFromEnemy(ent)
		damageSource = ent
		oppositeTarget = collider
	elseif FLIP:OriginatesFromEnemy(collider) then
		enemyTarget = FLIP:OriginatesFromEnemy(collider)
		damageSource = collider
		oppositeTarget = ent
	end
	if enemyTarget then
		local srcData = Mod:TryGetData(damageSource)
		local enemyData = Mod:TryGetData(enemyTarget)
		local fromFlippedEnemy = enemyData and enemyData.PeterFlipped
		local isFlippedEnemy = srcData and srcData.PeterFlipped
		if oppositeTarget:ToPlayer()
			and damageSource:IsActiveEnemy(false)
			and not isFlippedEnemy
			and not MUDDLED_CROSS:IsRoomEffectActive()
		then
			FLIP:BringEnemyToFlipside(damageSource)
			return false
		end
		if isFlippedEnemy and enemyData and enemyData.JustPeterFlipped then
			return false
		end
		if not fromFlippedEnemy then
			return true
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_LASER_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)

---@param ent Entity
---@param source EntityRef
function FLIP:HandleDamage(ent, amount, flags, source, countdown)
	if source and source.Entity then
		--If they shouldn't collide, ignore all sources of damage from that side as well
		local result = FLIP:CollisionMode(ent, source.Entity)
		if result then
			return false
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.IMPORTANT, FLIP.HandleDamage)

--#endregion

--#region Flip effect

function FLIP:AnimateFlip()
	local speed = 0.025
	--[[ if Furtherance.FlipSpeed == 1 then
		speed = 0.0172413793
	elseif Furtherance.FlipSpeed == 2 then
		speed = 0.05
	elseif Furtherance.FlipSpeed == 3 then
		speed = 0.1
	end ]]
	local isFlipped = Mod.Room():GetEffects():HasCollectibleEffect(MUDDLED_CROSS.ID)
	FLIP.PAUSE_MENU_STOP_FLIP = Mod.Game:IsPauseMenuOpen()

	if not FLIP.PAUSE_MENU_STOP_FLIP then
		if isFlipped == true then
			FLIP.FLIP_FACTOR = FLIP.FLIP_FACTOR + speed
		elseif isFlipped == false then
			FLIP.FLIP_FACTOR = FLIP.FLIP_FACTOR - speed
		end
	end

	FLIP.FLIP_FACTOR = Mod:Clamp(FLIP.FLIP_FACTOR, 0, 1)
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, FLIP.AnimateFlip)

function FLIP:FreezeEnemiesDuringFlip()
	local effects = Mod.Room():GetEffects()
	if FLIP.FLIP_FACTOR > 0 and FLIP.FLIP_FACTOR < 1 then
		if not FLIP.PAUSE_ENEMIES_DURING_FLIP then
			Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, false, false, false, false, -1)
			Isaac.GetPlayer():GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_PAUSE)
			FLIP.PAUSE_ENEMIES_DURING_FLIP = true
		end
	else
		if FLIP.PAUSE_ENEMIES_DURING_FLIP then
			FLIP.PAUSE_ENEMIES_DURING_FLIP = false
			effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_PAUSE)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FLIP.FreezeEnemiesDuringFlip)

-- Thank you im_tem for the shader!!
function FLIP:PeterFlip(name)
	if name == 'Peter Flip' then
		return { FlipFactor = FLIP.PAUSE_MENU_STOP_FLIP and 0 or FLIP.FLIP_FACTOR }
	end
end

Mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, FLIP.PeterFlip)

function FLIP:FixInputs(ent, _, button)
	local player = ent and ent:ToPlayer()
	if player and MUDDLED_CROSS:IsRoomEffectActive() then
		if button == ButtonAction.ACTION_DOWN then
			return Input.GetActionValue(ButtonAction.ACTION_UP, player.ControllerIndex)
		elseif button == ButtonAction.ACTION_UP then
			return Input.GetActionValue(ButtonAction.ACTION_DOWN, player.ControllerIndex)
		elseif button == ButtonAction.ACTION_SHOOTUP then
			return Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
		elseif button == ButtonAction.ACTION_SHOOTDOWN then
			return Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, FLIP.FixInputs, InputHook.GET_ACTION_VALUE)

--#endregion

return FLIP
