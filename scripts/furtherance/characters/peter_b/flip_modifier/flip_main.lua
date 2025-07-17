--#region Variables

local Mod = Furtherance

local FLIP = {}

local PETER_B = Mod.Character.PETER_B
Furtherance.Character.PETER_B.FLIP = FLIP

FLIP.FLIP_FACTOR = 0
FLIP.FLIP_SPEED = 0.2
FLIP.PAUSE_ENEMIES_DURING_FLIP = false
FLIP.FREEZE_ROOM_EFFECT_COOLDOWN = 0
FLIP.PETER_B_MODIFIER_ACTIVE = false
FLIP.SHOW_DEBUG = false

FLIP.TEAR_DEATH_EFFECTS = Mod:Set({
	EffectVariant.TEAR_POOF_A,
	EffectVariant.TEAR_POOF_B,
	EffectVariant.TEAR_POOF_SMALL,
	EffectVariant.TEAR_POOF_VERYSMALL,
	EffectVariant.BOMB_EXPLOSION,
	EffectVariant.BLOOD_EXPLOSION,
	EffectVariant.BULLET_POOF,
	EffectVariant.BOMB_EXPLOSION
})
FLIP.BLACKLISTED_EFFECTS = Mod:Set({
	EffectVariant.PURGATORY
})
--Interactable on both sides of the water
FLIP.BLACKLISTED_ENTITIES = Mod:Set({
	tostring(EntityType.ENTITY_WRAITH) .. ".0.0",
	tostring(EntityType.ENTITY_GAPING_MAW) .. ".0.0",
	tostring(EntityType.ENTITY_BROKEN_GAPING_MAW) .. ".0.0",
	tostring(EntityType.ENTITY_STONEY) .. ".0.0",
	tostring(EntityType.ENTITY_FIREPLACE) .. ".4.0", --White Fireplace
	tostring(EntityType.ENTITY_FIREPLACE) .. ".4.1", --White Fireplace
	tostring(EntityType.ENTITY_FIREPLACE) .. ".4.2", --White Fireplace
	tostring(EntityType.ENTITY_WILLO) .. ".0.0",
	EntityType.ENTITY_SHOPKEEPER,
})
--Bypas normal checks for if an enemy is allowed to be flipped
FLIP.WHITELISTED_ENTITIES = {}

--#endregion

--#region Helpers

function FLIP:IsEnemyFlipActive()
	return FLIP.FLIP_FACTOR > 0.5
end

---@param ent Entity
function FLIP:ShouldIgnoreEntity(ent)
	local primaryCheck = ent:IsBoss()
		or FLIP.BLACKLISTED_ENTITIES[Mod:GetTypeVarSubFromEnt(ent, true)]
		or FLIP.BLACKLISTED_ENTITIES[ent.Type]
		or ent:ToPickup()
	if not primaryCheck and ent.Parent then
		local result = Mod.Foreach.Parent(ent, function(parent)
			if FLIP:ShouldIgnoreEntity(parent) then
				return true
			end
		end)
		if result then
			return true
		end
	end
	return primaryCheck
end

---@param ent Entity
function FLIP:ValidEnemyToFlip(ent)
	if FLIP.WHITELISTED_ENTITIES[Mod:GetTypeVarSubFromEnt(ent, true)] then
		return true
	end
	return ent:IsActiveEnemy(false)
		and ent:ToNPC()
		and ent:ToNPC().CanShutDoors
		and not FLIP:ShouldIgnoreEntity(ent)
end

---@param inverse? boolean
---@return RenderMode
function FLIP:GetIgnoredWaterClipFlag(inverse)
	if Mod.Room():IsMirrorWorld() then
		inverse = not inverse
	end
	--[[ local waterClipFlag = inverse and WaterClipFlag.DISABLE_RENDER_REFLECTION or DISABLE_ABOVE_WATER
	if FLIP:IsRoomEffectActive() then
		waterClipFlag = inverse and DISABLE_ABOVE_WATER or WaterClipFlag.DISABLE_RENDER_REFLECTION
	end ]]
	local waterClipFlag = inverse and RenderMode.RENDER_WATER_REFLECT or RenderMode.RENDER_WATER_ABOVE
	if FLIP:IsEnemyFlipActive() then
		waterClipFlag = inverse and RenderMode.RENDER_WATER_ABOVE or RenderMode.RENDER_WATER_REFLECT
	end
	return waterClipFlag
end

---@param ent Entity
function FLIP:IsFlippedEnemy(ent)
	local data = Mod:GetData(ent)
	return (data.PeterFlipped
			or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
		or not ent:IsActiveEnemy(true) and FLIP:IsEnemyFlipActive()
end

---@param ent Entity
function FLIP:TryGetNPC(ent)
	if FLIP:ShouldIgnoreEntity(ent) then return end
	return ent:ToNPC() or ent.SpawnerEntity and ent.SpawnerEntity:ToNPC()
end

---@param ent Entity
function FLIP:IsEntitySubmerged(ent)
	if FLIP:ShouldIgnoreEntity(ent) then return false end
	local data = Mod:GetData(ent)
	return (data.PeterFlippedIgnoredRenderFlag or 0) == RenderMode.RENDER_WATER_ABOVE
end

---@param ent Entity
function FLIP:FlipEnemy(ent)
	local data = Mod:GetData(ent)
	data.PeterFlipped = true
	local flag = FLIP:GetIgnoredWaterClipFlag()
	if FLIP:IsEnemyFlipActive() then
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
	local effectsStatus = PETER_B:UsePeterFlipRoomEffects()
	if FLIP.PETER_B_MODIFIER_ACTIVE ~= effectsStatus then
		FLIP.PETER_B_MODIFIER_ACTIVE = PETER_B:UsePeterFlipRoomEffects()
		FLIP.RENDERING:UpdateReflections()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FLIP.OnUpdate)

--#endregion

--#region Lower ripple volume

function FLIP:ReduceRippleSound(id, volume, frameDelay, loop, pitch, pan)
	if FLIP.PETER_B_MODIFIER_ACTIVE then
		return { id, 0.05, frameDelay, loop, pitch, pan }
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, FLIP.ReduceRippleSound, SoundEffect.SOUND_WET_FEET)

--#endregion

--#region Loading other files

FLIP.RENDERING = Mod.Include("scripts.furtherance.characters.peter_b.flip_modifier.rendering")
FLIP.SEPARATE_SIDES = Mod.Include("scripts.furtherance.characters.peter_b.flip_modifier.separate_sides")
FLIP.SHADER = Mod.Include("scripts.furtherance.characters.peter_b.flip_modifier.shader")
FLIP.STATUS_EFFECTS = Mod.Include("scripts.furtherance.characters.peter_b.flip_modifier.status_effects")

--#endregion
