--#region Variables

local Mod = Furtherance

local POLARIS = {}

Furtherance.Item.POLARIS = POLARIS

POLARIS.ID = Isaac.GetItemIdByName("Polaris")
POLARIS.FAMILIAR = Isaac.GetEntityVariantByName("Polaris")
POLARIS.NULL_ID = Isaac.GetNullItemIdByName("polaris color")

POLARIS.YELLOW_HEART_SPAWN_CHANCE = 0.5

---@enum PolarisColor
POLARIS.COLOR = {
	RED = 1,
	ORANGE = 2,
	YELLOW = 3,
	WHITE = 4,
	BLUE = 5,
	NUM_COLORS = 6
}

POLARIS.COLOR_STATS = {
	[POLARIS.COLOR.RED] = {
		Weight = 50,
		Color = Color(1, 0, 0, 1, 0, 0, 0),
		CacheFlags = {
			[CacheFlag.CACHE_SHOTSPEED] = 2
		},
	},
	[POLARIS.COLOR.ORANGE] = {
		Weight = 33,
		Color = Color(1, 0.5, 0, 1, 0, 0, 0),
		CacheFlags = {
			[CacheFlag.CACHE_SHOTSPEED] = 1.5,
			[CacheFlag.CACHE_DAMAGE] = 0.5
		},
	},
	[POLARIS.COLOR.YELLOW] = {
		Weight = 45,
		Color = Color(1, 0.8, 0, 1, 0, 0, 0),
		CacheFlags = {
			[CacheFlag.CACHE_SHOTSPEED] = 1,
			[CacheFlag.CACHE_DAMAGE] = 1
		},
	},
	[POLARIS.COLOR.WHITE] = {
		Weight = 26,
		Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.5),
		CacheFlags = {
			[CacheFlag.CACHE_SHOTSPEED] = 0.5,
			[CacheFlag.CACHE_DAMAGE] = 1.5
		},
	},
	[POLARIS.COLOR.BLUE] = {
		Weight = 5,
		Color = Color(0, 0, 1, 1, 0, 0, 0),
		CacheFlags = {
			[CacheFlag.CACHE_DAMAGE] = 2
		},
	}
}

--#endregion

--#region Applying buff

---@param player EntityPlayer
function POLARIS:GetColorBuff(player)
	return player:GetEffects():GetNullEffectNum(POLARIS.NULL_ID)
end

---@param player EntityPlayer
function POLARIS:PickColorBuff(player)
	local rng = RNG(Mod.Level():GetCurrentRoomDesc().SpawnSeed)
	local buffChoice = rng:RandomInt(POLARIS.COLOR.NUM_COLORS - 1) + 1
	return buffChoice
end

---@param player EntityPlayer
function POLARIS:UpdateColorBuff(player)
	player:GetEffects():RemoveNullEffect(POLARIS.NULL_ID, -1)
	if player:HasCollectible(POLARIS.ID) then
		local effects = player:GetEffects()
		local colorBuff = POLARIS:PickColorBuff(player)
		effects:AddNullEffect(POLARIS.NULL_ID, false, colorBuff)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		player:EvaluateItems()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, POLARIS.UpdateColorBuff)

function POLARIS:OnNewWave(player)
	--Room would only continue to not be cleared if its a challenge/greed wave
	if not Mod.Room():IsClear() then
		POLARIS:UpdateColorBuff(player)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, CallbackPriority.LATE, POLARIS.OnNewWave)

---@param player EntityPlayer
function POLARIS:OnPickup(itemID, charge, firstTime, slot, varData, player)
	if player:GetEffects():HasNullEffect(POLARIS.NULL_ID) then
		POLARIS:UpdateColorBuff(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, POLARIS.OnPickup, POLARIS.ID)

---@param player EntityPlayer
function POLARIS:OnRemoval(player)
	if player:GetEffects():HasNullEffect(POLARIS.NULL_ID) then
		POLARIS:UpdateColorBuff(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, POLARIS.OnRemoval, POLARIS.ID)

---@param player EntityPlayer
---@param flag CacheFlag
function POLARIS:AddPlayerBuffs(player, flag)
	local effects = player:GetEffects()
	if not effects:HasCollectibleEffect(POLARIS.ID) then return end
	local colorBuff = POLARIS.COLOR_STATS[POLARIS:GetColorBuff(player)]
	if not colorBuff or not colorBuff.CacheFlags[flag] then return end

	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + colorBuff.CacheFlags[flag]
	elseif flag == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed + colorBuff.CacheFlags[flag]
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLARIS.AddPlayerBuffs, CacheFlag.CACHE_DAMAGE)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLARIS.AddPlayerBuffs, CacheFlag.CACHE_SHOTSPEED)

