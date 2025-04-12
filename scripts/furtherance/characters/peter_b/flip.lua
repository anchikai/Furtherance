--#region Variables

local SEL = StatusEffectLibrary
local Mod = Furtherance

local FLIP = {}

local PETER_B = Mod.Character.PETER_B
local MUDDLED_CROSS = Mod.Item.MUDDLED_CROSS
Furtherance.Item.MUDDLED_CROSS.FLIP = FLIP

FLIP.FLIP_FACTOR = 0
FLIP.FLIP_SPEED = 0.2
FLIP.PAUSE_ENEMIES_DURING_FLIP = false
FLIP.FREEZE_ROOM_EFFECT_COOLDOWN = 0
FLIP.PETER_EFFECTS_ACTIVE = false
FLIP.SHOW_DEBUG = false

FLIP.TEAR_DEATH_EFFECTS = Mod:Set({
	EffectVariant.TEAR_POOF_A,
	EffectVariant.TEAR_POOF_B,
	EffectVariant.TEAR_POOF_SMALL,
	EffectVariant.TEAR_POOF_VERYSMALL,
	EffectVariant.BOMB_EXPLOSION,
	EffectVariant.BLOOD_EXPLOSION,
	EffectVariant.BULLET_POOF
})
FLIP.BLACKLISTED_EFFECTS = Mod:Set({
	EffectVariant.PURGATORY
})
FLIP.ENEMY_EFFECTS = Mod:Set({
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
--They have their own funky mirror stuff. Don't bother with their effects and allow them to exist on both sides
FLIP.BLACKLISTED_ENTITIES = Mod:Set({
	EntityType.ENTITY_WRAITH,
	EntityType.ENTITY_GAPING_MAW,
	EntityType.ENTITY_BROKEN_GAPING_MAW
})
--Not an enemy but should only be interactable on the above world
FLIP.WHITELISTED_ENTITIES = Mod:Set({
	EntityType.ENTITY_MOVABLE_TNT
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

local floor = math.floor

local identifier = "FR_STRENGTH"
local statusSprite = Sprite("gfx/ui/fr_statuseffects.anm2", true)
statusSprite:Play("Strength")
local STATUS_COLOR = Color(1, 1, 1, 1, 0.3, 0, 0, 0.2, 0, 0, 0.75)
SEL.RegisterStatusEffect(identifier, statusSprite, STATUS_COLOR, nil, true)

FLIP.STATUS_STRENGTH = SEL.StatusFlag[identifier]

--local DISABLE_ABOVE_WATER = WaterClipFlag.DISABLE_RENDER_ABOVE_WATER | WaterClipFlag.DISABLE_RENDER_BELOW_WATER
--@cast DISABLE_ABOVE_WATER WaterClipFlag

--#endregion

--#region Helpers

---@param ent Entity
function FLIP:ShouldIgnoreEnemy(ent)
	return ent:IsBoss()
		or FLIP.BLACKLISTED_ENTITIES[ent.Type]
end

---@param ent Entity
function FLIP:ValidEnemyToFlip(ent)
	return ent:IsActiveEnemy(false)
		and ent:ToNPC()
		and ent:ToNPC().CanShutDoors
		and not FLIP:ShouldIgnoreEnemy(ent)
end

---@param inverse? boolean
---@return RenderMode
function FLIP:GetIgnoredWaterClipFlag(inverse)
	if Mod.Room():IsMirrorWorld() then
		inverse = not inverse
	end
	--[[ local waterClipFlag = inverse and WaterClipFlag.DISABLE_RENDER_REFLECTION or DISABLE_ABOVE_WATER
	if MUDDLED_CROSS:IsRoomEffectActive() then
		waterClipFlag = inverse and DISABLE_ABOVE_WATER or WaterClipFlag.DISABLE_RENDER_REFLECTION
	end ]]
	local waterClipFlag = inverse and RenderMode.RENDER_WATER_REFLECT or RenderMode.RENDER_WATER_ABOVE
	if MUDDLED_CROSS:IsRoomEffectActive() then
		waterClipFlag = inverse and RenderMode.RENDER_WATER_ABOVE or RenderMode.RENDER_WATER_REFLECT
	end
	return waterClipFlag
end

---@param ent Entity
function FLIP:IsFlippedEnemy(ent)
	local data = Mod:GetData(ent)
	return (data.PeterFlipped
			or ent:HasEntityFlags(EntityFlag.FLAG_CHARM)
			or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
		or not ent:IsActiveEnemy(true) and MUDDLED_CROSS:IsRoomEffectActive()
end

---@param ent Entity
function FLIP:TryGetEnemy(ent)
	if FLIP:ShouldIgnoreEnemy(ent) then return end
	return ent.SpawnerEntity and ent.SpawnerEntity:ToNPC() or ent:ToNPC()
end

---@param ent Entity
function FLIP:IsEntitySubmerged(ent)
	local player = Mod:TryGetPlayer(ent)
	local flipActive = MUDDLED_CROSS:IsRoomEffectActive()
	local fromEnemy = FLIP:TryGetEnemy(ent)
	local isFlippedEnemy = fromEnemy and FLIP:IsFlippedEnemy(fromEnemy)
	return (player and PETER_B:IsPeterB(player) and not flipActive)
		or (fromEnemy and isFlippedEnemy and not flipActive)
		or (fromEnemy and not isFlippedEnemy and flipActive)
end

---@param ent Entity
---@param parent? Entity @Set to use this Entity for checking whether or not to be reflected, and to put the result onto `ent`
function FLIP:SetAppropriateWaterClipFlag(ent, parent)
	local flagCheckEnt = parent or ent
	local enemy = FLIP:TryGetEnemy(flagCheckEnt)
	local player = Mod:TryGetPlayer(flagCheckEnt)
	local data = Mod:GetData(ent)

	if enemy and (not FLIP:ShouldIgnoreEnemy(enemy) or FLIP:ValidEnemyToFlip(ent)) then
		local isFlippedEnemy = FLIP:IsFlippedEnemy(enemy)
		local flag = FLIP:GetIgnoredWaterClipFlag(not isFlippedEnemy)
		if flag then
			--[[ local flags = flagCheckEnt:GetWaterClipFlags()
			if Mod:HasBitFlags(flags, WaterClipFlag.ENABLE_RENDER_BELOW_WATER) then
				flag = flag | WaterClipFlag.ENABLE_RENDER_BELOW_WATER
			end ]]
			data.PeterFlippedIgnoredRenderFlag = flag
			--ent:SetWaterClipFlags(flag)
		end
	elseif player then
		if PETER_B:IsPeterB(player) then
			local flag = FLIP:GetIgnoredWaterClipFlag()
			data.PeterFlippedIgnoredRenderFlag = flag
			--ent:SetWaterClipFlags(flag)
		else
			--local flag = Mod.Room():IsMirrorWorld() and DISABLE_ABOVE_WATER or WaterClipFlag.DISABLE_RENDER_REFLECTION
			local flag = Mod.Room():IsMirrorWorld() and RenderMode.RENDER_WATER_ABOVE or RenderMode.RENDER_WATER_REFLECT
			data.PeterFlippedIgnoredRenderFlag = flag
			--ent:SetWaterClipFlags(flag)
		end
	end
end

---@param ent Entity
function FLIP:FlipEnemy(ent)
	local data = Mod:GetData(ent)
	data.PeterFlipped = true
	local flag = FLIP:GetIgnoredWaterClipFlag()
	if MUDDLED_CROSS:IsRoomEffectActive() then
		flag = FLIP:GetIgnoredWaterClipFlag(true)
	end
	--[[ if Mod:HasBitFlags(ent:GetWaterClipFlags(), WaterClipFlag.ENABLE_RENDER_BELOW_WATER) then
		flag = flag | WaterClipFlag.ENABLE_RENDER_BELOW_WATER
	end
	ent:SetWaterClipFlags(flag) ]]
	data.PeterFlippedIgnoredRenderFlag = flag
end

--#endregion

--#region Update if Peter Flip Room Effects should be active

function FLIP:OnUpdate()
	FLIP.PETER_EFFECTS_ACTIVE = PETER_B:UsePeterFlipRoomEffects()
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FLIP.OnUpdate)

--#endregion

--#region Handle entity rendering via WaterClipFlags

---@param ent Entity
function FLIP:FlipIfRelatedEntity(ent)
	if ent.SpawnerEntity and FLIP:IsFlippedEnemy(ent.SpawnerEntity)
		and FLIP:ValidEnemyToFlip(ent)
	then
		FLIP:FlipEnemy(ent)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, FLIP.FlipIfRelatedEntity)

function FLIP:UpdateReflections()
	if FLIP.PETER_EFFECTS_ACTIVE then
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			FLIP:SetAppropriateWaterClipFlag(ent)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.PETER_B_ENEMY_ROOM_FLIP, FLIP.UpdateReflections)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FLIP.UpdateReflections)

function FLIP:UpdateShouldUsePeter()
	FLIP.PETER_EFFECTS_ACTIVE = PETER_B:UsePeterFlipRoomEffects()
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, FLIP.UpdateShouldUsePeter)

