local Mod = Furtherance

local LOVE_TELLER = {}

Furtherance.Slot.LOVE_TELLER = LOVE_TELLER

LOVE_TELLER.ID = Isaac.GetEntityVariantByName("Love Teller")
LOVE_TELLER.GOOD_COMPAT_CHANCE = 0.5
LOVE_TELLER.TRUE_LOVE_COMPAT_CHANCE = 0.15

LOVE_TELLER.ParentPlayerTypes = {
	[PlayerType.PLAYER_BLACKJUDAS] = PlayerType.PLAYER_JUDAS,
	[PlayerType.PLAYER_LAZARUS2] = PlayerType.PLAYER_LAZARUS,
	[PlayerType.PLAYER_THESOUL] = PlayerType.PLAYER_THEFORGOTTEN
}

local overlaySprite = Sprite("gfx/slot_love_teller.anm2", true)
overlaySprite:Play("OverlayIcons")

LOVE_TELLER.Matchmaking = {
	[PlayerType.PLAYER_ISAAC] = {
		TrueLove = PlayerType.PLAYER_BETHANY,
		Compatible = {PlayerType.PLAYER_JACOB, PlayerType.PLAYER_ESAU, Mod.PlayerType.LEAH}
	},
	[PlayerType.PLAYER_MAGDALENE] = {
		TrueLove = Mod.PlayerType.PETER,
		Compatible = {PlayerType.PLAYER_JUDAS, PlayerType.PLAYER_LAZARUS, PlayerType.PLAYER_BETHANY}
	},
	[PlayerType.PLAYER_CAIN] = {
		TrueLove = PlayerType.PLAYER_EVE,
		Compatible = {PlayerType.PLAYER_AZAZEL, PlayerType.PLAYER_EDEN, PlayerType.PLAYER_LILITH}
	},
	[PlayerType.PLAYER_JUDAS] = {
		TrueLove = PlayerType.PLAYER_LAZARUS,
		Compatible = {PlayerType.PLAYER_MAGDALENE, PlayerType.PLAYER_BETHANY, Mod.PlayerType.PETER}
	},
	[PlayerType.PLAYER_BLUEBABY] = {
		TrueLove = PlayerType.PLAYER_THELOST,
		Compatible = {PlayerType.PLAYER_KEEPER, PlayerType.PLAYER_APOLLYON, PlayerType.PLAYER_THEFORGOTTEN}
	},
	[PlayerType.PLAYER_EVE] = {
		TrueLove = PlayerType.PLAYER_CAIN,
		Compatible = {PlayerType.PLAYER_AZAZEL, PlayerType.PLAYER_EDEN, PlayerType.PLAYER_LILITH}
	},
	[PlayerType.PLAYER_SAMSON] = {
		TrueLove = Mod.PlayerType.MIRIAM,
		Compatible = {PlayerType.PLAYER_JACOB, PlayerType.PLAYER_ESAU, Mod.PlayerType.LEAH}
	},
	[PlayerType.PLAYER_AZAZEL] = {
		TrueLove = PlayerType.PLAYER_LILITH,
		Compatible = {PlayerType.PLAYER_CAIN, PlayerType.PLAYER_EVE, PlayerType.PLAYER_EDEN}
	},
	[PlayerType.PLAYER_LAZARUS] = {
		TrueLove = PlayerType.PLAYER_JUDAS,
		Compatible = {PlayerType.PLAYER_MAGDALENE, PlayerType.PLAYER_BETHANY, Mod.PlayerType.PETER}
	},
	[PlayerType.PLAYER_EDEN] = {
		TrueLove = PlayerType.PLAYER_EDEN,
		Compatible = {PlayerType.PLAYER_ISAAC, PlayerType.PLAYER_BLUEBABY, PlayerType.PLAYER_THEFORGOTTEN}
	},
	[PlayerType.PLAYER_THELOST] = {
		TrueLove = PlayerType.PLAYER_BLUEBABY,
		Compatible = {PlayerType.PLAYER_APOLLYON, PlayerType.PLAYER_THEFORGOTTEN, PlayerType.PLAYER_KEEPER}
	},
	[PlayerType.PLAYER_LILITH] = {
		TrueLove = PlayerType.PLAYER_AZAZEL,
		Compatible = {PlayerType.PLAYER_CAIN, PlayerType.PLAYER_EVE, PlayerType.PLAYER_EDEN}
	},
	[PlayerType.PLAYER_KEEPER] = {
		TrueLove = PlayerType.PLAYER_APOLLYON,
		Compatible = {PlayerType.PLAYER_BLUEBABY, PlayerType.PLAYER_THELOST, PlayerType.PLAYER_THEFORGOTTEN}
	},
	[PlayerType.PLAYER_APOLLYON] = {
		TrueLove = PlayerType.PLAYER_KEEPER,
		Compatible = {PlayerType.PLAYER_BLUEBABY, PlayerType.PLAYER_THELOST, PlayerType.PLAYER_THEFORGOTTEN}
	},
	[PlayerType.PLAYER_THEFORGOTTEN] = {
		TrueLove = PlayerType.PLAYER_ESAU,
		Compatible = {PlayerType.PLAYER_SAMSON, PlayerType.PLAYER_BETHANY, PlayerType.PLAYER_JACOB}
	},
	[PlayerType.PLAYER_BETHANY] = {
		TrueLove = PlayerType.PLAYER_ISAAC,
		Compatible = {PlayerType.PLAYER_JACOB, PlayerType.PLAYER_ESAU, Mod.PlayerType.LEAH}
	},
	[PlayerType.PLAYER_JACOB] = {
		TrueLove = Mod.PlayerType.LEAH,
		Compatible = {PlayerType.PLAYER_SAMSON, PlayerType.PLAYER_BETHANY, PlayerType.PLAYER_ESAU}
	},
	[PlayerType.PLAYER_ESAU] = {
		TrueLove = PlayerType.PLAYER_THEFORGOTTEN,
		Compatible = {PlayerType.PLAYER_SAMSON, PlayerType.PLAYER_BETHANY,PlayerType.PLAYER_JACOB}
	},
	[Mod.PlayerType.LEAH] = {
		TrueLove = PlayerType.PLAYER_JACOB,
		Compatible = {PlayerType.PLAYER_SAMSON, PlayerType.PLAYER_BETHANY,PlayerType.PLAYER_ESAU}
	},
	[Mod.PlayerType.PETER] = {
		TrueLove = PlayerType.PLAYER_MAGDALENE,
		Compatible = {PlayerType.PLAYER_JUDAS, PlayerType.PLAYER_LAZARUS,PlayerType.PLAYER_BETHANY}
	},
	[Mod.PlayerType.MIRIAM] = {
		TrueLove = PlayerType.PLAYER_SAMSON,
		Compatible = {PlayerType.PLAYER_ISAAC, PlayerType.PLAYER_JACOB, Mod.PlayerType.LEAH}
	},
}

