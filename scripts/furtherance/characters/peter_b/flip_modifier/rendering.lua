local Mod = Furtherance
local PETER_B = Mod.Character.PETER_B
local FLIP = PETER_B.FLIP

local FLIP_RENDERING = {}

--local DISABLE_ABOVE_WATER = WaterClipFlag.DISABLE_RENDER_ABOVE_WATER | WaterClipFlag.DISABLE_RENDER_BELOW_WATER
--@cast DISABLE_ABOVE_WATER WaterClipFlag

---@param ent Entity
---@param parent? Entity @Set to use this Entity for checking whether or not to be reflected, and to put the result onto `ent`
function FLIP_RENDERING:SetAppropriateWaterClipFlag(ent, parent)
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

--#region Handle entity rendering via WaterClipFlags

---@param ent Entity
function FLIP_RENDERING:FlipIfRelatedEntity(ent)
	if ent.SpawnerEntity and FLIP:IsFlippedEnemy(ent.SpawnerEntity)
		and FLIP:ValidEnemyToFlip(ent)
	then
		FLIP:FlipEnemy(ent)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, FLIP_RENDERING.FlipIfRelatedEntity)

function FLIP_RENDERING:UpdateReflections()
	if FLIP.PETER_EFFECTS_ACTIVE then
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			FLIP_RENDERING:SetAppropriateWaterClipFlag(ent)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.PETER_B_ENEMY_ROOM_FLIP, FLIP_RENDERING.UpdateReflections)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FLIP_RENDERING.UpdateReflections)

function FLIP_RENDERING:UpdateShouldUsePeter()
	FLIP.PETER_EFFECTS_ACTIVE = PETER_B:UsePeterFlipRoomEffects()
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, FLIP_RENDERING.UpdateShouldUsePeter)

---@param ent Entity
function FLIP_RENDERING:Reflection(ent)
	if FLIP.PETER_EFFECTS_ACTIVE then
		FLIP_RENDERING:SetAppropriateWaterClipFlag(ent)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, FLIP_RENDERING.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, FLIP_RENDERING.Reflection)
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FLIP_RENDERING.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, FLIP_RENDERING.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, FLIP_RENDERING.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, FLIP_RENDERING.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, FLIP_RENDERING.Reflection)
Mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, FLIP_RENDERING.Reflection)

---!Temporarily in place while we wait for RGON to come out of Rep+ development
---@param ent Entity
function FLIP_RENDERING:TempPreRender(ent)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end
	local renderMode = Mod.Room():GetRenderMode()
	local data = Mod:GetData(ent)
	if renderMode == data.PeterFlippedIgnoredRenderFlag then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, FLIP_RENDERING.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, FLIP_RENDERING.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, FLIP_RENDERING.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_BOMB_RENDER, FLIP_RENDERING.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_RENDER, FLIP_RENDERING.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_RENDER, FLIP_RENDERING.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, FLIP_RENDERING.TempPreRender)
Mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, FLIP_RENDERING.TempPreRender)

if Isaac.IsInGame() then
	FLIP.PETER_EFFECTS_ACTIVE = PETER_B:UsePeterFlipRoomEffects()
	FLIP_RENDERING:UpdateReflections()
end

--#endregion

--#region Manage specific effects

---@param tearOrProj EntityTear | EntityProjectile
function FLIP_RENDERING:TearSplash(tearOrProj)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end
	local renderFlag = Mod:GetData(tearOrProj).PeterFlippedIgnoredRenderFlag

	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
		if ent.Position:DistanceSquared(tearOrProj.Position) <= 1
			and FLIP.TEAR_DEATH_EFFECTS[ent.Variant]
		then
			Mod:GetData(ent).PeterFlippedIgnoredRenderFlag = renderFlag
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, FLIP_RENDERING.TearSplash)
Mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, FLIP_RENDERING.TearSplash)

function FLIP_RENDERING:PostBombExplode(bomb)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end
	local renderFlag = Mod:GetData(bomb).PeterFlippedIgnoredRenderFlag

	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
		if ent.Position:DistanceSquared(bomb.Position) <= 1 and FLIP.TEAR_DEATH_EFFECTS[ent.Variant] then
			Mod:GetData(ent).PeterFlippedIgnoredRenderFlag = renderFlag
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, FLIP_RENDERING.PostBombExplode)

---@param effect EntityEffect
function FLIP:MarkEnemyEffectOnInit(effect)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end

	if effect.SpawnerEntity
		and not FLIP.BLACKLISTED_EFFECTS[effect.Variant]
	then
		FLIP_RENDERING:SetAppropriateWaterClipFlag(effect, effect.SpawnerEntity)
	else
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if FLIP:TryGetEnemy(ent)
				and effect.Position:DistanceSquared(ent.Position) <= 500
				and Mod.Item.KEYS_TO_THE_KINGDOM.ENEMY_DEATH_EFFECTS[effect.Variant]
			then
				local renderFlag = Mod:GetData(ent).PeterFlippedIgnoredRenderFlag
				Mod:GetData(effect).PeterFlippedIgnoredRenderFlag = renderFlag
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, FLIP.MarkEnemyEffectOnInit)