---@param ent Entity
function FLIP:Reflection(ent)
	if FLIP.PETER_EFFECTS_ACTIVE then
		FLIP:SetAppropriateWaterClipFlag(ent)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, FLIP.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, FLIP.Reflection)

---!Temporarily in place while we wait for RGON to come out of Rep+ development
---@param ent Entity
function FLIP:TempPreRender(ent)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end
	local renderMode = Mod.Room():GetRenderMode()
	local data = Mod:GetData(ent)
	if renderMode == data.PeterFlippedIgnoredRenderFlag then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, FLIP.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, FLIP.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, FLIP.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_BOMB_RENDER, FLIP.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_RENDER, FLIP.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_RENDER, FLIP.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, FLIP.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, FLIP.TempPreRender)

if Isaac.IsInGame() then
	FLIP.PETER_EFFECTS_ACTIVE = PETER_B:UsePeterFlipRoomEffects()
	FLIP:UpdateReflections()
end

--#endregion

--#region Manage specific effects

---@param tearOrProj EntityTear | EntityProjectile
function FLIP:TearSplash(tearOrProj)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end

	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
		if ent.Position:DistanceSquared(tearOrProj.Position) <= 1
			and FLIP.TEAR_DEATH_EFFECTS[ent.Variant]
		then
			FLIP:SetAppropriateWaterClipFlag(ent, tearOrProj)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, FLIP.TearSplash)
Mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, FLIP.TearSplash)

function FLIP:PostBombExplode(bomb)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end

	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
		if ent.Position:DistanceSquared(bomb.Position) <= 1 and FLIP.TEAR_DEATH_EFFECTS[ent.Variant] then
			FLIP:SetAppropriateWaterClipFlag(ent, bomb)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, FLIP.PostBombExplode)

---@param effect EntityEffect
function FLIP:MarkEnemyEffectOnInit(effect)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end

	if effect.SpawnerEntity
		and not FLIP.BLACKLISTED_EFFECTS[effect.Variant]
	then
		FLIP:SetAppropriateWaterClipFlag(effect, effect.SpawnerEntity)
	else
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if FLIP:TryGetEnemy(ent)
				and effect.Position:DistanceSquared(ent.Position) <= 500
				and FLIP.ENEMY_EFFECTS[effect.Variant]
			then
				FLIP:SetAppropriateWaterClipFlag(effect, ent)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, FLIP.MarkEnemyEffectOnInit)

---@param npc EntityNPC
function FLIP:MarkEnemyEffectOnDeath(npc)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end

	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
		if ent.Position:DistanceSquared(npc.Position) <= 324
			and FLIP.ENEMY_EFFECTS[ent.Variant]
		then
			FLIP:SetAppropriateWaterClipFlag(ent, npc)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, FLIP.MarkEnemyEffectOnDeath)

--#endregion

