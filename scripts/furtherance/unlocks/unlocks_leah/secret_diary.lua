local Mod = Furtherance

local SECRET_DIARY = {}

Furtherance.Item.SECRET_DIARY = SECRET_DIARY

SECRET_DIARY.ID = Isaac.GetItemIdByName("Secret Diary")

function SECRET_DIARY:UseSecretDiary()
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, SECRET_DIARY.UseSecretDiary, SECRET_DIARY.ID)

function SECRET_DIARY:Test(modCount, player, itemID, onlyTrue)
	if itemID == CollectibleType.COLLECTIBLE_BIRTHRIGHT
		and player:GetEffects():HasCollectibleEffect(SECRET_DIARY.ID)
		and not onlyTrue
	then
		return modCount + 1
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_APPLY_INNATE_COLLECTIBLE_NUM, SECRET_DIARY.Test)