local Mod = Furtherance
local SEL = StatusEffectLibrary
local FLIP = Mod.Character.PETER_B.FLIP

local SEPARATE_SIDES = {}

--So that their Pathfinders obey their ability to ignore grid entities
---@param npc EntityNPC
function SEPARATE_SIDES:AdjustEnemyGridCollision(npc)
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

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, SEPARATE_SIDES.AdjustEnemyGridCollision)

---@param ent Entity
function SEPARATE_SIDES:BringEnemyToFlipside(ent)
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
	SEL:AddStatusEffect(ent, FLIP.STATUS_EFFECTS.STRENGTH_FLAG, -1, EntityRef(nil))
	ent:SetColor(StatusEffectLibrary.StatusConfig[Mod.Character.PETER_B.FLIP.STATUS_EFFECTS.STRENGTH_NAME].Color, 32, 1,
		false, false)
	data.PeterJustFlipped = true
	Isaac.CreateTimer(function()
		data.PeterJustFlipped = false
		ent.EntityCollisionClass = oldCollision
		ent:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
	end, 30, 1, false)
end

---@param ent Entity
---@param collider Entity
function SEPARATE_SIDES:CollisionMode(ent, collider)
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
		local isFlippedEnemy = FLIP:IsFlippedEnemy(damageSource)
		if oppositeTarget:ToPlayer()
			and FLIP:ValidEnemyToFlip(ent)
			and not isFlippedEnemy
			and not FLIP:IsRoomEffectActive()
		then
			SEPARATE_SIDES:BringEnemyToFlipside(damageSource)
			return false
		end
		local enemyData = Mod:GetData(enemyTarget)
		local entData = Mod:GetData(ent)
		if (entData.PeterFlippedIgnoredRenderFlag ~= enemyData.PeterFlippedIgnoredRenderFlag or Mod:GetData(enemyTarget).PeterJustFlipped) and not enemyTarget:IsBoss() then
			return true
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_LASER_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, CallbackPriority.IMPORTANT,
	SEPARATE_SIDES.CollisionMode)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES.CollisionMode)

---@param ent Entity
---@param gridIndex integer
---@param gridEnt GridEntity?
function SEPARATE_SIDES:GridCollision(ent, gridIndex, gridEnt)
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

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, CallbackPriority.IMPORTANT,
	SEPARATE_SIDES.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_GRID_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES
	.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_GRID_COLLISION, CallbackPriority.IMPORTANT,
	SEPARATE_SIDES.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_BOMB_GRID_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES
	.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_GRID_COLLISION, CallbackPriority.IMPORTANT,
	SEPARATE_SIDES.GridCollision)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, CallbackPriority.IMPORTANT, SEPARATE_SIDES.GridCollision)

---@param ent Entity
---@param source EntityRef
function SEPARATE_SIDES:HandleDamage(ent, amount, flags, source, countdown)
	if source.Entity then
		--If they shouldn't collide, ignore all sources of damage from that side as well
		local shouldNotCollide = SEPARATE_SIDES:CollisionMode(ent, source.Entity)
		if shouldNotCollide then
			return false
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.IMPORTANT, SEPARATE_SIDES.HandleDamage)

---Mainly for spikes
---@param gridEnt GridEntity
---@param ent Entity
function SEPARATE_SIDES:PreventDamageFromGrids(gridEnt, ent, _, _)
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

Mod:AddCallback(ModCallbacks.MC_GRID_HURT_DAMAGE, SEPARATE_SIDES.PreventDamageFromGrids)

---@param gridEnt GridEntity
function SEPARATE_SIDES:PreventNoCollGridUpdate(gridEnt)
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

Mod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_WEB_UPDATE, SEPARATE_SIDES.PreventNoCollGridUpdate)
Mod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_TELEPORTER_UPDATE, SEPARATE_SIDES.PreventNoCollGridUpdate)

---@param gridEnt GridEntityPressurePlate
function SEPARATE_SIDES:PressurePlateUpdate(gridEnt)
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

Mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_PRESSUREPLATE_UPDATE, SEPARATE_SIDES.PressurePlateUpdate)

---@param tear EntityTear
function SEPARATE_SIDES:FlatStone(tear)
	if tear:HasTearFlags(TearFlags.TEAR_HYDROBOUNCE)
		and tear.PositionOffset.Y == -5
	then
		local normal = FLIP:GetIgnoredWaterClipFlag()
		local inverse = FLIP:GetIgnoredWaterClipFlag(true)
		local data = Mod:GetData(tear)

		if data.PeterFlippedIgnoredRenderFlag == normal then
			data.PeterFlippedIgnoredRenderFlag = inverse
		else
			data.PeterFlippedIgnoredRenderFlag = normal
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, SEPARATE_SIDES.FlatStone)