--#region Handle collision/ignoring damage

--So that their Pathfinders obey their ability to ignore grid entities
---@param npc EntityNPC
function FLIP:AdjustEnemyGridCollision(npc)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end
	local data = Mod:GetData(npc)
	if not data.PeterFlipOGGridColl then return end
	if FLIP:IsFlippedEnemy(npc) then
		if FLIP:IsEntitySubmerged(npc) then
			npc.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
		else
			npc.GridCollisionClass = data.PeterFlipOGGridColl
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, FLIP.AdjustEnemyGridCollision)

---@param ent Entity
function FLIP:BringEnemyToFlipside(ent)
	local data = Mod:GetData(ent)
	FLIP:FlipEnemy(ent)
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
	data.PeterJustFlipped = true
	Isaac.CreateTimer(function()
		data.PeterJustFlipped = false
		ent.EntityCollisionClass = oldCollision
		ent:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
	end, 30, 1, false)
end

---@param ent Entity
---@param collider Entity
function FLIP:CollisionMode(ent, collider)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end
	local damageSource
	local enemyTarget
	local oppositeTarget
	if FLIP:TryGetEnemy(ent) then
		enemyTarget = FLIP:TryGetEnemy(ent)
		damageSource = ent
		oppositeTarget = collider
	elseif FLIP:TryGetEnemy(collider) then
		enemyTarget = FLIP:TryGetEnemy(collider)
		damageSource = collider
		oppositeTarget = ent
	end
	if enemyTarget then
		local fromFlippedEnemy = FLIP:IsFlippedEnemy(enemyTarget)
		local isFlippedEnemy = FLIP:IsFlippedEnemy(damageSource)
		if oppositeTarget:ToPlayer()
			and FLIP:ValidEnemyToFlip(ent)
			and not isFlippedEnemy
			and not MUDDLED_CROSS:IsRoomEffectActive()
		then
			FLIP:BringEnemyToFlipside(damageSource)
			return false
		end
		if (not fromFlippedEnemy or Mod:GetData(enemyTarget).PeterJustFlipped) and not enemyTarget:IsBoss() then
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
	if FLIP.PETER_EFFECTS_ACTIVE
		and (
			(gridEnt
				and (
					gridEnt:ToRock()
					or gridEnt:ToPoop()
					or gridEnt:ToStatue()
					or gridEnt:ToTNT()
					or gridEnt:ToPit()
				) and FLIP:IsEntitySubmerged(ent))
			or not gridEnt and Mod.Room():GetGridPath(gridIndex) >= 1000
		)
	then
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_GRID_COLLISION, CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_GRID_COLLISION, CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_BOMB_GRID_COLLISION, CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_GRID_COLLISION, CallbackPriority.IMPORTANT, FLIP.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, CallbackPriority.IMPORTANT, FLIP.GridCollision)

---@param ent Entity
---@param source EntityRef
function FLIP:HandleDamage(ent, amount, flags, source, countdown)
	if source.Entity then
		--If they shouldn't collide, ignore all sources of damage from that side as well
		local shouldNotCollide = FLIP:CollisionMode(ent, source.Entity)
		if shouldNotCollide then
			return false
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.IMPORTANT, FLIP.HandleDamage)

---Mainly for spikes
---@param gridEnt GridEntity
---@param ent Entity
function FLIP:PreventDamageFromGrids(gridEnt, ent, _, _)
	if FLIP.PETER_EFFECTS_ACTIVE
		and FLIP:IsEntitySubmerged(ent)
		and not gridEnt:ToSpikes()
		or (
			Mod.Room():GetType() ~= RoomType.ROOM_SACRIFICE
			and (Mod.Room():GetType() ~= RoomType.ROOM_DEVIL
				or gridEnt:GetGridIndex() ~= 67) --Sanguine Bond
		)
	then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_GRID_HURT_DAMAGE, FLIP.PreventDamageFromGrids)

