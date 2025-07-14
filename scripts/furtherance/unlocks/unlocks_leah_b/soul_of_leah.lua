local Mod = Furtherance
local floor = Mod.math.floor
local min = Mod.math.min

local SOUL_OF_LEAH = {}

Furtherance.Rune.SOUL_OF_LEAH = SOUL_OF_LEAH

SOUL_OF_LEAH.ID = Isaac.GetCardIdByName("Soul of Leah")
SOUL_OF_LEAH.NULL_ID = Isaac.GetNullItemIdByName("soul of leah")

SOUL_OF_LEAH.HEARTS_PER_USE = 3
SOUL_OF_LEAH.HEART_CAP = 48

---@param player EntityPlayer
function SOUL_OF_LEAH:IsKeeper(player)
	return player:GetHealthType() == HealthType.COIN
end

---@param player EntityPlayer
function SOUL_OF_LEAH:UseSoulOfLeah(_, player, _)
	player:GetEffects():AddNullEffect(SOUL_OF_LEAH.NULL_ID, false, SOUL_OF_LEAH.HEARTS_PER_USE)
	player:AddBrokenHearts(SOUL_OF_LEAH:IsKeeper(player) and 1 or SOUL_OF_LEAH.HEARTS_PER_USE)
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_LEAH.UseSoulOfLeah, SOUL_OF_LEAH.ID)


---@param player EntityPlayer
---@param heartLimit integer
---@param isKeeper boolean
function SOUL_OF_LEAH:IncreaseHeartCap(player, heartLimit, isKeeper)
	local effectNum = player:GetEffects():GetNullEffectNum(SOUL_OF_LEAH.NULL_ID)
	if effectNum == 0 then return end
	local numHearts = isKeeper and floor(effectNum / SOUL_OF_LEAH.HEARTS_PER_USE) or effectNum
	return min(SOUL_OF_LEAH.HEART_CAP, heartLimit + (numHearts * 2))
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, SOUL_OF_LEAH.IncreaseHeartCap)