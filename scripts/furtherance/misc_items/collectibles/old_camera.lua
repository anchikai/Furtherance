local Mod = Furtherance

local OLD_CAMERA = {}

Furtherance.Item.OLD_CAMERA = OLD_CAMERA

OLD_CAMERA.ID = Isaac.GetItemIdByName("Old Camera")

OLD_CAMERA.PHOTO_IDs = {
	Isaac.GetCardIdByName("Spooky Photo"),
	Isaac.GetCardIdByName("Haunted Photo"),
	Isaac.GetCardIdByName("Possessed Photo")
}
OLD_CAMERA.CAMERA_FLASH = Isaac.GetSoundIdByName("Camera Flash")

OLD_CAMERA.HIT_POINT_THRESHOLD = 20

local WHITE_SQUARE = Sprite("gfx/hud_whitesquare.anm2", true)
WHITE_SQUARE:Play("Idle", true)
WHITE_SQUARE.Color = Color(1, 1, 1, 0)

local MAX_FLASHBANG = 60
OLD_CAMERA.FLASHBANG_TIMER = 0

function OLD_CAMERA:ApplyFlashbang(timer)
	Mod.SFXMan:Play(OLD_CAMERA.CAMERA_FLASH)
	WHITE_SQUARE:Play("Idle", true)
	if not timer then
		timer = MAX_FLASHBANG
	end
	OLD_CAMERA.FLASHBANG_TIMER = timer
end

function OLD_CAMERA:RenderFlashbang()
	if OLD_CAMERA.FLASHBANG_TIMER ~= 0 then
		local size = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenWidth())
		WHITE_SQUARE.Scale = size
		WHITE_SQUARE.Color.A = OLD_CAMERA.FLASHBANG_TIMER / MAX_FLASHBANG
		WHITE_SQUARE:Render(Vector.Zero)

		OLD_CAMERA.FLASHBANG_TIMER = math.max(OLD_CAMERA.FLASHBANG_TIMER - 1, 0)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_RENDER, OLD_CAMERA.RenderFlashbang)

---@param player EntityPlayer
---@param rng RNG
function OLD_CAMERA:OnUse(itemID, rng, player, flags, slot)
	local totalHitPoints = 0
	local source = EntityRef(player)
	Mod.Foreach.NPC(function(npc)
		if not npc:IsBoss() then
			totalHitPoints = totalHitPoints + npc.MaxHitPoints
			npc:Remove()
		else
			npc:AddFreeze(source, 75)
			npc:AddConfusion(source, 150, false)
		end
	end, nil, nil, nil, {UseEnemySearchParams = true, NoCollision = true, Invincible = true})
	OLD_CAMERA:ApplyFlashbang()
	if totalHitPoints == 0 then
		return true
	end
	local photoTier = Mod:Clamp(math.floor(totalHitPoints / OLD_CAMERA.HIT_POINT_THRESHOLD), 1, 3)
	local pos = Mod.Room():FindFreePickupSpawnPosition(player.Position, 40)
	Mod.Spawn.Pickup(PickupVariant.PICKUP_TAROTCARD, OLD_CAMERA.PHOTO_IDs[photoTier], pos, Vector.Zero, player, rng:Next())
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, OLD_CAMERA.OnUse, OLD_CAMERA.ID)

---@param player EntityPlayer
---@param strength integer
function OLD_CAMERA:GetGhostAmount(player, strength)
	local power = strength*2
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
		power = math.floor(Mod:Round(power * 1.5, 0))
	end
	return power
end

---@param card Card
---@param player EntityPlayer
---@param useFlags UseFlag
function OLD_CAMERA:OnPhotoUse(card, player, useFlags)
	local power
	for i, _card in ipairs(OLD_CAMERA.PHOTO_IDs) do
		if card == _card then
			power = OLD_CAMERA:GetGhostAmount(player, i)
			break
		end
	end

	if not power then return end

	for _ = 1, power do
		local ghost = Mod.Spawn.Effect(EffectVariant.PURGATORY, 1, player.Position, Vector.Zero, player, player:GetCardRNG(card):Next())
		ghost:GetSprite():SetLastFrame()
		ghost:Update()
	end
end

for _, card in ipairs(OLD_CAMERA.PHOTO_IDs) do
	Mod:AddCallback(ModCallbacks.MC_USE_CARD, OLD_CAMERA.OnPhotoUse, card)
end