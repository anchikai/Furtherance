local Mod = Furtherance

local OWLS_EYE = {}

Furtherance.Item.OWLS_EYE = OWLS_EYE

OWLS_EYE.ID = Isaac.GetItemIdByName("Owl's Eye")

OWLS_EYE.COLOR = Color(1, 1, 1, 1, 0, 0, 0, 3, 1, 0, 1)

OWLS_EYE.TEAR_MODIFIER = Mod.TearModifier.New({
	Name = "Owl's Eye",
	Items = {OWLS_EYE.ID},
	MinChance = 0.08,
	MaxChance = 0.5,
	MinLuck = 0,
	MaxLuck = 15,
	ShouldAffectBombs = true,
	Color = OWLS_EYE.COLOR
})

local modifier = OWLS_EYE.TEAR_MODIFIER

function modifier:PostFire(object)
	if object:ToTear() or object:ToBomb() then
		local player = Mod:TryGetPlayer(object)
		if not player then return end
		object:AddTearFlags(TearFlags.TEAR_HOMING | TearFlags.TEAR_PIERCING)
		if object:ToTear() then
			object.CollisionDamage = object.CollisionDamage * 2
			---@cast object EntityTear
			local isBlood = Mod:TryChangeTearToBloodVariant(object)
			if isBlood then
				object:ChangeVariant(TearVariant.CUPID_BLOOD)
			else
				object:ChangeVariant(TearVariant.CUPID_BLUE)
			end
			object:ResetSpriteScale(true)
		else
			---@cast object EntityBomb
			object.ExplosionDamage = object.ExplosionDamage * 2
			object:SetScale(object.ExplosionDamage / 35)
			object:SetLoadCostumes(true)
		end
	end
end
