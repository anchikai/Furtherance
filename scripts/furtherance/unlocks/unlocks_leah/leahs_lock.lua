local Mod = Furtherance

local LEAHS_LOCK = {}

Furtherance.Trinket.LEAHS_LOCK = LEAHS_LOCK

LEAHS_LOCK.ID = Isaac.GetTrinketIdByName("Leah's Lock")

LEAHS_LOCK.CHARM_COLOR = Color(1, 0, 1, 1, 0.196, 0, 0)
LEAHS_LOCK.FEAR_COLOR = Color(1, 1, 0.455, 1, 0.169, 0.145, 0)

LEAHS_LOCK.TEAR_MODIFIER = Mod.TearModifier.New({
	Name = "Leah's Lock",
	Trinkets = { LEAHS_LOCK.ID },
	MinChance = 0.25,
	MaxChance = 0.5,
})

local modifier = LEAHS_LOCK.TEAR_MODIFIER

function LEAHS_LOCK:ApplyFearOrCharm(object, player)
	local roll = modifier.LastRoll
	local totalChance = modifier:GetChance(player)
	local sprite = object:GetSprite()
	if roll < (totalChance / 2) then
		object:AddTearFlags(TearFlags.TEAR_CHARM)
		sprite.Color = LEAHS_LOCK.CHARM_COLOR
	else
		object:AddTearFlags(TearFlags.TEAR_FEAR)
		sprite.Color = LEAHS_LOCK.FEAR_COLOR
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

---@param ent EntityTear | EntityKnife | EntityLaser | EntityBomb
function LEAHS_LOCK:FireLLWeapon(ent)
	local player = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()
	if not player or not player:HasTrinket(LEAHS_LOCK.ID) then return end

	local rng = player:GetTrinketRNG(LEAHS_LOCK.ID)
	local chance = 0.25 + math.min(player.Luck * 0.025, 0.25)
	if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
		chance = 1 - (1 - chance) ^ 2
	end

	local choice = rng:RandomFloat()
	if choice < chance / 2 then
		ent:AddTearFlags(TearFlags.TEAR_CHARM)
		ent:SetColor(LEAHS_LOCK.CHARM_COLOR, -1, 1, false, true)
	elseif choice < chance then
		ent:AddTearFlags(TearFlags.TEAR_FEAR)
		ent:SetColor(LEAHS_LOCK.FEAR_COLOR, -1, 1, false, true)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, LEAHS_LOCK.FireLLWeapon)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, LEAHS_LOCK.FireLLWeapon)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL, LEAHS_LOCK.FireLLWeapon)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, LEAHS_LOCK.FireLLWeapon)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_KNIFE, LEAHS_LOCK.FireLLWeapon)