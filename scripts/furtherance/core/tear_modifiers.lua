--Credit to Epiphany for original tear modifier code. Upgraded by Benny with RGON implementation
local Mod = Furtherance
local modInitial = "FR_"
local game = Mod.Game

local function getData(ent)
	return Mod:GetData(ent)
end

---@class Cooldown
---@field Laser integer
---@field KnifeHit integer
---@field KnifeSwing integer
---@field Ludovico integer
---@field CSection integer

---@class CooldownParams
---@field Laser integer?
---@field KnifeHit integer?
---@field KnifeSwing integer?
---@field Ludovico integer?
---@field CSection integer?

---@class TearModifier
---@field Name string @The string identifier for this TearModifier.
---@field Items CollectibleType[] @List of items that cause this TearModifier to activate.
---@field Trinkets TrinketType[] @List of trinkets that cause this TearModifier to activate.
---@field RngGetter (fun(player:EntityPlayer): RNG?, baseChanceMult: integer?)? @A function that returns the rng to use for the chance calculation. Overrides the item/trinket checks.
---@field IsTrinket boolean @If `Item` is a `TrinketType`.
---@field MinLuck number @The minimum luck for calculating chance-based tear modifiers.
---@field MaxLuck number @The maximum luck for calculating chance-based tear modifiers.
---@field MinChance number @The minimum chance of proccing for chance-based tear modifiers. Affected by the luck variables.
---@field MaxChance number @The maximum chance of proccing for chance-based tear modifiers. Affected by the luck variables.
---@field LastRoll integer @The last chance roll made. Only set when using the default GetChance.
---@field ShouldAffectBombs boolean @Whether Dr and Epic fetus are affected by this modifier.
---@field Cooldown Cooldown
---@field GFX string? @The anm2 to use for the tear.
---@field GFX_BLOOD string? @The anm2 to use for the blood tear.
---@field Color Color? @The color to use for the tear.
---@field LaserColor Color? @The color to use for the laser
local TearModifier = {}
TearModifier.__index = TearModifier


---Before an affected tear, bomb, knife, or laser collides with an entity. If not a laser, return "true" to cancel the collision, "false" to collide but not execute internal code, or nothing to pass.
---For performance reasons, when a laser this only activates for pickups, NPCs, and projectiles.
---Does not affect Epic Fetus.
---@param object EntityTear | EntityKnife | EntityLaser | EntityBomb
---@param collider Entity
---@param low boolean
function TearModifier:PreEntityCollision(object, collider, low)

end

---Before an affected tear, bomb, knife, or laser hits an NPC. `hitter` will be an EntityEffect if Epic Fetus.
---@param hitter EntityTear | EntityKnife | EntityLaser | EntityBomb | EntityEffect
---@param npc EntityNPC
---@param isKnifeSwing boolean? This will be true or nil. True means it came from a swinging knife, a la bone clubs.
---@param isSamsonPunch boolean? This will be true or nil. True means it was a Samson punch, and `hitter` is the player.
---@param isCainBag boolean? This will be true or nil. True means it was a Cain's bag, and `hitter` is the bag.
function TearModifier:PostNpcHit(hitter, npc, isKnifeSwing, isSamsonPunch, isCainBag)

end

---After an affected tear, knife, bomb, or laser collides with a grid entity. Called after but in the same frame as PostUpdate. Does not affect Epic Fetus.
---@param object EntityTear | EntityKnife | EntityLaser | EntityBomb
---@param collidePosition Vector
function TearModifier:PostGridCollision(object, collidePosition)

end

---After an affected tear, knife, bomb, or laser updates. Does not affect Epic Fetus.
---@param object EntityTear | EntityKnife | EntityLaser  | EntityBomb
function TearModifier:PostUpdate(object)

end

---After an affected tear, knife, bomb, or laser renders. Does not affect Epic Fetus.
---@param object EntityTear | EntityKnife | EntityLaser | EntityBomb
---@param renderOffset Vector
function TearModifier:PostRender(object, renderOffset)

end

---After an affected tear spawns, a laser fires, an Epic/Dr Fetus bomb fires, or a knife fires. Keep in mind that affected lasers and knives may not be affected for the rest of their lifespan.
---`object` is an EntityEffect if Epic Fetus.
---@param object EntityTear | EntityLaser | EntityKnife | EntityBomb | EntityEffect
function TearModifier:PostFire(object)

