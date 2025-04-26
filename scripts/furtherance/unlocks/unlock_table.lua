local Mod = Furtherance

local function achievement(str)
	return Isaac.GetAchievementIdByName(str)
end

---@alias CompletionTable {[CompletionType|FurtheranceCompletionType]: Achievement}

---@type {[string]: CompletionTable}
Furtherance.CompletionMarkToAchievement = {}

---@type {[PlayerType]: CompletionTable}
Furtherance.PlayerTypeToCompletionTable = {}

---@enum FurtheranceCompletionType
Furtherance.CompletionType = {
	TAINTED = 15,
	ALL = 16
}

--#region Leah

Furtherance.Item.SECRET_DIARY.ACHIEVEMENT = achievement("Secret Diary")
Furtherance.Item.BINDS_OF_DEVOTION.ACHIEVEMENT = achievement("Binds of Devotion")
Furtherance.Item.RUE.ACHIEVEMENT = achievement("Rue")
Furtherance.Trinket.LEAHS_LOCK.ACHIEVEMENT = achievement("Leah's Lock")
Furtherance.Item.MANDRAKE.ACHIEVEMENT = achievement("Mandrake")
Furtherance.Trinket.PARASOL.ACHIEVEMENT = achievement("Parasol")
Furtherance.Item.D16.ACHIEVEMENT = achievement("D16")
Furtherance.Trinket.HOLY_HEART.ACHIEVEMENT = achievement("Holy Heart")
Furtherance.Item.KERATOCONUS.ACHIEVEMENT = achievement("Keratoconus")
Furtherance.Item.HEART_EMBEDDED_COIN.ACHIEVEMENT = achievement("Heart Embedded Coin")
Furtherance.Item.HEART_RENOVATOR.ACHIEVEMENT = achievement("Heart Renovator")
Furtherance.Item.OWLS_EYE.ACHIEVEMENT = achievement("Owl's Eye")
Furtherance.Item.EXSANGUINATION.ACHIEVEMENT = achievement("Exsanguination")
Furtherance.Rune.ESSENCE_OF_LOVE.ACHIEVEMENT = achievement("Essence of Love")
Furtherance.Character.LEAH_B.ACHIEVEMENT = achievement("The Unloved")

Furtherance.CompletionMarkToAchievement.LEAH = {
	[CompletionType.MOMS_HEART] = Mod.Item.SECRET_DIARY.ACHIEVEMENT,
	[CompletionType.ISAAC] = Mod.Item.BINDS_OF_DEVOTION.ACHIEVEMENT,
	[CompletionType.SATAN] = Mod.Item.RUE.ACHIEVEMENT,
	[CompletionType.BOSS_RUSH] = Mod.Trinket.LEAHS_LOCK.ACHIEVEMENT,
	[CompletionType.BLUE_BABY] = Mod.Item.MANDRAKE.ACHIEVEMENT,
	[CompletionType.LAMB] = Mod.Trinket.PARASOL.ACHIEVEMENT,
	[CompletionType.MEGA_SATAN] = Mod.Item.D16.ACHIEVEMENT,
	[CompletionType.ULTRA_GREED] = Mod.Trinket.HOLY_HEART.ACHIEVEMENT,
	[CompletionType.HUSH] = Mod.Item.KERATOCONUS.ACHIEVEMENT,
	[CompletionType.ULTRA_GREEDIER] = Mod.Item.HEART_EMBEDDED_COIN.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.HEART_RENOVATOR.ACHIEVEMENT,
	[CompletionType.MOTHER] = Mod.Item.OWLS_EYE.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.EXSANGUINATION.ACHIEVEMENT,
	[Mod.CompletionType.TAINTED] = Mod.Character.LEAH_B.ACHIEVEMENT,
	[Mod.CompletionType.ALL] = achievement("Essence of Love")
}
Furtherance.PlayerTypeToCompletionTable[Mod.PlayerType.LEAH] = Mod.CompletionMarkToAchievement.LEAH

--#endregion

--#region Tainted Leah

