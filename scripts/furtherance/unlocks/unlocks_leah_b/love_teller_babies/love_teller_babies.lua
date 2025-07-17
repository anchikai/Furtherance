--#region Variables

local Mod = Furtherance

local LOVE_TELLER_BABY = {}

Furtherance.Slot.LOVE_TELLER.BABY = LOVE_TELLER_BABY

LOVE_TELLER_BABY.FAMILIAR = Isaac.GetEntityVariantByName("Love Teller Baby")

LOVE_TELLER_BABY.EFFECT_COOLDOWN = 900
LOVE_TELLER_BABY.EFFECT_CHANCE = 0.5
LOVE_TELLER_BABY.PASSIVE_DURATION = 300

---@type {[PlayerType]: {Skin: BabySubType | string, OnUpdate: fun(familiar: EntityFamiliar), OnFire?: fun(tear: EntityTear, familiar: EntityFamiliar)}}
LOVE_TELLER_BABY.PlayerTypeBabies = {
	[PlayerType.PLAYER_ISAAC] = {
		Skin = BabySubType.BABY_BUDDY,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_GUILLOTINE)
		end
	},
	[PlayerType.PLAYER_MAGDALENE] = {
		Skin = BabySubType.BABY_CUTE,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_YUM_HEART)
		end
	},
	[PlayerType.PLAYER_CAIN] = {
		Skin = BabySubType.BABY_PICKY,
		OnUpdate = function()
		end
	},
	[PlayerType.PLAYER_JUDAS] = {
		Skin = BabySubType.BABY_BELIAL,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, true, true)
		end,
		OnFire = function(tear, familiar)
			tear:ChangeVariant(TearVariant.BLOOD)
		end
	},
	[PlayerType.PLAYER_BLUEBABY] = {
		Skin = BabySubType.BABY_HIVE,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_HIVE_MIND)
		end
	},
	[PlayerType.PLAYER_EVE] = {
		Skin = BabySubType.BABY_WHORE,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, true, true)
		end
	},
	[PlayerType.PLAYER_SAMSON] = {
		Skin = BabySubType.BABY_FIGHTING,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_BLOODY_LUST)
		end,
		OnFire = function(tear, familiar)
			tear:ChangeVariant(TearVariant.FIST)
		end
	},
	[PlayerType.PLAYER_AZAZEL] = {
		Skin = BabySubType.BABY_BEGOTTEN,
		OnUpdate = function(familiar)
			local player = familiar.Player
			local effects = player:GetEffects()
			if LOVE_TELLER_BABY:ShouldTriggerEffect(familiar)
				and not effects:HasTrinketEffect(TrinketType.TRINKET_AZAZELS_STUMP)
			then
				effects:AddTrinketEffect(TrinketType.TRINKET_AZAZELS_STUMP)
				Mod:GetData(familiar).GlitchBabySubtype = nil
			end
		end,
		OnFire = function(tear, familiar)
			tear:ChangeVariant(TearVariant.BLOOD)
		end
	},
	[PlayerType.PLAYER_LAZARUS] = {
		Skin = BabySubType.BABY_WRAPPED,
		OnUpdate = function(familiar)
			--The collectible effect is what grants the bleeding effect, however its automatically removed
			--if the player doesn't have Anemic, so grant the item and then on POST_ADD, add the effect
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_ANEMIC)
		end,
		OnFire = function(tear, familiar)
			tear:ChangeVariant(TearVariant.BLOOD)
		end
	},
	[PlayerType.PLAYER_EDEN] = {
		Skin = BabySubType.BABY_GLITCH,
		OnUpdate = function(familiar)
			local data = Mod:GetData(familiar)
			local sprite = familiar:GetSprite()
			if not data.GlitchBabySubtype then
				local availableBabies = {}
				for playerType in ipairs(LOVE_TELLER_BABY.PlayerTypeBabies) do
					if playerType ~= PlayerType.PLAYER_EDEN then
						Mod.Insert(availableBabies, playerType)
					end
				end
				data.GlitchBabySubtype = availableBabies[familiar:GetDropRNG():RandomInt(#availableBabies) + 1]
				LOVE_TELLER_BABY:UpdateBabySkin(familiar, BabySubType.BABY_GLITCH)
				sprite:PlayOverlay("FloatOverlay", true)
				Mod.SFXMan:Play(SoundEffect.SOUND_EDEN_GLITCH)
				familiar.FireCooldown = 30
			end

			if sprite:IsOverlayPlaying() and sprite:GetOverlayFrame() == sprite:GetOverlayAnimationData():GetLength() - 1 then
				sprite:RemoveOverlay()
				LOVE_TELLER_BABY:UpdateBabySkin(familiar, LOVE_TELLER_BABY.PlayerTypeBabies[data.GlitchBabySubtype].Skin)
			end
			if not sprite:IsOverlayPlaying() then
				LOVE_TELLER_BABY.PlayerTypeBabies[data.GlitchBabySubtype].OnUpdate(familiar)
				if data.LoveTellerEffectCooldown then
					data.GlitchBabyWaitSubtype = true
				end
			end
			if data.GlitchBabyWaitSubtype and not data.LoveTellerEffectCooldown then
				data.GlitchBabyWaitSubtype = nil
				data.GlitchBabySubtype = nil
			end
		end,
		OnFire = function(tear, familiar)
			local data = Mod:GetData(familiar)
			if not data.GlitchBabySubtype then return end
			local babyTable = LOVE_TELLER_BABY.PlayerTypeBabies[data.GlitchBabySubtype]
			if babyTable.OnFire then
				babyTable.OnFire(tear, familiar)
			end
		end
	},
	[PlayerType.PLAYER_THELOST] = {
		Skin = BabySubType.BABY_WHITE,
		OnUpdate = function(familiar)
			local data = Mod:GetData(familiar)
			if not data.LostBabyAddedMantle then
				LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_HOLY_MANTLE, true)
			end
		end,
		OnFire = function(tear, familiar)
			tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
		end
	},
	[PlayerType.PLAYER_LILITH] = {
		Skin = BabySubType.BABY_DARK,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
		end,
		OnFire = function(tear, familiar)
			tear:ChangeVariant(TearVariant.BLOOD)
		end
	},
	[PlayerType.PLAYER_KEEPER] = {
		Skin = BabySubType.BABY_SUPER_GREED,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_EYE_OF_GREED)
		end,
		OnFire = function(tear, familiar)
			tear:ChangeVariant(TearVariant.COIN)
		end
	},
	[PlayerType.PLAYER_APOLLYON] = {
		Skin = BabySubType.BABY_APOLLYON,
		OnUpdate = function(familiar)
			local data = Mod:GetData(familiar)
			if LOVE_TELLER_BABY:ShouldTriggerEffect(familiar) then
				data.LoveTellerEffectCooldown = LOVE_TELLER_BABY.EFFECT_COOLDOWN
				Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY,
					Mod:RandomNum(LocustSubtypes.LOCUST_OF_CONQUEST) + 1,
					familiar.Position, Vector.Zero, nil)
			end
		end
	},
	[PlayerType.PLAYER_THEFORGOTTEN] = {
		Skin = BabySubType.BABY_BONE,
		OnUpdate = function(familiar)
			local data = Mod:GetData(familiar)
			if LOVE_TELLER_BABY:ShouldTriggerEffect(familiar) then
				data.LoveTellerEffectCooldown = LOVE_TELLER_BABY.EFFECT_COOLDOWN
				familiar:SetColor(Color(1, 1, 1, 1, 0.5, 0.75, 1), 15, 1, true, true)
				Mod:GetData(familiar).LoveTellerExtra = nil
				familiar.SubType = 17
				LOVE_TELLER_BABY:UpdateBabySkin(familiar, BabySubType.BABY_BOUND)
			end
		end,
		OnFire = function(tear, familiar)
			tear:ChangeVariant(TearVariant.BONE)
			tear:AddTearFlags(TearFlags.TEAR_BONE)
		end
	},
	[PlayerType.PLAYER_THESOUL] = {
		Skin = BabySubType.BABY_BOUND,
		OnUpdate = function(familiar)
			local data = Mod:GetData(familiar)
			if LOVE_TELLER_BABY:ShouldTriggerEffect(familiar) then
				data.LoveTellerEffectCooldown = LOVE_TELLER_BABY.EFFECT_COOLDOWN
				familiar:SetColor(Color(1, 1, 1, 1, 0.5, 0.75, 1), 15, 1, true, true)
				Mod:GetData(familiar).LoveTellerExtra = nil
				familiar.SubType = 16
				LOVE_TELLER_BABY:UpdateBabySkin(familiar, BabySubType.BABY_BONE)
			end
		end,
		OnFire = function(tear, familiar)
			local player = familiar.Player
			local c = player:GetColor()
			local cz = player:GetColor():GetColorize()

			tear:SetColor(Color(c.R, c.G, c.B, 0.5, c.RO, c.GO, c.BO, cz.R, cz.G, cz.B, cz.A), -1, 1, false, true)
			tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
			Mod:DelayOneFrame(function ()
				familiar.FireCooldown = familiar.FireCooldown - 5
			end)
		end
	},
	[PlayerType.PLAYER_BETHANY] = {
		Skin = BabySubType.BABY_GLOWING,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
		end
	},
	[PlayerType.PLAYER_JACOB] = {
		Skin = BabySubType.BABY_SOLOMON_A,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_FRIEND_FINDER)
		end
	},
	[PlayerType.PLAYER_ESAU] = {
		Skin = BabySubType.BABY_SOLOMON_B,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, CollectibleType.COLLECTIBLE_RED_STEW)
		end,
		OnFire = function(tear, familiar)
			tear:ChangeVariant(TearVariant.BLOOD)
		end
	},
	[Mod.PlayerType.LEAH] = {
		Skin = BabySubType.BABY_LOVE,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, Mod.Item.HEART_RENOVATOR.ID)
		end
	},
	[Mod.PlayerType.PETER] = {
		Skin = BabySubType.BABY_PSY,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, Mod.Item.KEYS_TO_THE_KINGDOM.ID)
		end
	},
	[Mod.PlayerType.MIRIAM] = {
		Skin = BabySubType.BABY_WATER,
		OnUpdate = function(familiar)
			LOVE_TELLER_BABY:GrantCollectible(familiar, Mod.Item.TAMBOURINE.ID)
		end
	}
}

