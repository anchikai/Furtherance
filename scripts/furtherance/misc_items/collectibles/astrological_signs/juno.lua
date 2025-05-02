local Mod = Furtherance

local JUNO = {}

Furtherance.Item.JUNO = JUNO

JUNO.ID = Isaac.GetItemIdByName("Juno?")

JUNO.ANIMA_SOLA_DURATION = 60

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
		Laser = 6
	}
})

---@param npc Entity
---@param duration integer
function JUNO:SummonAnimaSola(npc, duration)
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ANIMA_CHAIN, 0, npc.Position, Vector.Zero, nil)
	:ToEffect()
	---@cast effect EntityEffect
	effect.Target = npc
	effect.Timeout = duration
end

function JUNO.TEAR_MODIFIER:PostNpcHit(hitter, npc, isKnifeSwing, isSamsonPunch, isCainBag)
	JUNO:SummonAnimaSola(npc, JUNO.ANIMA_SOLA_DURATION)
end
