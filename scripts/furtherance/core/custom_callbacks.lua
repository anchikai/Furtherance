local Mod = Furtherance

Furtherance.ModCallbacks = {
	---() - Called when the Muddled Cross flip shader is flipping from one side to the other
	PETER_B_ENEMY_ROOM_FLIP = "FURTHERANCE_TRIGGER_PETER_B_ENEMY_ROOM_FLIP",

	---(EntityBomb Bomb) - Called
	POST_BOMB_EXPLODE = "FURTHERANCE_POST_BOMB_EXPLODE"
}

local function postBombExplode(_, bomb)
	if bomb:GetSprite():IsPlaying("Explode") then
		Isaac.RunCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, bomb)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, postBombExplode)