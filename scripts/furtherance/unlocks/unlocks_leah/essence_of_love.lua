local Mod = Furtherance

local ESSENCE_OF_LOVE = {}

Furtherance.Rune.ESSENCE_OF_LOVE = ESSENCE_OF_LOVE

ESSENCE_OF_LOVE.ID = Isaac.GetCardIdByName("Essence of Love")

function ESSENCE_OF_LOVE:UseEssenceOfLove(card, player, flag)
	Mod:ForEachEnemy(function(npc)
		if npc:IsActiveEnemy(false) and npc:IsVulnerableEnemy() and npc:IsBoss() == false then
			npc:AddCharmed(EntityRef(player), -1)
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_LOVE.UseEssenceOfLove, ESSENCE_OF_LOVE.ID)