--#endregion

--#region Extra baby-specific handling

local specialLoadList = {
	"cain",
	"esau",
	"lazarus",
	"peter",
	"samson",
	"the_lost"
}

Mod.LoopInclude(specialLoadList, "scripts.furtherance.unlocks.unlocks_leah_b.love_teller_babies.players")

--#endregion

--#region Handle collectible effects

---@param familiar EntityFamiliar
function LOVE_TELLER_BABY:ShouldTriggerEffect(familiar)
	local data = Mod:GetData(familiar)
	return familiar.FrameCount % 30 == 0
		and familiar:GetDropRNG():RandomFloat() <= LOVE_TELLER_BABY.EFFECT_CHANCE
		and not data.LoveTellerEffectCooldown
		and not Mod.Room():IsClear()
end

---@param familiar EntityFamiliar
---@param itemID CollectibleType
---@param isEffect? boolean
---@param delayNextRoom? boolean
function LOVE_TELLER_BABY:GrantCollectible(familiar, itemID, isEffect, delayNextRoom)
	local player = familiar.Player
	local data = Mod:GetData(familiar)
	local subtype = data.GlitchBabySubtype or familiar.SubType

	if LOVE_TELLER_BABY:ShouldTriggerEffect(familiar) then
		data.LoveTellerEffectCooldown = LOVE_TELLER_BABY.EFFECT_COOLDOWN
		local item = Mod.ItemConfig:GetCollectible(itemID)
		local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.PRE_LOVE_TELLER_BABY_ADD_COLLECTIBLE, subtype,
			familiar, itemID, isEffect)

		if not result then
			if delayNextRoom then
				data.LoveTellerWaitNextRoom = true
			end
			if item.Type == ItemType.ITEM_ACTIVE then
				player:UseActiveItem(itemID, UseFlag.USE_NOANIM)
			else
				if isEffect then
					player:AddCollectibleEffect(itemID, true)
				else
					local pData = Mod:GetData(player)
					pData.LoveTellerAddedInnates = pData.LoveTellerAddedInnates or {}
					pData.LoveTellerAddedInnates[itemID] = (pData.LoveTellerAddedInnates[itemID] or 0) + 1
					player:AddInnateCollectible(itemID)
				end
				data.LoveTellerPassiveCountdown = LOVE_TELLER_BABY.PASSIVE_DURATION
				Isaac.RunCallbackWithParam(Mod.ModCallbacks.POST_LOVE_TELLER_BABY_ADD_COLLECTIBLE, subtype,
					familiar, itemID, isEffect)
			end
		end
	end
	if (data.LoveTellerPassiveCountdown or 0) > 0 then
		data.LoveTellerPassiveCountdown = data.LoveTellerPassiveCountdown - 1
	elseif data.LoveTellerPassiveCountdown then
		local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.PRE_LOVE_TELLER_BABY_REMOVE_COLLECTIBLE, subtype,
			familiar, itemID, isEffect)
		if not result then
			if isEffect then
				player:GetEffects():RemoveCollectibleEffect(itemID)
			else
				local pData = Mod:GetData(player)
				pData.LoveTellerAddedInnates = pData.LoveTellerAddedInnates or {}
				pData.LoveTellerAddedInnates[itemID] = (pData.LoveTellerAddedInnates[itemID] or 0) - 1
				player:AddInnateCollectible(itemID, -1)
			end
			if not player:HasCollectible(itemID, true) then
				player:RemoveCostume(Mod.ItemConfig:GetCollectible(itemID))
			end
			Isaac.RunCallbackWithParam(Mod.ModCallbacks.POST_LOVE_TELLER_BABY_REMOVE_COLLECTIBLE, subtype,
				familiar, itemID, isEffect)
		end
		data.LoveTellerPassiveCountdown = nil
	end
