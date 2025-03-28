local Mod = Furtherance
local game = Game()

local FindTargets = include("lua.items.collectibles.SpiritualWound.FindTargets")
local TargetType = FindTargets.TargetType

local SpiritualWoundSoundStart = Isaac.GetSoundIdByName("SpiritualWoundStart")
local SpiritualWoundSoundLoop = Isaac.GetSoundIdByName("SpiritualWoundLoop")

local LASER_COLOR = Color(1, 1, 1)
LASER_COLOR:SetColorize(1, 0.3, 0.3, 1)
LASER_COLOR:SetOffset(0.6, 0.3, 0.25)

local CHOCOLATE_MILK_LASER_COLOR = Color(1, 1, 1)
CHOCOLATE_MILK_LASER_COLOR:SetColorize(1, 0.5, 0.3, 1)
CHOCOLATE_MILK_LASER_COLOR:SetOffset(0.2, 0.2, 0.2)

local IPECAC_LASER_COLOR = Color(1, 1, 1, 1, 0, 0, 0)
IPECAC_LASER_COLOR:SetColorize(0.5, 0.9, 0.4, 1)
IPECAC_LASER_COLOR:SetOffset(0.2, 0.4, 0.2)

---@param vector1 Vector
---@param vector2 Vector
---@param alpha number
---@return Vector
local function lerp(vector1, vector2, alpha)
	return vector1 * (1 - alpha) + vector2 * alpha
end

local LaserVariant = {
	BRIMSTONE = 1,
	TECHNOLOGY = 2,
	SHOOP_DA_WHOOP = 3,
	PRIDE = 4,
	LIGHT_BEAM = 5,
	MEGA_BLAST = 6,
	TRACTOR_BEAM = 7,
	LIGHT_RING = 8, -- crashes if you run this with homing
	BRIMTECH = 9,
	JACOBS_LADDER = 10,
	BIG_BRIMSTONE = 11,
	DIARRHEASTONE = 12,
	MEGA_BRIMTECH = 13,
	BIG_BRIMTECH = 14,
	BIGGER_BRIMTECH = 15,
}

local LaserHomingType = {
	NORMAL = 0,
	FREEZE = 1,
	FREEZE_HEAD = 2
}

local SpiritualWoundVariant = {
	NORMAL = LaserVariant.BRIMTECH,
	POLARITY_SHIFT = LaserVariant.JACOBS_LADDER
}

local function playLaserSounds()
	SFXManager():Play(SpiritualWoundSoundLoop, nil, nil, true)
	SFXManager():Play(SpiritualWoundSoundStart)
end

local function stopLaserSounds()
	SFXManager():Stop(SpiritualWoundSoundLoop)
end

---@param itemData SpiritualWoundItemData
---@param targetPosition Vector
---@return EntityLaser
local function spawnLaser(itemData, targetPosition)
	local player = itemData.Owner
	local woundVariant = itemData.LaserVariant

	-- Set laser start and end position
	local sourcePos = player.Position
	local laser = EntityLaser.ShootAngle(woundVariant, sourcePos, ((targetPosition - sourcePos):GetAngleDegrees()), 0,
		Vector(0, player.SpriteScale.Y * -32), player)
	laser:SetMaxDistance(sourcePos:Distance(targetPosition) + 50)

	if woundVariant == SpiritualWoundVariant.NORMAL then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
			laser:SetColor(IPECAC_LASER_COLOR, 0, 1)
		elseif player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
			laser:SetColor(CHOCOLATE_MILK_LASER_COLOR, 0, 1)
		else
			laser:SetColor(LASER_COLOR, 0, 1)
		end
		laser.SpriteScale = Vector.One * 0.3
	elseif woundVariant == SpiritualWoundVariant.POLARITY_SHIFT then
		laser.SpriteScale = Vector.One * 2
	end

	laser.Mass = 0         -- removes knockback
	laser:AddTearFlags(TearFlags.TEAR_HOMING)
	laser.CollisionDamage = 0 -- they still do 0.1 damage...
	Mod:GetData(laser).IsSpiritualWound = true
	laser:SetHomingType(LaserHomingType.NORMAL)

	return laser
