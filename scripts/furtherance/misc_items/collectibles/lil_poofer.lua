local Mod = Furtherance
local floor = Mod.math.floor

local LIL_POOFER = {}

Furtherance.Item.LIL_POOFER = LIL_POOFER

LIL_POOFER.ID = Isaac.GetItemIdByName("Lil Poofer")
LIL_POOFER.FAMILIAR = Isaac.GetEntityVariantByName("Lil Poofer")

LIL_POOFER.EXPLOSION_DMG = 10
LIL_POOFER.EXPLOSION_SIZE_RANGE_MULT = 8
LIL_POOFER.COOLDOWN = 600

---@param familiar EntityFamiliar
function LIL_POOFER:FamiliarInit(familiar)
	familiar.IsFollower = true
	familiar:AddToFollowers()
	familiar:GetSprite():Play("Idle" .. floor(familiar.Hearts / 2))
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LIL_POOFER.FamiliarInit, LIL_POOFER.FAMILIAR)

---@param familiar EntityFamiliar
function LIL_POOFER:FamiliarUpdate(familiar)
	familiar:GetSprite():SetAnimation("Idle" .. floor(familiar.Hearts / 2), false)
	if familiar.FireCooldown > 0 then
		familiar.FireCooldown = familiar.FireCooldown - 1
	elseif familiar.State == 1 then
		familiar.State = 0
		familiar:AddToFollowers()
		local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, nil)
		poof.SpriteScale = Vector(0.75, 0.75)
		familiar.Visible = true
	end
	familiar:FollowParent()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LIL_POOFER.FamiliarUpdate, LIL_POOFER.FAMILIAR)

---@param player EntityPlayer
function LIL_POOFER:FamiliarCache(player)
	local effects = player:GetEffects()
	local numFamiliars = player:GetCollectibleNum(LIL_POOFER.ID) + effects:GetCollectibleEffectNum(LIL_POOFER.ID)
	local rng = player:GetCollectibleRNG(LIL_POOFER.ID)
	rng:Next()
	player:CheckFamiliar(LIL_POOFER.FAMILIAR, numFamiliars, rng, Mod.ItemConfig:GetCollectible(LIL_POOFER.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LIL_POOFER.FamiliarCache, CacheFlag.CACHE_FAMILIARS)

function LIL_POOFER:FollowerPriority()
	return FollowerPriority.DEFENSIVE
end

Mod:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, LIL_POOFER.FollowerPriority, LIL_POOFER.FAMILIAR)

function LIL_POOFER:PreFamiliarCollision(familiar, collider)
	if collider:ToProjectile() and familiar.State == 1 then
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, LIL_POOFER.PreFamiliarCollision, LIL_POOFER.FAMILIAR)

---@param familiar EntityFamiliar
function LIL_POOFER:Explode(familiar)
	local bffs = familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
	local radius = familiar.Size * LIL_POOFER.EXPLOSION_SIZE_RANGE_MULT
	local source = EntityRef(familiar)

	--Damage enemies
	Mod.Foreach.NPCInRadius(familiar.Position, radius, function (npc, index)
		npc:TakeDamage(LIL_POOFER.EXPLOSION_DMG * familiar:GetMultiplier(),
			DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR, source, 0)
	end, nil, nil, {UseEnemySearchParams = true})

	--Heal players
	Mod.Foreach.PlayerInRadius(familiar.Position, radius, function (player, index)
		if player:GetHearts() < player:GetEffectiveMaxHearts()
			and player:GetHealthType() == HealthType.RED
		then
			player:AddHearts(1)
			Mod.Spawn.Notification(player.Position, 0, true)
		end
	end)

	--These are all effects that the original Poofer spawns
	Mod.Spawn.Poof02(3, familiar.Position)
	Mod.Spawn.Poof02(4, familiar.Position)
	local explosion = Mod.Spawn.Effect(EffectVariant.BOMB_EXPLOSION, 0, familiar.Position)
	explosion.Color = Color(1, 0, 0, 1)
	local poof02 = Mod.Spawn.Poof02(5, familiar.Position)
	poof02.Color.A = 0.4

	--Dust clouds
	local dustClouds = Mod.Spawn.DustClouds(familiar.Position, 8)
	for _, dustCloud in ipairs(dustClouds) do
		dustCloud.Color = Color(0.619608, 0.0431373, 0.0588235)
	end

	--Creep in the middle
	local creepMiddle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, familiar.Position,
		Vector.Zero, familiar)
	creepMiddle:Update()

	--Random blood explosions
	for _ = 1, 5 do
		local position = Vector(Mod:RandomNum(-radius, radius), Mod:RandomNum(-radius, radius))
		position = position + familiar.Position
		Mod.Spawn.Effect(EffectVariant.BLOOD_EXPLOSION, 0, position, nil, familiar)
	end

	--Spawn 6-directional radial of blood creep
	local scale = bffs and 1.5 or 1
	local spritescale = Vector(scale, scale)
	local randomOffset = Mod:RandomNum(-15, 15)

	for i = 1, 2 do
		for j = 1, 6 do
			local rotation = (360 / 6) * j
			local pos = familiar.Position + Vector(40 * i, 0):Rotated(rotation + randomOffset)
			local creapSpread = Mod.Spawn.Effect(EffectVariant.PLAYER_CREEP_RED, 0, pos, nil, familiar)
			creapSpread.SpriteScale = spritescale
			creapSpread:Update()
		end
	end

	Mod.SFXMan:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS)
	Mod.SFXMan:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
end

---@param familiar EntityFamiliar
---@param collider Entity
function LIL_POOFER:FamiliarCollision(familiar, collider)
	local size = familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 7.5 or 5
	if collider:ToProjectile() and familiar.State == 0 then
		if familiar.Hearts < 9 then
			familiar.Hearts = familiar.Hearts + 1
			local sizeUp = 2 * floor(familiar.Hearts / 2)
			familiar:SetSize(size + sizeUp, Vector.One, 12)
			familiar:SetShadowSize((size + 2 + sizeUp) * 0.01)
		else
			LIL_POOFER:Explode(familiar)
			familiar:SetSize(size, Vector.One, 12)
			familiar:SetShadowSize((size + 2) * 0.01)
			familiar.Hearts = 0
			familiar.State = 1
			familiar:RemoveFromFollowers()
			familiar.Visible = false
			familiar.FireCooldown = LIL_POOFER.COOLDOWN
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, LIL_POOFER.FamiliarCollision, LIL_POOFER.FAMILIAR)
