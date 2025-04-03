local Mod = Furtherance

local SALINE_SPRAY = {}

Furtherance.Trinket.SALINE_SPRAY = SALINE_SPRAY

SALINE_SPRAY.ID = Isaac.GetTrinketIdByName("Saline Spray")

SALINE_SPRAY.TEAR_MODIFIER = Mod.TearModifier.New({
	Name = "Saline Spray",
	Trinkets = { SALINE_SPRAY.ID },
	MinChance = 0.05,
	MaxChance = 1,
	LaserColor = Color(1, 1, 1, 1, 0.1, 0.1, 0.1, 4, 4.4, 6, 1),
	ShouldAffectBombs = true
})

local modifier = SALINE_SPRAY.TEAR_MODIFIER

function modifier:PostFire(object)
	if object:ToTear() or object:ToBomb() then
		local player = Mod:TryGetPlayer(object)
		if not player then return end
		object:AddTearFlags(TearFlags.TEAR_ICE)
		if object:ToTear() then
			object:ChangeVariant(TearVariant.ICE)
		end
	end
end

function modifier:PostUpdate(object)
	if object:ToLaser() or object:ToKnife() then
		local player = Mod:TryGetPlayer(object)
		if not player then return end
	end
end

function modifier:PostNpcHit(hitter, npc)
	if not hitter:ToTear() and not hitter:ToBomb() then
		if hitter:HasTearFlags(TearFlags.TEAR_ICE) then
			npc:AddEntityFlags(EntityFlag.FLAG_ICE)
		end
	end
end