local Mod = Furtherance

local SOUL_OF_LEAH = {}

Furtherance.Rune.SOUL_OF_LEAH = SOUL_OF_LEAH

SOUL_OF_LEAH.ID = Isaac.GetCardIdByName("Soul of Leah")

SOUL_OF_LEAH.DAMAGE_PER_BROKEN_HEART = 0.75

--TODO: Kinda sucks, could use a rework

---@param player EntityPlayer
function SOUL_OF_LEAH:UseSoulOfLeah(_, player, _)
	Mod.SFXMan:Play(Mod.Item.HEART_RENOVATOR.SFX_HEARTBEAT)
	local player_run_save = Mod:RunSave(player)
	local level = Mod.Level()
	local roomsList = level:GetRooms()
	for i = 0, roomsList.Size - 1 do
		local room = roomsList:Get(i)
		if room.Data.Type ~= RoomType.ROOM_SUPERSECRET and room.Data.Type ~= RoomType.ROOM_ULTRASECRET then -- based off of world card which doesn't reveal these
			if not room.Clear then
				player:AddBrokenHearts(1)
				player_run_save.SoulOfLeahDamage = (player_run_save.SoulOfLeahDamage or 0) + 0.75
				if player:GetBrokenHearts() == 12 then
					break
				end
			end
		end
	end
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
	player:EvaluateItems()
end
Mod:AddCallback(ModCallbacks.MC_USE_CARD, SOUL_OF_LEAH.UseSoulOfLeah, SOUL_OF_LEAH.ID)

---@param player EntityPlayer
function SOUL_OF_LEAH:SoulDamage(player, flag)
	local player_run_save = Mod:RunSave(player)
	if player_run_save.SoulOfLeahDamage then
		player.Damage = player.Damage + player_run_save.SoulOfLeahDamage
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SOUL_OF_LEAH.SoulDamage, CacheFlag.CACHE_DAMAGE)