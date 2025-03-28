local Mod = Furtherance

local ENTER_KEY = {}

Furtherance.Item.KEY_ENTER = ENTER_KEY

ENTER_KEY.ID = Isaac.GetItemIdByName("Enter Key")

function ENTER_KEY:OnUse(_, _, player)
	local roomIndex = Mod.Level():GetCurrentRoomIndex()
	local room = Mod.Room()
	if roomIndex < 0 then
		player:AnimateSad()
		return
	end
	for doorSlot = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		if room:IsDoorSlotAllowed(doorSlot) and room:GetDoor(doorSlot) ~= nil then
			Mod.SFXMan:Play(SoundEffect.SOUND_MENU_FLIP_DARK)
			Mod.Game:Darken(1, 100)
			room:EmitBloodFromWalls(3, 10)
			Mod.HUD:ShowFortuneText("Time knows no bounds")
			room:TrySpawnBossRushDoor(true, true)
			room:MamaMegaExplosion(Vector.Zero)
			return {Discharge = true, Remove = true, ShowAnim = true}
		end
	end
	player:AnimateSad()
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, ENTER_KEY.OnUse, ENTER_KEY.ID)
