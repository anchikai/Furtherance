local Mod = Furtherance
local game = Game()

function Mod:UseEnter(_, _, player)
	local room = game:GetRoom()
	local level = game:GetLevel()
	local hud = game:GetHUD()
	if (level:GetCurrentRoomIndex() == -1) or (level:GetCurrentRoomIndex() == -3) or (level:GetCurrentRoomIndex() == -5) or (level:GetCurrentRoomIndex() == -10) then
		Mod:playFailSound()
		player:AnimateSad()
	elseif ((room:IsDoorSlotAllowed(DoorSlot.LEFT0) == true and room:GetDoor(DoorSlot.LEFT0) == nil) or (room:IsDoorSlotAllowed(DoorSlot.UP0) == true and room:GetDoor(DoorSlot.UP0) == nil) or (room:IsDoorSlotAllowed(DoorSlot.DOWN0) == true and room:GetDoor(DoorSlot.DOWN0) == nil) or (room:IsDoorSlotAllowed(DoorSlot.RIGHT0) == true and room:GetDoor(DoorSlot.RIGHT0) == nil)) then
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_ENTER_KEY)
		SFXManager():Play(SoundEffect.SOUND_MENU_FLIP_DARK)
		game:Darken(1, 100)
		room:EmitBloodFromWalls(3, 10)
		hud:ShowFortuneText("Time knows no bounds")
		room:TrySpawnBossRushDoor(true, true)
		room:MamaMegaExplosion(Vector.Zero)
		return true
	else
		Mod:playFailSound()
		player:AnimateSad()
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseEnter, CollectibleType.COLLECTIBLE_ENTER_KEY)
