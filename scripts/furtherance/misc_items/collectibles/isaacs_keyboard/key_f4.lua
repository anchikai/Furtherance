--#region Variables

local Mod = Furtherance

local F4_KEY = {}

Furtherance.Item.KEY_F4 = F4_KEY

F4_KEY.ID = Isaac.GetItemIdByName("F4 Key")

F4_KEY.POWER_DOWN = Isaac.GetSoundIdByName("Power Down")

local isPoweredDown = false

F4_KEY.ALLOWED_ROOMS = {
	Equal = Mod:Set({
		RoomType.ROOM_SUPERSECRET,
		RoomType.ROOM_ISAACS,
		RoomType.ROOM_BARREN,
		RoomType.ROOM_SECRET,
		RoomType.ROOM_SHOP,
		RoomType.ROOM_TREASURE,
		RoomType.ROOM_DICE,
		RoomType.ROOM_LIBRARY,
		RoomType.ROOM_CHEST,
		RoomType.ROOM_PLANETARIUM,
		RoomType.ROOM_ARCADE
	}),
	LeastCoins = Mod:Set({
		RoomType.ROOM_ARCADE
	}),
	LeastBombs = Mod:Set({
		RoomType.ROOM_SUPERSECRET,
		RoomType.ROOM_ISAACS,
		RoomType.ROOM_BARREN,
		RoomType.ROOM_SECRET
	}),
	LeastKeys = Mod:Set({
		RoomType.ROOM_SHOP,
		RoomType.ROOM_TREASURE,
		RoomType.ROOM_DICE,
		RoomType.ROOM_LIBRARY,
		RoomType.ROOM_CHEST,
		RoomType.ROOM_PLANETARIUM
	})
}

local stopSomeLoopingSFX = {
	SoundEffect.SOUND_INSECT_SWARM_LOOP,
	SoundEffect.SOUND_PORTAL_LOOP,
	SoundEffect.SOUND_TAR_LOOP,
	SoundEffect.SOUND_WATER_FLOW_LOOP,
	SoundEffect.SOUND_LAVA_LOOP,
	SoundEffect.SOUND_CHAIN_LOOP,
	SoundEffect.SOUND_MINECART_LOOP,
	SoundEffect.SOUND_FLAMETHROWER_LOOP,
	SoundEffect.SOUND_BALL_AND_CHAIN_LOOP,
	SoundEffect.SOUND_FIRE_BURN
}

local collisionCallbacks = {
	ModCallbacks.MC_PRE_PLAYER_COLLISION,
	ModCallbacks.MC_PRE_TEAR_COLLISION,
	ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
	ModCallbacks.MC_PRE_NPC_COLLISION,
	ModCallbacks.MC_PRE_BOMB_COLLISION,
	ModCallbacks.MC_PRE_KNIFE_COLLISION,
	ModCallbacks.MC_PRE_PROJECTILE_COLLISION
}

local initCallbacks = {
	ModCallbacks.MC_POST_NPC_INIT,
	ModCallbacks.MC_POST_PROJECTILE_INIT
}

local preUpdateCallbacks = {
	"MC_PRE_NPC_UPDATE",
	"MC_PRE_PROJECTILE_UPDATE",
	"MC_PRE_GRID_ENTITY_FIRE_UPDATE",
	"MC_PRE_GRID_ENTITY_SPIKES_UPDATE",
	"MC_PRE_GRID_ENTITY_WEB_UPDATE",
	"MC_PRE_GRID_ENTITY_TNT_UPDATE",
}

local environmentEffects = {
	EffectVariant.WALL_BUG,
	EffectVariant.TINY_BUG,
	EffectVariant.TINY_FLY,
	EffectVariant.WISP
}

--#endregion

--#region On use

