local Mod = Furtherance

local IRON = {}

Furtherance.Item.IRON = IRON

IRON.ID = Isaac.GetItemIdByName("Iron")
IRON.FAMILIAR = Isaac.GetEntityVariantByName("Iron")

IRON.TEAR_COLOR = Color(1, 1, 1, 1, 0.3, 0, 0)
IRON.ORBIT_DISTANCE = Vector(128, 128)
IRON.ORBIT_SPEED = 0.01

---@param familiar EntityFamiliar
function IRON:IronInit(familiar)
	familiar:AddToOrbit(5)
	familiar.OrbitDistance = IRON.ORBIT_DISTANCE
	familiar.OrbitSpeed = IRON.ORBIT_SPEED
	familiar:RecalculateOrbitOffset(familiar.OrbitLayer, true)
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, IRON.IronInit, IRON.FAMILIAR)

---@param familiar EntityFamiliar
function IRON:IronUpdate(familiar)
	local player = familiar.Player
	local targetPosition = familiar:GetOrbitPosition(player.Position + player.Velocity)
	familiar.Velocity = targetPosition - familiar.Position

	for _, ent in ipairs(Isaac.FindInRadius(familiar.Position, familiar.Size, EntityPartition.TEAR)) do
		local tear = ent:ToTear()
		---@cast tear EntityTear
		local data = Mod:GetData(tear)
		if not data.WentThruIron then
			tear.CollisionDamage = tear.CollisionDamage * 2
			tear.Scale = tear.Scale * 2
			tear:AddTearFlags(TearFlags.TEAR_BURN)
			tear:SetColor(IRON.TEAR_COLOR, -1, 1, false, true)
			data.WentThruIron = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, IRON.IronUpdate, IRON.FAMILIAR)

---@param player EntityPlayer
function IRON:FamiliarCache(player)
	local effects = player:GetEffects()
	local numFamiliars = player:GetCollectibleNum(IRON.ID) + effects:GetCollectibleEffectNum(IRON.ID)
	local rng = player:GetCollectibleRNG(IRON.ID)
	rng:Next()
	player:CheckFamiliar(IRON.FAMILIAR, numFamiliars, rng, Mod.ItemConfig:GetCollectible(IRON.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, IRON.FamiliarCache, CacheFlag.CACHE_FAMILIARS)