---@param gridEnt GridEntity
function FLIP:PreventNoCollGridUpdate(gridEnt)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end
	for _, ent in ipairs(Isaac.GetRoomEntities()) do
		if (ent:ToPlayer() or ent:ToNPC())
			and ent.Position:DistanceSquared(gridEnt.Position) <= 40 ^ 2
			and FLIP:IsEntitySubmerged(ent)
		then
			return false
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_WEB_UPDATE, FLIP.PreventNoCollGridUpdate)
Mod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_TELEPORTER_UPDATE, FLIP.PreventNoCollGridUpdate)

---@param gridEnt GridEntityPressurePlate
function FLIP:PressurePlateUpdate(gridEnt)
	if FLIP.PETER_EFFECTS_ACTIVE
		and (not Mod.Game:IsGreedMode()
			or gridEnt:GetGridIndex() == 112
			and not Mod:IsInStartingRoom()
		)
		and gridEnt.State ~= 1
	then
		local grid_save = Mod:RoomSave(gridEnt:GetGridIndex())
		local validPlayerOnPlate = false
		for _, ent in ipairs(Isaac.FindInRadius(gridEnt.Position, 40, EntityPartition.PLAYER)) do
			if FLIP:IsEntitySubmerged(ent) and gridEnt.State == 0 and not validPlayerOnPlate then
				gridEnt.State = 3
			elseif not FLIP:IsEntitySubmerged(ent) and gridEnt.State == 3 and not grid_save.PeterBPlateTriggered then
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
	if FLIP.PETER_EFFECTS_ACTIVE
		and not FLIP:ShouldIgnoreEnemy(npc)
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
	if FLIP.PETER_EFFECTS_ACTIVE
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
			and not FLIP:ShouldIgnoreEnemy(ent)
			and ent:ToNPC()
			and ent:ToNPC().CanShutDoors
		)
	then
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
		return { Damage = amount * 0.75 }
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
	if FLIP:ShouldIgnoreEnemy(npc) then
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
	local isFlipped = Mod.Room():GetEffects():HasCollectibleEffect(MUDDLED_CROSS.ID)
	if not Mod.Game:IsPauseMenuOpen() then
		if not isFlipped then
			--Should only ever be true if done within via instant room change (i.e. debug console) or restarting the game via holding R
			if Mod.Game:GetFrameCount() == 0 then
				FLIP.FLIP_FACTOR = 0
				return
			end
		end
		local lerp = Mod:Lerp(FLIP.FLIP_FACTOR, isFlipped and 1 or 0, FLIP.FLIP_SPEED)
		FLIP.FLIP_FACTOR = Mod:Clamp(floor(lerp * 100) / 100, 0, 1)
	end

	if FLIP.FLIP_FACTOR > 0.05 and FLIP.FLIP_FACTOR < 0.95 then
		Isaac.RunCallback(Mod.ModCallbacks.PETER_B_ENEMY_ROOM_FLIP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, FLIP.AnimateFlip)

---@param ent EntityNPC | EntityPlayer
function FLIP:FlashNearFlipEnd(ent)
	if FLIP.PETER_EFFECTS_ACTIVE
		and not FLIP:IsEntitySubmerged(ent)
		and (FLIP:ValidEnemyToFlip(ent) or ent:ToPlayer())
	then
		local room = Mod.Room():GetEffects()
		if room:HasCollectibleEffect(MUDDLED_CROSS.ID) then
			local cooldown = room:GetCollectibleEffect(MUDDLED_CROSS.ID).Cooldown
			if cooldown > 0 and cooldown < 60 and cooldown % 15 == 0 then
				ent:SetColor(STATUS_COLOR, 15, 10, true, false)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, FLIP.FlashNearFlipEnd)
Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, FLIP.FlashNearFlipEnd)

function FLIP:BeepNearFlipEnd()
	local room = Mod.Room():GetEffects()
	if room:HasCollectibleEffect(MUDDLED_CROSS.ID) then
		local cooldown = room:GetCollectibleEffect(MUDDLED_CROSS.ID).Cooldown
		if cooldown > 0 and cooldown < 60 and cooldown % 15 == 0 then
			Mod.SFXMan:Play(SoundEffect.SOUND_BEEP)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FLIP.BeepNearFlipEnd)