end

---After a ludovico tear, a laser or knife loses the chance based effects
---`object` is an EntityEffect if Epic Fetus.
---@param object EntityTear | EntityLaser | EntityKnife | EntityBomb | EntityEffect
function TearModifier:PostLoseEffects(object)

end

---After a Dr Fetus bomb explodes.
---Can't get it to work for Epic Fetus at this time.
---@param bomb EntityBomb
function TearModifier:PostExplode(bomb)

end

---Returns the RNG object for the item or trinket that causes this TearModifier to activate.
---Returns nil if the player doesn't have any items or trinkets that contribute to the tear modifier.
---@param player EntityPlayer
---@return RNG?, integer?
function TearModifier:TryGetItemRNG(player)
	if self.RngGetter then
		local rng, baseChanceMult = self.RngGetter(player)
		baseChanceMult = baseChanceMult or 1
		return rng, baseChanceMult
	end

	for i = 1, #self.Items do
		if player:HasCollectible(self.Items[i]) then
			return player:GetCollectibleRNG(self.Items[i]), player:GetCollectibleNum(self.Items[i])
		end
	end

	for i = 1, #self.Trinkets do
		if player:HasTrinket(self.Trinkets[i], false) then
			return player:GetTrinketRNG(self.Trinkets[i]), player:GetTrinketMultiplier(self.Trinkets[i])
		end
	end
end

---Only called for tears and bombs, this checks if the TearModifier should be applied.
---@param player EntityPlayer
---@param ignoreTeardrop? boolean
function TearModifier:CheckTearAffected(player, ignoreTeardrop)
	local rng, numItems = self:TryGetItemRNG(player)

	return rng and rng:RandomFloat() < self:GetChance(player, ignoreTeardrop, numItems)
end

---Only called for knives, lasers, samson's punch, and Ludovico, this checks if the TearModifier should be applied.
---@param player EntityPlayer
---@param weapon EntityKnife | EntityLaser | EntityTear | nil Nil if a samson punch.
---@param ignoreTeardrop? boolean
function TearModifier:CheckKnifeLaserAffected(player, weapon, ignoreTeardrop)
	local rng, numItems = self:TryGetItemRNG(player)
	if not rng then
		return false
	end

	local frameCount = weapon and weapon.FrameCount or 0

	if frameCount == 0 or frameCount % 6 == 0 then
		self.LastRoll = rng:RandomFloat()
	end

	return self.LastRoll < self:GetChance(player, ignoreTeardrop, numItems)
end

---Credit to Epiphany
---Gives the player's luck accounting for teardrop charm
---@param player EntityPlayer
---@param ignoreTeardrop? boolean @Set to true to ignore Teardrop Charm. This is for the purposes of INIT/POST_FIRE callbacks so as to not double stack the luck chance. The game adds the charm's luck bonus directly into player.Luck during these callbacks and is reset immediately afterwards
---@return integer
local function getTearModifierLuck(player, ignoreTeardrop)
	local luck = player.Luck
	if not ignoreTeardrop and player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
		local mult = player:GetTrinketMultiplier(TrinketType.TRINKET_TEARDROP_CHARM)
		luck = luck + (mult + mult + 2)
	end
	return luck
end

---A percentage float chance to be used with an RNG object.
---@param player EntityPlayer
---@param ignoreTeardrop? boolean
---@param baseChanceMult? integer
function TearModifier:GetChance(player, ignoreTeardrop, baseChanceMult)
	local luck = getTearModifierLuck(player, ignoreTeardrop)
	luck = Mod:Clamp(luck, self.MinLuck, self.MaxLuck)
	baseChanceMult = baseChanceMult or 1
	local deltaX = self.MaxLuck - self.MinLuck
	local rngRequirement = ((self.MaxChance - self.MinChance) / deltaX) * luck + (self.MaxLuck * self.MinChance - self.MinLuck * self.MaxChance) / deltaX
	rngRequirement = rngRequirement + (self.MinChance * (baseChanceMult - 1))

	return rngRequirement
end

