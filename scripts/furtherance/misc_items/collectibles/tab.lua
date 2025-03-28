local Mod = Furtherance
local game = Game()

function Mod:UseTab(_, _, player)
	local level = game:GetLevel()
	if not player:HasCollectible(CollectibleType.COLLECTIBLE_ALT_KEY) then
		level:ApplyCompassEffect(false)
		level:ApplyMapEffect()
		level:ApplyBlueMapEffect()
		player:UseCard(Card.CARD_REVERSE_MOON, 0)
		SFXManager():Stop(SoundEffect.SOUND_REVERSE_MOON)
	else
		game:Fadeout(100, 3)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseTab, CollectibleType.COLLECTIBLE_TAB_KEY)
