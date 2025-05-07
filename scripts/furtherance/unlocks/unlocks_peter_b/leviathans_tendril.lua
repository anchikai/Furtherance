--#region Variables

local Mod = Furtherance

local LEVIATHANS_TENDRIL = {}

Furtherance.Trinket.LEVIATHANS_TENDRIL = LEVIATHANS_TENDRIL

LEVIATHANS_TENDRIL.ID = Isaac.GetTrinketIdByName("Leviathan's Tendril")

-- 2Spooky radius
LEVIATHANS_TENDRIL.FEAR_RADIUS = 80
LEVIATHANS_TENDRIL.FEAR_CHANCE = 0.05
LEVIATHANS_TENDRIL.FEAR_DURATION = 90
LEVIATHANS_TENDRIL.REFLECT_CHANCE = 0.25
LEVIATHANS_TENDRIL.LEVIATHAN_CHANCE_BUFF = 0.05

local wormFriendColor = Color(1, 1, 1)
wormFriendColor:SetColorize(1, 1, 1, 1)
wormFriendColor:SetTint(0.5, 0.5, 0.5, 1)

LEVIATHANS_TENDRIL.WORM_FRIEND_COLOR = wormFriendColor

--#endregion

--#region Reflect projectiles

---@param player EntityPlayer
---@param projectile EntityProjectile
---@param angleOffset number
local function redirectProjectile(player, projectile, angleOffset)
	-- redirect it in a direction away from the player
	local delta = projectile.Position - player.Position
	local tear = Mod.Spawn.Tear(TearVariant.BLUE, projectile.Position,
		delta:Rotated(angleOffset):Resized(projectile.Velocity:Length() * 1.5), TearFlags.TEAR_HOMING, player)
	tear.Color = Color.TearHoming
	tear.CollisionDamage = tear.CollisionDamage * projectile.CollisionDamage
	tear.Scale = Mod:TearDamageToScale(tear)
	tear:ResetSpriteScale(true)
	projectile:Remove()
end

---@param proj EntityProjectile
---@param collider Entity
function LEVIATHANS_TENDRIL:PreProjectileCollision(proj, collider)
	local player = collider:ToPlayer()

	if player and player:HasTrinket(LEVIATHANS_TENDRIL.ID) then
		local rng = player:GetTrinketRNG(LEVIATHANS_TENDRIL.ID)
		local reflectChance = LEVIATHANS_TENDRIL.REFLECT_CHANCE * player:GetTrinketMultiplier(LEVIATHANS_TENDRIL.ID)
		if player:HasPlayerForm(PlayerForm.PLAYERFORM_EVIL_ANGEL) then
			reflectChance = reflectChance + LEVIATHANS_TENDRIL.LEVIATHAN_CHANCE_BUFF
		end
		if rng:RandomFloat() <= reflectChance then
			redirectProjectile(player, proj, rng:RandomFloat() * 180 - 90)
			return true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, LEVIATHANS_TENDRIL.PreProjectileCollision)

--#region

--#region Fear enemies

---@param player EntityPlayer
function LEVIATHANS_TENDRIL:FearEnemies(player)
	if player:HasTrinket(LEVIATHANS_TENDRIL.ID) then
		local rng = player:GetTrinketRNG(LEVIATHANS_TENDRIL.ID)
		local fearChance = LEVIATHANS_TENDRIL.FEAR_CHANCE * player:GetTrinketMultiplier(LEVIATHANS_TENDRIL.ID)
		local source = EntityRef(player)

		if player:HasPlayerForm(PlayerForm.PLAYERFORM_EVIL_ANGEL) then
			fearChance = fearChance + 0.05
		end

		Mod.Foreach.NPCInRadius(player.Position, LEVIATHANS_TENDRIL.FEAR_RADIUS, function (npc, index)
			if rng:RandomFloat() <= fearChance then
				npc:AddFear(source, LEVIATHANS_TENDRIL.FEAR_DURATION)
			end
		end, nil, nil, {UseEnemySearchParams = true})
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LEVIATHANS_TENDRIL.FearEnemies)

--#endregion

--#region Unique Worm Friend interaction

---@param familiar EntityFamiliar
function LEVIATHANS_TENDRIL:WormFriendColorChange(familiar)
	local player = familiar.SpawnerEntity and familiar.SpawnerEntity:ToPlayer()

	if player and player:HasTrinket(LEVIATHANS_TENDRIL.ID) then
		--Updated so long as they have the trinket. Will go away if trinket is removed
		familiar:SetColor(LEVIATHANS_TENDRIL.WORM_FRIEND_COLOR, 2, 1, false, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LEVIATHANS_TENDRIL.WormFriendColorChange, FamiliarVariant.WORM_FRIEND)

---@param ent Entity
function LEVIATHANS_TENDRIL:WormFriendKilledEnemy(ent)
	local killedByLeviathanWormFriend = Mod.Foreach.Familiar(function(familiar)
		local player = familiar.Player
		if player and player:HasTrinket(LEVIATHANS_TENDRIL.ID) and familiar.Target and GetPtrHash(familiar.Target) == GetPtrHash(ent) then
			return true
		end
	end, FamiliarVariant.WORM_FRIEND)
	if killedByLeviathanWormFriend then
		Mod.Spawn.Heart(HeartSubType.HEART_BLACK, ent.Position, nil, ent, ent.DropSeed)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, LEVIATHANS_TENDRIL.WormFriendKilledEnemy)

--#endregion