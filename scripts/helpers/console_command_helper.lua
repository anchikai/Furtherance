--Full credit to Epiphany
local Mod = Furtherance

local CMDHelper = {}
Furtherance.ConsoleCommandHelper = CMDHelper
CMDHelper.CMDs = {}

local parentInfos = {}

Furtherance.ConsoleCommandPrefix = "furtherance"

CMDHelper.ArgumentTypes = {
	String = "string",
	Number = "number",
	Boolean = "boolean",
}

local function splitArgs(args)
	local argsTab = {}
	-- Split command args by spaces and write them into a table
	for i in string.gmatch(args, "%S+") do
		table.insert(argsTab, i)
	end

	return argsTab
end

-- Creates a new argument for a console command. This is used to make the command more user-friendly.
---@param argument_name string @Name of the argument
---@param argument_description string @Description of what the argument does
---@param argument_type string | string[] @Data type of the argument. Use the CMDHelper.ArgumentTypes enumerator table, or a table of strings to for a multiple-choice argument. Add the string "__wildcard" somewhere in that table to allow DSS users to type in a custom string, as opposed to selecting from the list
---@param optional boolean? @Whether or not the argument is optional. Defaults to false. Optional arguments must be at the end of the argument list
---@scope Furtherance.ConsoleCommandHelper
function CMDHelper:MakeArgument(argument_name, argument_description, argument_type, optional)
	return {
		Name = argument_name,
		Description = argument_description,
		Type = argument_type,
		Optional = optional or false,
	}
end

-- Creates a new console command
---@param command_name string @Name of the command to add
---@param command_description string @Description of the command to add
---@param arguments table[] @A table of arguments to add to the command, or an empty table for no arguments. Use CMDHelper:MakeArgument to create arguments
---@param command_func function @Function to run when the command is ran. Arguments are packed into a table and are provided as the type specified, e.g. a number argument will be provided as a number
---@scope Furtherance.ConsoleCommandHelper
function CMDHelper:Create(command_name, command_description, arguments, command_func)
	local hasOptional = false
	for _, arg in ipairs(arguments) do
		if arg.Optional then
			hasOptional = true
		elseif hasOptional then -- Non-optional argument found after an optional argument
			error("[Furtherance] Error creating command [" ..
				command_name .. "]: Non-optional argument found after an optional argument.")
		end
	end

	CMDHelper.CMDs[command_name] = {
		Name = command_name,
		Description = command_description,
		Parent = "",
		Arguments = arguments,
		Func = command_func,
		RequiresConfirmation = false,
	}
end

-- Sets the parent of a command. This is used to assign subcommands to a main command (e.g. "unlock" as the parent of "all" will make the command "unlock all")
---@param command_name string @Command to set the parent of
---@param parent_name string @Name of the parent command
---@scope Furtherance.ConsoleCommandHelper
function CMDHelper:SetParent(command_name, parent_name)
	CMDHelper.CMDs[command_name].Parent = parent_name
end

-- Used for REPENTOGON autocomplete. Use this when making a new parent name.
function CMDHelper:AddParentDescription(parent_name, description)
	parentInfos[parent_name] = description
end

---@param command_name string @Command to remove
---@scope Furtherance.ConsoleCommandHelper
function CMDHelper:Remove(command_name)
	CMDHelper.CMDs[command_name] = nil
end

-- Sets whether a command requires confirmation before running. Only applies to the DSS menu.
---@param command_name string @Command to set the confirmation requirement for
---@param has_confirmation boolean @Whether the command requires confirmation.
---@scope Furtherance.ConsoleCommandHelper
function CMDHelper:SetRequiresConfirmation(command_name, has_confirmation)
	CMDHelper.CMDs[command_name].RequiresConfirmation = has_confirmation
end

---@param command_name string @Command to run
---@param ... any @Arguments to pass to the command
---@return string | boolean @Returns true if the command was ran successfully, false if not
---@scope Furtherance.ConsoleCommandHelper
function CMDHelper:Run(command_name, ...)
	local args = { ... }
	local command = CMDHelper.CMDs[command_name]

	local argumentsLength = 0

	for _, argument in ipairs(command.Arguments) do
		if not argument.Optional then
			argumentsLength = argumentsLength + 1
		end
	end

	for i, arg in ipairs(args) do
		local originalType = type(arg)
		local argExists = arg ~= nil
		local tooManyArguments = i > argumentsLength

		if tooManyArguments and not command.Arguments[i].Optional then
			return "[Furtherance] Error running command [" .. command_name .. "]: Too many arguments provided."
		end

		if not argExists then
			arg = nil
		end

		if argExists and command.Arguments[i].Type == CMDHelper.ArgumentTypes.Boolean then
			if arg == "true" or arg == "on" or arg == true then
				arg = true
			elseif arg == "false" or arg == "off" or arg == false then
				arg = false
			else
				arg = nil
			end
		end

		if argExists and command.Arguments[i].Type == CMDHelper.ArgumentTypes.Number then
			arg = tonumber(arg)
		end

		if argExists and command.Arguments[i].Type == CMDHelper.ArgumentTypes.String then
			arg = tostring(arg)
		end

		if argExists and command.Arguments[i].Type == "table" then
			local found = false
			for _, type in ipairs(command.Arguments[i].Type) do
				if type == tostring(arg) or type == "__wildcard" then -- wildcard is a special type that will accept any string
					found = true
					arg = tostring(arg)
					break
				end
			end

			if not found then
				arg = nil
			end
		end

		if arg == nil then
			if argExists then
				return "[Furtherance] Error running command [" ..
					command_name ..
					"]: Argument " ..
					i .. " is of type " .. originalType .. " but should be of type " .. command.Arguments[i].Type
			else
				return "[Furtherance] Error running command [" .. command_name .. "]: Argument " .. i .. " does not exist."
			end
		end

		args[i] = arg
	end

	if #args < argumentsLength then
		return "[Furtherance] Error running command [" .. command_name .. "]: Not enough arguments provided."
	end

	-- Everything works! Run the command
	return command.Func(args)
