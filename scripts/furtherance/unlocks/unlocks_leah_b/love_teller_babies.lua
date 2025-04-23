local Mod = Furtherance

local LOVE_TELLER_BABY = {}

Furtherance.Slot.LOVE_TELLER.BABY = LOVE_TELLER_BABY

LOVE_TELLER_BABY.FAMILIAR = Isaac.GetEntityVariantByName("Love Teller Baby")

---@type {[PlayerType]: {Skin: BabySubType, OnUpdate: fun(familiar: EntityFamiliar)}}
LOVE_TELLER_BABY.PlayerTypeBabies = {
	[PlayerType.PLAYER_ISAAC] = {
		Skin = BabySubType.BABY_BUDDY,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_MAGDALENE] = {
		Skin = BabySubType.BABY_CUTE,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_CAIN] = {
		Skin = BabySubType.BABY_PICKY,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_JUDAS] = {
		Skin = BabySubType.BABY_BELIAL,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_BLUEBABY] = {
		Skin = BabySubType.BABY_HIVE,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_EVE] = {
		Skin = BabySubType.BABY_WHORE,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_SAMSON] = {
		Skin = BabySubType.BABY_FIGHTING,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_AZAZEL] = {
		Skin = BabySubType.BABY_BEGOTTEN,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_LAZARUS] = {
		Skin = BabySubType.BABY_WRAPPED,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_EDEN] = {
		Skin = BabySubType.BABY_GLITCH,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_THELOST] = {
		Skin = BabySubType.BABY_WHITE,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_LILITH] = {
		Skin = BabySubType.BABY_DARK,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_KEEPER] = {
		Skin = BabySubType.BABY_SUPER_GREED,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_APOLLYON] = {
		Skin = BabySubType.BABY_APOLLYON,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_THEFORGOTTEN] = {
		Skin = BabySubType.BABY_BONE,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_THESOUL] = {
		Skin = BabySubType.BABY_BOUND,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_BETHANY] = {
		Skin = BabySubType.BABY_GLOWING,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_JACOB] = {
		Skin = BabySubType.BABY_SOLOMON_A,
		OnUpdate = function(familiar)

		end
	},
	[PlayerType.PLAYER_ESAU] = {
		Skin = BabySubType.BABY_SOLOMON_B,
		OnUpdate = function(familiar)

		end
	},
	[Mod.PlayerType.LEAH] = {
		Skin = BabySubType.BABY_LOVE,
		OnUpdate = function(familiar)

		end
	},
	[Mod.PlayerType.PETER] = {
		Skin = BabySubType.BABY_PSY,
		OnUpdate = function(familiar)

		end
	},
	[Mod.PlayerType.MIRIAM] = {
		Skin = BabySubType.BABY_WATER,
		OnUpdate = function(familiar)

		end
	}
}

---@param familiar EntityFamiliar
function LOVE_TELLER_BABY:UpdateBabySkin(familiar)
	local skin = EntityConfig.GetBaby(LOVE_TELLER_BABY.PlayerTypeBabies[familiar.SubType].Skin):GetSpritesheetPath()
	familiar:GetSprite():ReplaceSpritesheet(0, skin, true)
end

---@param player EntityPlayer
function LOVE_TELLER_BABY:OnFamiliarCache(player)
	local extraBabies = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
	local subtypes = Mod:RunSave(player).LoveTellerBabies
	for subtype, count in pairs(subtypes or {}) do
		local familiars = player:CheckFamiliarEx(LOVE_TELLER_BABY.FAMILIAR, count + extraBabies, Mod.GENERIC_RNG, nil, tonumber(subtype))
		for _, familiar in ipairs(familiars) do
			LOVE_TELLER_BABY:UpdateBabySkin(familiar)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LOVE_TELLER_BABY.OnFamiliarCache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
function LOVE_TELLER_BABY:OnFamiliarInit(familiar)
	familiar:AddToFollowers()
	familiar:GetSprite():PlayOverlay("FloatOverlay")
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LOVE_TELLER_BABY.OnFamiliarInit, LOVE_TELLER_BABY.FAMILIAR)

---@param familiar EntityFamiliar
function LOVE_TELLER_BABY:ShooterPriority(familiar)
	return FollowerPriority.SHOOTER
end

Mod:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, LOVE_TELLER_BABY.ShooterPriority, LOVE_TELLER_BABY.FAMILIAR)

---@param familiar EntityFamiliar
function LOVE_TELLER_BABY:OnFamiliarUpdate(familiar)
	local sprite = familiar:GetSprite()
	local data = Mod:GetData(familiar)

	--Handles absolutely everything akin to a generic Brother Bobbby-like familiar
	familiar:Shoot()
	if familiar.FlipX then
		--As this follows base shooter familiar logic, it will be constantly trying to force FlipX and Side animation
		--Override this behavior while its active and manually increment current frame
		familiar.FlipX = false
		sprite:SetAnimation(string.gsub(sprite:GetAnimation(), "Side", "Side2"), false)
		if not data.ForceSide2Frame then
			data.ForceSide2Frame = sprite:GetFrame()
		end
		local nextFrame = data.ForceSide2Frame + 1
		data.ForceSide2Frame = nextFrame
		nextFrame = nextFrame == 16 and 0 or nextFrame
		sprite:SetFrame(nextFrame)
		data.ForceSide2Frame = nextFrame
	elseif data.ForceSide2Frame then
		data.ForceSide2Frame = nil
	end
	familiar:FollowParent()
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, LOVE_TELLER_BABY.OnFamiliarUpdate, LOVE_TELLER_BABY.FAMILIAR)
