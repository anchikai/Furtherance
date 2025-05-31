local Mod = Furtherance
local Item = Mod.Item
local loader = Mod.PatchesLoader

local function fiendFolioPatch()
	local ff = FiendFolio
	Mod:AppendTable(ff.PennyRollSpawns, {
		{ID = Mod.Trinket.ABYSSAL_PENNY.ID, Unlocked = function() return Mod.PersistGameData:Unlocked(Mod.Trinket.ABYSSAL_PENNY.ACHIEVEMENT) end},
		{ID = Mod.Trinket.GLITCHED_PENNY.ID, Unlocked = function() return true end}
	})

	Mod:AppendTable(FiendFolio.ReferenceItems.Passives, {
		{ ID = Mod.Item.LITTLE_RAINCOAT.ID,      Reference = "Little Nightmares" }
	})

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
		Item.TECH_IX.ID
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
end

loader:RegisterPatch("FiendFolio", fiendFolioPatch)