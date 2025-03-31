local Mod = Furtherance

local POLYDIPSIA = {}

Furtherance.Item.POLYDIPSIA = POLYDIPSIA

POLYDIPSIA.ID = Isaac.GetItemIdByName("Polydipsia")

--[[
local WhirlpoolVariant = Isaac.GetEntityVariantByName("Miriam Whirlpool")

local allPuddles = {}

local function hasItem(player)
	return player ~= nil and player:HasCollectible(CollectibleType.COLLECTIBLE_POLYDIPSIA)
end

local function isMiriam(player)
	return player ~= nil and player:GetPlayerType() == PlayerType.PLAYER_MIRIAM
end

function Mod:GetPolydipsia(player, cacheFlag)
	if hasItem(player) or isMiriam(player) then
		if cacheFlag == CacheFlag.CACHE_RANGE then
			player.TearFallingSpeed = player.TearFallingSpeed + 20
			player.TearFallingAcceleration = player.TearFallingAcceleration + 1
		end
	end

	if hasItem(player) and not isMiriam(player) and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN then
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = (player.MaxFireDelay * 2) + 10
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.GetPolydipsia)

local function makeMiriamPuddle(miriam, tear)
	local data = Mod:GetData(tear)
	local playerData = Mod:GetData(miriam)
	if playerData.MiriamAOE == nil then
		playerData.MiriamAOE = 1
	end
	if data.MiriamPullEnemies then
		local whirlpool = Isaac.Spawn(EntityType.ENTITY_EFFECT, WhirlpoolVariant, 0, tear.Position, Vector.Zero, miriam)
		:ToEffect()
		whirlpool.CollisionDamage = miriam.Damage * 0.33
		whirlpool.LifeSpan = 60
	else
		local puddle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 1, tear
		.Position, Vector.Zero, miriam):ToEffect()
		---@cast puddle EntityEffect
		local puddleDamage = miriam.Damage * 0.33
		puddle.CollisionDamage = 0
		puddle.SpriteScale = Vector.One * playerData.MiriamAOE
		puddle.Scale = playerData.MiriamAOE
		if miriam:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
			puddle.Color = Color(0.75, 0.25, 0.05, 1)
		end
		if miriam:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or miriam:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
			puddle.Color = Color(1, 0, 0, 1)
			if miriam:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
				puddleDamage = miriam.Damage * 0.4
			end
		end
		if miriam:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
			local color = Color(1, 1, 1, 1, 0, 0, 0)
			color:SetColorize(2, 2, 2, 1)
			puddle.Color = color
			puddle.SpriteScale = Vector.One * playerData.MiriamAOE / 2
			puddle.Scale = playerData.MiriamAOE / 2
		end
		allPuddles[GetPtrHash(puddle)] = {
			Entity = puddle,
			Damage = puddleDamage,
			CollisionRadius = 25 * playerData.MiriamAOE,
			DamageCooldown = 0,
			DamageRef = EntityRef(miriam)
		}
	end

	if hasItem(miriam) and tear.SubType == 0 then
		local PolyMiriam = miriam:FireTear(tear.Position, tear.Velocity, true, true, false, miriam, 1)
		PolyMiriam.SubType = 1
	end
end

function Mod:OnTearImpact(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if not hasItem(player) and not isMiriam(player) then return end

	if isMiriam(player) then
		makeMiriamPuddle(player, tear)
	else
		local puddle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 1, tear
		.Position, Vector.Zero, player):ToEffect()
		---@cast puddle EntityEffect
		puddle.CollisionDamage = 0
		allPuddles[GetPtrHash(puddle)] = {
			Entity = puddle,
			Damage = player.Damage * 0.33,
			CollisionRadius = 25,
			DamageCooldown = 0,
			DamageRef = EntityRef(player)
		}
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, Mod.OnTearImpact, EntityType.ENTITY_TEAR)

function Mod:PolydipsiaPuddleUpdate()
	-- remove puddles that don't exist
	for k, puddleData in pairs(allPuddles) do
		if puddleData.Entity.Timeout <= 0 or not puddleData.Entity:Exists() then
			allPuddles[k] = nil
		end
	end

	-- update puddles
	for _, puddleData in pairs(allPuddles) do
		if puddleData.DamageCooldown <= 0 then
			local puddle = puddleData.Entity
			for _, enemy in ipairs(Isaac.FindInRadius(puddle.Position, puddleData.CollisionRadius, EntityPartition.ENEMY)) do
				if not enemy:IsFlying() then
					enemy:TakeDamage(puddleData.Damage, 0, puddleData.DamageRef, 0)
					puddleData.DamageCooldown = 4
				end
			end
		end
		puddleData.DamageCooldown = math.max(puddleData.DamageCooldown - 1, 0)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Mod.PolydipsiaPuddleUpdate)

function Mod:MakePolydipsiaTear(tear)
	local player = tear.Parent:ToPlayer()
	if hasItem(player) or isMiriam(player) then
		tear.Scale = tear.Scale * 1.4
		tear:AddTearFlags(TearFlags.TEAR_KNOCKBACK)
		tear:SetKnockbackMultiplier(tear.KnockbackMultiplier * 2)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.MakePolydipsiaTear)

-- Dr. Fetus Synergy
function Mod:PolyBombUpdate(bomb)
	local player = Mod:GetPlayerFromTear(bomb)
	local data = Mod:GetData(bomb)
	if player then
		if bomb.FrameCount == 1 then
			if bomb.Type == EntityType.ENTITY_BOMB and bomb.Variant ~= BombVariant.BOMB_THROWABLE
				and (player:HasCollectible(CollectibleType.COLLECTIBLE_POLYDIPSIA) or isMiriam(player)) then
				if data.isPolyBomb == nil then
					data.isPolyBomb = true
				end
			end
		end
	end
	if data.isPolyBomb then
		local sprite = bomb:GetSprite()
		if sprite:IsPlaying("Explode") then
			makeMiriamPuddle(player, bomb)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, Mod.PolyBombUpdate)

-- Brimstone & Tech "Synergy"
function Mod:PolyLasers(laser)
	local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
	if player ~= nil and (player:HasCollectible(CollectibleType.COLLECTIBLE_POLYDIPSIA) or isMiriam(player)) and laser.FrameCount == 1 then
		makeMiriamPuddle(player, laser)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, Mod.PolyLasers)
 ]]