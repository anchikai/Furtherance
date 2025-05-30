local Mod = Furtherance
local loader = Mod.PatchesLoader

local sprite = Sprite("gfx/ui/furtherance_minimap_icons.anm2")

local function minimapPatch()
	MinimapAPI:AddIcon("MoonHeart", sprite, "MoonHeart", 0)
	MinimapAPI:AddPickup("MoonHeart", "MoonHeart", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, Mod.Pickup.MOON_HEART.ID, MinimapAPI.PickupNotCollected, "hearts")

	MinimapAPI:AddIcon("LoveTeller", sprite, "LoveTeller", 0)
	MinimapAPI:AddPickup("LoveTeller", "LoveTeller", EntityType.ENTITY_SLOT, Mod.Slot.LOVE_TELLER.ID, 0, MinimapAPI.PickupSlotMachineNotBroken, "slots")

	MinimapAPI:AddIcon("EscortBeggar", sprite, "EscortBeggar", 0)
	MinimapAPI:AddPickup("EscortBeggar", "EscortBeggar", EntityType.ENTITY_SLOT, Mod.Slot.ESCORT_BEGGAR.ID, 0, MinimapAPI.PickupSlotMachineNotBroken, "slots")

	MinimapAPI:AddIcon("ChargedBomb", sprite, "ChargedBomb", 0)
	MinimapAPI:AddPickup("ChargedBomb", "ChargedBomb", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, Mod.Pickup.CHARGED_BOMB.ID, MinimapAPI.PickupNotCollected, "bombs")

	MinimapAPI:AddIcon("GoldenSack", sprite, "GoldenSack", 0)
	MinimapAPI:AddPickup("GoldenSack", "GoldenSack", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, Mod.Pickup.GOLDEN_SACK.ID, MinimapAPI.PickupNotCollected, "other")
end

loader:RegisterPatch("MinimapAPI", minimapPatch)