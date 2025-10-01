local Mod = Furtherance

local SHATTERED_HEART = {}

Furtherance.Item.SHATTERED_HEART = SHATTERED_HEART

SHATTERED_HEART.ID = Isaac.GetItemIdByName("Shattered Heart")

SHATTERED_HEART.SCARED_HEART_CHANCE = Mod.Character.LEAH.SCARED_HEART_CHANCE / 2
SHATTERED_HEART.DEFAULT_EXPLOSION_DAMAGE = 5.25
SHATTERED_HEART.EXPLOSION_MULT = 7.5

SHATTERED_HEART.HEART_EXPLOSION = {
	[HeartSubType.HEART_ETERNAL] = 21,
	[HeartSubType.HEART_GOLDEN] = 10.5,
	[HeartSubType.HEART_ROTTEN] = 10.5,
	[HeartSubType.HEART_BONE] = 10.5,
}

--Copied from Madalene's Birthcake (hehe I made that)

---@param pickup EntityPickup
function SHATTERED_HEART:GetHeartDamage(pickup)
	local heartExplosion = SHATTERED_HEART.HEART_EXPLOSION[pickup.SubType] or ((Mod.HeartAmount[pickup.SubType] or 2) * 3.5)
	local baseDamage = heartExplosion or SHATTERED_HEART.DEFAULT_EXPLOSION_DAMAGE
	return baseDamage + (0.5 * Mod.Game:GetLevel():GetAbsoluteStage())
end

---@param pickup EntityPickup
---@param player? EntityPlayer
---@param radiusMult? number
function SHATTERED_HEART:ExplodeHeart(pickup, player, radiusMult)
	radiusMult = radiusMult or 1
	local damage = SHATTERED_HEART:GetHeartDamage(pickup)
	local radius = pickup.Size * SHATTERED_HEART.EXPLOSION_MULT * radiusMult
	local kColor = pickup:GetSprite():GetTexel(Vector(4, -7), Vector.Zero, 1, 0)
	local color = Color(kColor.Red, kColor.Green, kColor.Blue, 1)
	local posRange = radius / 2

	if player and Mod.Character.LEAH_B:LeahBHasBirthright(player) then
		damage = damage * 2
	end

	Mod.Foreach.NPCInRadius(pickup.Position, radius, function(npc, index)
		npc:TakeDamage(damage, DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_IGNORE_ARMOR,
			EntityRef(pickup), 0)
	end, nil, nil, { UseEnemySearchParams = true })

	for _ = 1, 5 do
		local position = Vector(Mod:RandomNum(-posRange, posRange), Mod:RandomNum(-posRange, posRange))
		position = position + pickup.Position
		local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, position,
			Vector.Zero, pickup)
		local eSprite = explosion:GetSprite()
		eSprite:ReplaceSpritesheet(0, "gfx/effects/shattered_heart_explosion.png", true)
		explosion.Color = color

		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, position,
			Vector.Zero, pickup)
		local cSprite = creep:GetSprite()
		cSprite:ReplaceSpritesheet(0, "gfx/effects/shattered_heart_bloodpool.png", true)
		creep.Color = color
		creep.SpriteScale = Vector(2.5, 2.5)
		creep:Update()
	end

	Mod.SFXMan:Play(SoundEffect.SOUND_EXPLOSION_WEAK)
	pickup:GetSprite():SetFrame("Idle", 0)
	pickup:BloodExplode()
	pickup:Remove()
end

---@param flags UseFlag
---@param player EntityPlayer
function SHATTERED_HEART:OnUse(_, _, player, flags, slot)
	if Mod:HasBitFlags(flags, UseFlag.USE_CARBATTERY) then
		return
	end
	Mod.Foreach.Pickup(function(pickup, index)
		local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.SHATTERED_HEART_EXPLODE, pickup.SubType,
			pickup:ToPickup())
		if result then
			return
		end
		SHATTERED_HEART:ExplodeHeart(pickup, player, Mod:ActiveUsesCarBattery(player, slot) and 1.5 or 1)
	end, PickupVariant.PICKUP_HEART)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, SHATTERED_HEART.OnUse, SHATTERED_HEART.ID)

---@param pickup EntityPickup
function SHATTERED_HEART:SharpHeartUpdate(pickup)
	local data = Mod:TryGetData(pickup)
	if not (data
			and data.ShatteredHeartPickup
			and (pickup:GetSprite():IsPlaying("Idle")
				or pickup:GetSprite():WasEventTriggered("DropSound")
			))
	then
		return
	end
	local player = pickup.SpawnerEntity and pickup.SpawnerEntity:ToPlayer()

	Mod.Foreach.NPCInRadius(pickup.Position, pickup.Size, function(npc, index)
		Mod.SFXMan:Play(SoundEffect.SOUND_MEAT_IMPACTS, 1, 2, false, 0.5)
		if player and Mod.Character.LEAH_B:LeahBHasBirthright(player) and Mod:CanCollectHeart(player, pickup.SubType) then
			player:ForceCollide(pickup, true)
		else
			pickup:GetSprite():Play("Collect")
			pickup:Die()
		end
		npc:TakeDamage(SHATTERED_HEART:GetHeartDamage(pickup), DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(pickup), 0)
		return true
	end, nil, nil, { UseEnemySearchParams = true })
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, SHATTERED_HEART.SharpHeartUpdate, PickupVariant.PICKUP_HEART)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function SHATTERED_HEART:RemoveBrokensFromDamage(ent, amount, flags, source, countdown)
	if not ent:IsActiveEnemy(true) then return end
	local player = Mod:TryGetPlayer(source, { LoopSpawnerEnt = true })
	if player and PlayerManager.AnyoneHasCollectible(Mod.Item.SHATTERED_HEART.ID) then
		local rng = player:GetCollectibleRNG(Mod.Item.SHATTERED_HEART.ID)
		local chance = SHATTERED_HEART.SCARED_HEART_CHANCE
		if BirthcakeRebaked and BirthcakeRebaked:PlayerTypeHasBirthcake(player, Mod.PlayerType.LEAH_B) then
			chance = chance * (BirthcakeRebaked:GetTrinketMult(player) + 1)
		end
		if rng:RandomFloat() <= chance then
			local sharpPickup = Mod.Spawn.Heart(HeartSubType.HEART_SCARED, ent.Position,
				EntityPickup.GetRandomPickupVelocity(ent.Position, rng), player, rng:Next()
			)
			local data = Mod:GetData(sharpPickup)
			data.ShatteredHeartPickup = true
			sharpPickup:GetSprite().Color = Color(0.5, 0.5, 0.5)
			sharpPickup.Timeout = 300
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, SHATTERED_HEART.RemoveBrokensFromDamage)