end

function LOVE_TELLER_BABY:RemoveActiveItemWait()
	Mod.Foreach.Familiar(function(familiar, index)
		local data = Mod:GetData(familiar)
		data.LoveTellerWaitNextRoom = nil
	end, LOVE_TELLER_BABY.FAMILIAR)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LOVE_TELLER_BABY.RemoveActiveItemWait)

---@param ent Entity
function LOVE_TELLER_BABY:EmergencyRemoveItem(ent)
	local familiar = ent:ToFamiliar()
	if not familiar or familiar.Variant ~= LOVE_TELLER_BABY.FAMILIAR then return end
	local player = familiar.Player
	local data = Mod:GetData(player)
	local fData = Mod:GetData(familiar)

	for itemID, num in pairs((data.LoveTellerAddedInnates or {})) do
		if num > 0 and not player:HasCollectible(itemID, true, true) then
			local babyTable = LOVE_TELLER_BABY.PlayerTypeBabies[familiar.SubType]
			if fData.LoveTellerPassiveCountdown > 0 then
				fData.LoveTellerPassiveCountdown = 0
				babyTable.OnUpdate(familiar)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, LOVE_TELLER_BABY.EmergencyRemoveItem, EntityType.ENTITY_FAMILIAR)

function LOVE_TELLER_BABY:EmergencyRemoveCostumePlayer()
	Mod.Foreach.Player(function(player)
		if not player then return end
		local data = Mod:GetData(player)

		for itemID, num in pairs((data.LoveTellerAddedInnates or {})) do
			if num > 0 and not player:HasCollectible(itemID, true, true) then
				player:RemoveCostume(Mod.ItemConfig:GetCollectible(itemID))
			end
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, LOVE_TELLER_BABY.EmergencyRemoveCostumePlayer)

