---@param ptr EntityPtr
---@return EntityNPC?
function Furtherance:TryGetNPCFromPtr(ptr)
	if not ptr or not ptr.Ref then return end
	return ptr.Ref:ToNPC()
end

---@param npc EntityNPC
---@return Vector?
function Furtherance:GetStatusEffectOffset(npc)
	local sprite = npc:GetSprite()
	local nullFrame = sprite:GetNullFrame("OverlayEffect")
	local statusOffset = nullFrame ~= nil and nullFrame:IsVisible() and nullFrame:GetPos() or nil
	return statusOffset
end
