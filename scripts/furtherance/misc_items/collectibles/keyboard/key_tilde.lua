local Mod = Furtherance

local TILDE_KEY = {}

Furtherance.Item.KEY_TILDE = TILDE_KEY

TILDE_KEY.ID = Isaac.GetItemIdByName("Tilde Key")

local debugFlags = {}
local FLAG_TO_NAME = {
	"Entity Positions",
	"Grid",
	"Infinite HP",
	"High Damage",
	"Room Info",
	"Hitspheres",
	"Damage Values",
	"Infinite Item Charges",
	"High Luck",
	"Quick Kill",
	"Grid Info",
	"Player Item Info",
	"Grid Collision Points",
	"Lua Memory Usage",
}

function TILDE_KEY:UseTilde(_, rng, player)
	local randomDebug = rng:RandomInt(13) + 1
	if not Mod:HasBitFlags(Mod.Game:GetDebugFlags(), 1 << (randomDebug - 1)) then
		Isaac.ExecuteCommand("debug " .. randomDebug)
		debugFlags[randomDebug] = true
		Mod.HUD:ShowFortuneText(FLAG_TO_NAME[randomDebug])
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK, true)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, TILDE_KEY.UseTilde, TILDE_KEY.ID)

function TILDE_KEY:ResetDebug()
	for debugNum, _ in pairs(debugFlags) do
		Isaac.ExecuteCommand("debug " .. debugNum)
	end
	debugFlags = {}
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TILDE_KEY.ResetDebug)
