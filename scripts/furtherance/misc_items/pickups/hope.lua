local Mod = Furtherance

local HOPE = {}

Furtherance.Card.HOPE = HOPE

HOPE.ID = Isaac.GetCardIdByName("Hope")
HOPE.NULL_ID = Isaac.GetNullItemIdByName("hope")

HOPE.PICKUP_DROP_CHANCE = 0.2

function HOPE:UseHope()
	Mod.Room():GetEffects():AddNullEffect(HOPE.NULL_ID, false, 1)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, HOPE.UseHope, HOPE.ID)

---@param ent Entity
function HOPE:HopeKills(ent)
	if Mod:IsDeadEnemy(ent) and Mod.Room():GetEffects():HasNullEffect(HOPE.NULL_ID) then
		local chance = HOPE.PICKUP_DROP_CHANCE * Mod.Room():GetEffects():GetNullEffectNum(HOPE.NULL_ID)
		local rng = ent:GetDropRNG()

		if rng:RandomFloat() <= chance then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_NULL, NullPickupSubType.NO_COLLECTIBLE_TRINKET_CHEST, ent.Position, Vector.Zero, nil)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, HOPE.HopeKills)
