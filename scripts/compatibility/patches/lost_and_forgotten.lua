local Mod = Furtherance
local loader = Mod.PatchesLoader

local function lostAndForgottenPatch()
	LNF:AddReanimatorBeggarEffect(Mod.Slot.ESCORT_BEGGAR.SLOT, 0, function()

	end)
	local ALTRUISM = Mod.Trinket.ALTRUISM

	-- Doing this as this runs on PRE_PLAYER_COLLISION which proceeds with payment before PRE_SLOT_COLLISION triggers
	---@param player EntityPlayer
	---@param collider Entity
	local function weirdBeggarOnTouch(_, player, collider)
		local sprite = collider:GetSprite()

		if not (
			--I don't :ToSlot() here (I cast out of habit even if its not needed) because it breaks LNF's code
			--Their :GetLNFData() is directly embedded into the class functions and :ToX() casts remove it for the remainer of the callback
			--Truly wacky
				collider.Type == EntityType.ENTITY_SLOT
				and collider.Variant == LNF.SlotVariant.SLOT_WEIRD_BEGGAR
				and player:HasTrinket(ALTRUISM.ID)
				and player:GetSoulHearts() > 0
				and sprite:IsPlaying("Idle")
			)
		then
			return
		end
		local rng = player:GetTrinketRNG(ALTRUISM.ID)
		local smallerMultiplier = (player:GetTrinketMultiplier(ALTRUISM.ID) - 1) * 0.5
		local trinketMult = ALTRUISM.BEGGAR_TRIGGER_ALTRUISM_CHANCE * smallerMultiplier

		if rng:RandomFloat() > ALTRUISM.BEGGAR_TRIGGER_ALTRUISM_CHANCE + trinketMult and not ALTRUISM.DEBUG_REFUND then
			Mod:DebugLog("Failed Altruism chance")
			return
		end

		if rng:RandomFloat() <= ALTRUISM.BEGGAR_HEAL_CHANCE and not ALTRUISM.DEBUG_REFUND then
			Mod:DebugLog("Altruism heal")
			Mod.Spawn.Notification(player.Position, 0, true)
			Mod.SFXMan:Play(SoundEffect.SOUND_VAMP_GULP)
			player:AddHearts(1)
		else
			local data = Mod:GetData(player)
			Mod:DebugLog("Altruism beggar refund")
			data.AltruismPreventWeirdBeggar = true
			Mod:DelayOneFrame(function()
				data.AltruismPreventWeirdBeggar = nil
			end)
			Mod.Trinket.ALTRUISM:SpawnRefundNotification(player.Position)
		end
	end

	Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, CallbackPriority.EARLY, weirdBeggarOnTouch)

	local function preventHealthLoss(_, player, amount, healthtype)
		if Mod:GetData(player).AltruismPreventWeirdBeggar then
			return 0
		end
	end

	Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, preventHealthLoss, AddHealthType.SOUL)
	Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, preventHealthLoss, AddHealthType.BLACK)
end

loader:RegisterPatch("LNF", lostAndForgottenPatch, "Lost and Forgotten")
