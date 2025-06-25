local Mod = Furtherance
local loader = Mod.PatchesLoader

local function brawlerBeggarPatch()
	local BRAWLER_BEGGAR = Isaac.GetEntityVariantByName("Brawler Beggar")
	Mod.Trinket.ALTRUISM.ResourceRequirement[BRAWLER_BEGGAR] = function (player, slot)
		local sprite = slot:GetSprite()
		local frame = sprite:GetFrame()
		return player:GetNumCoins() >= 3 and sprite:IsPlaying("PayPrize") and frame == 1
	end
	Mod.Trinket.ALTRUISM.ResourceRefund[BRAWLER_BEGGAR] = function (player, slot)
		player:AddCoins(3)
	end
end

loader:RegisterPatch(function() return Isaac.GetEntityVariantByName("Brawler Beggar") ~= -1 end, brawlerBeggarPatch, "Brawler Beggar")