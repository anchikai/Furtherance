local Mod = Furtherance
local game = Game()

function Mod:UseAceOfShields(card, player, flag)
	if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) > 0 then
		if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) == 0 then
			player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + 2, ActiveSlot.SLOT_PRIMARY)
		else
			player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) * 2, ActiveSlot.SLOT_PRIMARY)
		end
		game:GetHUD():FlashChargeBar(player, ActiveSlot.SLOT_PRIMARY)
		if player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < 6 then
			SFXManager():Play(SoundEffect.SOUND_BEEP)
		else
			SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
			SFXManager():Play(SoundEffect.SOUND_ITEMRECHARGE)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, Mod.UseAceOfShields, CARD_TWO_OF_SHIELDS)
