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
		ff.Sounds.CacaDeath
	})

	Mod:AddToDictionary(Mod.Item.KEYS_TO_THE_KINGDOM.MINIBOSS, Mod:Set({
		Mod:GetTypeVarSubFromName("Gravedigger", true),
		Mod:GetTypeVarSubFromName("Psion", true)
	}))
end

loader:RegisterPatch("FiendFolio", fiendFolioPatch)