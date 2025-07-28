local allSettings = {}
local SettingsHelper = {}
Furtherance.SettingsHelper = SettingsHelper

Furtherance.SettingTypes = {
	Choice = 0,
	Keybind = 1,
	Boolean = 2,
}

-- Update this if you add more categories. Case sensitive!!!!!
-- If you don't add a category here, it won't show up in the settings menus.
SettingsHelper.Categories = {
	"General",
	"Tainted Peter"
}

--- Saves the value for a setting. Verifies that the setting exists before saving it.
---@param settingKey string
---@param value any
---@function
function Furtherance.SaveSetting(settingKey, value)
	local game_save = Furtherance:GameSave()

	if not game_save.FurtheranceSettings then
		game_save.FurtheranceSettings = {}
	end

	if SettingsHelper.GetSettingInfo(settingKey) then
		game_save.FurtheranceSettings[settingKey] = value
	end

	Furtherance.SaveManager.Save()
end

---Gets the value for a setting. Settings have default values, so unless the setting doesn't exist, this doesn't return nil.
---@return any?
---@function
function Furtherance.GetSetting(settingKey)
	local game_save = Furtherance:GameSave()

	if not game_save.FurtheranceSettings then
		game_save.FurtheranceSettings = {}
	end

	local setting = game_save.FurtheranceSettings[settingKey]

	if setting == nil then
		local info = SettingsHelper.GetSettingInfo(settingKey)
		if info then
			setting = info.Default
		else
			return
		end
	end

	return setting
end

---Returns the string value of current setting. Works only for choice settings.
function Furtherance.GetSettingStr(settingKey)
	local settingValue = Furtherance.GetSetting(settingKey)

	local settingInfo = SettingsHelper.GetSettingInfo(settingKey)

	if not settingInfo.Choices then
		error("Setting " .. settingKey .. " is not a choice setting")
	end
	return settingInfo.Choices[settingValue]
end

-- Gets all settings. This is used by the settings menu.
---@return table
---@function
function SettingsHelper.GetAllSettings()
	return allSettings
end

---@function
function SettingsHelper.GetSettingInfo(name)
	for _, group in pairs(allSettings) do
		for _, setting in pairs(group) do
			if setting.Name == name then
				return setting
			end
		end
	end
end

---@function
function SettingsHelper.GetDefault(settingKey)
	return SettingsHelper.GetSettingInfo(settingKey).Default
end

-- Creates a new multiple-choice setting.
---@param category string @The category the setting falls under.
---@param settingName string @The name of the setting. This is what will be displayed in the settings menu and how you'll get it with Furtherance.GetSetting()
---@param settingDescription any @The description of the setting. This is what will be displayed in the settings menu.
---@param possibleValues string[] @Array of possible values
---@param defaultValue number? @The index of the possibleValues array that is the default value. If this is nil, the first value in the array will be used.
---@param condition function? @A function that returns a boolean. If this function returns false, the setting will not be displayed.
---@function
function SettingsHelper.AddChoiceSetting(category, settingName, settingDescription, possibleValues, defaultValue,
										 condition)
	local group = allSettings[category]
	defaultValue = defaultValue or 1

	if group == nil then
		group = {}
		allSettings[category] = group
	end

	table.insert(group, {
		Name = settingName,
		Description = settingDescription,
		Default = defaultValue,
		Choices = possibleValues,
		Condition = condition,
		Type = Furtherance.SettingTypes.Choice,
	})
end

---@param category string @The category the setting falls under.
---@param settingName string @The name of the setting. This is what will be displayed in the settings menu and how you'll get it with Furtherance.GetSetting()
---@param settingDescription any @The description of the setting. This is what will be displayed in the settings menu.
---@param defaultValue boolean
---@param condition function? @A function that returns a boolean. If this function returns false, the setting will not be displayed.
---@function
function SettingsHelper.AddBooleanSetting(category, settingName, settingDescription, defaultValue, condition)
	local group = allSettings[category]

	if group == nil then
		group = {}
		allSettings[category] = group
	end

	table.insert(group, {
		Name = settingName,
		Description = settingDescription,
		Default = defaultValue,
		Condition = condition,
		Type = Furtherance.SettingTypes.Boolean,
	})
end

-- Creates a new keybind setting.
---@param category string @The category the setting falls under.
---@param settingName string @The name of the setting. This is what will be displayed in the settings menu and how you'll get it with Furtherance.GetSetting()
---@param settingDescription any @The description of the setting. This is what will be displayed in the settings menu.
---@param defaultKey Keyboard @The default key for the setting.
---@param condition function? @A function that returns a boolean. If this function returns false, the setting will not be displayed.
---@function
function SettingsHelper.AddKeybindSetting(category, settingName, settingDescription, defaultKey, condition)
	local group = allSettings[category]

	if group == nil then
		group = {}
		allSettings[category] = group
	end

	table.insert(group, {
		Name = settingName,
		Description = settingDescription,
		Default = defaultKey,
		Condition = condition,
		Type = Furtherance.SettingTypes.Keybind,
	})
end