Furtherance.Rune.SOUL_OF_LEAH.ACHIEVEMENT = achievement("Soul of Leah")
Furtherance.Item.LEAHS_HEART.ACHIEVEMENT = achievement("Leah's Heart")
--Mega Satan Unlock. Used to be Rotten Hearts but is not fit for this unlock
Furtherance.Item.SHATTERED_HEART.ACHIEVEMENT = achievement("Shattered Heart")
Furtherance.Item.COLD_HEARTED.ACHIEVEMENT = achievement("Cold Hearted")
--Beast Unlock. Moon Hearts
Furtherance.Card.REVERSE_HOPE.ACHIEVEMENT = achievement("Reverse Hope")
Furtherance.Rune.ESSENCE_OF_HATE.ACHIEVEMENT = achievement("Essence of Hate")

Furtherance.CompletionMarkToAchievement.LEAH_B = {
	[TaintedMarksGroup.SOULSTONE] = Mod.Rune.SOUL_OF_LEAH.ACHIEVEMENT,
	[TaintedMarksGroup.POLAROID_NEGATIVE] = Mod.Item.LEAHS_HEART.ACHIEVEMENT,
	[CompletionType.MEGA_SATAN] = achievement("Secret Diary"), --Placeholder
	[CompletionType.ULTRA_GREEDIER] = Mod.Card.REVERSE_HOPE.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.SHATTERED_HEART.ID,
	[CompletionType.MOTHER] = Mod.Item.COLD_HEARTED.ACHIEVEMENT,
	[CompletionType.BEAST] = achievement("Moon Hearts"), --Placeholderish, need to actually get around to implementing it with CustomHealthAPI. Scary....
	[Mod.CompletionType.ALL] = Mod.Rune.ESSENCE_OF_HATE.ACHIEVEMENT
}
Furtherance.PlayerTypeToCompletionTable[Mod.PlayerType.LEAH_B] = Mod.CompletionMarkToAchievement.LEAH_B

--#endregion

--#region Peter

Furtherance.Item.PRAYER_JOURNAL.ACHIEVEMENT = achievement("Prayer Journal")
Furtherance.Item.PALLIUM.ACHIEVEMENT = achievement("Pallium")
Furtherance.Item.SEVERED_EAR.ACHIEVEMENT = achievement("Severed Ear")
Furtherance.Item.CHI_RHO.ACHIEVEMENT = achievement("Chi Rho")
Furtherance.Item.BOOK_OF_LEVITICUS.ACHIEVEMENT = achievement("Book of Leviticus")
Furtherance.Trinket.ALTRUISM.ACHIEVEMENT = achievement("Altruism")
Furtherance.Item.ASTRAGALI.ACHIEVEMENT = achievement("Astragali")
Furtherance.Trinket.ALABASTER_SCRAP.ACHIEVEMENT = achievement("Alabaster Scrap")
Furtherance.Item.LIBERATION.ACHIEVEMENT = achievement("Liberation")
Furtherance.Item.MOLTEN_GOLD.ACHIEVEMENT = achievement("Molten Gold")
Furtherance.Item.KEYS_TO_THE_KINGDOM.ACHIEVEMENT = achievement("Keys to the Kingdom")
Furtherance.Item.ITCHING_POWDER.ACHIEVEMENT = achievement("Itching Powder")
Furtherance.Item.GOLDEN_PORT.ACHIEVEMENT = achievement("Golden Port")
Furtherance.Character.PETER_B.ACHIEVEMENT = achievement("The Martyr")
Furtherance.Rune.ESSENCE_OF_LIFE.ACHIEVEMENT = achievement("Essence of Life")

Furtherance.CompletionMarkToAchievement.PETER = {
	[CompletionType.MOMS_HEART] = Mod.Item.PRAYER_JOURNAL.ACHIEVEMENT,
	[CompletionType.ISAAC] = Mod.Item.PALLIUM.ACHIEVEMENT,
	[CompletionType.SATAN] = Mod.Item.SEVERED_EAR.ACHIEVEMENT,
	[CompletionType.BOSS_RUSH] = Mod.Item.CHI_RHO.ACHIEVEMENT,
	[CompletionType.BLUE_BABY] = Mod.Item.BOOK_OF_LEVITICUS.ACHIEVEMENT,
	[CompletionType.LAMB] = Mod.Trinket.ALTRUISM.ACHIEVEMENT,
	[CompletionType.MEGA_SATAN] = Mod.Item.ASTRAGALI.ACHIEVEMENT,
	[CompletionType.ULTRA_GREED] = Mod.Trinket.ALABASTER_SCRAP.ACHIEVEMENT,
	[CompletionType.HUSH] = Mod.Item.LIBERATION.ACHIEVEMENT,
	[CompletionType.ULTRA_GREEDIER] = Mod.Item.MOLTEN_GOLD.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.KEYS_TO_THE_KINGDOM.ACHIEVEMENT,
	[CompletionType.MOTHER] = Mod.Item.ITCHING_POWDER.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.GOLDEN_PORT.ACHIEVEMENT,
	[Mod.CompletionType.TAINTED] = Mod.Character.PETER_B.ACHIEVEMENT,
	[Mod.CompletionType.ALL] = Mod.Rune.ESSENCE_OF_LIFE.ACHIEVEMENT,
}
Furtherance.PlayerTypeToCompletionTable[Mod.PlayerType.PETER] = Mod.CompletionMarkToAchievement.PETER

