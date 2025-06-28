local Mod = Furtherance

local CHARGED_BOMB = {}

Furtherance.Pickup.CHARGED_BOMB = CHARGED_BOMB

CHARGED_BOMB.ID = Isaac.GetEntitySubTypeByName("Charged Bomb")

CHARGED_BOMB.EXPLODE_CHANCE = 0.01

Mod:RegisterReplacement({
	OldType = Mod:Set({ EntityType.ENTITY_PICKUP }),
	OldVariant = Mod:Set({ PickupVariant.PICKUP_BOMB }),
	NewType = EntityType.ENTITY_PICKUP,
	NewVariant = PickupVariant.PICKUP_BOMB,
	NewSubtype = CHARGED_BOMB.ID,
	ReplacementChance = 0.02
})

---@param entType EntityType
---@param variant PickupVariant
---@param subtype integer
---@param spawner Entity
---@param seed integer
function CHARGED_BOMB:SpawnChargedBomb(entType, variant, subtype, _, _, spawner, seed)
	if entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_BOMB
		and subtype == BombSubType.BOMB_NORMAL
	then
		local rng = RNG(seed)
		if rng:RandomFloat() <= CHARGED_BOMB.REPLACE_CHANCE then
			return { entType, variant, CHARGED_BOMB.ID, seed }
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
		if rng:RandomFloat() <= CHARGED_BOMB.EXPLODE_CHANCE and Mod:GetEffectiveHitPoints(player) > 1 then
			Isaac.Explode(pickup.Position, pickup, 100)
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, CHARGED_BOMB.CollectChargedBomb, PickupVariant.PICKUP_BOMB)