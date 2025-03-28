local Mod = Furtherance
local rng = RNG()

local HopeActive = false
function Mod:UseHope(card, player, flag)
	HopeActive = true
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, Mod.UseHope, CARD_HOPE)

function Mod:NewRoom()
	HopeActive = false
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.NewRoom)

function Mod:HopeKills(entity)
	if HopeActive then
		if rng:RandomFloat() <= 0.2 then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, entity.Position, Vector.Zero, player)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, Mod.HopeKills)