--#endregion

--#region Tainted Peter

Furtherance.Rune.SOUL_OF_PETER.ACHIEVEMENT = achievement("Soul of Peter")
Furtherance.Trinket.LEVIATHANS_TENDRIL.ACHIEVEMENT = achievement("Leviathan's Tendril")
--Mega Satan Unlock. Used to be Trepanation but is not fitting for the unlock
Furtherance.Card.REVERSE_FAITH.ACHIEVEMENT = achievement("Reverse Faith")
Furtherance.Item.MUDDLED_CROSS.ACHIEVEMENT = achievement("Muddled Cross")
Furtherance.Trinket.DUNGEON_KEY.ACHIEVEMENT = achievement("Key to the Pit")
--Beast Unlock. Potentially Escort Beggar
Furtherance.Rune.ESSENCE_OF_DEATH.ACHIEVEMENT = achievement("Essence of Death")

Furtherance.CompletionMarkToAchievement.PETER_B = {
	[TaintedMarksGroup.SOULSTONE] = Mod.Rune.SOUL_OF_PETER.ACHIEVEMENT,
	[TaintedMarksGroup.POLAROID_NEGATIVE] = Mod.Trinket.LEVIATHANS_TENDRIL.ACHIEVEMENT,
	[CompletionType.MEGA_SATAN] = achievement("Secret Diary"), --Placeholder
	[CompletionType.ULTRA_GREEDIER] = Mod.Card.REVERSE_FAITH.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.MUDDLED_CROSS.ACHIEVEMENT,
	[CompletionType.MOTHER] = Mod.Trinket.DUNGEON_KEY.ACHIEVEMENT,
	[CompletionType.BEAST] = achievement("Secret Diary"), --Placeholder
	[Mod.CompletionType.ALL] = Mod.Rune.ESSENCE_OF_DEATH.ACHIEVEMENT
}
Furtherance.PlayerTypeToCompletionTable[Mod.PlayerType.PETER_B] = Mod.CompletionMarkToAchievement.PETER_B

--#endregion

--#region Miriam

Furtherance.Item.BOOK_OF_GUIDANCE.ACHIEVEMENT = achievement("Book of Guidance")
Furtherance.Item.APOCALYPSE.ACHIEVEMENT = achievement("Apocalypse")
Furtherance.Item.KARETH.ACHIEVEMENT = achievement("Kareth")
Furtherance.Trinket.WORMWOOD_LEAF.ACHIEVEMENT = achievement("Wormwood Leaf")
Furtherance.Item.PILLAR_OF_CLOUDS.ACHIEVEMENT = achievement("Pillar of Clouds")
Furtherance.Item.PILLAR_OF_FIRE.ACHIEVEMENT = achievement("Pillar of Fire")
Furtherance.Item.THE_DREIDEL.ACHIEVEMENT = achievement("The Dreidel")
Furtherance.Trinket.SALINE_SPRAY.ACHIEVEMENT = achievement("Saline Spray")
Furtherance.Item.CADUCEUS_STAFF.ACHIEVEMENT = achievement("Caduceus Staff")
Furtherance.Item.MIRIAMS_WELL.ACHIEVEMENT = achievement("Miriam's Well")
Furtherance.Item.TAMBOURINE.ACHIEVEMENT = achievement("Tambourine")
Furtherance.Item.FIRSTBORN_SON.ACHIEVEMENT = achievement("Firstborn Son")
Furtherance.Item.POLYDIPSIA.ACHIEVEMENT = achievement("Polydipsia")
Furtherance.Character.MIRIAM_B.ACHIEVEMENT = achievement("The Condemned")
Furtherance.Rune.ESSENCE_OF_DELUGE.ACHIEVEMENT = achievement("Essence of Deluge")

