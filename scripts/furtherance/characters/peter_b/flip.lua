--#region Variables

local SEL = StatusEffectLibrary
local Mod = Furtherance

local FLIP = {}

local PETER_B = Mod.Character.PETER_B
local MUDDLED_CROSS = Mod.Item.MUDDLED_CROSS
Furtherance.Item.MUDDLED_CROSS.FLIP = FLIP

FLIP.FLIP_FACTOR = 0
FLIP.PAUSE_MENU_STOP_FLIP = false
FLIP.PAUSE_ENEMIES_DURING_FLIP = false

FLIP.TEAR_DEATH_EFFECTS = Mod:Set({
	EffectVariant.TEAR_POOF_A,
	EffectVariant.TEAR_POOF_B,
	EffectVariant.TEAR_POOF_SMALL,
	EffectVariant.TEAR_POOF_VERYSMALL,
	EffectVariant.BOMB_EXPLOSION,
	EffectVariant.BLOOD_EXPLOSION,
	EffectVariant.BULLET_POOF
})
FLIP.ENEMY_EFFECTS = Mod:Set({
	EffectVariant.FLY_EXPLOSION,
	EffectVariant.BLOOD_EXPLOSION,
	EffectVariant.BLOOD_GUSH,
	EffectVariant.BLOOD_PARTICLE,
	EffectVariant.BLOOD_SPLAT,
	EffectVariant.BLOOD_PARTICLE
})

--Highest to lowest, top to bottom
local VANILLA_STATUS_PRIORITY = {
	EntityFlag.FLAG_CHARM,
	EntityFlag.FLAG_BRIMSTONE_MARKED,
	EntityFlag.FLAG_MAGNETIZED,
	EntityFlag.FLAG_BAITED,
	EntityFlag.FLAG_CONFUSION,
	EntityFlag.FLAG_BURN,
	EntityFlag.FLAG_POISON,
	EntityFlag.FLAG_FEAR,
	EntityFlag.FLAG_BLEED_OUT,
	EntityFlag.FLAG_SLOW,
	EntityFlag.FLAG_WEAKNESS
}
local FLAG_TO_ICON = {
	[EntityFlag.FLAG_CHARM] = "Charm",
	[EntityFlag.FLAG_BRIMSTONE_MARKED] = "BrimstoneCurse",
	[EntityFlag.FLAG_MAGNETIZED] = "Magnetize",
	[EntityFlag.FLAG_BAITED] = "Bait",
	[EntityFlag.FLAG_CONFUSION] = "Confuse",
	[EntityFlag.FLAG_BURN] = "Burn",
	[EntityFlag.FLAG_POISON] = "Poison",
	[EntityFlag.FLAG_FEAR] = "Fear",
	[EntityFlag.FLAG_BLEED_OUT] = "BleedingOut",
	[EntityFlag.FLAG_SLOW] = "Slow",
	[EntityFlag.FLAG_WEAKNESS] = "Weakness",
}

local identifier = "FR_STRENGTH"
local statusSprite = Sprite("gfx/ui/fr_statuseffects.anm2", true)
statusSprite:Play("Strength")
local STATUS_COLOR = Color(1,1,1,1,0.3,0,0,0.2,0,0,0.75)
SEL.RegisterStatusEffect(identifier, statusSprite, STATUS_COLOR, nil, true)

FLIP.STATUS_STRENGTH = SEL.StatusFlag[identifier]

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
function FLIP:EnemyOnPeterSide(ent)
	local data = Mod:GetData(ent)
	return data.PeterFlipped or ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
end

---@param ent Entity
function FLIP:GetEnemyIgnoredRenderMode(ent)
	local npc = ent:ToNPC() or ent.SpawnerEntity
	if not npc then return RenderMode.RENDER_NULL end
	local wasFlipped = FLIP:EnemyOnPeterSide(ent)
	local renderMode = FLIP:GetIgnoredRenderMode(true)
	if wasFlipped then
		renderMode = FLIP:GetIgnoredRenderMode(false)
	end
	return renderMode
end

---@param ent Entity
function FLIP:OriginatesFromEnemy(ent)
	if ent:IsBoss() then return end
	return (ent:ToNPC()
		or ent.SpawnerEntity and ent.SpawnerEntity:ToNPC())
