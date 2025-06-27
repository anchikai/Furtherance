local Mod = Furtherance
local Item = Mod.Item
local loader = Mod.PatchesLoader

local function fiendFolioPatch()
	local ff = FiendFolio

	--#region Hearts

	Mod.HeartGroups.Black[ff.PICKUP.VARIANT.HALF_BLACK_HEART] = true
	Mod.HeartGroups.Red[ff.PICKUP.VARIANT.BLENDED_BLACK_HEART] = true
	Mod.HeartGroups.Black[ff.PICKUP.VARIANT.BLENDED_BLACK_HEART] = true
	Mod.HeartGroups.Blended[ff.PICKUP.VARIANT.BLENDED_BLACK_HEART] = true
	Mod.HeartAmount[ff.PICKUP.VARIANT.HALF_BLACK_HEART] = 1
	Mod.HeartAmount[ff.PICKUP.VARIANT.BLENDED_BLACK_HEART] = 2

	--#endregion

	--#region Adding stuff to lists

	ff.AddItemsToPennyTrinketPool({
		Mod.Trinket.ABYSSAL_PENNY.ID,
		Mod.Trinket.GLITCHED_PENNY.ID
	})

	Mod:AppendTable(FiendFolio.ReferenceItems.Passives, {
		{ ID = Mod.Item.LITTLE_RAINCOAT.ID, Reference = "Little Nightmares" }
	})

	Mod:AddToDictionary(ff.DadsBattery.BLACKLIST, Mod:Set({
		Mod.Item.SERVITUDE.ID
	}))

	Mod.API:AddRottenAppleWormTrinket(ff.ITEM.TRINKET.FORTUNE_WORM)
	Mod.API:AddRottenAppleWormTrinket(ff.ITEM.TRINKET.TRINITY_WORM)

	ff:AddStackableItems({
		Item.BINDS_OF_DEVOTION.ID,
		Item.RUE.ID,
		Item.HEART_EMBEDDED_COIN.ID,
		Item.OWLS_EYE.ID,
		Item.EXSANGUINATION.ID,
		Item.PALLIUM.ID,
		Item.SEVERED_EAR.ID,
		Item.CHI_RHO.ID,
		Item.LIBERATION.ID,
		Item.MOLTEN_GOLD.ID,
		Item.ITCHING_POWDER.ID,
		Item.POLYDIPSIA.ID,
		Item.CADUCEUS_STAFF.ID,
		Item.MIRIAMS_WELL.ID,
		Item.FIRSTBORN_SON.ID,
		Item.IRON.ID,
		Item.LIL_POOFER.ID,
		Item.OPHIUCHUS.ID,
		Item.CHIRON.ID,
		Item.JUNO.ID,
		Item.TECH_IX.ID,
		Item.UNSTABLE_CORE.ID,
		Item.TECHNOLOGY_MINUS_1.ID,
		Item.BRUNCH.ID,
		Item.CRAB_LEGS.ID,
		Item.LIL_POOFER.ID,
		Item.QUARANTINE.ID,
		Item.BUTTERFLY.ID,
		Item.ROTTEN_APPLE.ID,
		Item.BEGINNERS_LUCK.ID,
		Item.COFFEE_BREAK.ID
	})

	Mod:AddToDictionary(ff.PocketObjectMimicCharges, {
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]] = 4,
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[2]] = 8,
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[3]] = 12,
	})

	--#endregion

	-- Keys to the Kingdom

	Mod:AddToDictionary(Mod.Item.KEYS_TO_THE_KINGDOM.ENTITY_BLACKLIST, Mod:Set({
		Mod:GetTypeVarSubFromName("Whispers Controller", true)
	}))

	Mod:AppendTable(Mod.Item.KEYS_TO_THE_KINGDOM.ENEMY_DEATH_SOUNDS, {
		ff.Sounds.CacaDeath,
		ff.Sounds.WarpZoneHurt,
		ff.Sounds.WarpZoneDeath,
		ff.Sounds.GriddleDeath,
		ff.Sounds.BuckDeath1,
		ff.Sounds.BuckDeath2,
		ff.Sounds.BuckDeath3,
		ff.Sounds.DuskDeath,
		ff.Sounds.BusterGhostDeath,
		ff.Sounds.MadommeDeath
	})

	Mod.API:RegisterKTTKMiniboss(ff.FF.Gravedigger.ID, ff.FF.Gravedigger.Var, Isaac.GetEntitySubTypeByName("Gravedigger"))
	Mod.API:RegisterKTTKMiniboss(ff.FF.Psion.ID, ff.FF.Psion.Var, Isaac.GetEntitySubTypeByName("Psion"))
	Mod.API:RegisterKTTKMiniboss(ff.FF.Hermit.ID, ff.FF.Hermit.Var, Isaac.GetEntitySubTypeByName("Hermit"))

	local function killWhisperController(_, npc)
		if npc.Variant == ff.FF.Whispers.Var and npc.SpawnerEntity and not npc.SpawnerEntity:IsDead() then
			Mod.Item.KEYS_TO_THE_KINGDOM:RemoveBoss(npc.SpawnerEntity)
		end
	end

	Mod:AddCallback(Mod.ModCallbacks.POST_RAPTURE_BOSS_DEATH, killWhisperController, ff.FF.Whispers.ID)

	--#endregion

	--#region Astragali

	local DIRE_CHEST = ff.PICKUP.VARIANT.DIRE_CHEST
	local GLASS_CHEST = ff.PICKUP.VARIANT.GLASS_CHEST

	Mod.API:RegisterAstragaliChest(DIRE_CHEST, function ()
		return ff.ACHIEVEMENT.DIRE_CHEST:IsUnlocked()
	end)

	Mod.API:RegisterAstragaliChest(GLASS_CHEST, function ()
		return ff.ACHIEVEMENT.GLASS_CHEST:IsUnlocked()
	end)

	local function correctChestSelection(_, pickup)
		return pickup.SubType == 0 --For Rotten Chest, 1 is open, 0 is closed
	end

	Mod:AddCallback(Mod.ModCallbacks.ASTRAGALI_PRE_SELECT_CHEST, correctChestSelection, DIRE_CHEST)
	Mod:AddCallback(Mod.ModCallbacks.ASTRAGALI_PRE_SELECT_CHEST, correctChestSelection, GLASS_CHEST)

	local function correctChestReroll(_, pickup, selectedVariant)
		return {EntityType.ENTITY_PICKUP, selectedVariant, 0}
	end

	Mod:AddCallback(Mod.ModCallbacks.ASTRAGALI_PRE_REROLL_CHEST, correctChestReroll, DIRE_CHEST)
	Mod:AddCallback(Mod.ModCallbacks.ASTRAGALI_PRE_REROLL_CHEST, correctChestReroll, GLASS_CHEST)

	--#endregion

	--#region Altruism

	Mod.API:RegisterAltruismBeggar(ff.FF.ZodiacBeggar.Var,
		function (player, slot)
			local sprite = slot:GetSprite()
			return player:GetNumCoins() >= 1 and (sprite:IsOverlayPlaying("PayNothing") or sprite:IsOverlayPlaying("PayPrize")) and sprite:GetOverlayFrame() == 1
		end,
		function (player, slot)
			player:AddCoins(1)
		end
	)

	Mod.API:RegisterAltruismBeggar(ff.FF.CosplayBeggar.Var,
		function (player, slot)
			local sprite = slot:GetSprite()
			return player:GetNumCoins() >= 5 and (sprite:IsPlaying("PayNothing") or sprite:IsPlaying("PayPrize")) and sprite:GetFrame() == 1
		end,
		function (player, slot)
			player:AddCoins(5)
		end
	)

	Mod.API:RegisterAltruismBeggar(ff.FF.CellGame.Var,
		function (player, slot)
			local sprite = slot:GetSprite()
			print(sprite:GetAnimation(), sprite:GetFrame())
			return player:GetNumKeys() >= 1 and sprite:IsPlaying("PayShuffle") and sprite:GetFrame() == 1
		end,
		function (player, slot)
			player:AddKeys(1)
		end
	)

	Mod.API:RegisterAltruismBeggar(ff.FF.EvilBeggar.Var,
		function(player, slot)
			local sprite = slot:GetSprite()
			return sprite:IsPlaying("PayCoin") and sprite:GetFrame() == 1
		end,
		function(player, slot)
			player:AddCoins(15)
		end
	)

	local ALTRUISM = Mod.Trinket.ALTRUISM

	-- Doing this as this runs on POST_UPDATE which proceeds with payment before PRE_SLOT_COLLISION triggers
	---@param player EntityPlayer
	---@param slot EntitySlot
	local function evilBeggarOnTouch(player, slot)

		if not (
				player:HasTrinket(ALTRUISM.ID)
				and (player:GetEffectiveMaxHearts() > 0
				or player:GetSoulHearts() >= 4)
				and slot:GetSprite():IsPlaying("Idle")
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
			player:AddHearts(1)
		else
			local data = Mod:GetData(player)
			Mod:DebugLog("Altruism beggar refund")
			data.AltruismPreventEvilBeggar = true
			Mod:DelayOneFrame(function ()
				data.AltruismPreventEvilBeggar = nil
			end)
			Mod.Trinket.ALTRUISM:SpawnRefundNotification(player.Position)
		end
	end

	--Copy of Fiend Folio's slot detection
	local function evilBeggarAltruismPreUpdate(_, p)
		local slots = Isaac.FindByType(EntityType.ENTITY_SLOT, ff.FF.EvilBeggar.Var, -1, false, false)
		for _, slot in ipairs(slots) do
			if slot:GetData().sizeMulti then
				if (math.abs(slot.Position.X-p.Position.X) ^ 2 <= (slot.Size*slot.SizeMulti.X + p.Size) ^ 2)
				and (math.abs(slot.Position.Y-p.Position.Y) ^ 2 <= (slot.Size*slot.SizeMulti.Y + p.Size) ^ 2)
					then
					---@diagnostic disable-next-line: param-type-mismatch
					evilBeggarOnTouch(p, slot:ToSlot())
				end
			else
				if slot.Position:DistanceSquared(p.Position) <= (slot.Size + p.Size) ^ 2 then
					---@diagnostic disable-next-line: param-type-mismatch
					evilBeggarOnTouch(p, slot:ToSlot())
				end
			end
		end
	end

	Mod:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CallbackPriority.EARLY, evilBeggarAltruismPreUpdate)

	local function preventHealthLoss(_, player, amount, healthtype)
		if Mod:GetData(player).AltruismPreventEvilBeggar then
			return 0
		end
	end

	Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, preventHealthLoss, AddHealthType.BLACK)
	Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, preventHealthLoss, AddHealthType.SOUL)
	Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, preventHealthLoss, AddHealthType.MAX)
	Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, preventHealthLoss, AddHealthType.BONE)

	--#endregion

	--#region Heart Renovator double-tap drop prevention

	local revertBlacklist = {}

	local function onGainRenovator(_, _, _, _, _, _, player)
		local playerType = player:GetPlayerType()
		if not ff.doubleTapCTRLBlacklist[playerType] then
			ff.doubleTapCTRLBlacklist[playerType] = true
			revertBlacklist[playerType] = true
		end
	end

	Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, onGainRenovator, Mod.Item.HEART_RENOVATOR.ID)

	local function onLoseRenovator(_, player)
		local playerType = player:GetPlayerType()
		if not player:HasCollectible(Mod.Item.HEART_RENOVATOR.ID)
			and revertBlacklist[playerType]
		then
			ff.doubleTapCTRLBlacklist[playerType] = false
			revertBlacklist[playerType] = false
		end
	end

	Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, onLoseRenovator, Mod.Item.HEART_RENOVATOR.ID)

	local function onPlayerInit(_, player)
		if player:HasCollectible(Mod.Item.HEART_RENOVATOR.ID) then
			onGainRenovator(_, _, _, _, _, player)
		else
			onLoseRenovator(_, player)
		end
	end
	Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)

	--#endregion
end

loader:RegisterPatch("FiendFolio", fiendFolioPatch)
