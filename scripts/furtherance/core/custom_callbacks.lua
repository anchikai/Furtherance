local Mod = Furtherance

Furtherance.ModCallbacks = {
	---() - Called when the Muddled Cross flip shader is flipping from one side to the other
	PETER_B_ENEMY_ROOM_FLIP = "FURTHERANCE_PETER_B_ENEMY_ROOM_FLIP",

	---(EntityBomb Bomb) - Called when a bomb explodes
	POST_BOMB_EXPLODE = "FURTHERANCE_POST_BOMB_EXPLODE",

	---(EntityBomb Bomb) - Called when an Epic Fetus rocket explodes
	POST_ROCKET_EXPLODE = "FURTHERANCE_POST_ROCKET_EXPLODE",

	--(), Optional Arg: RoomType - Called when a special room is being flipped. Providing a RoomType argument will have it only run for the current room's type
	MUDDLED_CROSS_ROOM_FLIP = "FURTHERANCE_MUDDLED_CROSS_ROOM_FLIP",

	--(RoomType oldRoomType), Optional Arg: RoomType - Called after a special room is flipped. Providing a RoomType argument will have it only run for the new room's type
	POST_MUDDLED_CROSS_ROOM_FLIP = "FURTHERANCE_POST_MUDDLED_CROSS_ROOM_FLIP",

	--(), Optional Arg: RoomType - Called when Muddled Cross' puddle effect needs to get a backdrop. Providing a RoomType argument will have it only run for the current room's type
	GET_MUDDLED_CROSS_PUDDLE_BACKDROP = "FURTHERANCE_GET_MUDDLED_CROSS_PUDDLE_BACKDROP",

	--(EntityNPC npc, EntityPlayer player, RNG collectibleRNG, UseFlag flags, ActiveSlot slot): boolean, Optional Arg: EntityType - Called when initiating the rapture process from Keys to the Kingdom on a boss enemy. Return `true` to stop the usual process from initiating
	PRE_START_RAPTURE_BOSS = "FURTHERANCE_PRE_START_RAPTURE_BOSS",

	--(EntityNPC npc), Optional Arg: EntityType - Called after the "death" of a boss raptured by Keys to the Kingdom
	POST_RAPTURE_BOSS_DEATH = "FURTHERANCE_POST_RAPTURE_BOSS_DEATH",

	---() - Return `true` if the current room should be considered similarly to story boss rooms for Keys to the Kingdom, where it grants a Holy Mantle effect instead of rapturing any enemies or bosses
	KTTK_GRANT_HOLY_MANTLE = "FURTHERANCE_KTTK_GRANT_HOLY_MANTLE",

	--(EntityPickup pickup): boolean, OptionalArg: HeartSubType - Called when Shattered Heart wants to explode a heart pickup. Return `true` to stop the heart from exploding
	SHATTERED_HEART_EXPLODE = "FURTHERANCE_SHATTERED_HEART_EXPLODE",

	PRE_LOVE_TELLER_BABY_ADD_EFFECT = "FURTHERANCE_PRE_LOVE_TELLER_BABY_ADD_EFFECT",

	POST_LOVE_TELLER_BABY_ADD_EFFECT = "FURTHERANCE_PRE_LOVE_TELLER_BABY_ADD_EFFECT",

	PRE_LOVE_TELLER_BABY_REMOVE_EFFECT = "FURTHERANCE_PRE_LOVE_TELLER_BABY_REMOVE_EFFECT",

	POST_LOVE_TELLER_BABY_REMOVE_EFFECT = "FURTHERANCE_PRE_LOVE_TELLER_BABY_REMOVE_EFFECT",

	HOLY_HEART_GET_MANTLE_CHANCE = "FURTHERANCE_HOLY_HEART_GET_MANTLE_CHANCE"
}

local function postBombExplode(_, bomb)
	if bomb:GetSprite():IsPlaying("Explode") then
		Isaac.RunCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, bomb)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, postBombExplode)

local function postEpicFetusExplode(_, effect)
	if effect.Variant == EffectVariant.ROCKET and effect.PositionOffset.Y == 0 then
		Isaac.RunCallback(Mod.ModCallbacks.POST_ROCKET_EXPLODE, effect:ToEffect())
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, postEpicFetusExplode, EntityType.ENTITY_EFFECT)