-- Thanks for solving this problem Connor!
---@param player EntityPlayer
---@param rng RNG
function F4_KEY:OnRegularUse(player, rng)
	local level = Mod.Level()
	local roomsList = level:GetRooms()
	local bombs = player:GetNumBombs()
	local coins = player:GetNumCoins()
	local keys = player:GetNumKeys()
	local allowedRooms

	if (coins == bombs) and (bombs == keys) then
		allowedRooms = F4_KEY.ALLOWED_ROOMS.Equal
	elseif (coins < bombs) and (coins < keys) then
		allowedRooms = F4_KEY.ALLOWED_ROOMS.LeastCoins
	elseif (bombs <= coins) and (bombs <= keys) then
		allowedRooms = F4_KEY.ALLOWED_ROOMS.LeastBombs
	elseif (keys <= coins) and (keys < bombs) then
		allowedRooms = F4_KEY.ALLOWED_ROOMS.LeastKeys
	end

	local unvisitedRooms = {}
	for i = 0, roomsList.Size - 1 do
		local roomDesc = roomsList:Get(i)
		if roomDesc.VisitedCount == 0 and allowedRooms[roomDesc.Data.Type] then
			table.insert(unvisitedRooms, roomDesc.GridIndex)
		end
	end

	if #unvisitedRooms > 0 then
		local choice = rng:RandomInt(#unvisitedRooms) + 1
		local roomIndex = unvisitedRooms[choice]
		Mod.Game:StartRoomTransition(roomIndex, Direction.NO_DIRECTION, 3)
		return true
	else
		player:AnimateSad()
		return false
	end
end

function F4_KEY:UpdateDoorsAndShadow()
	local room = Mod.Room()
	local fxParams = room:GetFXParams()
	fxParams.ShadowAlpha = 2
	fxParams.LightColor = KColor(1, 1, 1, 0)
	for i = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(i)
		if door and not door:IsLocked() then
			door:Open()
			if door:IsOpen() then
				door:GetSprite():Play(door.OpenAnimation)
				door:GetSprite():SetLastFrame()
			end
		end
	end
end

---@param player EntityPlayer
function F4_KEY:OnAltSynergyUse(player)
	local floor_save = Mod:FloorSave()
	floor_save.AltF4Shutdown = true
	isPoweredDown = true
	Mod.SFXMan:Play(F4_KEY.POWER_DOWN, 2)
	F4_KEY:UpdateDoorsAndShadow()
	for _, ent in ipairs(Isaac.GetRoomEntities()) do
		local sprite = ent:GetSprite()
		sprite:Stop()
	end
	Mod.MusicMan:Pause()
	for _, sfx in ipairs(stopSomeLoopingSFX) do
		Mod.SFXMan:Stop(sfx)
	end
	return true
end

---@param rng RNG
---@param player EntityPlayer
function F4_KEY:OnUse(_, rng, player)
	if not player:HasCollectible(Mod.Item.KEY_ALT.ID) then
		return F4_KEY:OnRegularUse(player, rng)
	else
		local roomType = Mod.Room():GetType()
		if roomType ~= RoomType.ROOM_BOSS then
			local slots = Mod:GetActiveItemSlots(player, Mod.Item.KEY_ALT.ID)
			for _, slot in ipairs(slots) do
				if not player:NeedsCharge(slot) then
					player:DischargeActiveItem(slot)
					return F4_KEY:OnAltSynergyUse(player)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, F4_KEY.OnUse, F4_KEY.ID)

--#endregion

function F4_KEY:DarkenScreen(shaderName)
	if shaderName == "AltF4PowerDown" then
		return { PowerValue = isPoweredDown and 0.5 or 0 }
	end
end

Mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, F4_KEY.DarkenScreen)

function F4_KEY:StopAltF4()
	local floor_save = Mod:FloorSave()
	isPoweredDown = false
	floor_save.AltF4Shutdown = nil
	local fxParams = Mod.Room():GetFXParams()
	fxParams.ShadowAlpha = 0
	fxParams.LightColor = KColor(1, 1, 1, 1)
end

function F4_KEY:OnNewRoom()
	if Mod.Room():GetType() == RoomType.ROOM_BOSS then return end
	local floor_save = Mod:FloorSave()
	if floor_save.AltF4Shutdown then
		isPoweredDown = true
		F4_KEY:UpdateDoorsAndShadow()
		Mod.SFXMan:Stop(SoundEffect.SOUND_UNLOCK00)
		Mod.SFXMan:Stop(SoundEffect.SOUND_DOOR_HEAVY_CLOSE)
		Mod.SFXMan:Stop(SoundEffect.SOUND_DOOR_HEAVY_OPEN)
		Mod.SFXMan:Stop(SoundEffect.SOUND_METAL_DOOR_CLOSE)
		Mod.SFXMan:Stop(SoundEffect.SOUND_METAL_DOOR_OPEN)
	elseif isPoweredDown then
		F4_KEY:StopAltF4()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, F4_KEY.OnNewRoom)

