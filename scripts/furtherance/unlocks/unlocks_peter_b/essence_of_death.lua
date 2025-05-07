local Mod = Furtherance

local ESSENCE_OF_DEATH = {}

Furtherance.Rune.ESSENCE_OF_DEATH = ESSENCE_OF_DEATH

ESSENCE_OF_DEATH.ID = Isaac.GetCardIdByName("Essence of Death")

---@param player EntityPlayer
function ESSENCE_OF_DEATH:OnUse(_, player, _)
	Mod.Foreach.NPC(function (npc, index)
		if not npc:IsBoss() then
			player:AddSwarmFlyOrbital(npc.Position)
			npc:Kill()
		end
	end, nil, nil, nil, {UseEnemySearchParams = true})
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_DEATH.OnUse, ESSENCE_OF_DEATH.ID)
