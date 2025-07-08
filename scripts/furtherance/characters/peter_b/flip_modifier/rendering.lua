local Mod = Furtherance
local PETER_B = Mod.Character.PETER_B
local FLIP = PETER_B.FLIP

local FLIP_RENDERING = {}

--local DISABLE_ABOVE_WATER = WaterClipFlag.DISABLE_RENDER_ABOVE_WATER | WaterClipFlag.DISABLE_RENDER_BELOW_WATER
--@cast DISABLE_ABOVE_WATER WaterClipFlag

---@param ent Entity
---@param parent? Entity @Set to use this Entity for checking whether or not to be reflected, and to put the result onto `ent`
function FLIP_RENDERING:SetAppropriateWaterClipFlag(ent, parent)
	local data = Mod:GetData(ent)
	local pData = parent and Mod:TryGetData(parent)
	if pData and pData.PeterFlippedIgnoredRenderFlag then
		data.PeterFlippedIgnoredRenderFlag = pData.PeterFlippedIgnoredRenderFlag
		if pData.PeterFlipped then
			data.PeterFlipped = pData.PeterFlipped
		end
		return
	end
	local enemy = FLIP:TryGetNPC(ent)
	local player = Mod:TryGetPlayer(ent)

	if player then
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
	elseif enemy and (not FLIP:ShouldIgnoreEntity(enemy) or FLIP:ValidEnemyToFlip(ent)) then
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
	end
end

--#region Handle entity rendering via WaterClipFlags

function FLIP_RENDERING:UpdateReflections()
	FLIP.PETER_EFFECTS_ACTIVE = PETER_B:UsePeterFlipRoomEffects()
	if FLIP.PETER_EFFECTS_ACTIVE then
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			FLIP_RENDERING:SetAppropriateWaterClipFlag(ent)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.PETER_B_ENEMY_ROOM_FLIP, FLIP_RENDERING.UpdateReflections)
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FLIP_RENDERING.UpdateReflections)
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, FLIP_RENDERING.UpdateReflections)

---@param ent Entity
function FLIP_RENDERING:Reflection(ent)
	if FLIP.PETER_EFFECTS_ACTIVE then
		FLIP_RENDERING:SetAppropriateWaterClipFlag(ent, ent.SpawnerEntity)
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

	if (renderMode == data.PeterFlippedIgnoredRenderFlag)
		or data.PeterFlippedIgnoredRenderFlag == RenderMode.RENDER_WATER_ABOVE
		and renderMode == RenderMode.RENDER_NORMAL
	then
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
	if not renderFlag then return end

	Mod.Foreach.EffectInRadius(tearOrProj.Position, 1, function(effect)
		if FLIP.TEAR_DEATH_EFFECTS[effect.Variant] or effect.SpawnerEntity and GetPtrHash(effect.SpawnerEntity) == GetPtrHash(tearOrProj) then
			Mod:GetData(effect).PeterFlippedIgnoredRenderFlag = renderFlag
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, FLIP_RENDERING.TearSplash)
Mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, FLIP_RENDERING.TearSplash)

function FLIP_RENDERING:PostBombExplode(bomb)
	if not FLIP.PETER_EFFECTS_ACTIVE then return end
	local renderFlag = Mod:GetData(bomb).PeterFlippedIgnoredRenderFlag
	if not renderFlag then return end

	Mod.Foreach.EffectInRadius(bomb.Position, 1, function(effect)
		if FLIP.TEAR_DEATH_EFFECTS[effect.Variant] then
			Mod:GetData(effect).PeterFlippedIgnoredRenderFlag = renderFlag
		end
	end)
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
			if FLIP:TryGetNPC(ent)
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

	Mod.Foreach.EffectInRadius(npc.Position, 324, function(effect)
		if FLIP.TEAR_DEATH_EFFECTS[effect.Variant]
			and Mod.Item.KEYS_TO_THE_KINGDOM.ENEMY_DEATH_EFFECTS[effect.Variant]
		then
			FLIP_RENDERING:SetAppropriateWaterClipFlag(effect, npc)
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, FLIP_RENDERING.MarkEnemyEffectOnDeath)

