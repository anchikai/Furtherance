local Mod = Furtherance
local SettingsHelper = Mod.SettingsHelper

if ModConfigMenu and not ModConfigMenu.GetCategoryIDByName("Furtherance") then
	ModConfigMenu.SetCategoryInfo("Furtherance", "Furtherance config settings")

	for i = 1, #SettingsHelper.Categories do
		ModConfigMenu.AddSpace("Furtherance", SettingsHelper.Categories[i])
	end

	for group, groupSettings in pairs(SettingsHelper.GetAllSettings()) do
		for _, info in ipairs(groupSettings) do
			local constructedArgs = {}

			constructedArgs.Attribute = info.Name
			constructedArgs.Default = info.Default

			constructedArgs.CurrentSetting = function()
				return Mod.GetSetting(info.Name)
			end

			if info.Type == Mod.SettingTypes.Boolean then
				constructedArgs.Type = ModConfigMenu.OptionType.BOOLEAN

				constructedArgs.Display = function()
					local currentValue = Mod.GetSetting(info.Name)
					if currentValue then
						return info.Name .. ": On"
					else
						return info.Name .. ": Off"
					end
				end

				constructedArgs.OnChange = function(currentValue)
					Mod.SaveSetting(info.Name, currentValue)
				end

				constructedArgs.Info = info.Description
			elseif info.Type == Mod.SettingTypes.Choice then
				constructedArgs.Type = ModConfigMenu.OptionType.NUMBER
				constructedArgs.Default = info.Default

				constructedArgs.Display = function()
					local currentValue = Mod.GetSetting(info.Name)
					return info.Name .. ": " .. info.Choices[currentValue]
				end

				constructedArgs.OnChange = function(currentValue)
					Mod.SaveSetting(info.Name, currentValue)
				end

				constructedArgs.Minimum = 1
				constructedArgs.Maximum = #info.Choices
				constructedArgs.ModifyBy = 1

				constructedArgs.Info = info.Description
			elseif info.Type == Mod.SettingTypes.Keybind then
				constructedArgs.Type = ModConfigMenu.OptionType.KEYBIND_KEYBOARD

				constructedArgs.Display = function()
					local currentValue = Mod.GetSetting(info.Name)
					return info.Name .. ": " .. tostring(InputHelper.KeyboardToString[currentValue]) .. " (keyboard)"
				end

				constructedArgs.OnChange = function(currentValue)
					Mod.SaveSetting(info.Name, currentValue)
				end

				constructedArgs.PopupGfx = ModConfigMenu.PopupGfx.WIDE_SMALL
				constructedArgs.PopupWidth = 280
				constructedArgs.Popup = function()
					local currentValue = Mod.GetSetting(info.Name)

					local goBackString = "back"
					if ModConfigMenu.Config.LastBackPressed then
						if InputHelper.KeyboardToString[ModConfigMenu.Config.LastBackPressed] then
							goBackString = InputHelper.KeyboardToString[ModConfigMenu.Config.LastBackPressed]
						elseif InputHelper.ControllerToString[ModConfigMenu.Config.LastBackPressed] then
							goBackString = InputHelper.ControllerToString[ModConfigMenu.Config.LastBackPressed]
						end
					end

					local keepSettingString = ""
					if currentValue > -1 then
						local currentSettingString = nil
						if InputHelper.KeyboardToString[currentValue] then
							currentSettingString = InputHelper.KeyboardToString[currentValue]
						end

						keepSettingString = "This setting is currently set to \"" ..
							currentSettingString .. "\".$newlinePress this button to keep it unchanged.$newline$newline"
					end

					local deviceString = "keyboard"

					return "Press a button on your " ..
						deviceString ..
						" to change this setting.$newline$newline" ..
						keepSettingString .. "Press \"" .. goBackString .. "\" to go back and clear this setting."
				end

				constructedArgs.Info = info.Description
			end

			ModConfigMenu.AddSetting(
				"Furtherance", -- category name
				group, -- group name
				constructedArgs
			)
		end
	end
end
