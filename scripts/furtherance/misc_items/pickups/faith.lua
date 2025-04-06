local Mod = Furtherance

local FAITH = {}

Furtherance.Card.FAITH = FAITH

FAITH.ID = Isaac.GetCardIdByName("Faith")

function FAITH:OnUse(card, player, flag)
	local confess = Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.CONFESSIONAL, 0, Isaac.GetFreeNearPosition(player.Position, 40),
		Vector.Zero, player)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 3, confess.Position, Vector.Zero, nil)
	Mod.SFXMan:Play(SoundEffect.SOUND_SUMMONSOUND)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, FAITH.OnUse, FAITH.ID)