--#endregion

--#region Entity outline (GIGANTIC thanks to Goganidze)

local wtr = 20 / 13
local vd = Vector(0, 40)

---@param ent Entity
---@param spr Sprite
---@param trackMode? string @`head` to track the player's head animations. `body` for the body. `backup` if the player has a head and body costume and needs something to play player animations
function FLIP_RENDERING:AddOutlineSprite(ent, spr, trackMode)
	local data = Mod:GetData(ent)
	local copyspr = Mod:CopySprite(spr)
	local mirrorWorld = Mod.Room():IsMirrorWorld()

	for _, layer in pairs(spr:GetAllLayers()) do
		local id = layer:GetLayerID()
		local clayer = copyspr:GetLayer(id)
		local clayercolor = layer:GetColor()
		clayercolor.A = 0.5
		---@cast clayer LayerState
		copyspr:ReplaceSpritesheet(id, layer:GetSpritesheetPath())
		clayer:SetColor(clayercolor)
	end
	copyspr:SetCustomShader("shaders/PeterBOutline")
	copyspr:LoadGraphics()

	copyspr.Offset = spr.Offset / 1
	copyspr.Offset = -(spr.Offset + ent.PositionOffset / wtr)
	copyspr.Rotation = spr.Rotation - 180
	if mirrorWorld then
		copyspr.FlipX = spr.FlipX
	else
		copyspr.FlipX = not spr.FlipX
	end
	copyspr.Color.A = 0

	data.GSGSAGS = data.GSGSAGS or {}
	Mod.Insert(data.GSGSAGS, { copyspr, 0, spr, trackMode })
end

