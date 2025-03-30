local Mod = Furtherance

local PARASITIC_POOFER = {}

Furtherance.Item.PARASITIC_POOFER = PARASITIC_POOFER

PARASITIC_POOFER.ID = Isaac.GetItemIdByName("Parasitic Poofer")

PARASITIC_POOFER.PROC_CHANCE = 0.2

--TODO: Seems....eehhhh? I dunno. Is useless and, in fact, punishes you, if you don't have red health

function PARASITIC_POOFER:Parasite(entity)
	local player = entity:ToPlayer()
	local poofRNG = player:GetCollectibleRNG(PARASITIC_POOFER.ID)
	if player:HasCollectible(PARASITIC_POOFER.ID) then
		if poofRNG:RandomFloat() <= PARASITIC_POOFER.PROC_CHANCE then
			player:UseCard(Card.CARD_HEARTS_2, 257)
			player:AddBrokenHearts(1)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, player.Position, Vector.Zero, player)
			SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, PARASITIC_POOFER.Parasite, EntityType.ENTITY_PLAYER)