Furtherance.CompletionMarkToAchievement.MIRIAM = {
	[CompletionType.MOMS_HEART] = Mod.Item.BOOK_OF_GUIDANCE.ACHIEVEMENT,
	[CompletionType.ISAAC] = Mod.Item.APOCALYPSE.ACHIEVEMENT,
	[CompletionType.SATAN] = Mod.Item.KARETH.ACHIEVEMENT,
	[CompletionType.BOSS_RUSH] = Mod.Trinket.WORMWOOD_LEAF.ACHIEVEMENT,
	[CompletionType.BLUE_BABY] = Mod.Item.PILLAR_OF_CLOUDS.ACHIEVEMENT,
	[CompletionType.LAMB] = Mod.Item.PILLAR_OF_FIRE.ACHIEVEMENT,
	[CompletionType.MEGA_SATAN] = Mod.Item.THE_DREIDEL.ACHIEVEMENT,
	[CompletionType.ULTRA_GREED] = Mod.Trinket.SALINE_SPRAY.ACHIEVEMENT,
	[CompletionType.HUSH] = Mod.Item.CADUCEUS_STAFF.ACHIEVEMENT,
	[CompletionType.ULTRA_GREEDIER] = Mod.Item.MIRIAMS_WELL.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.TAMBOURINE.ACHIEVEMENT,
	[CompletionType.MOTHER] = Mod.Item.FIRSTBORN_SON.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.POLYDIPSIA.ACHIEVEMENT,
	[Mod.CompletionType.TAINTED] = Mod.Character.MIRIAM_B.ACHIEVEMENT,
	[Mod.CompletionType.ALL] = Mod.Rune.ESSENCE_OF_DELUGE.ACHIEVEMENT,
}
Furtherance.PlayerTypeToCompletionTable[Mod.PlayerType.MIRIAM] = Mod.CompletionMarkToAchievement.MIRIAM

--#endregion

--#region Tainted Miriam

Furtherance.Rune.SOUL_OF_MIRIAM.ACHIEVEMENT = achievement("Soul of Miriam")
Furtherance.Trinket.ALMAGEST_SCRAP.ACHIEVEMENT = achievement("Almagest Scrap")
Furtherance.Pickup.GOLDEN_SACK.ACHIEVEMENT = achievement("Golden Sack")
Furtherance.Card.REVERSE_CHARITY.ACHIEVEMENT = achievement("Reverse Charity")
Furtherance.Item.SPIRITUAL_WOUND.ACHIEVEMENT = achievement("Spiritual Wound")
Furtherance.Trinket.ABYSSAL_PENNY.ACHIEVEMENT = achievement("Abyssal Penny")
Furtherance.Item.JAR_OF_MANNA.ACHIEVEMENT = achievement("Jar of Manna")
Furtherance.Rune.ESSENCE_OF_DROUGHT.ACHIEVEMENT = achievement("Essence of Drought")

Furtherance.CompletionMarkToAchievement.MIRIAM_B = {
	[TaintedMarksGroup.SOULSTONE] = Mod.Rune.SOUL_OF_MIRIAM.ACHIEVEMENT,
	[TaintedMarksGroup.POLAROID_NEGATIVE] = Mod.Trinket.ALMAGEST_SCRAP.ACHIEVEMENT,
	[CompletionType.MEGA_SATAN] = Mod.Pickup.GOLDEN_SACK.ACHIEVEMENT,
	[CompletionType.ULTRA_GREEDIER] = Mod.Card.REVERSE_CHARITY.ACHIEVEMENT,
	[CompletionType.DELIRIUM] = Mod.Item.SPIRITUAL_WOUND.ACHIEVEMENT,
	[CompletionType.MOTHER] = Mod.Trinket.ABYSSAL_PENNY.ACHIEVEMENT,
	[CompletionType.BEAST] = Mod.Item.JAR_OF_MANNA.ACHIEVEMENT,
	[Mod.CompletionType.ALL] = Mod.Rune.ESSENCE_OF_DROUGHT.ACHIEVEMENT
}
Furtherance.PlayerTypeToCompletionTable[Mod.PlayerType.MIRIAM_B] = Mod.CompletionMarkToAchievement.MIRIAM_B

--#endregion
