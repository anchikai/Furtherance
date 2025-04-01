local Mod = Furtherance

local ESSENCE_OF_LIFE = {}

Furtherance.Rune.ESSENCE_OF_LIFE = ESSENCE_OF_LIFE

ESSENCE_OF_LIFE.ID = Isaac.GetCardIdByName("Essence of Life")

function ESSENCE_OF_LIFE:UseEssenceOfLife(card, player, flag)
	Mod:ForEachEnemy(function(npc)
		player:AddMinisaac(npc.Position, true)
	end, false)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_LIFE.UseEssenceOfLife, ESSENCE_OF_LIFE.ID)