Mod.Include("scripts.furtherance.unlocks.unlocks_leah_b.love_teller_babies")

local function unknownCoopIcon()
	local sprite = Sprite("gfx/ui/coop menu.anm2", true)
	sprite:SetFrame("Main", 0)
	return sprite, 0
end

---@param playerOrType EntityPlayer | PlayerType
---@param allowTainted? boolean
function LOVE_TELLER:TryGetCoopIcon(playerOrType, allowTainted)
	local playerType = type(playerOrType) == "number" and playerOrType or
		---@cast playerOrType EntityPlayer
		playerOrType:GetPlayerType()
	local entityConfigPlayer = EntityConfig.GetPlayer(playerType)
	if not entityConfigPlayer then return unknownCoopIcon() end
	local mainPlayerConfig = entityConfigPlayer
	if not allowTainted and mainPlayerConfig:IsTainted() then
		local nonTainted = mainPlayerConfig:GetTaintedCounterpart()
		---@cast nonTainted EntityConfigPlayer
		mainPlayerConfig = nonTainted
	end
	if playerType >= PlayerType.PLAYER_ISAAC and playerType < PlayerType.NUM_PLAYER_TYPES then
		local sprite = Sprite("gfx/ui/coop menu.anm2", true)
		sprite:SetFrame("Main", playerType + 1)
		return sprite, 0
	end
	local coopSprite = mainPlayerConfig:GetModdedCoopMenuSprite()
	if not coopSprite then return unknownCoopIcon() end
	local testSprite, wasLoadSuccessful = Sprite(coopSprite:GetFilename(), true)
	if not wasLoadSuccessful then return unknownCoopIcon() end
	coopSprite = testSprite
	local name = EntityConfig.GetPlayer(playerType):GetName()
	coopSprite:SetFrame(name, 0)
	if coopSprite:GetAnimation() ~= name then return unknownCoopIcon() end
	local iconAnimData = coopSprite:GetCurrentAnimationData()
	local renderLayer = 0
	if not iconAnimData:GetLayer(0):GetFrame(0) then
		local foundFrame = false
		for _, iconLayerData in ipairs(iconAnimData:GetAllLayers()) do
			if iconLayerData:GetFrame(0) then
				renderLayer = iconLayerData:GetLayerID()
				foundFrame = true
				break
			end
		end
		if not foundFrame then return unknownCoopIcon() end
	end
	return coopSprite, renderLayer