--#endregion

--#region Helpers

---@param familiar EntityFamiliar
function LOVE_TELLER_BABY:UpdateBabySkin(familiar, babySubType)
	babySubType = babySubType or LOVE_TELLER_BABY.PlayerTypeBabies[familiar.SubType].Skin
	local spritePath = "gfx/characters/players2/466_baby_blindcursed.png"
	if type(babySubType) == "string" then
		spritePath = babySubType
	else
		local skin = EntityConfig.GetBaby(babySubType)
		if skin then
			spritePath = skin:GetSpritesheetPath()
		end
	end
	familiar:GetSprite():ReplaceSpritesheet(0, spritePath, true)
end

---@param familiar EntityFamiliar
---@param subtype integer
function LOVE_TELLER_BABY:IsSubtype(familiar, subtype)
	return familiar.SubType == subtype or (Mod:GetData(familiar).GlitchBabySubtype or -1) == subtype
end

--#endregion

--#region On fire

---@param tear EntityTear
function LOVE_TELLER_BABY:ForgorTears(tear)
	local familiar = tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar()
	if not familiar then return end
	local babyTable = LOVE_TELLER_BABY.PlayerTypeBabies[familiar.SubType]
	if babyTable.OnFire then
		babyTable.OnFire(tear, familiar)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, LOVE_TELLER_BABY.ForgorTears, LOVE_TELLER_BABY.FAMILIAR)

--#endregion

--#region Extra animation

