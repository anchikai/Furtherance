local Mod = Furtherance

local POG_COSTUMES = {
	{"Leah", Mod.PlayerType.LEAH, "01_leah"},
	{"LeahB", Mod.PlayerType.LEAH_B, "01b_leah"},
	{"PeterB", Mod.PlayerType.PETER_B, "02b_peter"},
	{"Miriam", Mod.PlayerType.MIRIAM, "03_miriam"},
	{"MiriamB", Mod.PlayerType.MIRIAM_B, "03b_miriam"}
}

if Poglite then
	for _, pogInfo in ipairs(POG_COSTUMES) do
		Poglite:AddPogCostume(
			"FR" .. pogInfo[1] .. "Pog",
			pogInfo[2],
			Isaac.GetCostumeIdByPath("gfx/characters/character_" .. pogInfo[3] .. "_pog.anm2")
		)
	end
end