end

---@param slot EntitySlot
function LOVE_TELLER:OnSlotInit(slot)
	slot:SetSize(slot.Size, Vector(1.5, 0.75), 24)
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, LOVE_TELLER.OnSlotInit, LOVE_TELLER.ID)

---@param playerType PlayerType
---@param result integer
function LOVE_TELLER:GetMatchMaker(playerType, result)
	local mainPlayerType = LOVE_TELLER.ParentPlayerTypes[playerType] or playerType
	local entityConfigPlayer = EntityConfig.GetPlayer(mainPlayerType)
	---@cast entityConfigPlayer EntityConfigPlayer
	local mainPlayerConfig = entityConfigPlayer
	if mainPlayerConfig:IsTainted() then
		local nonTainted = mainPlayerConfig:GetTaintedCounterpart()
		---@cast nonTainted EntityConfigPlayer
		mainPlayerType = nonTainted:GetPlayerType()
	end
	local matchmakingList = LOVE_TELLER.Matchmaking[playerType]
	if result == 0 then
		---Grab a list of all characters that aren't compatible/true love and pick a random one
		local avoidTypes = Mod:Set({
			mainPlayerType,
			matchmakingList.TrueLove,
			matchmakingList.Compatible[1],
			matchmakingList.Compatible[2],
			matchmakingList.Compatible[3],
		})
		local playerTypes = {}
		for i = 0, PlayerType.PLAYER_ISAAC_B - 1 do
			if not avoidTypes[i] and not LOVE_TELLER.ParentPlayerTypes[i] then
				Mod:Insert(playerTypes, i)
			end
		end
		local modded = {
			Mod.PlayerType.LEAH,
			Mod.PlayerType.PETER,
			Mod.PlayerType.MIRIAM
		}
		for _, moddedType in ipairs(modded) do
			if not avoidTypes[moddedType] then
				Mod:Insert(playerTypes, moddedType)
			end
		end
		local shithead = playerTypes[Mod:RandomNum(#playerTypes)]
		return shithead
	elseif result == 1 then
		return matchmakingList.Compatible[Mod:RandomNum(#matchmakingList.Compatible)]
	elseif result == 2 then
		return matchmakingList.TrueLove
	end
end

---@param slot EntitySlot
---@return EntityPlayer?
function LOVE_TELLER:TryGetPlayer(slot)
	local player = Mod:GetData(slot).TouchedPlayer
	if not player or not player:Exists() then
		Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		slot:SetState(Mod.SlotState.IDLE)
		slot:GetSprite():Play("Idle")
	end
	return player
end

---@param slot EntitySlot
function LOVE_TELLER:OnSlotUpdate(slot)
	local sprite = slot:GetSprite()
	local data = Mod:GetData(slot)
	local slot_save = Mod:RoomSave(slot)
	local state = slot:GetState()
	if not data.SlotRNG then
		local seed = slot_save.SlotRNGSeed or slot.InitSeed
		data.SlotRNG = RNG(seed)
		slot_save.SlotRNGSeed = seed
	end
	if state == Mod.SlotState.IDLE and sprite:IsOverlayFinished("CoinInsert") then
		sprite:Play("Initiate")
		sprite:RemoveOverlay()
		Mod.SFXMan:Play(SoundEffect.SOUND_COIN_SLOT)
		slot:SetState(Mod.SlotState.REWARD)
	elseif sprite:IsFinished("Initiate") then
		sprite:Play("Wiggle")
		slot:SetTimeout(30)
	elseif sprite:IsPlaying("Wiggle") and slot:GetTimeout() == 0 then
		sprite:Play("WiggleEnd")
	elseif sprite:IsFinished("WiggleEnd") then
		local roll = data.SlotRNG:RandomFloat()
		slot_save.SlotRNGSeed = data.SlotRNG:GetSeed()
		local prizeResult = 0
		local luckyFoot = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
			and 11.5 or 0
		if roll <= LOVE_TELLER.TRUE_LOVE_COMPAT_CHANCE + luckyFoot then
			prizeResult = 2
		elseif roll <= LOVE_TELLER.GOOD_COMPAT_CHANCE + luckyFoot then
			prizeResult = 1
		end
		sprite:Play("Prize" .. prizeResult)
		local player = LOVE_TELLER:TryGetPlayer(slot)
		if not player then return end
		local iconLeft, layerLeft = LOVE_TELLER:TryGetCoopIcon(player, true)
		data.IconLeft = {Sprite = iconLeft, Layer = layerLeft}
		local playerTypeRight = LOVE_TELLER:GetMatchMaker(player:GetPlayerType(), prizeResult)
		local iconRight, layerRight = LOVE_TELLER:TryGetCoopIcon(playerTypeRight, false)
		data.IconRight = {Sprite = iconRight, Layer = layerRight}
		data.MatchedPlayer = playerTypeRight
	elseif sprite:IsPlaying("Prize2")
		and sprite:IsEventTriggered("Ding")
	then
		Mod.SFXMan:Play(SoundEffect.SOUND_THUMBSUP)
	elseif string.find(sprite:GetAnimation(), "Prize")
		and sprite:IsEventTriggered("Prize")
	then
		local num = string.gsub(sprite:GetAnimation(), "Prize", "")
		if num == "0" then
			Isaac.Spawn(EntityType.ENTITY_FLY, 0, 0, slot.Position, Vector.Zero, nil)
			Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
			slot:SetState(Mod.SlotState.IDLE)
		elseif num == "1" then
			for _ = 1, 2 do
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, NullPickupSubType.ANY, slot.Position, EntityPickup.GetRandomPickupVelocity(slot.Position, Mod.RandomRNG, 1), nil)
			end
			Mod.SFXMan:Play(SoundEffect.SOUND_SLOTSPAWN)
			slot:SetState(Mod.SlotState.IDLE)
		elseif num == "2" then
			local player = LOVE_TELLER:TryGetPlayer(slot)
			if not player then return end
			local player_run_save = Mod:RunSave(player)
			player_run_save.LoveTellerBabies = player_run_save.LoveTellerBabies or {}
			local subtypeToSpawn = data.MatchedPlayer
			local key = tostring(subtypeToSpawn)
			player_run_save.LoveTellerBabies[key] = (player_run_save.LoveTellerBabies[key] or 0) + 1
			local familiar = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, LOVE_TELLER.BABY.FAMILIAR, subtypeToSpawn, slot.Position, Vector.Zero, player):ToFamiliar()
			---@cast familiar EntityFamiliar
			familiar.Player = player
			LOVE_TELLER.BABY:UpdateBabySkin(familiar)
			player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
			slot:SetState(Mod.SlotState.PAYOUT)
			slot:GetSprite():Play("Death")
		end
	end
	if sprite:IsPlaying("Death")
		and sprite:IsEventTriggered("Explosion")
	then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, slot.Position + Vector(0, 1), Vector.Zero, slot)
		Mod.SFXMan:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS)
	elseif sprite:IsFinished("Death") then
		sprite:Play("Broken")
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, LOVE_TELLER.OnSlotUpdate, LOVE_TELLER.ID)

