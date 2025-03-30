local Mod = Furtherance

local ESSENCE_OF_DEATH = {}

Furtherance.Rune.ESSENCE_OF_DEATH = ESSENCE_OF_DEATH

ESSENCE_OF_DEATH.ID = Isaac.GetCardIdByName("Essence of Death")

function ESSENCE_OF_DEATH:OnUse(card, player, flag)
	Mod:ForEachEnemy(function(npc)
		if not npc:IsBoss() then
			player:AddSwarmFlyOrbital(npc.Position)
			npc:Kill()
		end
	end, true)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_DEATH.OnUse, ESSENCE_OF_DEATH.ID)
