local Mod = Furtherance

local POLARIS = {}

Furtherance.Item.POLARIS = POLARIS

POLARIS.ID = Isaac.GetItemIdByName("Polaris")
POLARIS.FAMILIAR = Isaac.GetEntityVariantByName("Polaris")

---@enum PolarisColor
POLARIS.COLOR = {
	RED = 1,
	ORANGE = 2,
	YELLOW = 3,
	WHITE = 4,
	BLUE = 5
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

local WOP = WeightedOutcomePicker()
for i, colorTable in ipairs(POLARIS.COLOR_STATS) do
	WOP:AddOutcomeWeight(i, colorTable.Weight)
end

POLARIS.WOP = WOP

---@param player EntityPlayer
function POLARIS:PickColorBuff(player)
	local rng = player:GetCollectibleRNG(POLARIS.ID)
	local buffChoice = WOP:PickOutcome(rng)
	return buffChoice
end

function POLARIS:PreUpdateBuff()
	Mod:ForEachPlayer(function(player)
		local effects = player:GetEffects()
		local colorBuff = effects:GetCollectibleEffectNum(POLARIS.ID)

		if colorBuff == POLARIS.COLOR.YELLOW then
			player:AddMaxHearts(-1, false)
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, POLARIS.PreUpdateBuff)

---@param player EntityPlayer
function POLARIS:PostUpdateBuff(player)
	if player:HasCollectible(POLARIS.ID) then
		local effects = player:GetEffects()
		local colorBuff = POLARIS:PickColorBuff(player)
		effects:AddCollectibleEffect(POLARIS.ID, false, colorBuff)

		if colorBuff == POLARIS.COLOR.YELLOW then
			player:AddMaxHearts(1, false)
			player:AddHearts(1)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, POLARIS.PostUpdateBuff)

---@param player EntityPlayer
function POLARIS:OnPickup(itemID, charge, firstTime, slot, varData, player)
	if not player:GetEffects():HasCollectibleEffect(POLARIS.ID) then
		POLARIS:PostUpdateBuff(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, POLARIS.OnPickup, POLARIS.ID)

---@param player EntityPlayer
function POLARIS:OnFamiliarCache(player)
	local rng = player:GetCollectibleRNG(POLARIS.ID)
	rng:Next()
	local numFamiliars = math.min(1, player:GetCollectibleNum(POLARIS.ID) + player:GetEffects():GetCollectibleEffectNum(POLARIS.ID))
	player:CheckFamiliar(POLARIS.FAMILIAR, numFamiliars, rng, Mod.ItemConfig:GetCollectible(POLARIS.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLARIS.OnFamiliarCache, CacheFlag.CACHE_FAMILIARS)

---@param player EntityPlayer
---@param flag CacheFlag
function POLARIS:AddPlayerBuffs(player, flag)
	local effects = player:GetEffects()
	if not effects:HasCollectibleEffect(POLARIS.ID) then return end
	local colorBuff = POLARIS.COLOR_STATS[effects:GetCollectibleEffectNum(POLARIS.ID)]
	if not colorBuff or not colorBuff.CacheFlags[flag] then return end

	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + colorBuff.CacheFlags[flag]
	elseif flag == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed + colorBuff.CacheFlags[flag]
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLARIS.AddPlayerBuffs, CacheFlag.CACHE_DAMAGE)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLARIS.AddPlayerBuffs, CacheFlag.CACHE_SHOTSPEED)

---@param tear EntityTear
function POLARIS:PolarisTearBuffs(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if not player then return end
	local effects = player:GetEffects()
	local colorBuff = effects:GetCollectibleEffectNum(POLARIS.ID)
	if colorBuff == 0 then return end
	local rng = player:GetCollectibleRNG(POLARIS.ID)

	if colorBuff == POLARIS.COLOR.RED then
		tear.Scale = tear.Scale * 0.5
	elseif colorBuff == POLARIS.COLOR.WHITE then
		--TODO: Revisit for tear modifier implementation
		--[[ if rng:RandomFloat() <= 0.2 then
			tear:AddTearFlags(TearFlags.TEAR_LIGHT_FROM_HEAVEN)
		end ]]
	elseif colorBuff == POLARIS.COLOR.BLUE then
		tear.Scale = tear.Scale * 2
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, POLARIS.PolarisTearBuffs)

--TODO: Revisit for tear modifier implementation
function POLARIS:PolarisTearHit(tear, collider)
	--[[ local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player == nil or not player:HasCollectible(POLARIS.ID) then return end

	local data = Mod:GetData(player)
	if data.PolarisBuff == nil then
		POLARIS:UpdatePlayerBuff(player)
	end
	if data.PolarisBuff.ColorEnum == POLARIS.COLOR.BLUE then
		if collider:IsActiveEnemy(false) and collider:IsVulnerableEnemy() then
			collider:TakeDamage(10, DamageFlag.DAMAGE_FIRE, EntityRef(tear), 0)
		end
	end ]]
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, POLARIS.PolarisTearHit)

---@param familiar EntityFamiliar
function POLARIS:FamiliarInit(familiar)
	familiar:AddToFollowers()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, POLARIS.FamiliarInit, POLARIS.FAMILIAR)

---@param familiar EntityFamiliar
function POLARIS:FamiliarUpdate(familiar)
	local player = familiar.Player
	local colorBuff = player:GetEffects():GetCollectibleEffectNum(POLARIS.ID)

	if POLARIS.COLOR_STATS[colorBuff] then
		familiar:SetColor(POLARIS.COLOR_STATS[colorBuff].Color, 2, 1, false, false)
	end

	familiar:FollowParent()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, POLARIS.FamiliarUpdate, POLARIS.FAMILIAR)