---@param slot EntitySlot
---@param collider Entity
function LOVE_TELLER:OnSlotCollision(slot, collider)
	local player = collider:ToPlayer()
	if not player or player:GetNumCoins() < 5 then return end
	local sprite = slot:GetSprite()
	if slot:GetState() == Mod.SlotState.IDLE and not sprite:IsOverlayPlaying("CoinInsert") then
		player:AddCoins(-5)
		sprite:PlayOverlay("CoinInsert", true)
		local data = Mod:GetData(slot)
		data.TouchedPlayer = player
		slot:SetState(Mod.SlotState.IDLE)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, LOVE_TELLER.OnSlotCollision, LOVE_TELLER.ID)

---@param slot EntitySlot
function LOVE_TELLER:SlotDrops(slot)
	if slot:GetState() == Mod.SlotState.BOMBED then
		local sprite = slot:GetSprite()
		if not sprite:IsPlaying("Death") and sprite:GetAnimation() ~= "Broken" then
			sprite:Play("Death", true)
		end
	end
	local data = Mod:GetData(slot)
	---@type RNG
	local rng = data.SlotRNG
	local num = 3
	local pickup = PickupVariant.PICKUP_COIN
	if rng:RandomFloat() <= 0.25 then
		num = 2
		pickup = PickupVariant.PICKUP_HEART
	end
	for _ = 1, num do
		Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup, NullPickupSubType.ANY, slot.Position, EntityPickup.GetRandomPickupVelocity(slot.Position, Mod.RandomRNG, 0), nil)
	end
	return false
