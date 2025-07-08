local Mod = Furtherance

Furtherance.ModCallbacks = {
	CAN_COLLECT_HEART = "FURTHERANCE_CAN_COLLECT_HEART",

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

	--(EntityNPC npc), Optional Arg: EntityType - Before :Kill() is called for the boss. Return `true` to cancel this. Primarily used for Great Gideon
	PRE_RAPTURE_BOSS_KILL = "FURTHERANCE_PRE_RAPTURE_BOSS_KILL",

	--(EntityNPC npc), Optional Arg: EntityType - When a boss is raptured, :Kill() is called onto it and the code attempts to force its death animation to the end. This is called after these steps
	POST_RAPTURE_BOSS_KILL = "FURTHERANCE_POST_RAPTURE_BOSS_KILL",

	--(EntityNPC npc), Optional Arg: EntityType - Called after the "death" of a boss raptured by Keys to the Kingdom
	POST_RAPTURE_BOSS_DEATH = "FURTHERANCE_POST_RAPTURE_BOSS_DEATH",

	---() - Return `true` if the current room should be considered similarly to story boss rooms for Keys to the Kingdom, where it grants a Holy Mantle effect instead of rapturing any enemies or bosses
	KTTK_GRANT_HOLY_MANTLE = "FURTHERANCE_KTTK_GRANT_HOLY_MANTLE",

	---(EntityNPC npc): boolean - Optional Arg: EntityType - Called when Keys to the Kingdom attempts to spare an enemy. Return `true` to bypass the normal checks and allow sparing or `false` to stop sparing
	KTTK_CAN_SPARE = "FURTHERANCE_CAN_SPARE",

	--(EntityPickup pickup): boolean, OptionalArg: HeartSubType - Called when Shattered Heart wants to explode a heart pickup. Return `true` to stop the heart from exploding
	SHATTERED_HEART_EXPLODE = "FURTHERANCE_SHATTERED_HEART_EXPLODE",

	--(EntityFamiliar familiar, CollectibleType itemID, boolean isEffect): boolean, Optional Arg: PlayerType - Called before a Love Teller Baby adds a set CollectibleType to the player for a set amount of time. Return `true` to cancel adding the effect. This will still trigger the cooldown until they can roll to trigger the collectible again
	-- - `familiar` - The familiar adding the item
	-- - `itemID` - The CollectibleType being added to the player
	-- - `isEffect` - `false` if it's an innate item. `true` if it's a CollectibleEffect
	-- - OptionalArg - Corresponds to the SubType of the familiar, which matches the PlayerType of the character it represents
	PRE_LOVE_TELLER_BABY_ADD_COLLECTIBLE = "FURTHERANCE_PRE_LOVE_TELLER_BABY_ADD_COLLECTIBLE",


	--(EntityFamiliar familiar, CollectibleType itemID, boolean isEffect), Optional Arg: PlayerType - Called after a Love Teller Baby adds a set CollectibleType to the player for a set amount of time
	-- - `familiar` - The familiar adding the item
	-- - `itemID` - The CollectibleType added to the player
	-- - `isEffect` - `false` if it's an innate item. `true` if it's a CollectibleEffect
	-- - OptionalArg - Corresponds to the SubType of the familiar, which matches the PlayerType of the character it represents
	POST_LOVE_TELLER_BABY_ADD_COLLECTIBLE = "FURTHERANCE_PRE_LOVE_TELLER_BABY_ADD_COLLECTIBLE",


	--(EntityFamiliar familiar, CollectibleType itemID, boolean isEffect): boolean, Optional Arg: PlayerType - Called before a Love Teller Baby removes its previously added CollectibleType from the player. Return `true` to cancel removing the effect. This is only allowed due to the nature of The Lost's baby, which grants a mantle that isn't removed until it's broken
	-- - `familiar` - The familiar adding the item
	-- - `itemID` - The CollectibleType being removed from the player
	-- - `isEffect` - `false` if it's an innate item. `true` if it's a CollectibleEffect
	-- - OptionalArg - Corresponds to the SubType of the familiar, which matches the PlayerType of the character it represents
	PRE_LOVE_TELLER_BABY_REMOVE_COLLECTIBLE = "FURTHERANCE_PRE_LOVE_TELLER_BABY_REMOVE_COLLECTIBLE",

	--(EntityFamiliar familiar, CollectibleType itemID, boolean isEffect): boolean, Optional Arg: PlayerType - Called after a Love Teller Baby removes its previously added CollectibleType from the player
	-- - `familiar` - The familiar adding the item
	-- - `itemID` - The CollectibleType removed from the player
	-- - `isEffect` - `false` if it's an innate item. `true` if it's a CollectibleEffect
	-- - OptionalArg - Corresponds to the SubType of the familiar, which matches the PlayerType of the character it represents
	POST_LOVE_TELLER_BABY_REMOVE_COLLECTIBLE = "FURTHERANCE_PRE_LOVE_TELLER_BABY_REMOVE_COLLECTIBLE",

	--(EntityPickup pickup, EntityPlayer player, number chance): number, Optional Arg: HeartSubType - Called when getting the chance of activating Holy Heart's mantle effect when collecting a registered black, soul, or eternal heart. Return a number to override the chance
	HOLY_HEART_GET_MANTLE_CHANCE = "FURTHERANCE_HOLY_HEART_GET_MANTLE_CHANCE",

	--(EntityPickup pickup): boolean, OptionalArg: PickupVariant - Called when Astragali attempts to select a chest to reroll. Return `true` to force a reroll, `false` to prevent it from being rerolled.
	ASTRAGALI_PRE_SELECT_CHEST = "FURTHERANCE_ASTRAGALI_PRE_SELECT_CHEST",

	--(EntityPickup pickup, PickupVariant selectedVariant): {ID, Var, SubType}, OptionalArg: PickupVariant - Called before Astragali rerolls the selected pickup into a new chest
	-- - `pickup` - The pickup being rerolled.
	-- - `selectedVariant` - The entity variant selected to reroll the pickup into
	-- - Optional Arg - Corresponds to the `selectedVariant`
	ASTRAGALI_PRE_REROLL_CHEST = "FURTHERANCE_ASTRAGALI_PRE_REROLL_CHEST",
}

local function postBombExplode(_, bomb)
	if bomb:GetSprite():IsPlaying("Explode") then
		Isaac.RunCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, bomb)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, postBombExplode)

---@param effect EntityEffect
local function bombExplosionBestFriend(_, effect)
	if effect.SpawnerEntity and effect.SpawnerType == EntityType.ENTITY_BOMB and effect.SpawnerVariant == BombVariant.BOMB_DECOY then
		Isaac.RunCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, effect.SpawnerEntity)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, bombExplosionBestFriend, EffectVariant.BOMB_EXPLOSION)

local function postEpicFetusExplode(_, effect)
	if effect.Variant == EffectVariant.ROCKET and effect.PositionOffset.Y == 0 then
		Isaac.RunCallback(Mod.ModCallbacks.POST_ROCKET_EXPLODE, effect:ToEffect())
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, postEpicFetusExplode, EntityType.ENTITY_EFFECT)
