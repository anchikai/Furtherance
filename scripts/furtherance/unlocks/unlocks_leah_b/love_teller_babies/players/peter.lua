local Mod = Furtherance

---@param familiar EntityFamiliar
local function preEffectAdd(_, familiar)
	local validEnemies = {}

	Mod.Foreach.NPC(function(npc, index)
		if not npc:IsBoss() then
			Mod.Insert(validEnemies, npc)
		end
	end, nil, nil, nil, { UseEnemySearchParams = true })

	if #validEnemies == 0 then return end

	local rng = familiar.Player:GetCollectibleRNG(Mod.Item.KEYS_TO_THE_KINGDOM.ID)
	local enemy = validEnemies[rng:RandomInt(#validEnemies) + 1]
	Mod.Item.KEYS_TO_THE_KINGDOM:RaptureEnemy(enemy)
	Mod.Item.KEYS_TO_THE_KINGDOM:GrantRaptureStats(familiar.Player, rng, 1, true)

	return true
end

Mod:AddCallback(Mod.ModCallbacks.PRE_LOVE_TELLER_BABY_ADD_EFFECT, preEffectAdd, Mod.PlayerType.PETER)
