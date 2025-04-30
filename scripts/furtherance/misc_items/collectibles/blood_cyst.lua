local Mod = Furtherance

local BLOOD_CYST = {}

Furtherance.Item.BLOOD_CYST = BLOOD_CYST

BLOOD_CYST.ID = Isaac.GetItemIdByName("Blood Cyst")
BLOOD_CYST.FAMILIAR = Isaac.GetEntityVariantByName("Blood Cyst")

function BLOOD_CYST:RespawnCyst()
	local room = Mod.Room()
	Mod.Foreach.Familiar(function(familiar, index)
		familiar:Remove()
	end, BLOOD_CYST.FAMILIAR, -1, { Inverse = true })

	if room:IsClear() or not PlayerManager.AnyoneHasCollectible(BLOOD_CYST.ID) then return end

	Mod.Foreach.Player(function(player)
		for _ = 1, player:GetCollectibleNum(BLOOD_CYST.ID) do
			local position = Isaac.GetFreeNearPosition(room:GetRandomPosition(0), 40)
			Isaac.Spawn(EntityType.ENTITY_FAMILIAR, BLOOD_CYST.FAMILIAR, 0, position, Vector.Zero, player)
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BLOOD_CYST.RespawnCyst)

---@param familiar EntityFamiliar
function BLOOD_CYST:OnFamiliarInit(familiar)
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

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, BLOOD_CYST.OnFamiliarInit, BLOOD_CYST.FAMILIAR)

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
		if npc.SpawnerEntity
			and npc.SpawnerEntity:ToFamiliar()
			and npc.SpawnerVariant == BLOOD_CYST.FAMILIAR
		then
			npc:Remove()
			npc.SpawnerEntity:Kill()
		end
		return false
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_KILL, CallbackPriority.IMPORTANT, BLOOD_CYST.KillFamiliar, EntityType.ENTITY_BOIL)

---@param ent Entity
function BLOOD_CYST:OnDeath(ent)
	if ent.Variant ~= BLOOD_CYST.FAMILIAR then return end
	local familiar = ent:ToFamiliar()
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
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, BLOOD_CYST.OnDeath, EntityType.ENTITY_FAMILIAR)