end

---@param ent Entity
function FLIP:IsEntityInReflection(ent)
	local player = Mod:TryGetPlayer(ent)
	local flipActive = MUDDLED_CROSS:IsRoomEffectActive()
	local fromEnemy = FLIP:OriginatesFromEnemy(ent)
	local isFlippedEnemy = fromEnemy and FLIP:EnemyOnPeterSide(ent)
	return (player and PETER_B:IsPeterB(player) and not flipActive)
		or (fromEnemy and isFlippedEnemy and not flipActive)
		or (fromEnemy and not isFlippedEnemy and flipActive)
end

--#endregion

--#region Handle entity rendering

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

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_RENDER, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_PRE_BOMB_RENDER, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, FLIP.Reflection)

---@param npcOrProj EntityNPC | EntityProjectile
function FLIP:HideEnemies(npcOrProj)
	if PETER_B:UsePeterFlipRoomEffects()
		and not npcOrProj:IsBoss()
		and Mod.Room():GetRenderMode() == FLIP:GetEnemyIgnoredRenderMode(npcOrProj)
	then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, FLIP.HideEnemies)
Mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_RENDER, FLIP.HideEnemies)

--#endregion

--#region Manage specific effects

---@param tearOrProj EntityTear | EntityProjectile
function FLIP:TearSplash(tearOrProj)
	if not PETER_B:UsePeterFlipRoomEffects() then return end
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
		if ent.Position:DistanceSquared(tearOrProj.Position) <= 1
			and FLIP.TEAR_DEATH_EFFECTS[ent.Variant]
		then
			local player = Mod:TryGetPlayer(tearOrProj)
			if player and PETER_B:IsPeterB(player) or tearOrProj.SpawnerEntity and tearOrProj.SpawnerEntity:ToNPC() then
				Mod:GetData(ent).PeterBReflection = true
			elseif player and not PETER_B:IsPeterB(player) then
				Mod:GetData(ent).NonPeterBReflection = true
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, FLIP.TearSplash)
Mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, FLIP.TearSplash)

function FLIP:PostBombExplode(bomb)
	if not PETER_B:UsePeterFlipRoomEffects() then return end
	local player = Mod:TryGetPlayer(bomb)
	if player
		and player:GetPlayerType() == Mod.PlayerType.PETER_B
		and bomb:GetSprite():IsPlaying("Explode")
	then
		for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
			if ent.Position:DistanceSquared(bomb.Position) <= 1 and FLIP.TEAR_DEATH_EFFECTS[ent.Variant] then
				Mod:GetData(ent).PeterBReflection = true
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, FLIP.PostBombExplode)

function FLIP:FlyPoof(npc)
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.FLY_EXPLOSION)) do
		if ent.Position:DistanceSquared(npc.Position) <= 324 then
			Mod:GetData(ent).PeterBReflection = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, FLIP.FlyPoof)

function FLIP:HideEffects(effect)
	local data = Mod:TryGetData(effect)
	--Peter B players
	if data
		and data.PeterBReflection
		and Mod.Room():GetRenderMode() == FLIP:GetIgnoredRenderMode()
	then
		return false
	--Not-Peter B players
	elseif data
		and data.NonPeterBReflection
		and Mod.Room():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT
	then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, FLIP.HideEffects)

--#endregion

--#region Handle collision/ignoring damage

--So that their Pathfinders obey their ability to ignore grid entities
---@param npc EntityNPC
function FLIP:AdjustEnemyGridCollision(npc)
	if not PETER_B:UsePeterFlipRoomEffects() then return end
	local data = Mod:GetData(npc)
	if not data.PeterFlipOGGridColl then return end
	if FLIP:EnemyOnPeterSide(npc) then
		if FLIP:IsEntityInReflection(npc) then
			npc.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
		else
			npc.GridCollisionClass = data.PeterFlipOGGridColl
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, FLIP.AdjustEnemyGridCollision)

---@param ent Entity
function FLIP:ValidEnemyToFlip(ent)
	return ent:IsActiveEnemy(false)
		and ent:ToNPC()
		and ent:ToNPC().CanShutDoors
		and not ent:IsBoss()
