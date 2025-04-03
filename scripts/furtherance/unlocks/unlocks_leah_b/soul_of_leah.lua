local Mod = Furtherance

local SOUL_OF_LEAH = {}

Furtherance.Rune.SOUL_OF_LEAH = SOUL_OF_LEAH

SOUL_OF_LEAH.ID = Isaac.GetCardIdByName("Soul of Leah")
SOUL_OF_LEAH.NULL_ID = Isaac.GetNullItemIdByName("soul of leah")

SOUL_OF_LEAH.HEARTS_PER_USE = 3

--TODO: Kinda sucks, could use a rework

---@param player EntityPlayer
function SOUL_OF_LEAH:UseSoulOfLeah(_, player, _)
	player:GetEffects():AddNullEffect(SOUL_OF_LEAH.NULL_ID, false, SOUL_OF_LEAH.HEARTS_PER_USE)
	player:AddBrokenHearts(SOUL_OF_LEAH.HEARTS_PER_USE)
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_LEAH.UseSoulOfLeah, SOUL_OF_LEAH.ID)

local floor = math.floor

---@param player EntityPlayer
---@param heartLimit integer
---@param isKeeper boolean
function SOUL_OF_LEAH:IncreaseHeartCap(player, heartLimit, isKeeper)
	local effectNum = player:GetEffects():GetNullEffectNum(SOUL_OF_LEAH.NULL_ID)
	if effectNum == 0 then return end
	local numHearts = isKeeper and floor(effectNum / SOUL_OF_LEAH.HEARTS_PER_USE) or effectNum
	return heartLimit + (numHearts * 2)
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, SOUL_OF_LEAH.IncreaseHeartCap)