function LOVE_TELLER_BABY:RenderDebug(familiar)
	local p = Isaac.WorldToScreen(familiar.Position)
	local data = Mod:GetData(familiar)
	local x = p.X + 7
	Isaac.RenderText(familiar.SubType, p.X - 2.5, p.Y - 35, 1, 1, 1, 1)
	Isaac.RenderScaledText("Effect cooldown: " .. (data.LoveTellerEffectCooldown or "N/A"), x, p.Y - 30, 0.5, 0.5, 1, 1,
		1, 1)
	Isaac.RenderScaledText("Passive countdown: " .. (data.LoveTellerPassiveCountdown or "N/A"), x, p.Y - 25, 0.5, 0.5, 1,
		1, 1, 1)
	Isaac.RenderScaledText("ActiveHold: " .. (data.LoveTellerWaitNextRoom or "N/A"), x, p.Y - 20, 0.5, 0.5, 1, 1,
		1, 1)
	if familiar.SubType == PlayerType.PLAYER_EDEN then
		Isaac.RenderScaledText("Glitch Subtype: " .. (data.GlitchBabySubtype or "N/A"), x, p.Y - 15, 0.5, 0.5, 1, 1, 1, 1)
	end
end

--Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, LOVE_TELLER_BABY.RenderDebug)

---@param familiar EntityFamiliar
---@param offset Vector
function LOVE_TELLER_BABY:PreRender(familiar, offset)
	if familiar.SubType == PlayerType.PLAYER_EDEN then return end
	local data = Mod:GetData(familiar)
	local sprite = familiar:GetSprite()

	if not data.LoveTellerExtra then
		data.LoveTellerExtra = Sprite(sprite:GetFilename(), true)
		data.LoveTellerExtra:Play("FloatOverlay")
		data.LoveTellerExtra:ReplaceSpritesheet(0, sprite:GetLayer(0):GetSpritesheetPath(), true)
	end
	local renderPos = Isaac.WorldToScreen(familiar.Position + familiar.PositionOffset)
	if Mod.Room():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
		renderPos = Isaac.WorldToRenderPosition(familiar.Position + familiar.PositionOffset) + offset
	end
	for key, value in pairs(getmetatable(sprite).__propget) do
		data.LoveTellerExtra[key] = value(sprite)
	end
	data.LoveTellerExtra:Render(renderPos)
	if Mod:ShouldUpdateSprite() then
		data.LoveTellerExtra:Update()
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, LOVE_TELLER_BABY.PreRender, LOVE_TELLER_BABY.FAMILIAR)

--#endregion

--#region Core familiar stuff

---@param familiar EntityFamiliar
function LOVE_TELLER_BABY:OnFamiliarInit(familiar)
	familiar:AddToFollowers()
	LOVE_TELLER_BABY:UpdateBabySkin(familiar)
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, LOVE_TELLER_BABY.OnFamiliarInit, LOVE_TELLER_BABY.FAMILIAR)

---@param player EntityPlayer
function LOVE_TELLER_BABY:OnFamiliarCache(player)
	local subtypes = Mod:RunSave(player).LoveTellerBabies
	if not subtypes then return end
	local extraBabies = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
	for subtype, count in pairs(subtypes) do
		local familiars = player:CheckFamiliarEx(LOVE_TELLER_BABY.FAMILIAR, count + extraBabies, Mod.GENERIC_RNG, nil,
			tonumber(subtype))
		for _, familiar in ipairs(familiars) do
			LOVE_TELLER_BABY:UpdateBabySkin(familiar)
		end
	end
	Mod.Foreach.Familiar(function (familiar, index)
		if not subtypes[tostring(familiar.SubType)] then
			familiar:Remove()
		end
	end, LOVE_TELLER_BABY.FAMILIAR, nil, {Inverse = true})
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LOVE_TELLER_BABY.OnFamiliarCache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
function LOVE_TELLER_BABY:ShooterPriority(familiar)
	return FollowerPriority.SHOOTER
end

Mod:AddCallback(ModCallbacks.MC_GET_FOLLOWER_PRIORITY, LOVE_TELLER_BABY.ShooterPriority, LOVE_TELLER_BABY.FAMILIAR)

---@param familiar EntityFamiliar
function LOVE_TELLER_BABY:OnFamiliarUpdate(familiar)
	local sprite = familiar:GetSprite()
	local data = Mod:GetData(familiar)
	local babyInfo = LOVE_TELLER_BABY.PlayerTypeBabies[familiar.SubType]

	if babyInfo and not data.LoveTellerWaitNextRoom then
		babyInfo.OnUpdate(familiar)
	end

	if (data.LoveTellerEffectCooldown or 0) > 0 then
		data.LoveTellerEffectCooldown = data.LoveTellerEffectCooldown - 1
	elseif data.LoveTellerEffectCooldown then
		data.LoveTellerEffectCooldown = nil
	end

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

--#endregion
