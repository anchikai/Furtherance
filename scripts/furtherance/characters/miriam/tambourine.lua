local Mod = Furtherance

local TambourineMedium = Isaac.GetSoundIdByName("TambourineMedium")
local WhirlpoolVariant = Isaac.GetEntityVariantByName("Miriam Whirlpool")

function Mod:UseTambourine(_, _, player, flags)
	-- create a whirlpool at the player's feet
	local whirlpool = Isaac.Spawn(EntityType.ENTITY_EFFECT, WhirlpoolVariant, 1, player.Position, Vector.Zero, player)
	:ToEffect()
	whirlpool.LifeSpan = 60
	whirlpool.CollisionDamage = player.Damage * 0.33

	-- create a pull effect
	local rift = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0, player.Position, Vector(0, 0), player)
	:ToEffect()
	rift.SpriteScale = Vector.Zero
	Mod:DelayFunction(rift.Die, 60, { rift }, true)

	SFXManager():Play(TambourineMedium)
	return not Mod:HasBitFlags(flags, UseFlag.USE_NOANIM)
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseTambourine, CollectibleType.COLLECTIBLE_TAMBOURINE)