---@param npc EntityNPC
function FLIP_RENDERING:MarkEnemyEffectOnDeath(npc)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end

	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
		if ent.Position:DistanceSquared(npc.Position) <= 324
			and Mod.Item.KEYS_TO_THE_KINGDOM.ENEMY_DEATH_EFFECTS[ent.Variant]
		then
			FLIP_RENDERING:SetAppropriateWaterClipFlag(ent, npc)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, FLIP_RENDERING.MarkEnemyEffectOnDeath)

--#endregion

--#region Entity outline (GIGANTIC thanks to Goganidze)

local wtr = 20 / 13
local vd = Vector(0, 40)

function FLIP_RENDERING:AddOutlineSprite(ent, spr)
	local data = Mod:GetData(ent)
	local copyspr = Sprite(spr:GetFilename(), true)
	copyspr:SetFrame(spr:GetAnimation(), spr:GetFrame())
	copyspr:Play(spr:GetAnimation())

	for i, layer in pairs(spr:GetAllLayers()) do
		local id = layer:GetLayerID()
		local clayer = copyspr:GetLayer(id)
		---@cast clayer LayerState
		copyspr:ReplaceSpritesheet(id, layer:GetSpritesheetPath())
		clayer:SetColor(Color(1, 1, 1, 0.5, 0, 0, 0, i))
	end
	copyspr:SetCustomShader("shaders/PeterBOutline")
	copyspr:LoadGraphics()
	copyspr.Offset = spr.Offset / 1
	copyspr.FlipY = true
	copyspr.Color.A = 0

	data.GSGSAGS = data.GSGSAGS or {}
	Mod:Insert(data.GSGSAGS, { copyspr, Vector(0, 0), 0 })
end

---@param ent Entity
function FLIP_RENDERING:EntityUpdate(ent)
	if ent:ToNPC() and ent.FrameCount < 10 or ent.FrameCount < 1 then return end
	local data = Mod:GetData(ent)
	if not data.GSGSAGS
		and FLIP:IsEntitySubmerged(ent)
	then
		FLIP_RENDERING:AddOutlineSprite(ent, ent:GetSprite())
		local player = ent:ToPlayer()
		if player then
			local head = Mod:GetCostumeSpriteFromLayer(player, PlayerSpriteLayer.SPRITE_HEAD)
			local hair = Mod:GetCostumeSpriteFromLayer(player, PlayerSpriteLayer.SPRITE_HEAD0)
			if head then
				FLIP_RENDERING:AddOutlineSprite(ent, head)
			end
			if hair then
				FLIP_RENDERING:AddOutlineSprite(ent, hair)
			end
		end
	elseif data.GSGSAGS then
		for _, GSGSAGS in ipairs(data.GSGSAGS) do
			local cspr = GSGSAGS[1]
			local spr = ent:GetSprite()

			cspr.Rotation = spr.Rotation
			cspr.Offset = -(spr.Offset + ent.PositionOffset / wtr)
			cspr.Rotation = spr.Rotation - 180
			cspr.FlipX = not spr.FlipX
			cspr.FlipY = spr.FlipY

			cspr:SetOverlayFrame(spr:GetOverlayAnimation(), spr:GetOverlayFrame())
			cspr:SetFrame(spr:GetAnimation(), spr:GetFrame())
			local gridCol = Mod.Room():GetGridCollisionAtPos(ent.Position + vd)
			if gridCol == GridCollisionClass.COLLISION_SOLID or gridCol == GridCollisionClass.COLLISION_OBJECT
				or gridCol == GridCollisionClass.COLLISION_WALL then
				GSGSAGS[3] = GSGSAGS[3] * 0.8 + 0.2
			else
				GSGSAGS[3] = GSGSAGS[3] * 0.8
			end
			cspr.Color.A = GSGSAGS[3]
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, FLIP_RENDERING.EntityUpdate)
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, FLIP_RENDERING.EntityUpdate)
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, FLIP_RENDERING.EntityUpdate)
Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, FLIP_RENDERING.EntityUpdate)
Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, FLIP_RENDERING.EntityUpdate)
Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, FLIP_RENDERING.EntityUpdate)
Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, FLIP_RENDERING.EntityUpdate)
Mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, FLIP_RENDERING.EntityUpdate)

local WorldToScreen = Isaac.WorldToScreen

local renderlist = {}

function FLIP_RENDERING:EntityRender(ent, offset)
	local data = Mod:GetData(ent)
	if data.GSGSAGS then
		Mod:inverseiforeach(data.GSGSAGS, function(GSGSAGS)
			local cspr = GSGSAGS[1]
			local rendermod = Mod.Room():GetRenderMode()
			if rendermod == RenderMode.RENDER_WATER_REFLECT then
				renderlist[#renderlist + 1] = { cspr, WorldToScreen(ent.Position) }
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, FLIP_RENDERING.EntityRender)
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, FLIP_RENDERING.EntityRender)
Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, FLIP_RENDERING.EntityRender)
Mod:AddCallback(ModCallbacks.MC_POST_BOMB_RENDER, FLIP_RENDERING.EntityRender)
Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_RENDER, FLIP_RENDERING.EntityRender)
Mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_RENDER, FLIP_RENDERING.EntityRender)
Mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, FLIP_RENDERING.EntityRender)
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, FLIP_RENDERING.EntityRender)

local render = Sprite().Render
Mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	for i = 1, #renderlist do
		local sr = renderlist[i]
		render(sr[1], sr[2])
	end
	renderlist = {}
end)

--#endregion

return FLIP_RENDERING
