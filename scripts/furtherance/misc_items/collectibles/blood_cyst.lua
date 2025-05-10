local Mod = Furtherance

local BLOOD_CYST = {}

Furtherance.Item.BLOOD_CYST = BLOOD_CYST

BLOOD_CYST.ID = Isaac.GetItemIdByName("Blood Cyst")
BLOOD_CYST.FAMILIAR = Isaac.GetEntityVariantByName("Blood Cyst")

---@param familiar EntityFamiliar
function BLOOD_CYST:GrantHitsphere(familiar)
	local hitbox = Isaac.Spawn(EntityType.ENTITY_BOIL, BLOOD_CYST.FAMILIAR, 0, familiar.Position, Vector.Zero, familiar):ToNPC()
	---@cast hitbox EntityNPC
	hitbox.HitPoints = 0
	hitbox.CanShutDoors = false
	hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	hitbox.Visible = false
	hitbox.Mass = 9999
	hitbox.CollisionDamage = 0
	hitbox.Parent = familiar
	hitbox:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end

---@param familiar EntityFamiliar
function BLOOD_CYST:UpdateCystState(familiar)
	local room = Mod.Room()
	if room:IsClear() then
		familiar.State = 1
		familiar.Visible = false
	else
		familiar.State = 0
		familiar.Visible = true
		local position = Isaac.GetFreeNearPosition(room:GetRandomPosition(0), 40)
		familiar.Position = position
		BLOOD_CYST:GrantHitsphere(familiar)
	end
end

function BLOOD_CYST:RespawnCyst()
	Mod.Foreach.Familiar(function(familiar, index)
		BLOOD_CYST:UpdateCystState(familiar)
	end, BLOOD_CYST.FAMILIAR)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BLOOD_CYST.RespawnCyst)

---@param npc EntityNPC
function BLOOD_CYST:StopBoilUpdate(npc)
	if npc.Variant == BLOOD_CYST.FAMILIAR then
		npc.Velocity = Vector.Zero
		npc.HitPoints = 0
		npc.Visible = false
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.IMPORTANT, BLOOD_CYST.StopBoilUpdate, EntityType.ENTITY_BOIL)

---@param npc EntityNPC
function BLOOD_CYST:KillFamiliar(npc)
	if npc.Variant == BLOOD_CYST.FAMILIAR then
		local familiar = npc.SpawnerEntity and npc.SpawnerEntity:ToFamiliar()
		if familiar and familiar == BLOOD_CYST.FAMILIAR then
			npc:Remove()
			BLOOD_CYST:OnDeath(familiar)
		end
		return false
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_KILL, CallbackPriority.IMPORTANT, BLOOD_CYST.KillFamiliar, EntityType.ENTITY_BOIL)

---@param familiar EntityFamiliar
function BLOOD_CYST:OnDeath(familiar)
	---@cast familiar EntityFamiliar
	for _ = 1, 20 do
		local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, familiar.Position,
			RandomVector():Resized(Mod:RandomNum(4, 8)), familiar):ToTear()
		---@cast tear EntityTear
		tear.FallingSpeed = Mod:RandomNum(-18, -13) - Mod:RandomNum()
		tear.FallingAcceleration = 1 + Mod:RandomNum()
		tear.CollisionDamage = tear.CollisionDamage * familiar:GetMultiplier()
		tear:ResetSpriteScale(true)
	end
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, familiar.Position, Vector.Zero, familiar)
	familiar.State = 1
	familiar.Visible = false
end

function BLOOD_CYST:FamiliarCache(player)
	local effects = player:GetEffects()
	local numFamiliars = player:GetCollectibleNum(BLOOD_CYST.ID) + effects:GetCollectibleEffectNum(BLOOD_CYST.ID)
	local rng = player:GetCollectibleRNG(BLOOD_CYST.ID)
	rng:Next()
	local familiars = player:CheckFamiliarEx(BLOOD_CYST.FAMILIAR, numFamiliars, rng, Mod.ItemConfig:GetCollectible(BLOOD_CYST.ID))
	for _, familiar in ipairs(familiars) do
		BLOOD_CYST:UpdateCystState(familiar)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BLOOD_CYST.FamiliarCache, CacheFlag.CACHE_FAMILIARS)