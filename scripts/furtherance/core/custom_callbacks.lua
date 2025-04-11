local Mod = Furtherance

Furtherance.ModCallbacks = {
	---() - Called when the Muddled Cross flip shader is flipping from one side to the other
	PETER_B_ENEMY_ROOM_FLIP = "FURTHERANCE_PETER_B_ENEMY_ROOM_FLIP",

	---(EntityBomb Bomb) - Called
	POST_BOMB_EXPLODE = "FURTHERANCE_POST_BOMB_EXPLODE",

	--(), Optional Arg: RoomType - Called when a special room is being flipped. RoomType is for the type of the current room that's under the effect
	MUDDLED_CROSS_ROOM_FLIP = "FURTHERANCE_MUDDLED_CROSS_ROOM_FLIP",

	--(), Optional Arg: RoomType - Called after a special room is flipped. RoomType is for the type the room was before the flip
	POST_MUDDLED_CROSS_ROOM_FLIP = "FURTHERANCE_POST_MUDDLED_CROSS_ROOM_FLIP",

	GET_MUDDLED_CROSS_PUDDLE_BACKDROP = "FURTHERANCE_GET_MUDDLED_CROSS_PUDDLE_BACKDROP"
}

local function postBombExplode(_, bomb)
	if bomb:GetSprite():IsPlaying("Explode") then
		Isaac.RunCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, bomb)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, postBombExplode)
