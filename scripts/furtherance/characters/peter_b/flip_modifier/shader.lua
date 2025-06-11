local Mod = Furtherance
local MUDDLED_CROSS = Mod.Item.MUDDLED_CROSS
local FLIP = Mod.Character.PETER_B.FLIP
local floor = math.floor

local FLIP_SHADER = {}

---@param itemConfig ItemConfigItem
function FLIP_SHADER:OnLoseFlipEffect(itemConfig)
	if itemConfig:IsCollectible()
		and itemConfig.ID == MUDDLED_CROSS.ID
		--Should only ever be false if removed via instant room change (i.e. debug console)
		and (not Mod.Game:IsPaused() or RoomTransition.GetTransitionMode() > 0)
	then
		Mod.SFXMan:Play(MUDDLED_CROSS.SFX_UNFLIP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_EFFECT_REMOVED, FLIP_SHADER.OnLoseFlipEffect)

function FLIP_SHADER:AnimateFlip()
	local isFlipped = Mod.Room():GetEffects():HasCollectibleEffect(MUDDLED_CROSS.ID)
	if not Mod.Game:IsPauseMenuOpen() then
		if not isFlipped then
			--Should only ever be true if done within via instant room change (i.e. debug console) or restarting the game via holding R
			if Mod.Game:GetFrameCount() == 0 then
				FLIP.FLIP_FACTOR = 0
				return
			end
		end
		local lerp = Mod:Lerp(FLIP.FLIP_FACTOR, isFlipped and 1 or 0, FLIP.FLIP_SPEED)
		FLIP.FLIP_FACTOR = Mod:Clamp(floor(lerp * 100) / 100, 0, 1)
	end

	if FLIP.FLIP_FACTOR > 0.05 and FLIP.FLIP_FACTOR < 0.95 then
		Isaac.RunCallback(Mod.ModCallbacks.PETER_B_ENEMY_ROOM_FLIP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, FLIP_SHADER.AnimateFlip)

---@param ent EntityNPC | EntityPlayer
function FLIP_SHADER:FlashNearFlipEnd(ent)
	if FLIP.PETER_EFFECTS_ACTIVE
		and not FLIP:IsEntitySubmerged(ent)
		and (FLIP:ValidEnemyToFlip(ent)
		---@cast ent EntityPlayer
		or (ent:ToPlayer() and Mod.Character.PETER_B:IsPeterB(ent)))
	then
		local room = Mod.Room():GetEffects()
		if room:HasCollectibleEffect(MUDDLED_CROSS.ID) then
			local cooldown = room:GetCollectibleEffect(MUDDLED_CROSS.ID).Cooldown
			if cooldown > 0 and cooldown < 60 and cooldown % 15 == 0 then
				ent:SetColor(
					StatusEffectLibrary.StatusConfig[Mod.Character.PETER_B.FLIP.STATUS_EFFECTS.STRENGTH_NAME].Color,
				15, 10, true, false)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, FLIP_SHADER.FlashNearFlipEnd)
Mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, FLIP_SHADER.FlashNearFlipEnd)

function FLIP_SHADER:BeepNearFlipEnd()
	local room = Mod.Room():GetEffects()
	if room:HasCollectibleEffect(MUDDLED_CROSS.ID) then
		local cooldown = room:GetCollectibleEffect(MUDDLED_CROSS.ID).Cooldown
		if cooldown > 0 and cooldown < 60 and cooldown % 15 == 0 then
			Mod.SFXMan:Play(SoundEffect.SOUND_BEEP)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FLIP_SHADER.BeepNearFlipEnd)

