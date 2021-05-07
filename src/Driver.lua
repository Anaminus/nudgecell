local Maid = require(script.Parent.Maid)

local Driver = {__index={}}

local function new(plugin)
	local self = {
		Plugin = plugin,
		Maid = Maid.new(),
	}
	self.Maid.deactivation = plugin.Deactivation:Connect(function()
		self:OnDeactivated()
	end)
	self.Maid.unloading = plugin.Unloading:Connect(function()
		self.Maid:FinishAll()
	end)
	return setmetatable(self, Driver)
end

function Driver.__index:Activate(exclusiveMouse)
	if self.Plugin:IsActivated() then
		return
	end
	self.Plugin:Activate(exclusiveMouse)
	-- No Activation signal, so call it here.
	self:OnActivated()
end

function Driver.__index:Deactivate()
	if not self.Plugin:IsActivated() then
		return
	end
	self.Plugin:Deactivate()
end

return {
	new = new,
}