--#endregion

--#region Red/Blue Scale

---@param tear EntityTear
function POLARIS:PolarisTearBuffs(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if not player then return end
	local colorBuff = POLARIS:GetColorBuff(player)
	if colorBuff == 0 then return end

	if colorBuff == POLARIS.COLOR.RED then
		tear.Scale = tear.Scale * 0.5
	elseif colorBuff == POLARIS.COLOR.BLUE then
		tear.Scale = tear.Scale * 2
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, POLARIS.PolarisTearBuffs)

--#endregion

--#region White Holy Shot

POLARIS.WHITE_MODIFIER = Mod.TearModifier.New({
	Name = "Polaris White",
	RngGetter = function(player)
		if POLARIS:GetColorBuff(player) == POLARIS.COLOR.WHITE then
			return player:GetCollectibleRNG(POLARIS.ID)
		end
	end,
	MinLuck = 0,
	MaxLuck = 9,
	MinChance = 0.1,
	MaxChance = 0.5,
	ShouldAffectBombs = true
})

function POLARIS.WHITE_MODIFIER:PostFire(object)
	if object:ToTear() or object:ToBomb() then
		object:AddTearFlags(TearFlags.TEAR_LIGHT_FROM_HEAVEN)
		if object:ToTear() then
			object:Update()
		end
	end
end

function POLARIS.WHITE_MODIFIER:PostNpcHit(hitter, npc)
	if not hitter:ToTear() and not hitter:ToBomb() then
		local player = Mod:TryGetPlayer(hitter)
		if not player then return end
		npc:TakeDamage(player.Damage * 3, 0, EntityRef(hitter), 0)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 10, npc.Position, Vector.Zero, hitter)
	end
end

--#endregion

--#region Blue Burn

POLARIS.BLUE_MODIFIER = Mod.TearModifier.New({
	Name = "Polaris Blue",
	RngGetter = function(player)
		if POLARIS:GetColorBuff(player) == POLARIS.COLOR.BLUE then
			return player:GetCollectibleRNG(POLARIS.ID)
		end
	end,
	MinLuck = 0,
	MaxLuck = 1,
	MinChance = 1,
	MaxChance = 1,
	ShouldAffectBombs = true
})

function POLARIS.BLUE_MODIFIER:PostNpcHit(hitter, npc)
	local stage = Mod.Level():GetStage()
	npc:AddBurn(EntityRef(hitter), 150, 3 + (0.5 * stage))
end

--#endregion

--#region Yellow Heart Room Clear

---@param rng RNG
---@param pos Vector
function POLARIS:OnRoomClear(rng, pos)
	local hasYellowPolaris = Mod.Foreach.Player(function(player)
		if POLARIS:GetColorBuff(player) == POLARIS.COLOR.YELLOW then
			return true
		end
	end)
	if hasYellowPolaris and rng:RandomFloat() <= POLARIS.YELLOW_HEART_SPAWN_CHANCE then
		Mod.Game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART,
			Mod.Room():FindFreePickupSpawnPosition(pos), Vector.Zero, nil, NullPickupSubType.ANY, rng:GetSeed())
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.LATE, POLARIS.OnRoomClear)

--#endregion

--#region Familiar setup

---@param familiar EntityFamiliar
function POLARIS:FamiliarInit(familiar)
	familiar:AddToFollowers()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, POLARIS.FamiliarInit, POLARIS.FAMILIAR)

---@param familiar EntityFamiliar
function POLARIS:FamiliarUpdate(familiar)
	local player = familiar.Player
	local colorBuff = POLARIS:GetColorBuff(player)

	if POLARIS.COLOR_STATS[colorBuff] then
		familiar:SetColor(POLARIS.COLOR_STATS[colorBuff].Color, 2, 1, false, false)
	end

	familiar:FollowParent()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, POLARIS.FamiliarUpdate, POLARIS.FAMILIAR)


---@param player EntityPlayer
function POLARIS:OnFamiliarCache(player)
	local rng = player:GetCollectibleRNG(POLARIS.ID)
	rng:Next()
	local numFamiliars = math.min(1, player:GetCollectibleNum(POLARIS.ID) + player:GetEffects():GetCollectibleEffectNum(POLARIS.ID))
	player:CheckFamiliar(POLARIS.FAMILIAR, numFamiliars, rng, Mod.ItemConfig:GetCollectible(POLARIS.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLARIS.OnFamiliarCache, CacheFlag.CACHE_FAMILIARS)

--#endregion