---@param room? Room
function F4_KEY:ShouldNilBoss(room)
	room = room or Mod.Room()
	if room:GetType() ~= RoomType.ROOM_BOSS then return false end
	local level = Mod.Level()
	local stage = level:GetStage()
	local labyrinth = Mod:HasBitFlags(level:GetCurses(), LevelCurse.CURSE_OF_LABYRINTH)
	return Mod.Game:IsGreedMode() and (
		--If within a normal run, allow Pre-Mom and Womb I
		(labyrinth and stage == LevelStage.STAGE3_1 and not room:IsCurrentRoomLastBoss())
		or stage < LevelStage.STAGE3_2
		or (stage == LevelStage.STAGE4_1 and not labyrinth and not room:IsCurrentRoomLastBoss())
		--Otherwise, allow Pre-Ultra Greed
	) or stage < LevelStage.STAGE7_GREED
end

function F4_KEY:ShouldEndEffectEarly(room)
	if isPoweredDown
		and room:GetType() == RoomType.ROOM_BOSS
		and not F4_KEY:ShouldNilBoss(room)
	then
		F4_KEY:StopAltF4()
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, F4_KEY.ShouldEndEffectEarly)

function F4_KEY:HideBossPortraitAndName()
	if isPoweredDown and F4_KEY:ShouldNilBoss() then
		local sprite = RoomTransition.GetVersusScreenSprite()
		sprite:GetLayer(4):SetVisible(false) --Boss portrait
		sprite:GetLayer(9):SetVisible(false) --Second Boss portrait (Double Trouble)
		sprite:GetLayer(7):SetVisible(false) --Boss name
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_BOSS_INTRO_SHOW, CallbackPriority.LATE, F4_KEY.HideBossPortraitAndName)

---Doing PRE_ENTITY_SPAWN or NPC_INIT apparently just freezes the game when this is attempted
---and we stop early on PRE_NPC_UPDATE, so do a delay on NPC_INIT
function F4_KEY:Error404BossNotFound(ent)
	if isPoweredDown and F4_KEY:ShouldNilBoss() then
		Mod:DelayOneFrame(function()
			ent:Remove()
			Isaac.Spawn(EntityType.ENTITY_SHOPKEEPER, 2, 0, ent.Position, Vector.Zero, nil)
		end)
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, CallbackPriority.IMPORTANT, F4_KEY.Error404BossNotFound)

function F4_KEY:EndAltF4Effect()
	if isPoweredDown and Mod.Room():IsCurrentRoomLastBoss() then
		F4_KEY:StopAltF4()
		Mod.Room():PlayMusic()
		Mod.MusicMan:UpdateVolume()
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.IMPORTANT, F4_KEY.EndAltF4Effect)

--#region Pause a lot of things

for _, callback in ipairs(preUpdateCallbacks) do
	Mod:AddPriorityCallback(ModCallbacks[callback], CallbackPriority.IMPORTANT - 1000, function(_, ent)
		if isPoweredDown then
			if string.find(callback, "GRID") then
				return false
				--Let them update once for initiating their sprite at minimum
			elseif ent.FrameCount >= 1 then
				ent.Velocity = Vector.Zero
				ent:GetSprite():Stop()
				return true
			end
		end
	end)
end

--Special exceptions to red poops and spiked rocks
---@param gridEnt GridEntityRock
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_GRID_ENTITY_ROCK_UPDATE, CallbackPriority.IMPORTANT - 1000, function(_, gridEnt)
	if isPoweredDown and gridEnt:GetType() == GridEntityType.GRID_ROCK_SPIKED then
		return false
	end
end)
---@param gridEnt GridEntityRock
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_GRID_ENTITY_POOP_UPDATE, CallbackPriority.IMPORTANT - 1000, function(_, gridEnt)
	if isPoweredDown and gridEnt:GetType() == GridEntityType.GRID_POOP and gridEnt:GetVariant() == GridPoopVariant.RED then
		return false
	end
end)

for _, variant in ipairs(environmentEffects) do
	Mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, function(_, ent)
		if isPoweredDown then
			ent.Velocity = Vector.Zero
			ent:GetSprite():Stop()
		end
	end, variant)
end

for _, callback in ipairs(initCallbacks) do
	---@param ent Entity
	Mod:AddPriorityCallback(callback, CallbackPriority.LATE + 1000, function(_, ent)
		if isPoweredDown then
			ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			ent.Friction = 0
		end
	end)
end

for _, callback in ipairs(collisionCallbacks) do
	Mod:AddPriorityCallback(callback, CallbackPriority.IMPORTANT - 1000, function()
		if isPoweredDown then
			return true
		end
	end)
end

for _, sfx in ipairs(stopSomeLoopingSFX) do
	if isPoweredDown then
		Mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, function()
			return false
		end, sfx)
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_MUSIC_PLAY, function()
	if isPoweredDown then
		return false
	end
end)

--#endregion
