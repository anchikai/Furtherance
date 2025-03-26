local Mod = Furtherance

local MIRIAMS_WELL = {}

Furtherance.Item.MIRIAMS_WELL = MIRIAMS_WELL

MIRIAMS_WELL.ID = Isaac.GetItemIdByName("Miriam's Well")
MIRIAMS_WELL.FAMILIAR = Isaac.GetEntityVariantByName("Miriam's Well")

MIRIAMS_WELL.COOLDOWN = 240
MIRIAMS_WELL.DIST = Vector(40, 40)
MIRIAMS_WELL.SPEED = 0.03

---@param player EntityPlayer
function MIRIAMS_WELL:FamiliarCache(player)
	local effects = player:GetEffects()
	local numFamiliars = player:GetCollectibleNum(MIRIAMS_WELL.ID)
		+ effects:GetCollectibleEffectNum(MIRIAMS_WELL.ID)
	local rng = player:GetCollectibleRNG(MIRIAMS_WELL.ID)
	rng:Next()
	player:CheckFamiliar(MIRIAMS_WELL.FAMILIAR, numFamiliars, rng,
		Mod.ItemConfig:GetCollectible(MIRIAMS_WELL.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MIRIAMS_WELL.FamiliarCache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
function MIRIAMS_WELL:OnFamiliarInit(familiar)
	familiar.OrbitLayer = 1
	familiar.OrbitDistance = MIRIAMS_WELL.DIST
	familiar.OrbitSpeed = 0.03
	familiar:RecalculateOrbitOffset(familiar.OrbitLayer, true)
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, MIRIAMS_WELL.OnFamiliarInit, MIRIAMS_WELL.FAMILIAR)

---@param familiar EntityFamiliar
function MIRIAMS_WELL:WellUpdate(familiar)
	local player = familiar.Player
	local sprite = familiar:GetSprite()

	local targetPosition = familiar:GetOrbitPosition(player.Position + player.Velocity)
	familiar.Velocity = targetPosition - familiar.Position

	if familiar.FireCooldown > 0 and familiar.State == 1 then
		familiar.FireCooldown = familiar.FireCooldown - 1
	elseif not sprite:GetLayer(1):IsVisible() then
		sprite:Play("Idle", true)
		sprite:GetLayer(1):SetVisible(true)
		familiar:SetColor(Color(1, 1, 1, 1, 0, 0.2, 0.5), 15, 1, true, false)
		Mod.SFXMan:Play(SoundEffect.SOUND_WAR_LAVA_SPLASH, 0.8, 2, false, 1.2)
		familiar.State = 0
	end

	if sprite:IsPlaying("Break") and sprite:IsEventTriggered("SpawnPuddle") then
		local puddle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 1,
			familiar.Position, Vector.Zero, player):ToEffect()
		puddle.CollisionDamage = player.Damage / 2
		Mod.SFXMan:Play(SoundEffect.SOUND_GASCAN_POUR)
	end

	if sprite:IsFinished("Break") then
		sprite:GetLayer(1):SetVisible(false)
		sprite:Play("Idle")
	end
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, MIRIAMS_WELL.WellUpdate, MIRIAMS_WELL.FAMILIAR)

---@param familiar EntityFamiliar
---@param collider Entity
function MIRIAMS_WELL:WellCollide(familiar, collider)
	if collider:IsActiveEnemy(false) or collider:ToProjectile() and familiar.State == 0 then
		local sprite = familiar:GetSprite()
		familiar.State = 1
		sprite:Play("Break", true)
		familiar.FireCooldown = MIRIAMS_WELL.COOLDOWN
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, MIRIAMS_WELL.WellCollide, MIRIAMS_WELL.FAMILIAR)