---Checks and Adds a Cooldown to the modifier
---@param entity Entity
---@param addDelay integer
---@return boolean
function TearModifier:IsOnCooldown(entity, addDelay)
	local frame = Mod.Game:GetFrameCount()
	local data = getData(entity)
	local dataName = modInitial .. self.Name .. "_Frame"
	if data[dataName]
		and data[dataName] > frame
	then
		return true
	end

	if addDelay then
		data[dataName] = frame + addDelay
	end
	return false
end

---Prints the percentage chance the player would have at any given luck, with or without tear drop charm.
---@param luck number
---@param teardropCharm boolean @Act as if teardrop charm is enabled.
function TearModifier:PrintChanceLine(luck, teardropCharm)
	if teardropCharm then
		luck = luck + 4
	end
	luck = Mod:Clamp(luck, self.MinLuck, self.MaxLuck)

	local deltaX = self.MaxLuck - self.MinLuck
	local rngRequirement = ((self.MaxChance - self.MinChance) / deltaX) * luck +
		(self.MaxLuck * self.MinChance - self.MinLuck * self.MaxChance) / deltaX
	local luckString = teardropCharm and (tostring(luck - 3) .. " (+3 from teardrop charm)") or tostring(luck)

	Mod:DebugLog("The player has a " ..
		string.format("%.2f%%", rngRequirement * 100) ..
		" for the " .. self.Name .. " TearModifier to activate at " .. luckString .. " luck")
end

---When the affected ludo tear, laser, or knife loses its effect and needs to reset back to its expected color
---@param object EntityTear | EntityKnife | EntityLaser
function TearModifier:GetResetColor(object)
	local player = Mod:TryGetPlayer(object)
	if not player then return Color.Default end
	if object:ToLaser() then
		return player.LaserColor
	else
		return player:GetTearHitParams(player:GetWeapon(1):GetWeaponType()).TearColor
	end
end

function TearModifier:IsValidEnemyTarget(ent)
	return ent
		and ent:ToNPC()
		and ent:IsActiveEnemy(false)
		and ent:IsVulnerableEnemy()
		and not ent:IsDead()
		and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
		and ent.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE
		and (ent:ToNPC().CanShutDoors or ent.Type == EntityType.ENTITY_DUMMY)
end

local bloodTearTable = {
	[TearVariant.BLOOD] = true,
	[TearVariant.CUPID_BLOOD] = true,
	[TearVariant.NAIL_BLOOD] = true,
	[TearVariant.PUPULA_BLOOD] = true,
	[TearVariant.GODS_FLESH_BLOOD] = true,
	[TearVariant.GLAUCOMA_BLOOD] = true,
	[TearVariant.EYE_BLOOD] = true,
}

function TearModifier:IsBloodTear(tearVariant)
	return bloodTearTable[tearVariant] ~= nil
end

---@class TearModifierParams
---@field Name string @The string identifier for this TearModifier.
---@field Items CollectibleType[]? @List of items that cause this TearModifier to activate.
---@field Trinkets TrinketType[]? @List of trinkets that cause this TearModifier to activate.
---@field RngGetter (fun(player:EntityPlayer): RNG?, baseChanceMult: integer?)? @A function that returns the rng to use for the chance calculation. Overrides the item/trinket checks.
---@field MinLuck number? @The minimum luck for calculating chance-based tear modifiers. 0 by default.
---@field MaxLuck number? @The maximum luck for calculating chance-based tear modifiers. 10 by default.
---@field MinChance number? @The minimum chance of proccing for chance-based tear modifiers. Affected by the luck variables. 0 by default.
---@field MaxChance number? @The maximum chance of proccing for chance-based tear modifiers. Affected by the luck variables. 0.25 by default.
---@field GFX string? @The anm2 to use for a tear. Leave nil to let the game decide.
---@field GFX_BLOOD string? @The anm2 to use for a blood tear, will use normal gfx if not used
---@field Color Color? @The color to use for a tear, knife, or laser. Leave nil to let the game decide.
---@field LaserColor Color? @The color to use for only lasers. If `Color` is defined, this will override it
---@field ShouldAffectBombs boolean? @If Dr and Epic Fetus should be affected. By default, this is false.
---@field Cooldown CooldownParams?

