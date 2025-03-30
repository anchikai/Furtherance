local Mod = Furtherance

local LEAKING_TANK = {}

Furtherance.Item.LEAKING_TANK = LEAKING_TANK

LEAKING_TANK.ID = Isaac.GetItemIdByName("Leaking Tank")

LEAKING_TANK.MAX_EMPTY_HEALTH_PROC = 12 --6 hearts, 2 units = 1 heart

---@param player EntityPlayer
function LEAKING_TANK:Leaking(player)
	if not player:HasCollectible(LEAKING_TANK.ID) then return end

	local rng = player:GetCollectibleRNG(LEAKING_TANK.ID)
	if rng:RandomFloat() <= (player:GetEffectiveMaxHearts() / LEAKING_TANK.MAX_EMPTY_HEALTH_PROC) then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero,
			player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LEAKING_TANK.Leaking)