end

Mod:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, LOVE_TELLER.SlotDrops, LOVE_TELLER.ID)

---@param slot EntitySlot
function LOVE_TELLER:RenderCoopIcons(slot, offset)
	local sprite = slot:GetSprite()
	local slotLeft = sprite:GetNullFrame("SlotLeft")
	local slotRight = sprite:GetNullFrame("SlotRight")
	if not slotLeft or not slotRight then return end
	local data = Mod:GetData(slot)
	local iconLeft = data.IconLeft
	local iconRight = data.IconRight
	if not iconLeft or not iconRight then return end
	---@type Sprite
	local spriteLeft = iconLeft.Sprite
	---@type Sprite
	local spriteRight = iconRight.Sprite
	local layerLeft = iconLeft.Layer
	local layerRight = iconRight.Layer
	local renderPos = Isaac.WorldToScreen(slot.Position + slot.PositionOffset)
	if Mod.Room():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
		renderPos = Isaac.WorldToRenderPosition(slot.Position + slot.PositionOffset) + offset
	end
	spriteLeft.Scale = slotLeft:GetScale()
	spriteRight.Scale = slotRight:GetScale()
	spriteLeft:RenderLayer(layerLeft, renderPos + slotLeft:GetPos())
	spriteRight:RenderLayer(layerRight, renderPos + slotRight:GetPos())
	overlaySprite:Render(renderPos)
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_RENDER, LOVE_TELLER.RenderCoopIcons, LOVE_TELLER.ID)
