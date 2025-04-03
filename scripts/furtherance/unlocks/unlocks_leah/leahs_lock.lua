local Mod = Furtherance

local LEAHS_LOCK = {}

Furtherance.Trinket.LEAHS_LOCK = LEAHS_LOCK

LEAHS_LOCK.ID = Isaac.GetTrinketIdByName("Leah's Lock")

LEAHS_LOCK.CHARM_COLOR = Color(1, 0, 1, 1, 0.196, 0, 0)
LEAHS_LOCK.FEAR_COLOR = Color(1, 1, 0.455, 1, 0.169, 0.145, 0)
LEAHS_LOCK.CHARM_LASER_COLOR = Color(1,1,1,1,0,0,0,4,1,3.5,1)
LEAHS_LOCK.FEAR_LASER_COLOR = Color.Default

LEAHS_LOCK.TEAR_MODIFIER = Mod.TearModifier.New({
	Name = "Leah's Lock",
	Trinkets = { LEAHS_LOCK.ID },
	MinChance = 0.25,
	MaxChance = 0.5,
	Color = LEAHS_LOCK.CHARM_COLOR,
	LaserColor = LEAHS_LOCK.CHARM_LASER_COLOR,
	ShouldAffectBombs = true
})

local modifier = LEAHS_LOCK.TEAR_MODIFIER

function LEAHS_LOCK:ApplyFearOrCharm(object, player)
	local totalChance = modifier:GetChance(player)
	local roll = modifier.LastRoll

	if roll < (totalChance / 2) then
		object:AddTearFlags(TearFlags.TEAR_CHARM)
		modifier.Color = LEAHS_LOCK.CHARM_COLOR
		modifier.LaserColor = LEAHS_LOCK.CHARM_LASER_COLOR
	else
		object:AddTearFlags(TearFlags.TEAR_FEAR)
		modifier.Color = LEAHS_LOCK.FEAR_COLOR
		modifier.LaserColor = LEAHS_LOCK.FEAR_LASER_COLOR
	end
end

function modifier:PostFire(object)
	if object:ToTear() or object:ToBomb() then
		local player = Mod:TryGetPlayer(object)
		if not player then return end
		LEAHS_LOCK:ApplyFearOrCharm(object, player)
	end
end

function modifier:PostUpdate(object)
	if object:ToLaser() or object:ToKnife() then
		local player = Mod:TryGetPlayer(object)
		if not player then return end
		LEAHS_LOCK:ApplyFearOrCharm(object, player)
	end
end

function modifier:PostNpcHit(hitter, npc)
	if not hitter:ToTear() and not hitter:ToBomb() then
		if hitter:HasTearFlags(TearFlags.TEAR_CHARM) then
			npc:AddCharmed(EntityRef(hitter), 150)
		elseif hitter:HasTearFlags(TearFlags.TEAR_FEAR) then
			npc:AddFear(EntityRef(hitter), 150)
		end
	end
end