end

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
	if ent.GridCollisionClass > GridCollisionClass.COLLISION_SOLID then
		data.PeterFlipOGGridColl = ent.GridCollisionClass
		ent.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
	end
	SEL:AddStatusEffect(ent, FLIP.STATUS_STRENGTH, -1, EntityRef(nil))
	ent:SetColor(STATUS_COLOR, 32, 1, false, false)
	Isaac.CreateTimer(function()
		ent.EntityCollisionClass = oldCollision
		ent:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
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
		local fromFlippedEnemy = FLIP:EnemyOnPeterSide(enemyTarget)
		local isFlippedEnemy = FLIP:EnemyOnPeterSide(damageSource)
		if oppositeTarget:ToPlayer()
			and FLIP:ValidEnemyToFlip(ent)
			and not isFlippedEnemy
			and not MUDDLED_CROSS:IsRoomEffectActive()
		then
			FLIP:BringEnemyToFlipside(damageSource)
			return false
		end
		if not fromFlippedEnemy and not enemyTarget:IsBoss() then
			return true
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_LASER_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.IMPORTANT, FLIP.CollisionMode)

---@param ent Entity
---@param gridIndex integer
---@param gridEnt GridEntity?
function FLIP:GridCollision(ent, gridIndex, gridEnt)
	if gridEnt
		and PETER_B:UsePeterFlipRoomEffects()
		and (
			gridEnt:ToRock()
			or gridEnt:ToFire()
			or gridEnt:ToPoop()
			or gridEnt:ToSpikes()
			or gridEnt:ToWeb()
			or gridEnt:ToTeleporter()
			or gridEnt:ToPressurePlate()
			or gridEnt:ToStatue()
			or gridEnt:ToTNT()
		)
		and FLIP:IsEntityInReflection(ent)
	then
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION,CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_GRID_COLLISION,CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_GRID_COLLISION,CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_BOMB_GRID_COLLISION,CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_GRID_COLLISION,CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION,CallbackPriority.IMPORTANT, FLIP.GridCollision)

---@param ent Entity
---@param source EntityRef
function FLIP:HandleDamage(ent, amount, flags, source, countdown)
	if source and source.Entity then
		--If they shouldn't collide, ignore all sources of damage from that side as well
		local shouldNotCollide = FLIP:CollisionMode(ent, source.Entity)
		if shouldNotCollide then
			return false
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.IMPORTANT, FLIP.HandleDamage)

---@param gridEnt GridEntityPressurePlate
function FLIP:PressurePlateUpdate(gridEnt)
	if PETER_B:UsePeterFlipRoomEffects()
		and (not Mod.Game:IsGreedMode()
			or gridEnt:GetGridIndex() == 112
			and not Mod:IsInStartingRoom()
		)
		and gridEnt.State ~= 1
	then
		local grid_save = Mod:RoomSave(gridEnt:GetGridIndex())
		local validPlayerOnPlate = false
		for _, ent in ipairs(Isaac.FindInRadius(gridEnt.Position, 40, EntityPartition.PLAYER)) do
			if FLIP:IsEntityInReflection(ent) and gridEnt.State == 0 and not validPlayerOnPlate then
				gridEnt.State = 3
			elseif not FLIP:IsEntityInReflection(ent) and gridEnt.State == 3 and not grid_save.PeterBPlateTriggered then
				validPlayerOnPlate = true
				gridEnt.State = 0
				grid_save.PeterBPlateTriggered = true
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_PRESSUREPLATE_UPDATE, FLIP.PressurePlateUpdate)

--#endregion

--#region Weakness/Strength