function FLIP_SHADER:FreezeEnemiesDuringFlip()
	local effects = Mod.Room():GetEffects()
	if FLIP.FLIP_FACTOR > 0.05 and FLIP.FLIP_FACTOR < 0.95 then
		local roomEffects = Mod.Room():GetEffects()
		if roomEffects:HasCollectibleEffect(MUDDLED_CROSS.ID) then
			if FLIP.FREEZE_ROOM_EFFECT_COOLDOWN == 0 then
				FLIP.FREEZE_ROOM_EFFECT_COOLDOWN = roomEffects:GetCollectibleEffect(MUDDLED_CROSS.ID).Cooldown + 1
			end
			roomEffects:GetCollectibleEffect(MUDDLED_CROSS.ID).Cooldown = FLIP.FREEZE_ROOM_EFFECT_COOLDOWN
		end
		if not FLIP.PAUSE_ENEMIES_DURING_FLIP then
			Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, false, false, false, false, -1)
			Isaac.GetPlayer():GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_PAUSE)
			FLIP.PAUSE_ENEMIES_DURING_FLIP = true
			Mod.Foreach.Player(function (player)
				Mod.Foreach.ProjectileInRadius(player.Position, 80, function (projectile)
					projectile:Die()
				end, nil, nil, {Inverse = true})
			end)
		end
	else
		if FLIP.PAUSE_ENEMIES_DURING_FLIP then
			FLIP.PAUSE_ENEMIES_DURING_FLIP = false
			FLIP.FREEZE_ROOM_EFFECT_COOLDOWN = 0
			effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_PAUSE)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, FLIP_SHADER.FreezeEnemiesDuringFlip)

-- Thank you im_tem for the shader!!
function FLIP_SHADER:PeterFlip(name)
	if name == "Peter Flip" then
		local factor = MUDDLED_CROSS.FLIP_FACTOR > 0 and MUDDLED_CROSS.FLIP_FACTOR or FLIP.FLIP_FACTOR
		if Mod.FLAGS.Debug and FLIP.SHOW_DEBUG then
			Isaac.RenderText(
				"Expected to Peter Flip:" .. tostring(Mod.Room():GetEffects():HasCollectibleEffect(MUDDLED_CROSS.ID)), 50,
				30,
				1, 1, 1, 1)
			Isaac.RenderText("Expected to Room Flip (Overrides Peter Flip):" .. tostring(MUDDLED_CROSS.TARGET_FLIP > 0),
				50, 45, 1, 1, 1, 1)
			Isaac.RenderText("Peter Flip Factor:" .. tostring(FLIP.FLIP_FACTOR), 50, 60, 1, 1, 1, 1)
			Isaac.RenderText("Room Flip Factor:" .. tostring(MUDDLED_CROSS.FLIP_FACTOR), 50, 75, 1, 1, 1, 1)
		end
		return { FlipFactor = Mod.Game:IsPauseMenuOpen() and 0 or factor }
	--[[ elseif name == "Peter Flip HUD" then
		if FLIP.PETER_EFFECTS_ACTIVE then
			Mod.HUD:SetVisible(true)
			Mod.HUD:Render()
			Mod.HUD:SetVisible(false)
		end ]]
	end
end

Mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, FLIP_SHADER.PeterFlip)

---@diagnostic disable-next-line: inject-field
function Mod:PrintPeterBFlip()
	print("Expected to Peter Flip:" .. Mod.Room():GetEffects():HasCollectibleEffect(MUDDLED_CROSS.ID))
	print("Expected to Room Flip (Overrides Peter Flip):" .. MUDDLED_CROSS.TARGET_FLIP > 0)
	print("Peter Flip Factor:" .. FLIP.FLIP_FACTOR)
	print("Room Flip Factor:" .. MUDDLED_CROSS.FLIP_FACTOR)
end

function FLIP_SHADER:FixInputs(ent, _, button)
	local player = ent and ent:ToPlayer()
	if player and FLIP:IsRoomEffectActive() then
		if button == ButtonAction.ACTION_DOWN then
			return Input.GetActionValue(ButtonAction.ACTION_UP, player.ControllerIndex)
		elseif button == ButtonAction.ACTION_UP then
			return Input.GetActionValue(ButtonAction.ACTION_DOWN, player.ControllerIndex)
		elseif button == ButtonAction.ACTION_SHOOTUP then
			return Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
		elseif button == ButtonAction.ACTION_SHOOTDOWN then
			return Input.GetActionValue(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, FLIP_SHADER.FixInputs, InputHook.GET_ACTION_VALUE)

return FLIP_SHADER