end

---@param command string
---@param args string
---@scope Furtherance.ConsoleCommandHelper
function CMDHelper:OnCommand(command, args)
	local argsTab = splitArgs(args)
	local targetCommandName

	-- Require the prefix to maintain consistency with all of our commands
	if command ~= Furtherance.ConsoleCommandPrefix then
		return
	end

	-- Check if the command exists
	for _, cmd in pairs(CMDHelper.CMDs) do
		local cmdName = cmd.Parent ~= "" and cmd.Parent .. " " .. cmd.Name or cmd.Name
		local cmdNameSplit = splitArgs(cmdName)

		if #cmdNameSplit <= #argsTab then -- If the command name is longer than the arguments, then it can't be the command
			for i = 1, #cmdNameSplit do
				if cmdNameSplit[i] ~= argsTab[i] then
					break
				end

				if i == #cmdNameSplit then
					-- Found the real name of the command
					targetCommandName = cmdNameSplit[i]

					for _ = 1, #cmdNameSplit do -- Remove the command name from the arguments
						table.remove(argsTab, 1)
					end

					local success = CMDHelper:Run(targetCommandName, table.unpack(argsTab))
					if type(success) ~= "string" then
						print("[Furtherance] Ran command [" .. cmdName .. "] successfully!")
					else
						print(success)
					end
					return
				end
			end
		end
	end

	-- Command not found
	print("[Furtherance] Command not found.")
end

Mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, CMDHelper.OnCommand)

if REPENTOGON then
	Console.RegisterCommand(
		Furtherance.ConsoleCommandPrefix,
		"Debug commands for Furtherance",
		"Usage: furtherance command_name",
		true,
		AutocompleteType.CUSTOM
	)

	function CMDHelper:RepentogonAutocomplete(_, args)
		local argsSplit = splitArgs(args:lower())

		local parents = {}
		for _, registeredCmd in pairs(CMDHelper.CMDs) do
			local clone = Furtherance:CopyTable(registeredCmd)
			table.sort(clone.Arguments, function(a, b)
				return a.Name < b.Name
			end)

			parents[clone.Parent] = parents[clone.Parent] or {}
			table.insert(parents[clone.Parent], clone)
		end

		local parentOrder = {}
		local hasParentPrefix = false
		for str in pairs(parents) do
			parentOrder[#parentOrder + 1] = str
			if str == argsSplit[1] then
				hasParentPrefix = true
			end
		end

		table.sort(parentOrder)

		local returnTable = {}
		for _, parent in ipairs(parentOrder) do
			if hasParentPrefix or parent == "" then
				local cmdInfos = parents[parent]
				for _, cmdInfo in ipairs(cmdInfos) do
					local parentPrefix = parent and parent ~= "" and parent .. " " or ""
					local name = parentPrefix .. cmdInfo.Name
					local description = cmdInfo.Description

					if #cmdInfo.Arguments > 0 then
						description = description .. " Args: "
					end

					for i, cmdArg in ipairs(cmdInfo.Arguments) do
						local argNameStr = cmdArg.Optional and cmdArg.Name .. "?" or cmdArg.Name
						local argTypeStr = type(cmdArg.Type) == "table" and table.concat(cmdArg.Type, "|") or cmdArg
						.Type
						argTypeStr = string.gsub(argTypeStr, "__wildcard", "any")

						description = description .. "<" .. argNameStr .. ":" .. argTypeStr .. ">"

						if i < #cmdInfo.Arguments then
							description = description .. ", "
						end
					end
					table.insert(returnTable, {
						name,
						description
					})
				end
			else
				table.insert(returnTable, 1, {
					parent,
					parentInfos[parent] or "Parent command."
				})
			end
		end

		return returnTable
	end

	Furtherance:AddCallback(ModCallbacks.MC_CONSOLE_AUTOCOMPLETE, CMDHelper.RepentogonAutocomplete, Furtherance.ConsoleCommandPrefix)
end