end

---@param laser EntityLaser
---@param itemData SpiritualWoundItemData
---@param targetPosition Vector
local function updateLaser(laser, itemData, targetPosition)
	if game:GetFrameCount() % 2 ~= 0 then return end

	local player = itemData.Owner
	local rng = itemData.RNG

	local positionOffset = Vector(rng:RandomFloat() - 0.5, rng:RandomFloat() - 0.5) * 150

	targetPosition = targetPosition + positionOffset

	local newGoal = lerp(laser:GetEndPoint(), targetPosition, 0.4)
	local delta = newGoal - player.Position

	local angleOffset = 40 * (rng:RandomFloat() - 0.5) * 90 / delta:Length()

	laser:SetMaxDistance(delta:Length() + 50)
	laser.AngleDegrees = delta:GetAngleDegrees() + angleOffset
	laser.EndPoint = EntityLaser.CalculateEndPoint(player.Position, delta, Vector(0, player.SpriteScale.Y * -32), player,
		0)
	laser.TearFlags = laser.TearFlags | TearFlags.TEAR_HOMING
end



---@param itemData SpiritualWoundItemData
---@param targetPosition Vector
---@param count int
---@return EntityLaser[]
local function spawnLasers(itemData, targetPosition, count)
	local result = {}

	for _ = 1, count do
		local laser = spawnLaser(itemData, targetPosition)
		table.insert(result, laser)
	end

	return result
end

---@param lasers EntityLaser[]
---@param itemData SpiritualWoundItemData
---@param targetPosition Vector
local function updateLasers(lasers, itemData, targetPosition)
	if game:GetFrameCount() % 2 ~= 0 then return end
	for _, laser in ipairs(lasers) do
		updateLaser(laser, itemData, targetPosition)
	end
end

---@param lasers EntityLaser[]
local function removeLasers(lasers)
	for k, laser in pairs(lasers) do
		laser:Die()
		lasers[k] = nil
	end
end

--- Spawn a laser for every enemy
---@param itemData SpiritualWoundItemData
---@param targetQuery TargetQuery|nil
---@return boolean, boolean
local function handleBirthright(itemData, targetQuery)
	local untargetedLasers = itemData.UntargetedLasers

	if targetQuery == nil or #targetQuery.AllEnemies == 1 and targetQuery.Type == TargetType.ENTITY then
		removeLasers(untargetedLasers)
		return false, false
	end

	local lasersSpawned = false
	local lasersExisted = false

	local enemyMapping = {}
	for i = 2, #targetQuery.AllEnemies do -- this will need to change if we get multi-targeting??
		local enemy = targetQuery.AllEnemies[i]
		enemyMapping[GetPtrHash(enemy)] = enemy
	end

	-- remove lasers for enemies that don't exist/are dead
	for ptrHash, laser in pairs(untargetedLasers) do
		local enemy = enemyMapping[ptrHash]
		if enemy == nil then
			laser:Die()
			untargetedLasers[ptrHash] = nil
		end
	end

	-- spawn and update lasers for enemies that still exist
	for ptrHash, enemy in pairs(enemyMapping) do
		local laser = untargetedLasers[ptrHash]
		if laser == nil then
			untargetedLasers[ptrHash] = spawnLaser(itemData, enemy.Position)
			lasersSpawned = true
		else
			updateLaser(laser, itemData, enemy.Position)
			lasersExisted = true
		end
	end

	return lasersSpawned, lasersExisted
end

local RenderLasers = {
	LaserVariant = LaserVariant,
	ItemLaserVariant = SpiritualWoundVariant
}
setmetatable(RenderLasers, RenderLasers)

function RenderLasers.RemoveLasers(itemData)
	removeLasers(itemData.UntargetedLasers)
	removeLasers(itemData.TargetedLasers)
end

function RenderLasers.StopLaserSounds()
	stopLaserSounds()
end

