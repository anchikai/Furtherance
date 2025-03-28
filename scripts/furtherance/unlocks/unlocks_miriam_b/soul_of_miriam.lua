local Mod = Furtherance

local SOUL_OF_MIRIAM = {}

Furtherance.Rune.SOUL_OF_MIRIAM = SOUL_OF_MIRIAM

SOUL_OF_MIRIAM.ID = Isaac.GetCardIdByName("Soul of Miriam")

--TODO: These are basically identical so I'm just leaving this here for now until one or the other is reworked

---@param card Card
---@param player EntityPlayer
---@param flags UseFlag
function SOUL_OF_MIRIAM:OnUse(card, player, flags)
	Mod.Rune.ESSENCE_OF_DELUGE:OnUse(card, player, flags)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_MIRIAM.OnUse, SOUL_OF_MIRIAM.ID)
