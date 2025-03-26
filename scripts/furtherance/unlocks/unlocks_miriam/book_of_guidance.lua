local Mod = Furtherance

local BOOK_OF_GUIDANCE = {}

Furtherance.Item.BOOK_OF_GUIDANCE = BOOK_OF_GUIDANCE

BOOK_OF_GUIDANCE.ID = Isaac.GetItemIdByName("Book of Guidance")

function BOOK_OF_GUIDANCE:OnUse(_, _, player)
	local floor_save = Mod:FloorSave()
	player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, false, false, true, false, -1)
	floor_save.GuidanceActive = true
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, BOOK_OF_GUIDANCE.OnUse, BOOK_OF_GUIDANCE.ID)

function BOOK_OF_GUIDANCE:DadsKeyOnNewRoom()
	local floor_save = Mod:FloorSave()
	if floor_save.GuidanceActive then
		local player = Isaac.GetPlayer()
		player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, false, false, true, false, -1)
		Mod.SFXMan:Stop(SoundEffect.SOUND_GOLDENKEY)
		Mod.SFXMan:Stop(SoundEffect.SOUND_UNLOCK00)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BOOK_OF_GUIDANCE.DadsKeyOnNewRoom)
