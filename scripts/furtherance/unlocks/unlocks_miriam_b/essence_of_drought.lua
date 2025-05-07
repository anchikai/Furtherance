local Mod = Furtherance

local ESSENCE_OF_DROUGHT = {}

Furtherance.Rune.ESSENCE_OF_DROUGHT = ESSENCE_OF_DROUGHT

ESSENCE_OF_DROUGHT.ID = Isaac.GetCardIdByName("Essence of Drought")

function ESSENCE_OF_DROUGHT:OnUse(_, player)
	local room = Mod.Game:GetRoom()
	room:StopRain()
	local source = EntityRef(player)
	Mod.Foreach.NPC(function (npc, index)
		if not npc:IsBoss() then
			npc:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT | EntityFlag.FLAG_ICE)
		else
			npc:AddBleeding(source, 150)
		end
	end, nil, nil, nil, {UseEnemySearchParams = true})
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, ESSENCE_OF_DROUGHT.OnUse, ESSENCE_OF_DROUGHT.ID)
