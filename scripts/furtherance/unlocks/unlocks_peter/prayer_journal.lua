local Mod = Furtherance

local PRAYER_JOURNAL = {}

Furtherance.Item.PRAYER_JOURNAL = PRAYER_JOURNAL

PRAYER_JOURNAL.ID = Isaac.GetItemIdByName("Prayer Journal")

PRAYER_JOURNAL.BLACK_HEART_CHANCE = 0.5
PRAYER_JOURNAL.BROKEN_HEART_CHANCE = 0.1

function PRAYER_JOURNAL:UsePrayerJournal(_, _, player)
	local rng = player:GetCollectibleRNG(PRAYER_JOURNAL.ID)
	if rng:RandomFloat() <= PRAYER_JOURNAL.BROKEN_HEART_CHANCE then
		player:AddBrokenHearts(1)
	elseif rng:RandomFloat() <= PRAYER_JOURNAL.BROKEN_HEART_CHANCE then
		player:AddBlackHearts(2)
	else
		player:AddSoulHearts(2)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, PRAYER_JOURNAL.UsePrayerJournal, PRAYER_JOURNAL.ID)
