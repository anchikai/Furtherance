---@enum FurtheranceCallbacks
Furtherance.ModCallbacks = {

}

Furtherance.UniqueCallbackHandling = {

}

---@param id FurtheranceCallbacks
---@return any
function Furtherance.RunUniqueCallback(id, ...)
	local callbackName = string.gsub(id, "FURTHERANCE", "")
	if Furtherance.UniqueCallbackHandling[callbackName] then
		local callbacks = Isaac.GetCallbacks(id, true)
		table.sort(callbacks, function(a, b)
			return a.Priority < b.Priority
		end)
		return Furtherance.UniqueCallbackHandling[callbackName](callbacks, ...)
	end
end

