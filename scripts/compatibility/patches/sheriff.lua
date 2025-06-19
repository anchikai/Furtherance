local Mod = Furtherance
local loader = Mod.PatchesLoader

local function sheriffPatch()
	Mod.API:RegisterAltruismBeggar(Sheriff.Entities.Rancher.ID,
	function (player, slot)
		local sprite = slot:GetSprite()
		local anim = sprite:GetAnimation()
		local frame = sprite:GetFrame()
		return player:GetNumCoins() >= 3 and anim == "GiveQuest" and frame == 0
	end,
	function (player, slot)
		player:AddCoins(3)
	end)
end

loader:RegisterPatch("Sheriff", sheriffPatch)