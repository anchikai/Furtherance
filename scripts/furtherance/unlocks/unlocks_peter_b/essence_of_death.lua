local Mod = Furtherance

local ESSENCE_OF_DEATH = {}

Furtherance.Rune.ESSENCE_OF_DEATH = ESSENCE_OF_DEATH

ESSENCE_OF_DEATH.ID = Isaac.GetCardIdByName("Essence of Death")

function ESSENCE_OF_DEATH:OnUse(card, player, flag)
	local flies = 0
	Mod:ForEachEnemy(function(npc)
		if Mod:IsValidEnemyTarget(npc) and not npc:IsBoss() then
			npc:Kill()
			flies = flies + 1
		end
	end)
	for i = 1, flies do
		player:AddSwarmFlyOrbital(player.Position)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_DEATH.OnUse, ESSENCE_OF_DEATH.ID)
