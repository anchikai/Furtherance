local Mod = Furtherance
local game = Game()

local FindTargets = include("lua.items.collectibles.SpiritualWound.FindTargets")
local TargetType = FindTargets.TargetType

local HURT_COLOR = Color(1, 0, 0, 0.8)
local WOUND_DAMAGE_FLAGS = 0 -- no flags

local FIRE_DELAY_MULTIPLIER = 0.2
local HEAL_CHANCE = 0.05

local IPECAC_COLOR = Color(1, 1, 1, 1, 0, 0, 0)
IPECAC_COLOR:SetColorize(0.5, 0.9, 0.4, 1)

local function hasItem(player)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRITUAL_WOUND) or
		player:GetPlayerType() == PlayerType.PLAYER_MIRIAM_B
end

local function clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

local function addActiveCharge(player, amount, activeSlot)
	local polShiftConfig = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_POLARITY_SHIFT)
	assert(polShiftConfig, "Polarity Shift config not found")
	player:SetActiveCharge(math.min(player:GetActiveCharge(activeSlot) + amount, polShiftConfig.MaxCharges), activeSlot)
end

---@param itemData SpiritualWoundItemData
---@param targetDamage number
---@param targetQuery TargetQuery
local function handleBirthright(itemData, targetDamage, targetQuery)
	local player = itemData.Owner

	local allEnemies = targetQuery.AllEnemies

	local untargetedDamage
	if targetQuery.Type == TargetType.ENTITY then
		untargetedDamage = targetDamage * 0.05
	else
		untargetedDamage = targetDamage / (#allEnemies - 1)
	end

	for i = 2, #allEnemies do
		local enemy = allEnemies[i]
		enemy:TakeDamage(untargetedDamage, WOUND_DAMAGE_FLAGS, EntityRef(player), 1)
		enemy:SetColor(HURT_COLOR, 2, 1, false, false)
	end
end

---@param itemData SpiritualWoundItemData
---@param target Entity
local function fireNoSplitTear(itemData, target)
	local player = itemData.Owner
	local chance = clamp(0.10 + 0.05 * player.Luck, 0.10, 1)
	if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
		chance = 1 - (1 - chance) ^ 2
	end
	if itemData.RNG:RandomFloat() < chance then
		local angle = itemData.RNG:RandomFloat() * 360
		local directionVec = Vector.FromAngle(angle)
		local tearParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS)
		local tearPosition = target.Position + directionVec * target.Size * 2
		local tearVelocity = directionVec * 10 * player.ShotSpeed
		local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, tearParams.TearVariant, 0,
			tearPosition, tearVelocity, player):ToTear()
		---@cast tear EntityTear

		tear:AddTearFlags(player.TearFlags)
		tear:ClearTearFlags(TearFlags.TEAR_QUADSPLIT | TearFlags.TEAR_BURSTSPLIT)
	end
end

---@param player EntityPlayer
---@param target Entity
local function ipecacExplodeEnemy(player, target)
	game:BombExplosionEffects(target.Position, player.Damage, TearFlags.TEAR_EXPLOSIVE, IPECAC_COLOR, player)
end

local DamageEnemies = {}
setmetatable(DamageEnemies, DamageEnemies)

---@param itemData SpiritualWoundItemData
---@param targetQuery TargetQuery
function DamageEnemies:__call(itemData, targetQuery)
	if targetQuery == nil then return end

	local player = itemData.Owner

	if player.FireDelay > 0 then return end
	player.FireDelay = clamp(player.MaxFireDelay * FIRE_DELAY_MULTIPLIER, 1, 30)

	local damageMultiplier = 0.14
	if itemData.GetDamageMultiplier then
		damageMultiplier = itemData:GetDamageMultiplier()
	end

	-- give player a 1.3x damage buff
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
		damageMultiplier = damageMultiplier * 1.3
	end

	local targetDamage = player.Damage * damageMultiplier

	if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
		and player:GetPlayerType() == PlayerType.PLAYER_MIRIAM_B
	then
		handleBirthright(itemData, targetDamage, targetQuery)
		if targetQuery.Type == TargetType.ENTITY then
			targetDamage = targetDamage * (1 - 0.05 * (#targetQuery.AllEnemies - 1))
		end
	end

	if targetQuery.Type == TargetType.ENTITY then
		---@cast targetQuery EntityTargetQuery
		itemData.HitCount = itemData.HitCount + 1

		local target = targetQuery.Result[1]
		target:TakeDamage(targetDamage, WOUND_DAMAGE_FLAGS, EntityRef(player), 1)
		target:SetColor(HURT_COLOR, 2, 1, false, false)

		if player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)
			or player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY)
		then
			fireNoSplitTear(itemData, target)
		end

		if target:HasMortalDamage() then
			itemData.HitCount = 0
			itemData.SnapCooldown = 7
			Mod:GetData(target).SpiritualWoundDied = true
			if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
				ipecacExplodeEnemy(player, target)
			end
		end
	elseif targetQuery.Type == TargetType.GRID_ENTITY then
		---@cast targetQuery GridEntityTargetQuery
		local target = targetQuery.Result
		local roundedTargetDamage = math.floor(targetDamage + 0.5)
		target:Hurt(roundedTargetDamage)
	elseif targetQuery.Type == TargetType.PSEUDO_GRID_ENTITY then
		---@cast targetQuery PseudoGridEntityTargetQuery
		local target = targetQuery.Result
		target:TakeDamage(targetDamage, WOUND_DAMAGE_FLAGS, EntityRef(player), 1)
	end
end

function Mod:SpiritualWoundKill(entity)
	local enemyData = Mod:GetData(entity)
	if enemyData.SpiritualWoundDied == nil then return end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if not player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRITUAL_WOUND) and player:GetPlayerType() ~= PlayerType.PLAYER_MIRIAM_B then goto continueKill end

		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SPIRITUAL_WOUND)
		if rng:RandomFloat() > HEAL_CHANCE then goto continueKill end

		local data = Mod:GetData(player)

		if not player:HasCollectible(CollectibleType.COLLECTIBLE_POLARITY_SHIFT) then goto continueKill end

		if data.UsedPolarityShift or player:HasFullHearts() then
			for _, activeSlot in pairs(ActiveSlot) do
				if player:GetActiveItem(activeSlot) == CollectibleType.COLLECTIBLE_POLARITY_SHIFT then
					addActiveCharge(player, 1, activeSlot)
					game:GetHUD():FlashChargeBar(player, ActiveSlot.SLOT_PRIMARY)
					if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < 6 then
						SFXManager():Play(SoundEffect.SOUND_BEEP)
					else
						SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
						SFXManager():Play(SoundEffect.SOUND_ITEMRECHARGE)
					end
				end
			end
		elseif not data.UsedPolarityShift then
			SFXManager():Play(SoundEffect.SOUND_VAMP_GULP)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, player.Position, Vector.Zero, player)
			player:AddHearts(1)
		end
		::continueKill::
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Mod.SpiritualWoundKill)

---@param victim Entity
---@param flags DamageFlag
---@param source EntityRef
---@return false|nil -- returning true blocks other ENTITY_TAKE_DMG callbacks
function Mod:IgnoreEntityLaserDamage(victim, _, flags, source)
	if source == nil or source.Entity == nil then return nil end

	local player = source.Entity:ToPlayer()
	if player == nil
		or victim.Type == EntityType.ENTITY_FAMILIAR
		or flags & DamageFlag.DAMAGE_LASER == 0
		or not hasItem(player)
	then
		return nil
	else
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Mod.IgnoreEntityLaserDamage)

return DamageEnemies
