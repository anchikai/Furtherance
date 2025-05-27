local Mod = Furtherance

local JUNO = {}

Furtherance.Item.JUNO = JUNO

JUNO.ID = Isaac.GetItemIdByName("Juno?")

JUNO.ANIMA_SOLA_DURATION = 60
JUNO.ANIMA_SOLA_COOLDOWN = 120

JUNO.TEAR_MODIFIER = Mod.TearModifier.New({
	Name = "Juno",
	Items = { JUNO.ID },
	MinLuck = 0,
	MaxLuck = 11,
	MinChance = 0.03,
	MaxChance = 0.25,
	Color = Color(0.7, 0.3, 0, 1, 1, 0.5, 0.2),
	ShouldAffectBombs = true,
	Cooldown = {
		KnifeHit = JUNO.ANIMA_SOLA_COOLDOWN,
		KnifeSwing = JUNO.ANIMA_SOLA_COOLDOWN,
		Ludovico = JUNO.ANIMA_SOLA_COOLDOWN,
		Laser = JUNO.ANIMA_SOLA_COOLDOWN,
		CSection = JUNO.ANIMA_SOLA_COOLDOWN
	}
})

---@param npc Entity
---@param duration integer
function JUNO:SummonAnimaSola(npc, duration)
	local effect = Mod.Spawn.Effect(EffectVariant.ANIMA_CHAIN, 0, npc.Position)
	effect.Target = StatusEffectLibrary.Utils.GetLastParent(npc)
	effect.Timeout = duration
end

function JUNO.TEAR_MODIFIER:PostNpcHit(hitter, npc, isKnifeSwing, isSamsonPunch, isCainBag)
	local player = Mod:TryGetPlayer(hitter)
	if player then
		JUNO:SummonAnimaSola(npc, JUNO.ANIMA_SOLA_DURATION * player:GetCollectibleNum(JUNO.ID))
	end
end