---@param ent Entity
function FLIP_RENDERING:EntityUpdate(ent)
	if ent:ToNPC() and ent.FrameCount < 10 or ent.FrameCount < 1 then return end
	local data = Mod:GetData(ent)
	local room = Mod.Room()
	local pos = ent.Position + vd + ent.PositionOffset
	local gridCol = room:GetGridCollisionAtPos(pos)
	local underSolid = gridCol == GridCollisionClass.COLLISION_SOLID
		or gridCol == GridCollisionClass.COLLISION_OBJECT
		or gridCol == GridCollisionClass.COLLISION_WALL
		or not room:IsPositionInRoom(pos, 0)
	local sprite = ent:GetSprite()

	if not data.GSGSAGS
		and FLIP:IsEntitySubmerged(ent)
		and underSolid
		and ent.Visible
	then
		local player = ent:ToPlayer()
		if player then
			local body = Mod:GetCostumeSpriteFromLayer(player, PlayerSpriteLayer.SPRITE_BODY)
			local head = Mod:GetCostumeSpriteFromLayer(player, PlayerSpriteLayer.SPRITE_HEAD)
			local hairCostume = EntityConfig.GetPlayer(player:GetPlayerType()):GetCostumeID()
			local hair
			if hairCostume == -1 or not hairCostume then
				hair = Mod:GetCostumeSpriteFromLayer(player, PlayerSpriteLayer.SPRITE_HEAD0)
			else
				local layerMap = player:GetCostumeLayerMap()
				local costumeDescs = player:GetCostumeSpriteDescs()
				for i = PlayerSpriteLayer.SPRITE_HEAD0, PlayerSpriteLayer.SPRITE_HEAD5 do
					local costumeLayer = layerMap[i + 1]
					if costumeLayer then
						local costumeIndex = costumeLayer.costumeIndex
						local costumeDesc = costumeDescs[costumeIndex + 1]
						local itemConfig = costumeDesc:GetItemConfig()
						if itemConfig:IsNull() and costumeDesc and itemConfig.ID == hairCostume then
							hair = costumeDesc:GetSprite()
							break
						end
					end
				end
			end

			if hair then
				FLIP_RENDERING:AddOutlineSprite(ent, hair, "head")
			end
			if (not head and not body) or head and body then
				FLIP_RENDERING:AddOutlineSprite(ent, sprite, head and body and "backup" or nil)
			end
			if head then
				FLIP_RENDERING:AddOutlineSprite(ent, head, "head")
				if not body then
					FLIP_RENDERING:AddOutlineSprite(ent, sprite, "body")
				end
			end
			if body then
				if not head then
					FLIP_RENDERING:AddOutlineSprite(ent, sprite, "head")
				end
				FLIP_RENDERING:AddOutlineSprite(ent, body, "body")
			end
		else
			FLIP_RENDERING:AddOutlineSprite(ent, sprite)
		end
	elseif data.GSGSAGS then
		if not FLIP:IsEntitySubmerged(ent) then
			data.GSGSAGS = nil
			return
		end
		local mirrorWorld = Mod.Room():IsMirrorWorld()

		for _, GSGSAGS in ipairs(data.GSGSAGS) do
			---@type Sprite
			local copyspr = GSGSAGS[1]
			---@type Sprite
			local spr = GSGSAGS[3]
			local anim, frame = spr:GetAnimation(), spr:GetFrame()
			local overlayAnim, overlayFrame = spr:GetOverlayAnimation(), spr:GetOverlayFrame()
			local playerPart = GSGSAGS[4] ~= nil
			local trackMode = GSGSAGS[4]

			copyspr.Rotation = spr.Rotation
			copyspr.Offset = -(spr.Offset + ent.PositionOffset / wtr)
			copyspr.Rotation = spr.Rotation - 180
			if mirrorWorld then
				copyspr.FlipX = spr.FlipX
			else
				copyspr.FlipX = not spr.FlipX
			end
			copyspr.FlipY = spr.FlipY
			copyspr.Scale = spr.Scale

			if overlayFrame ~= -1 then
				copyspr:SetOverlayFrame(overlayAnim, overlayFrame)
			elseif copyspr:GetOverlayFrame() ~= -1 then
				copyspr:RemoveOverlay()
			end

			copyspr:SetFrame(anim, frame)

			if playerPart then
				if trackMode == "head" then
					local headScale = sprite:GetLayer("head"):GetSize()
					copyspr.Scale = sprite.Scale * headScale
				elseif trackMode == "body" then
					local bodyScale = sprite:GetLayer("body"):GetSize()
					copyspr.Scale = sprite.Scale * bodyScale
				end
			end

			if underSolid then
				GSGSAGS[2] = GSGSAGS[2] * 0.8 + 0.2
			else
				GSGSAGS[2] = GSGSAGS[2] * 0.8
			end

			copyspr.Color.A = GSGSAGS[2]

			if copyspr.Color.A <= 0.01 then
				data.GSGSAGS = nil
				break
			end
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
		local mirrorWorld = Mod.Room():IsMirrorWorld()
		for i = #data.GSGSAGS, 1, -1 do
			local GSGSAGS = data.GSGSAGS[i]
			local cspr = GSGSAGS[1]
			local renderMode = Mod.Room():GetRenderMode()
			if renderMode == RenderMode.RENDER_WATER_REFLECT
				and (GSGSAGS[4] == nil
					or (GSGSAGS[4] == "backup" and not ent:IsExtraAnimationFinished())
					or (GSGSAGS[4] ~= "backup" and ent:IsExtraAnimationFinished())
				)
			then
				local renderPos = WorldToScreen(ent.Position)
				if mirrorWorld then
					renderPos.X = Isaac.GetScreenWidth() - renderPos.X
				end
				renderlist[#renderlist + 1] = { cspr, renderPos }
			end
		end
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

function FLIP_RENDERING:ClearRenderListOnNewRoom()
	renderlist = {}
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, FLIP_RENDERING.ClearRenderListOnNewRoom)


local render = Sprite().Render
Mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	if Mod.Room():GetFrameCount() == 0 or HudHelper.ShouldHideHUD() then return end
	for i = 1, #renderlist do
		local sr = renderlist[i]
		render(sr[1], sr[2])
	end
	renderlist = {}
end)

--#endregion

return FLIP_RENDERING
