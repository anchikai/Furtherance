--By TheCatWizard
local game = Game()
local Spawn = {}


local function randomSeed()
	return math.max(Random(), 1) -- seed being 0 causes a crash
end

--#region Pickups

---@alias EntityOrNil Entity | nil
---@alias IntOrNil integer | nil
---@alias VectorOrNil Vector | nil
---@alias TearFlagsOrNil TearFlags | nil

---@type fun(variant: PickupVariant, subtype: integer, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
local function spawnPickup(variant, subtype, position, velocity, spawner, seed)
	local pickup =  game:Spawn(
		EntityType.ENTITY_PICKUP, variant,
		position, velocity or Vector.Zero,
		spawner, subtype, seed or randomSeed()
	):ToPickup() ---@cast pickup EntityPickup
	return pickup
end

---@type fun(variant: PickupVariant| 0, subtype: integer| 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Pickup(variant, subtype, position, velocity, spawner, seed)
	return spawnPickup(variant, subtype, position, velocity, spawner, seed)
end

---@type fun(subtype: HeartSubType| 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Heart(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_HEART, subtype,
						position, velocity, spawner, seed)
end

---@type fun(subtype: CoinSubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Coin(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_COIN, subtype,
						position, velocity, spawner, seed)
end

---@type fun(subtype: KeySubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Key(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_KEY, subtype,
						position, velocity, spawner, seed)
end

---@type fun(subtype: BombSubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Bomb(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_BOMB, subtype,
						position, velocity, spawner, seed)
end

---@type fun(chestVariant: PickupVariant, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Chest(chestVariant, position, velocity, spawner, seed)
	return spawnPickup(chestVariant, 0,
						position, velocity, spawner, seed)
end

---@type fun(subtype: SackSubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Sack(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_GRAB_BAG, subtype,
						position, velocity, spawner, seed)
end

---@type fun(subtype: PillColor | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Pill(pillColor, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_PILL, pillColor,
						position, velocity, spawner, seed)
end

---@type fun(pillColor: PillColor | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.HorsePill(pillColor, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_PILL, pillColor | PillColor.PILL_GIANT_FLAG,
						position, velocity, spawner, seed)
end

---@type fun(subtype: BatterySubType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Battery(subtype, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_LIL_BATTERY, subtype,
						position, velocity, spawner, seed)
end

---@type fun(itemId:CollectibleType | 0, position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Collectible(itemId, position, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_COLLECTIBLE, itemId,
						position, Vector.Zero, spawner, seed)
end

---@type fun(position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.ShopItem(position, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_SHOPITEM, 0,
						position, Vector.Zero, spawner, seed)
end

---@type fun(trinketType: TrinketType | 0, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityPickup
function Spawn.Trinket(trinketType, position, velocity, spawner, seed)
	return spawnPickup(PickupVariant.PICKUP_TRINKET, trinketType,
						position, velocity, spawner, seed)
end

--#endregion

---@type fun(variant: BombVariant, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityBomb
function Spawn.LitBomb(variant, position, velocity, spawner, seed)
	local bomb = game:Spawn(
		EntityType.ENTITY_BOMB, variant,
		position, velocity or Vector.Zero,
		spawner, 0, seed or randomSeed()
	):ToBomb() ---@cast bomb EntityBomb
	return bomb
end

---@type fun(tearVariant: TearVariant, position: Vector, velocity: VectorOrNil, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityTear
function Spawn.Tear(tearVariant, position, velocity, tearFlags, spawner, seed)
	local tear = game:Spawn(
		EntityType.ENTITY_TEAR, tearVariant,
		position, velocity or Vector.Zero,
		spawner, 0, seed or randomSeed()
	):ToTear() ---@cast tear EntityTear

	if tearFlags then
		tear:AddTearFlags(tearFlags)
	end

	return tear
end

---@type fun(slotVariant: integer, position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntitySlot
function Spawn.Slot(slotVariant, position, spawner, seed)
	local slot = game:Spawn(
		EntityType.ENTITY_SLOT, slotVariant,
		position, Vector.Zero,
		spawner, 0, seed or randomSeed()
	):ToSlot() ---@cast slot EntitySlot

	return slot
end

--#region Lasers

---@type fun(variant: LaserVariant, subtype: LaserSubType, position: Vector, velocity: VectorOrNil, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityLaser
local function spawnLaser(variant, subtype, position, velocity, tearFlags, spawner, seed)
	local laser = game:Spawn(
		EntityType.ENTITY_LASER, variant,
		position, velocity or Vector.Zero,
		spawner, subtype or 0, seed or randomSeed()
	):ToLaser() ---@cast laser EntityLaser

	if tearFlags then
		laser:AddTearFlags(tearFlags)
	end

	return laser
end

---@type fun(variant: LaserVariant, position: Vector, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityLaser
function Spawn.LinearLaser(variant, position, tearFlags, spawner, seed)
	return spawnLaser(variant, LaserSubType.LASER_SUBTYPE_LINEAR,
						position, Vector.Zero, tearFlags, spawner, seed)
end

---@type fun(variant: LaserVariant, position: Vector, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityLaser
function Spawn.LudoLaser(variant, position, tearFlags, spawner, seed)
	return spawnLaser(variant, LaserSubType.LASER_SUBTYPE_RING_LUDOVICO,
						position, Vector.Zero, tearFlags, spawner, seed)
end

---@type fun(variant: LaserVariant, position: Vector, tearFlags: TearFlagsOrNil, spawner: EntityOrNil, followParent: boolean, seed: IntOrNil): EntityLaser
function Spawn.RingLaser(variant, position, tearFlags, spawner, followParent, seed)
	local subtype = followParent and LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT
									or LaserSubType.LASER_SUBTYPE_RING_PROJECTILE
	return spawnLaser(variant, subtype,
						position, Vector.Zero, tearFlags, spawner, seed)
end

--#endregion

--#region Effects

---@type fun(variant: EffectVariant, subtype: integer, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
local function spawnEffect(variant, subtype, position, velocity, spawner, seed)
	local effect = game:Spawn(
		EntityType.ENTITY_EFFECT, variant,
		position, velocity or Vector.Zero,
		spawner, subtype, seed or randomSeed()
	):ToEffect() ---@cast effect EntityEffect

	return effect
end

---@type fun(variant: EffectVariant, subtype: integer, position: Vector, velocity: VectorOrNil, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.Effect(variant, subtype, position, velocity, spawner, seed)
	return spawnEffect(variant, subtype, position, velocity, spawner, seed)
end

---@type fun(subtype: integer, position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.Poof01(subtype, position, spawner, seed)
	return spawnEffect(EffectVariant.POOF01, subtype, position, Vector.Zero, spawner, seed)
end

---@type fun(subtype: integer, position: Vector, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.Poof02(subtype, position, spawner, seed)
	return spawnEffect(EffectVariant.POOF02, subtype, position, Vector.Zero, spawner, seed)
end

---@alias CrackTheSkySubtype
---|0  #Default Instant Crack the Sky. 17 frames of hitbox
---|1  #2 frames of hitbox before turning into SubType 10
---|2  #Delayed with a visual cue. 17 frames of hitbox
---|10 #Visual only, no hitbox

---@type fun(subtype: CrackTheSkySubtype, position: Vector, damage: number, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.CrackTheSky(subtype, position, damage, spawner, seed)
	local beam = spawnEffect(EffectVariant.CRACK_THE_SKY, subtype, position, Vector.Zero, spawner, seed)

	beam.Parent = spawner ---@diagnostic disable-line
	beam.CollisionDamage = damage
	beam:Update()

	return beam
end

---@type fun(target:Entity, spawner: EntityOrNil, seed: IntOrNil): EntityEffect
function Spawn.BigHornHand(target, spawner, seed)
	local hand = spawnEffect(EffectVariant.BIG_HORN_HAND, 0, target.Position, Vector.Zero, spawner, seed)
	hand.Target = target

	return hand
end

---@type fun(type: 0|1|2|3|4|5|6,
--- position: Vector,
--- colorize: { R: number, G: number, B: number, A: number } | nil,
--- persistent: boolean|nil): EntityEffect
function Spawn.BloodSplat(lvl, position, colorize, persistent)
	return Epiphany.BLOOD_SPLAT:SpawnBlood(lvl, position, colorize, persistent)
end

local rng = RNG()

---@param lower? integer
---@param upper? integer
local function randomNum(lower, upper)
	if upper then
		return rng:RandomInt((upper - lower) + 1) + lower
	elseif lower then
		return rng:RandomInt(lower) + 1
	else
		return rng:RandomFloat()
	end
end

---@param position Vector
---@param amount? integer
---@param velocity? Vector
---@param spawner? Entity
---@param seed? integer
function Spawn.DustClouds(position, amount, velocity, spawner, seed)
	local clouds = {}
	for _ = 1, amount or 5 do
		local cloud = spawnEffect(EffectVariant.DUST_CLOUD, 0, position, velocity or RandomVector():Resized(randomNum(0, 4) + randomNum()), spawner, seed)
		cloud:SetTimeout(randomNum(15, 25))
		cloud.Color.A = math.max(0.3, randomNum())
		clouds[#clouds + 1] = cloud
	end
	return clouds
end

--#endregion

return Spawn