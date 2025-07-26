---@enum SlotState
Furtherance.SlotState = {
	IDLE = 1,
	REWARD = 2,
	BOMBED = 3,
	PAYOUT = 4
}

---@enum BloodClotSubtype
Furtherance.BloodClotSubtype = {
	RED = 0,
	SOUL = 1,
	BLACK = 2,
	ETERNAL = 3,
	GOLD = 4,
	BONE = 5,
	ROTTEN = 6
}

Furtherance.DisplayFlags = {
	INVISIBLE = 1 << -1,
	VISIBLE = 1 << 0,
	ROOM_SHADOW = 1 << 1,
	SHOW_ICON = 1 << 2,
	VISIBLE_WITH_ICON = 1 << 0 | 1 << 2
}