---@param itemData SpiritualWoundItemData
---@param targetQuery TargetQuery|nil
function RenderLasers:__call(itemData, targetQuery)
	local player = itemData.Owner

	local lasersSpawned = false
	local lasersExisted = false

	if itemData.OldLaserVariant ~= itemData.LaserVariant
		or itemData.TriggeredSynergies[CollectibleType.COLLECTIBLE_CHOCOLATE_MILK]
		or itemData.TriggeredSynergies[CollectibleType.IPECAC]
	then
		RenderLasers.RemoveLasers(itemData)
		itemData.OldLaserVariant = itemData.LaserVariant
		lasersExisted = true
	end

	if player:GetPlayerType() == PlayerType.PLAYER_MIRIAM_B
		and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	then
		local subLasersSpawned, subLasersExisted = handleBirthright(itemData, targetQuery)
		lasersSpawned = lasersSpawned or subLasersSpawned
		lasersExisted = lasersExisted or subLasersExisted
	end

	local targetPosition
	local targetedLasers = itemData.TargetedLasers
	if targetQuery ~= nil then
		if targetQuery.Type == TargetType.ENTITY then
			targetPosition = targetQuery.Result[1].Position
		elseif targetQuery.Type == TargetType.GRID_ENTITY then
			targetPosition = targetQuery.Result.Position
		elseif targetQuery.Type == TargetType.PSEUDO_GRID_ENTITY then
			targetPosition = targetQuery.Result.Position
		end
	end

	if targetPosition ~= nil then
		if #targetedLasers == 0 then
			itemData.TargetedLasers = spawnLasers(itemData, targetPosition, 3)
			lasersSpawned = true
		else
			updateLasers(targetedLasers, itemData, targetPosition)
			lasersExisted = true
		end
	elseif #targetedLasers > 0 then
		removeLasers(targetedLasers)
	end

	if not lasersExisted then
		if lasersSpawned then
			playLaserSounds()
		else
			stopLaserSounds()
		end
	end
end

---@param laser EntityLaser
function Mod:SpiritualWoundRender(laser)
	if laser.FrameCount ~= 1 then return end
	local data = Mod:GetData(laser)
	if data.IsSpiritualWound and not laser:IsDead() then
		if laser.Variant == SpiritualWoundVariant.NORMAL then
			laser.SpriteScale = Vector.One * 0.3
		elseif laser.Variant == SpiritualWoundVariant.POLARITY_SHIFT then
			laser.SpriteScale = Vector.One * 2
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, Mod.SpiritualWoundRender)

local wasPaused = false
function Mod:ResumeSoundLoop()
	local isPaused = game:IsPaused()
	if isPaused == wasPaused then return end
	wasPaused = isPaused

	if isPaused then return end

	local spiritualWoundPresent = false
	for _, laser in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
		local data = Mod:GetData(laser)
		if data.IsSpiritualWound then
			spiritualWoundPresent = true
			break
		end
	end

	if not spiritualWoundPresent then return end

	SFXManager():Play(SpiritualWoundSoundLoop, nil, nil, true)
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, Mod.ResumeSoundLoop)

function Mod:StopBrimtechSounds(laser)
	local data = Mod:GetData(laser)
	if data.IsSpiritualWound then
		SFXManager():Stop(SoundEffect.SOUND_BLOOD_LASER)
		SFXManager():Stop(SoundEffect.SOUND_BLOOD_LASER_LOOP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, Mod.StopBrimtechSounds)

---@param effect EntityEffect
function Mod:ReplaceBrimtechImpact(effect)
	if effect.FrameCount ~= 0 then return end

	local laser = effect.Parent
	if laser == nil then return end

	local laserData = Mod:GetData(laser)
	if not laserData.IsSpiritualWound then return end

	local sprite = effect:GetSprite()
	sprite:ReplaceSpritesheet(0, "gfx/effects/spiritual_wound_impact.png")
	sprite:LoadGraphics()
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Mod.ReplaceBrimtechImpact, EffectVariant.LASER_IMPACT)

return RenderLasers