---Constructs a new TearModifier. Use this for deciding the luck stuff: https://www.desmos.com/calculator/b9x583q0md
---@param params TearModifierParams
---@return TearModifier
function TearModifier.New(params)
	local self = setmetatable({}, TearModifier)
	self.Name = params.Name or error('Field "Name" is required for TearModifier', 2)
	self.Items = params.Items or {}
	self.Trinkets = params.Trinkets or {}
	self.RngGetter = params.RngGetter
	if #self.Items == 0 and #self.Trinkets == 0 and not self.RngGetter then
		error('Both "Items" and "Trinkets" are empty', 2)
	end

	self.MinLuck = params.MinLuck or 0
	self.MaxLuck = params.MaxLuck or 10
	self.MinChance = params.MinChance or 0
	self.MaxChance = params.MaxChance or 0.25
	self.LastRoll = 0

	self.GFX = params.GFX
	self.GFX_BLOOD = params.GFX_BLOOD
	self.Color = params.Color
	self.LaserColor = params.LaserColor

	self.ShouldAffectBombs = params.ShouldAffectBombs or false

	local values = params.Cooldown
	self.Cooldown = {
		Laser = values and values.Laser or 3,
		KnifeHit = values and values.KnifeHit or 2,
		KnifeSwing = values and values.KnifeSwing or 4,
		Ludovico = values and values.Ludovico or 7,
		CSection = values and values.CSection or 6
	}

	--#region TEAR CODE
	---@param tear EntityTear
	Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
		local data = getData(tear)
		if not tear.SpawnerEntity or data[modInitial .. self.Name .. "_Disabled"] then
			return
		end

		local player = Mod:TryGetPlayer(tear.SpawnerEntity)
		if player and self:CheckTearAffected(player, true) then
			local sprite = tear:GetSprite()
			local appliedGFX = false
			local animationName = sprite:GetAnimation()

			if self.GFX_BLOOD and self:IsBloodTear(tear.Variant) then
				sprite:Load(self.GFX_BLOOD, true)
				sprite:Play(animationName, true)
				appliedGFX = true
			elseif self.GFX and not self:IsBloodTear(tear.Variant) then
				sprite:Load(self.GFX, true)
				sprite:Play(animationName, true)
				appliedGFX = true
			end
			if not sprite:IsPlaying(animationName) then
				sprite:Play(sprite:GetDefaultAnimation())
			end
			tear:ResetSpriteScale(true)

			if self.Color and not appliedGFX then
				sprite.Color = self.Color
			end
			data[modInitial .. self.Name] = true
			self:PostFire(tear)
		end
	end)

	--Ludo
	---@param tear EntityTear
	Mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
		local data = getData(tear)
		if not tear.SpawnerEntity or data[modInitial .. self.Name .. "_Disabled"] then
			return
		end
		if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			local player = Mod:TryGetPlayer(tear.SpawnerEntity)
			if player and self:CheckKnifeLaserAffected(player, tear, true) then
				local sprite = tear:GetSprite()
				data[modInitial .. self.Name] = true

				if self.Color then
					sprite.Color = self.Color
				end
			elseif data[modInitial .. self.Name] then
				data[modInitial .. self.Name] = false
				tear:GetSprite().Color = self:GetResetColor(tear)
			end
		end
	end)

	---@param tear EntityTear
	Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
		local data = getData(tear)
		if data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
			self:PostUpdate(tear)

			if tear:CollidesWithGrid() then
				self:PostGridCollision(tear, tear.Position)
			end
		end

		if not data[modInitial .. self.Name .. "_Disabled"] and tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			local player = Mod:TryGetPlayer(tear.SpawnerEntity)
			if player and self:CheckKnifeLaserAffected(player, tear) then
				local sprite = tear:GetSprite()
				if self.Color then
					sprite.Color = self.Color
				end

				data[modInitial .. self.Name] = true
			elseif data[modInitial .. self.Name] then
				data[modInitial .. self.Name] = false
				tear:GetSprite().Color = self:GetResetColor(tear)
				self:PostLoseEffects(tear)
			end
		end
	end)

	---@param tear EntityTear
	---@param offset Vector
	Mod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, function(_, tear, offset)
		local data = getData(tear)
		if data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
			self:PostRender(tear, offset)
		end
	end)


	---@param collider Entity
	Mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider, low)
		local data = getData(tear)
		if data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
			local npc = collider:ToNPC()
			if npc and TearModifier:IsValidEnemyTarget(npc) then
				-- I know it's ugly but the logic is making my brain melt
				local skip = false
				if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO)
					and self:IsOnCooldown(tear, self.Cooldown.Ludovico)
				then
					skip = true
				end
				if tear:HasTearFlags(TearFlags.TEAR_FETUS)
					and self:IsOnCooldown(tear, self.Cooldown.CSection)
				then
					skip = true
				end

				if not skip then
					self:PostNpcHit(tear, npc)
				end
			end

			return self:PreEntityCollision(tear, collider, low)
		end
	end)
	--#endregion

	--#region KNIFE CODE
	---@param knife EntityKnife
	local function fireKnife(_, knife)
		local data = getData(knife)
		if not knife.SpawnerEntity or data[modInitial .. self.Name .. "_Disabled"] then
			return
		end

		local player = Mod:TryGetPlayer(knife.SpawnerEntity)
		if player and self:CheckKnifeLaserAffected(player, knife, true) then
			local sprite = knife:GetSprite()

			if self.Color then
				sprite.Color = self.Color
			end
			data[modInitial .. self.Name] = true
			self:PostFire(knife)
		end
	end
	Mod:AddCallback(ModCallbacks.MC_POST_FIRE_KNIFE, fireKnife)
	Mod:AddCallback(ModCallbacks.MC_POST_FIRE_SWORD, fireKnife)
	Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BONE_CLUB, fireKnife)

	---@param knife EntityKnife
	Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
		local data = getData(knife)
		if not knife.SpawnerEntity or data[modInitial .. self.Name .. "_Disabled"] then
			return
		end

		local player = Mod:TryGetPlayer(knife)
		if not player then return end
		if self:CheckKnifeLaserAffected(player, knife) then
			local sprite = knife:GetSprite()
			if self.Color then
				sprite.Color = self.Color
			end

			data[modInitial .. self.Name] = true
		elseif data[modInitial .. self.Name] then
			data[modInitial .. self.Name] = false
			knife:GetSprite().Color = self:GetResetColor(knife)
			self:PostLoseEffects(knife)
		end

		if data[modInitial .. self.Name] then
			self:PostUpdate(knife)

			if knife:CollidesWithGrid() then
				self:PostGridCollision(knife, knife.Position)
			end
			local dataName = modInitial .. "EntityCollisionMap"

			data[dataName] = data[dataName] or {}

			if knife:GetIsSwinging() or knife:GetIsSpinAttack() then
				local hitList = Mod:Set(knife:GetHitList())
				for _, enemy in ipairs(Isaac.GetRoomEntities()) do
					if not data[dataName][GetPtrHash(enemy)] and hitList[enemy.Index] then
						data[dataName][GetPtrHash(enemy)] = true
						local npc = enemy:ToNPC()
						if npc and TearModifier:IsValidEnemyTarget(npc) then
							if not self:IsOnCooldown(npc, self.Cooldown.KnifeSwing) then
								self:PostNpcHit(knife, npc, true)
							end
						else
							self:PreEntityCollision(knife, enemy, false)
						end
					end
				end
			else
				data[dataName] = {}
			end
		end
	end)

	---@param knife EntityKnife
	Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_RENDER, function(_, knife, offset)
		local data = getData(knife)
		if data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
			self:PostRender(knife, offset)
		end
	end)

	---@param collider Entity
	Mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, function(_, knife, collider, low)
		local data = getData(knife)
		if data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
			local npc = collider:ToNPC()
			if npc and TearModifier:IsValidEnemyTarget(npc) then
				-- normal knife and sumptorium knife
				if knife.Variant == KnifeVariant.MOMS_KNIFE or knife.Variant == KnifeVariant.SUMPTORIUM then
					if not self:IsOnCooldown(npc, self.Cooldown.KnifeHit) then
						self:PostNpcHit(knife, npc)
					end
				end
			end

			return self:PreEntityCollision(knife, collider, low)
		end
	end)
	--#endregion

	--#region LASER CODE (the scary one)
	---@param laser EntityLaser
	local function laserFire(_, laser)
		local data = getData(laser)
		if not laser.SpawnerEntity or data[modInitial .. self.Name .. "_Disabled"] then
			return
		end

		local player = Mod:TryGetPlayer(laser.SpawnerEntity)
		if player and self:CheckKnifeLaserAffected(player, laser, true) then
			data[modInitial .. self.Name] = true
			self:PostFire(laser)
			local newColor = self.LaserColor or self.Color

			if newColor then
				local c = laser:GetSprite().Color
				local newC = newColor
				if not self.LaserColor then
					newC = Color(c.R, c.G, c.B, 1)
					newC:SetColorize(self.Color.R + 0.3, self.Color.G + 0.2, self.Color.B + 0.2, 1)
				end
				laser:GetSprite().Color = newC
			end
		end
	end

	Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, laserFire)
	Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL, laserFire)
	Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, laserFire)
	Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, laserFire)

	---@param laser EntityLaser
	Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
		local data = getData(laser)
		if not laser.SpawnerEntity or data[modInitial .. self.Name .. "_Disabled"] then
			return
		end

		if laser.Variant == LaserVariant.SHOOP and laser.MaxDistance == 0 then -- shoop da whoop
			return
		end

		local player = Mod:TryGetPlayer(laser.SpawnerEntity)
		if player and self:CheckKnifeLaserAffected(player, laser) then
			--Laser's Color in GetSprite is const. Use Entity Color instead.
			local newColor = self.LaserColor or self.Color
			if newColor then
				local c = laser:GetSprite().Color
				local newC = newColor
				if not self.LaserColor then
					newC = Color(c.R, c.G, c.B, 1)
					newC:SetColorize(self.Color.R + 0.3, self.Color.G + 0.2, self.Color.B + 0.2, 1)
				end
				laser:GetSprite().Color = newC
			end

			data[modInitial .. self.Name] = true
		elseif player and data[modInitial .. self.Name] then
			data[modInitial .. self.Name] = false
			laser:GetSprite().Color = self:GetResetColor(laser)
			self:PostLoseEffects(laser)
			-- I added this to fix a nil check when there is no spawner entity
		elseif data[modInitial .. self.Name] then
			data[modInitial .. self.Name] = false
			self:PostLoseEffects(laser)
		end

		if not data[modInitial .. self.Name] then return end
		self:PostUpdate(laser)

		local room = game:GetRoom()
		local samples = laser:GetNonOptimizedSamples()
		local collidedWidthGrid = {}
		local collidedWithEntity = {}
		for i = 0, #samples - 1 do
			local point = samples:Get(i) ---@diagnostic disable-line: undefined-field
			local gridEnt = room:GetGridEntityFromPos(point)
			if gridEnt and not collidedWidthGrid[gridEnt:GetGridIndex()] then
				self:PostGridCollision(laser, point)
				collidedWidthGrid[gridEnt:GetGridIndex()] = true
			end

			for _, entity in ipairs(Isaac.FindInRadius(point, laser.Size, EntityPartition.ENEMY)) do
				local npc = entity:ToNPC()

				if npc and TearModifier:IsValidEnemyTarget(npc) and not collidedWithEntity[GetPtrHash(npc)] then
					if not self:PreEntityCollision(laser, npc, false) then
						collidedWithEntity[GetPtrHash(npc)] = true
					end

					if self:IsOnCooldown(npc, self.Cooldown.Laser) then
						break
					end

					self:PostNpcHit(laser, npc)
				end
			end
		end
	end)

	---@param laser EntityLaser
	Mod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, function(_, laser, offset)
		local data = getData(laser)
		if data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
			self:PostRender(laser, offset)
		end
	end)
	--#endregion

	if Epiphany then
		--#region Samson code !!
			Epiphany:AddExtraCallback(Epiphany.ExtraCallbacks.SAMSON_PUNCH_ENTITY, function(player, npc, isSlam, point)
			if player and self:CheckKnifeLaserAffected(player, nil) then
				self:PostNpcHit(player, npc, false, true)
			end
		end)
		--#endregion

		--#region Cain Bag code
		Epiphany:AddExtraCallback(Epiphany.ExtraCallbacks.CAIN_POST_SWING_HIT, function(_, bag, entity, player, SbData, dmgDealt)
			local npc = entity:ToNPC()
			if player and npc and TearModifier:IsValidEnemyTarget(npc) and self:CheckTearAffected(player) then
				self:PostNpcHit(bag, npc, nil, nil, true)
			end
		end)

		Epiphany:AddExtraCallback(Epiphany.ExtraCallbacks.CAIN_POST_BAG_THROW, function(_, bag, TbData)
			if not TbData.PlayerOwner or TbData[modInitial .. self.Name .. "_Disabled"] then
				return
			end

			local player = TbData.PlayerOwner
			if player and self:CheckTearAffected(player) then
				local sprite = bag:GetSprite()
				TbData[modInitial .. self.Name] = true

				if self.Color then
					sprite.Color = self.Color
				end
				self:PostFire(bag)
			end
		end)

		Epiphany:AddExtraCallback(Epiphany.ExtraCallbacks.CAIN_POST_BAG_HIT, function(_, bag, entity, TbData, dmgDealt)
			if TbData[modInitial .. self.Name] and not TbData[modInitial .. self.Name .. "_Disabled"] then
				local npc = entity:ToNPC()
				if npc and TearModifier:IsValidEnemyTarget(npc) then
					self:PostNpcHit(bag, entity:ToNPC(), nil, nil, true)
				end
			end
		end)
		--#endregion
	end

	--#region Bomb code (the easy one)
	if self.ShouldAffectBombs then
		---@param effect EntityEffect
		Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
			if not effect.SpawnerEntity then
				return
			end
			local player = Mod:TryGetPlayer(effect.SpawnerEntity)

			if player and self:CheckTearAffected(player) then
				local sprite = effect:GetSprite()
				local data = getData(effect)
				data[modInitial .. self.Name] = true
				self:PostFire(effect)

				if self.Color then
					sprite.Color = self.Color
				end
			end
		end, EffectVariant.ROCKET)

		Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, function(_, bomb)
			local data = getData(bomb)
			if not bomb.SpawnerEntity or data[modInitial .. self.Name .. "_Disabled"] then
				return
			end

			local player = Mod:TryGetPlayer(bomb.SpawnerEntity)
			if player and self:CheckTearAffected(player, true) then
				local sprite = bomb:GetSprite()
				data[modInitial .. self.Name] = true

				if self.Color then
					sprite.Color = self.Color
				end

				self:PostFire(bomb)
			end
		end)

		---@param bomb EntityBomb
		Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, function(_, bomb)
			if not bomb.IsFetus then
				return
			end
			local data = getData(bomb)
			if not bomb.SpawnerEntity or data[modInitial .. self.Name .. "_Disabled"] then
				return
			end

			if data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
				self:PostUpdate(bomb)

				if bomb:CollidesWithGrid() then
					self:PostGridCollision(bomb, bomb.Position)
				end

				if bomb:GetSprite():IsPlaying("Explode") and not data[modInitial .. self.Name .. "_BombExploded"] then
					self:PostExplode(bomb)
					data[modInitial .. self.Name .. "_BombExploded"] = true
				end
			end
		end)

		---@param entity Entity
		---@param source EntityRef
		Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, _, _, source)
			local bomb = source.Entity and source.Entity:ToBomb()
			local effect = source.Entity and source.Entity:ToEffect()
			local npc = entity:ToNPC()

			local data = bomb and getData(bomb)
			if bomb and npc and data and TearModifier:IsValidEnemyTarget(npc) and data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
				if bomb.IsFetus and npc then
					self:PostNpcHit(bomb, npc)
				end
			end

			--Epic Fetus Rockets
			local eData = effect and getData(effect)
			if effect and npc and eData and TearModifier:IsValidEnemyTarget(npc) and eData[modInitial .. self.Name] and not eData[modInitial .. self.Name .. "_Disabled"] then
				if npc then
					self:PostNpcHit(effect, npc)
				end
			end
		end)

		---@param collider Entity
		Mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, function(_, bomb, collider, low)
			local data = getData(bomb)
			if data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
				if not bomb.IsFetus then
					return
				end

				local npc = collider:ToNPC()
				if npc and TearModifier:IsValidEnemyTarget(npc) then
					self:PostNpcHit(bomb, npc)
				end

				return self:PreEntityCollision(bomb, collider, low)
			end
		end)

		---@param bomb EntityBomb
		Mod:AddCallback(ModCallbacks.MC_POST_BOMB_RENDER, function(_, bomb, offset)
			local data = getData(bomb)
			if data[modInitial .. self.Name] and not data[modInitial .. self.Name .. "_Disabled"] then
				self:PostRender(bomb, offset)
			end
		end)
	end
	--#endregion

	return self
end

return TearModifier
