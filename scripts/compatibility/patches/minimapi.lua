local Mod = Furtherance
local loader = Mod.PatchesLoader

local sprite = Sprite("gfx/ui/minimap_icons.anm2")

local function minimapPatch()
	MinimapAPI:AddIcon("MoonHeart", sprite, "MoonHeart", 0)
	MinimapAPI:AddPickup("MoonHeart", "MoonHeart", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, Mod.Pickup.MOON_HEART.ID, MinimapAPI.PickupNotCollected, "hearts")
end

loader:RegisterPatch("MinimapAPI", minimapPatch)