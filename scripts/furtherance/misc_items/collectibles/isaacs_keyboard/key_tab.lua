local Mod = Furtherance

local TAB_KEY = {}

Furtherance.Item.KEY_TAB = TAB_KEY

TAB_KEY.ID = Isaac.GetItemIdByName("Tab Key")

local funny = false

---@param player EntityPlayer
function TAB_KEY:OnUse(_, _, player)
	local level = Mod.Level()
	if not player:HasCollectible(Mod.Item.KEY_ALT.ID) then
		level:ApplyCompassEffect(false)
		level:ApplyMapEffect()
		level:ApplyBlueMapEffect()
		local rooms = level:GetRooms()
		for i = 1, rooms.Size - 1 do
			local roomDesc = rooms:Get(i)
			if roomDesc.Data.Type == RoomType.ROOM_ULTRASECRET then
				roomDesc.DisplayFlags = Mod.DisplayFlags.VISIBLE_WITH_ICON
				break
			end
		end
		Mod.Level():UpdateVisibility()
		return true
	else
		funny = true
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, TAB_KEY.OnUse, TAB_KEY.ID)

function TAB_KEY:PauseGame(ent, hook, button)
	if funny
		and button == ButtonAction.ACTION_PAUSE
	then
		funny = false
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, TAB_KEY.PauseGame, InputHook.IS_ACTION_TRIGGERED)