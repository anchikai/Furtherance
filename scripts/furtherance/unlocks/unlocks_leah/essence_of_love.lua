local Mod = Furtherance

local ESSENCE_OF_LOVE = {}

Furtherance.Rune.ESSENCE_OF_LOVE = ESSENCE_OF_LOVE

ESSENCE_OF_LOVE.ID = Isaac.GetCardIdByName("Essence of Love")

---@param player EntityPlayer
function ESSENCE_OF_LOVE:UseEssenceOfLove(_, player, _)
	Mod.Foreach.NPC(function (npc, index)
		if not npc:IsBoss() then
			npc:AddCharmed(EntityRef(player), -1)
		end
	end, nil, nil, nil, {UseEnemySearchParams = true})
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_LOVE.UseEssenceOfLove, ESSENCE_OF_LOVE.ID)
