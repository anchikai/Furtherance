local Mod = Furtherance

local CHARGED_BOMB = {}

Furtherance.Pickup.CHARGED_BOMB = CHARGED_BOMB

CHARGED_BOMB.ID = Isaac.GetEntitySubTypeByName("Charged Bomb")

CHARGED_BOMB.REPLACE_CHANCE = 0.02
CHARGED_BOMB.EXPLODE_CHANCE = 0.01

---@param entType EntityType
---@param variant PickupVariant
---@param subtype integer
---@param position Vector
---@param spawner Entity
---@param seed integer
function CHARGED_BOMB:SpawnChargedBomb(entType, variant, subtype, position, _, spawner, seed)
	if entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_BOMB
		and subtype == BombSubType.BOMB_NORMAL
	then
		local floor_save = Mod:FloorSave()
		floor_save.CheckedChargedBomb = floor_save.CheckedChargedBomb or {}
		local key = tostring(seed)
		if floor_save.CheckedChargedBomb[key] then
			return
		end
		if (spawner and spawner:ToPlayer()) then
			floor_save.CheckedChargedBomb[key] = true
			return
		end
		local rng = RNG(seed)
		if rng:RandomFloat() <= CHARGED_BOMB.REPLACE_CHANCE then
			return { entType, variant, CHARGED_BOMB.ID, seed }
		else
			floor_save.CheckedChargedBomb[key] = true
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, CHARGED_BOMB.SpawnChargedBomb)

---@param pickup EntityPickup
---@param collider Entity
function CHARGED_BOMB:CollectChargedBomb(pickup, collider)
	if pickup.SubType ~= CHARGED_BOMB.ID then return end
	local player = collider:ToPlayer()
	if player then
		local rng = RNG(pickup.InitSeed)
		pickup:GetSprite():Play("Collect", true)
		pickup:PlayPickupSound()
		pickup:Die()
		player:AddBombs(1)
		player:FullCharge(ActiveSlot.SLOT_PRIMARY, false)
		pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		pickup.Friction = 0
		if pickup.OptionsPickupIndex > 0 then
			Mod:KillChoice(pickup)
		end
		if rng:RandomFloat() <= CHARGED_BOMB.EXPLODE_CHANCE then
			Isaac.Explode(pickup.Position, pickup, 100)
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, CHARGED_BOMB.CollectChargedBomb, PickupVariant.PICKUP_BOMB)
--[[
function CHARGED_BOMB:PostPickupRender(pickup)
	--if pickup.SubType ~= CHARGED_BOMB.ID then return end
	local pos = Isaac.WorldToScreen(pickup.Position)
	Isaac.RenderText(pickup.Velocity:Length(), pos.X, pos.Y, 1, 1, 1, 1)
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, CHARGED_BOMB.PostPickupRender, PickupVariant.PICKUP_BOMB) ]]