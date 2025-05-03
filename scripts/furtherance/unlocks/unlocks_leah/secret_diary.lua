local Mod = Furtherance

local SECRET_DIARY = {}

Furtherance.Item.SECRET_DIARY = SECRET_DIARY

SECRET_DIARY.ID = Isaac.GetItemIdByName("Secret Diary")

---@param player EntityPlayer
function SECRET_DIARY:UseSecretDiary(_, _, player)
	player:AddInnateCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, SECRET_DIARY.UseSecretDiary, SECRET_DIARY.ID)

---@param player EntityPlayer
---@param itemConfigItem ItemConfigItem
function SECRET_DIARY:RemoveBirthrightOnNewRoom(player, itemConfigItem)
	if itemConfigItem:IsCollectible()
		and itemConfigItem.ID == SECRET_DIARY.ID
	then
		player:AddInnateCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, -1)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, SECRET_DIARY.RemoveBirthrightOnNewRoom)

function SECRET_DIARY:RemoveBirthrightOnGameExit()
	Mod.Foreach.Player(function (player, index)
		if player:GetEffects():HasCollectibleEffect(SECRET_DIARY.ID) then
			player:AddInnateCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT, -1)
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SECRET_DIARY.RemoveBirthrightOnGameExit)