function FLIP:FreezeEnemiesDuringFlip()
	local effects = Mod.Room():GetEffects()
	if FLIP.FLIP_FACTOR > 0.05 and FLIP.FLIP_FACTOR < 0.95 then
		local roomEffects = Mod.Room():GetEffects()
		if roomEffects:HasCollectibleEffect(MUDDLED_CROSS.ID) then
			if FLIP.FREEZE_ROOM_EFFECT_COOLDOWN == 0 then
				FLIP.FREEZE_ROOM_EFFECT_COOLDOWN = roomEffects:GetCollectibleEffect(MUDDLED_CROSS.ID).Cooldown + 1
			end
			roomEffects:GetCollectibleEffect(MUDDLED_CROSS.ID).Cooldown = FLIP.FREEZE_ROOM_EFFECT_COOLDOWN
		end
		if not FLIP.PAUSE_ENEMIES_DURING_FLIP then
			Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, false, false, false, false, -1)
			Isaac.GetPlayer():GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_PAUSE)
			FLIP.PAUSE_ENEMIES_DURING_FLIP = true
			for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
				if not ent:IsDead() then
					ent:Die()
				end
			end
		end
	else
		if FLIP.PAUSE_ENEMIES_DURING_FLIP then
			FLIP.PAUSE_ENEMIES_DURING_FLIP = false
			FLIP.FREEZE_ROOM_EFFECT_COOLDOWN = 0
			effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_PAUSE)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FLIP.FreezeEnemiesDuringFlip)

-- Thank you im_tem for the shader!!
function FLIP:PeterFlip(name)
	if name == "Peter Flip" then
		local factor = MUDDLED_CROSS.FLIP_FACTOR > 0 and MUDDLED_CROSS.FLIP_FACTOR or FLIP.FLIP_FACTOR
		if Mod.FLAGS.Debug and FLIP.SHOW_DEBUG then
			Isaac.RenderText("Expected to Peter Flip:" .. tostring(Mod.Room():GetEffects():HasCollectibleEffect(MUDDLED_CROSS.ID)), 50, 30, 1, 1, 1, 1)
			Isaac.RenderText("Expected to Room Flip (Overrides Peter Flip):" .. tostring(MUDDLED_CROSS.TARGET_FLIP > 0), 50, 45, 1, 1, 1, 1)
			Isaac.RenderText("Peter Flip Factor:" .. tostring(FLIP.FLIP_FACTOR), 50, 60, 1, 1, 1, 1)
			Isaac.RenderText("Room Flip Factor:" .. tostring(MUDDLED_CROSS.FLIP_FACTOR), 50, 75, 1, 1, 1, 1)
		end
		return { FlipFactor = Mod.Game:IsPauseMenuOpen() and 0 or factor }
	elseif name == "Peter Flip HUD" then
		if FLIP.PETER_EFFECTS_ACTIVE then
			Mod.HUD:SetVisible(true)
			Mod.HUD:Render()
			Mod.HUD:SetVisible(false)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, FLIP.PeterFlip)

function Mod:PrintPeterBFlip()
	print("Expected to Peter Flip:" .. Mod.Room():GetEffects():HasCollectibleEffect(MUDDLED_CROSS.ID))
	print("Expected to Room Flip (Overrides Peter Flip):" .. MUDDLED_CROSS.TARGET_FLIP > 0)
	print("Peter Flip Factor:" ..FLIP.FLIP_FACTOR)
	print("Room Flip Factor:" .. MUDDLED_CROSS.FLIP_FACTOR)
end

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

--#region Lower ripple volume

function FLIP:ReduceRippleSound(id, volume, frameDelay, loop, pitch, pan)
	if FLIP.PETER_EFFECTS_ACTIVE then
		return {id, 0.05, frameDelay, loop, pitch, pan}
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, FLIP.ReduceRippleSound, SoundEffect.SOUND_WET_FEET)

--#endregion

return FLIP
