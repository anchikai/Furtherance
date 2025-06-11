local Mod = Furtherance
local Item = Mod.Item
local loader = Mod.PatchesLoader

local function fiendFolioPatch()
	local ff = FiendFolio

	ff.AddItemsToPennyTrinketPool({
		Mod.Trinket.ABYSSAL_PENNY.ID,
		Mod.Trinket.GLITCHED_PENNY.ID
	})

	Mod:AppendTable(FiendFolio.ReferenceItems.Passives, {
		{ ID = Mod.Item.LITTLE_RAINCOAT.ID,      Reference = "Little Nightmares" }
	})

	Mod:AddToDictionary(ff.DadsBattery.BLACKLIST, Mod:Set({
		Mod.Item.SERVITUDE.ID
	}))

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

	Mod:AddToDictionary(Mod.Item.KEYS_TO_THE_KINGDOM.MINIBOSS, Mod:Set({
		ff.FF.Gravedigger.ID .. "." .. ff.FF.Gravedigger.Var .. Isaac.GetEntitySubTypeByName("Gravedigger"),
		ff.FF.Psion.ID .. "." .. ff.FF.Psion.Var .. Isaac.GetEntitySubTypeByName("Psion"),
	}))

	local function killWhisperController(_, npc)
		if npc.Variant == ff.FF.Whispers.Var and npc.SpawnerEntity and not npc.SpawnerEntity:IsDead() then
			Mod.Item.KEYS_TO_THE_KINGDOM:RemoveBoss(npc.SpawnerEntity)
		end
	end

	Mod:AddCallback(Mod.ModCallbacks.POST_RAPTURE_BOSS_DEATH, killWhisperController, ff.FF.Whispers.ID)

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

	Mod:AddToDictionary(ff.PocketObjectMimicCharges, {
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]] = 4,
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[2]] = 8,
		[Mod.Item.OLD_CAMERA.PHOTO_IDs[3]] = 12,
	})
end

loader:RegisterPatch("FiendFolio", fiendFolioPatch)