---@param npc EntityNPC
function FLIP:RenderReflectiveStatusEffects(npc, offset)
	if PETER_B:UsePeterFlipRoomEffects()
		and not npc:IsBoss()
		and Mod.Room():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT
	then
		local data = Mod:GetData(npc)
		local anim = ""
		for _, statusFlag in ipairs(VANILLA_STATUS_PRIORITY) do
			if npc:HasEntityFlags(statusFlag) then
				anim = FLAG_TO_ICON[statusFlag]
				break
			end
		end
		if anim ~= "" and (not data.PeterFlippedRenderStatus or data.PeterFlippedRenderStatus:GetAnimation() ~= anim) then
			data.PeterFlippedRenderStatus = data.PeterFlippedRenderStatus or Sprite("gfx/statuseffects.anm2")
			data.PeterFlippedRenderStatus:Play(anim)
		end
		local statusOffset = Mod:GetStatusEffectOffset(npc)

		if not data.PeterFlippedRenderStatus or anim == "" or not statusOffset then return end
		local renderPos = Isaac.WorldToRenderPosition(npc.Position + npc.PositionOffset) + offset - statusOffset
		data.PeterFlippedRenderStatus:Render(renderPos)
		if Mod:ShouldUpdateSprite() then
			data.PeterFlippedRenderStatus:Update()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, FLIP.RenderReflectiveStatusEffects)

function FLIP:AllowReflectiveStatusEffects(ent)
	if PETER_B:UsePeterFlipRoomEffects()
		and not SEL.Utils.IsOpenSegment(ent)
	then
		return true
	end
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.PRE_RENDER_STATUS_EFFECTS, FLIP.AllowReflectiveStatusEffects)

---@param ent Entity
function FLIP:PreApplyStrength(ent)
	if not (ent:IsActiveEnemy(false)
		and ent:IsVulnerableEnemy()
		and not ent:IsBoss()
		and ent:ToNPC()
		and ent:ToNPC().CanShutDoors
	) then
		return true
	end
end

SEL.Callbacks.AddCallback(SEL.Callbacks.ID.PRE_ADD_ENTITY_STATUS_EFFECT, FLIP.PreApplyStrength, FLIP.STATUS_STRENGTH)

---@param ent Entity
---@param amount number
function FLIP:HalfDamage(ent, amount, flags, source, countdown)
	if not ent:IsActiveEnemy(false) then return end
	local hasStrength = SEL:GetStatusEffectData(ent, FLIP.STATUS_STRENGTH)
	if hasStrength then
		return {Damage = amount * 0.75}
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, FLIP.HalfDamage)

---@param npc EntityNPC
function FLIP:StrengthAndWeakness(npc)
	local data = Mod:GetData(npc)
	if data.PeterFlipped then
		if MUDDLED_CROSS:IsRoomEffectActive() then
			if SEL:HasStatusEffect(npc, FLIP.STATUS_STRENGTH) then
				SEL:RemoveStatusEffect(npc, FLIP.STATUS_STRENGTH)
			end
			if not npc:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
				npc:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
			end
		elseif not MUDDLED_CROSS:IsRoomEffectActive() and not SEL:HasStatusEffect(npc, FLIP.STATUS_STRENGTH) then
			if not SEL:HasStatusEffect(npc, FLIP.STATUS_STRENGTH) then
				SEL:AddStatusEffect(npc, FLIP.STATUS_STRENGTH, -1, EntityRef(nil))
			end
			if npc:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
				npc:ClearEntityFlags(EntityFlag.FLAG_WEAKNESS)
			end
		end
	end
	if npc:IsBoss() then
		if MUDDLED_CROSS:IsRoomEffectActive() and not npc:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
			npc:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
		elseif not MUDDLED_CROSS:IsRoomEffectActive() and npc:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
			npc:ClearEntityFlags(EntityFlag.FLAG_WEAKNESS)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, FLIP.StrengthAndWeakness)

--#endregion

--#region Flip effect

---@param itemConfig ItemConfigItem
function FLIP:OnLoseFlipEffect(itemConfig)
	if itemConfig:IsCollectible()
		and itemConfig.ID == MUDDLED_CROSS.ID
		--Should only ever be false if removed via instant room change (i.e. debug console)
		and (not Mod.Game:IsPaused() or RoomTransition.GetTransitionMode() > 0)
	then
		Mod.SFXMan:Play(MUDDLED_CROSS.SFX_UNFLIP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_EFFECT_REMOVED, FLIP.OnLoseFlipEffect)

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
			--Should only ever be true if done within via instant room change (i.e. debug console) or restarting the game via holding R
			if (Mod.Game:IsPaused() and RoomTransition.GetTransitionMode() == 0) or Mod.Game:GetFrameCount() == 0 then
				FLIP.FLIP_FACTOR = 0
				return
			end
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
