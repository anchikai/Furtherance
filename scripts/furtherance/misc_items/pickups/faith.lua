local Mod = Furtherance

function Mod:UseFaith(card, player, flag)
	local confess = Isaac.Spawn(EntityType.ENTITY_SLOT, 17, 0, Isaac.GetFreeNearPosition(player.Position, 40),
		Vector.Zero, player)
	local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 3, confess.Position, Vector.Zero, nil)
	:GetSprite()
	SFXManager():Stop(SoundEffect.SOUND_FART)
	SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, Mod.UseFaith, CARD_FAITH)
