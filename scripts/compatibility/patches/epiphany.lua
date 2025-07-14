local Mod = Furtherance
local loader = Mod.PatchesLoader
local Item = Mod.Item

local function epiphanyPatch()
	local api = Epiphany.API
	local KEEPER = Epiphany.Character.KEEPER
	local GOLDEN_BEGGAR = KEEPER.GoldenBeggar

	Mod.KeeperPlayers[Epiphany.PlayerType.KEEPER] = true
	Mod.LostPlayers[Epiphany.PlayerType.LOST] = true

	Epiphany.UnlockChecker:AddModdedItems("Furtherance", Item.KEY_ESC.ID, Item.ASTRAGALI.ID, function(item_id)
		return Mod.PersistGameData:Unlocked(Mod.ItemConfig:GetCollectible(item_id).AchievementID)
	end)

	Mod:AddToDictionary(KEEPER.CollectibleSpawnedPickups, {
		[Item.BOX_OF_BELONGINGS.ID] = {
			{ PickupVariant.PICKUP_TRINKET,   2 },
			{ PickupVariant.PICKUP_TAROTCARD, 1 }
		}
	})

	Mod:AddToDictionary(KEEPER.PickupVariants[PickupVariant.PICKUP_BOMB], {
		[Mod.Pickup.CHARGED_BOMB.ID] = 9
	})
	Mod:AddToDictionary(KEEPER.HeartToFliesTable[PickupVariant.PICKUP_HEART], {
		[Mod.Pickup.MOON_HEART.ID] = 4
	})

	local ESCORT_MIDAS = Isaac.GetEntityVariantByName("Midas Cursed escort Beggar")
	GOLDEN_BEGGAR.NormalToGold[Mod.Slot.ESCORT_BEGGAR.SLOT] = ESCORT_MIDAS
	Mod:AddToDictionary(GOLDEN_BEGGAR.GoldBeggarInfo, {
		[ESCORT_MIDAS] = {
			{
				ItemPool = Mod.Slot.ESCORT_BEGGAR.ITEM_POOL,
				Drops = {}
			}
		}
	})

	api:AddCardsToCardGroup("Magic",
		{ V = Mod.Card.TRAP_CARD.ID }
	)
	api:AddCardsToCardGroup("Special",
		{ V = Mod.Card.KEY_CARD.ID },
		{ V = Mod.Card.GOLDEN_CARD.ID, Weight = 0.1 }
	)

	api:AddCardsToCardGroup("Suit",
		{ V = Mod.Card.TWO_OF_SHIELDS.ID, Weight = 0.2 },
		{ V = Mod.Card.ACE_OF_SHIELDS.ID, Weight = 0.2 }
	)

	api:AddCardsToCardGroup("Tarot",
		{ V = Mod.Card.HOPE.ID },
		{ V = Mod.Card.FAITH.ID },
		{ V = Mod.Card.CHARITY.ID }
	)

	api:AddCardsToCardGroup("ReverseTarot",
		{ V = Mod.Card.REVERSE_HOPE.ID },
		{ V = Mod.Card.REVERSE_FAITH.ID },
		{ V = Mod.Card.REVERSE_CHARITY.ID }
	)

	api:AddHeartsToHeartGroup("Soul",
		{ V = Mod.Pickup.MOON_HEART.ID },
		{ V = Mod.Pickup.MOON_HEART.ID_HALF }
	)

	api:AddSlotsToSlotGroup("Beggars", { V = Mod.Slot.ESCORT_BEGGAR.SLOT })
	api:AddSlotsToSlotGroup("SpecialBeggars", { V = Mod.Slot.ESCORT_BEGGAR.SLOT })
	api:AddSlotsToSlotGroup("Slots", { V = Mod.Slot.LOVE_TELLER.ID })

	api:AddItemsToEdenBlackList(
		Item.BRUNCH.ID,
		Item.COFFEE_BREAK.ID,
		Item.CRAB_LEGS.ID,
		Item.LITTLE_RAINCOAT.ID
	)

	Mod.API:RegisterAstragaliChest(Epiphany.Pickup.DUSTY_CHEST.ID,
		function()
			return Epiphany:GetAchievement("DUSTY_CHEST") > 0
		end
	)

	local cainSynergies = {
		angel_bagged = {
			Item.KEYS_TO_THE_KINGDOM.ID
		},
		bone_bagged = {
			Item.ASTRAGALI.ID
		},
		book_bagged = {
			Item.BOOK_OF_AMBIT.ID,
			Item.BOOK_OF_BOOKS.ID,
			Item.BOOK_OF_GUIDANCE.ID,
			Item.BOOK_OF_LEVITICUS.ID,
			Item.BOOK_OF_SWIFTNESS.ID,
			Item.SECRET_DIARY.ID,
			Item.COSMIC_OMNIBUS.ID
		},
		cursed_bagged = {
			Item.MUDDLED_CROSS.ID
		},
		childhood_bagged = {
			Item.BOX_OF_BELONGINGS.ID
		},
		dice_bagged = {
			Item.D16.ID,
			Item.D9.ID
		},
		fear_bagged = {
			Item.QUARANTINE.ID
		},
		fertilizer_bagged = {
			Item.ROTTEN_APPLE.ID
		},
		fire_bagged = {
			Item.UNSTABLE_CORE.ID,
			Item.PILLAR_OF_FIRE.ID
		},
		gamer_bagged = {
			Item.PLUG_N_PLAY.ID
		},
		glitched_bagged = {
			Item.PLUG_N_PLAY.ID,
			Item.ZZZZOPTIONSZZZZ.ID
		},
		golden_bagged = {
			Item.GOLDEN_PORT.ID,
			Item.MOLTEN_GOLD.ID
		},
		homing_bagged = {
			Item.OWLS_EYE.ID
		},
		luck_bagged = {
			Item.BEGINNERS_LUCK.ID
		},
		medical_bagged = {
			Item.KERATOCONUS.ID,
			Item.CARDIOMYOPATHY.ID
		},
		mystic_bagged = {
			Item.OPHIUCHUS.ID,
			Item.CHIRON.ID,
			Item.JUNO.ID,
			Item.PALLAS.ID,
			Item.CERES.ID,
			Item.VESTA.ID,
			Item.COSMIC_OMNIBUS.ID
		},
		organ_bagged = {
			Item.COLD_HEARTED.ID,
			Item.HEART_RENOVATOR.ID,
			Item.SHATTERED_HEART.ID,
			Item.LEAHS_HEART.ID,
			Item.SEVERED_EAR.ID,
			Item.OWLS_EYE.ID
		},
		paper_bagged = {
			Item.BEGINNERS_LUCK.ID
		},
		piercing_bagged = {
			Item.BOOK_OF_AMBIT.ID,
			Item.OWLS_EYE.ID
		},
		poison_bagged = {
			Item.QUARANTINE.ID
		},
		lunch_bagged = {
			Item.COFFEE_BREAK.ID,
			Item.BRUNCH.ID
		},
		slow_bagged = {
			Item.COLD_HEARTED.ID
		},
		spectral_bagged = {
			Item.VESTA.ID,
			Item.OPHIUCHUS.ID,
			Item.FLUX.ID
		},
		spirit_bagged = {
			Item.FIRSTBORN_SON.ID,
			Item.OLD_CAMERA.ID
		},
		uranus_bagged = {
			Item.COLD_HEARTED.ID
		}
	}

	for generic_group, items_list in pairs(cainSynergies) do
		api:AddCollectibleToCainBagSynergy(generic_group, items_list)
	end

	for name, playerType in pairs(Epiphany.PlayerType) do
		if PlayerType["PLAYER_".. name] then
			Mod.Slot.LOVE_TELLER.Matchmaking[playerType] = Mod.Slot.LOVE_TELLER.Matchmaking[PlayerType["PLAYER_".. name]]
		end
	end

	--[[ Mod.Capsule.D9 = {
		ID = Isaac.GetCardIdByName("Capsule D9"),
		WEIGHT = 0.3,
		MOD = "Furtherance"
	}

	Mod.Capsule.D16 = {
		ID = Isaac.GetCardIdByName("Capsule D16"),
		WEIGHT = 0.3,
		MOD = "Furtherance"
	}

	--#region Dice Capsules
	for name, capsuleData in pairs(Mod.Capsule) do
		local weight = Dice.WEIGHT or 1
		if capsuleData.MOD == "Furtherance" then
			api:AddCardsToCardGroup("DiceCapsule", { V = capsuleData.ID, Weight = weight })

			Mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, _, player, useFlags)
				player:UseActiveItem(Mod.Item[name].ID, 1, -1)
			end)
		end
	end

	Mod:AddExtraCallback(Mod.ExtraCallbacks.PRE_UNLOCK_CACHE, function(unlocks)
		unlocks.Cards[Mod.Capsule.D9] = true
		unlocks.Cards[Mod.Capsule.D16] = Mod.PersistGameData:Unlocked(Mod.Item.D16.ACHIEVEMENT)
	end) ]]
end

loader:RegisterPatch("Epiphany", epiphanyPatch)
