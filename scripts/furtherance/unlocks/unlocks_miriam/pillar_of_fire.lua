local Mod = Furtherance

local PILLAR_OF_FIRE = {}

Furtherance.Item.PILLAR_OF_FIRE = PILLAR_OF_FIRE

PILLAR_OF_FIRE.ID = Isaac.GetItemIdByName("Pillar of Fire")

PILLAR_OF_FIRE.PROJ_SPEED = 10
PILLAR_OF_FIRE.INIT_SPEED = 6.5
PILLAR_OF_FIRE.RADIUS = 500
PILLAR_OF_FIRE.FIRE_FIRE_RATE_DEVIANCE = 5
PILLAR_OF_FIRE.FIRE_FIRE_RATE = 60
PILLAR_OF_FIRE.BASE_CHANCE = 0.05
PILLAR_OF_FIRE.MAX_CHANCE = 0.5
PILLAR_OF_FIRE.LUCK_VALUE = 0.05
PILLAR_OF_FIRE.FIRE_SCALE = 0.75

function PILLAR_OF_FIRE:TrySpawnFlamesOnDamage(ent)
	local player = ent:ToPlayer()
	if player and player:HasCollectible(PILLAR_OF_FIRE.ID) then
		local rng = player:GetCollectibleRNG(PILLAR_OF_FIRE.ID)
		if Mod:DoesLuckChanceTrigger(PILLAR_OF_FIRE.BASE_CHANCE, PILLAR_OF_FIRE.MAX_CHANCE, PILLAR_OF_FIRE.LUCK_VALUE, player.Luck, rng) then
			for _ = 1, 5 do
				local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HOT_BOMB_FIRE, 0,
					player.Position, RandomVector():Resized(PILLAR_OF_FIRE.INIT_SPEED), player)
				fire:ToEffect().Scale = fire:ToEffect().Scale * PILLAR_OF_FIRE.FIRE_SCALE
				Mod:GetData(fire).PillarOfFireFlame = true
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PILLAR_OF_FIRE.TrySpawnFlamesOnDamage, EntityType.ENTITY_PLAYER)

---@param effect EntityEffect
function PILLAR_OF_FIRE:FireTears(effect)
	local data = Mod:TryGetData(effect)
	if not data or not data.PillarOfFireFlame or effect:GetSprite():IsPlaying("Disappear") then return end
	local FIRE_RATE = PILLAR_OF_FIRE.FIRE_FIRE_RATE
	if not data.PillarOfFireShootCooldown then
		data.PillarOfFireShootCooldown = FIRE_RATE
	end
	if data.PillarOfFireShootCooldown > 0 then
		data.PillarOfFireShootCooldown = data.PillarOfFireShootCooldown - 1
	else
		local target = Mod:GetClosestEnemy(effect.Position, PILLAR_OF_FIRE.RADIUS, true, false)
		if not target then return end
		local velocity = (target.Position - effect.Position):Resized(PILLAR_OF_FIRE.PROJ_SPEED)
		local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.FIRE_MIND, 0, effect.Position, velocity, effect):ToTear()
		---@cast tear EntityTear
		tear:ResetSpriteScale(true)
		Mod:GetData(tear).PillarOfFlameTear = true
		local DEVIANCE = PILLAR_OF_FIRE.FIRE_FIRE_RATE_DEVIANCE
		data.PillarOfFireShootCooldown = FIRE_RATE + Mod:RandomNum(-DEVIANCE, DEVIANCE)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PILLAR_OF_FIRE.FireTears, EffectVariant.HOT_BOMB_FIRE)

---@param tear EntityTear
---@param collider Entity
function PILLAR_OF_FIRE:OnFireTearCollision(tear, collider)
	local data = Mod:TryGetData(tear)
	if data
		and data.PillarOfFlameTear
		and collider:IsActiveEnemy(false)
		and collider:IsVulnerableEnemy()
	then
		collider:AddBurn(EntityRef(tear), 150, tear.CollisionDamage)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, PILLAR_OF_FIRE.OnFireTearCollision)