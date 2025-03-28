local Mod = Furtherance
local game = Game()

local Cyst = Isaac.GetEntityVariantByName("Blood Cyst")
local CystHitbox = Isaac.GetEntityVariantByName("Blood Cyst Hitbox")

function Mod:RespawnCyst()
	local room = game:GetRoom()

	-- the cyst hitbox gets automatically removed
	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == Cyst then
			entity:Remove()
		end
	end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if not room:IsClear() then
			for _ = 1, player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BLOOD_CYST) do
				local position = Isaac.GetFreeNearPosition(room:GetRandomPosition(0), 40)
				local bloodCyst = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, Cyst, 0, position, Vector.Zero, player)
				local data = Mod:GetData(bloodCyst)
				data.SavedPosition = position

				local hitbox = Isaac.Spawn(EntityType.ENTITY_BOIL, 0, 0, bloodCyst.Position, Vector.Zero, player):ToNPC()
				hitbox.HitPoints = 0
				hitbox.CanShutDoors = false
				hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
				hitbox:SetColor(Color(1, 1, 1, 0), 0, 1)

				local hitboxData = Mod:GetData(hitbox)
				hitboxData.IsBloodCystHitbox = true
				hitboxData.BloodCyst = bloodCyst
				hitboxData.SavedPosition = position
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.RespawnCyst)

function Mod:FreezePosition(bloodCyst)
	local data = Mod:GetData(bloodCyst)
	if data.SavedPosition == nil then return end

	bloodCyst.Position = data.SavedPosition
	bloodCyst.Velocity = Vector.Zero
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Mod.FreezePosition, Cyst)

function Mod:StopHitboxAI(boil)
	local data = Mod:GetData(boil)
	if not data.IsBloodCystHitbox then return false end

	if data.SavedPosition ~= nil then
		boil.Position = data.SavedPosition
	end
	boil.Velocity = Vector.Zero

	return true
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, Mod.StopHitboxAI, EntityType.ENTITY_BOIL)

function Mod:IgnorePlayerCollisions(boil, collider)
	local data = Mod:GetData(boil)
	if data.IsBloodCystHitbox and collider and collider:ToPlayer() then
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, Mod.IgnorePlayerCollisions, EntityType.ENTITY_BOIL)

function Mod:HitboxDied(boil)
	local data = Mod:GetData(boil)
	if not data.IsBloodCystHitbox then return end

	local bloodCyst = data.BloodCyst
	local player = bloodCyst.SpawnerEntity:ToPlayer()

	bloodCyst:Die()
	boil:Remove()

	local hasBFFs = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
	for i = 1, 8 do
		local CystTears = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, bloodCyst.Position,
			Vector(8, 0):Rotated(i * 45), bloodCyst):ToTear()
		if hasBFFs then
			CystTears.CollisionDamage = 7
			CystTears.Scale = 1.1
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Mod.HitboxDied, EntityType.ENTITY_BOIL)
