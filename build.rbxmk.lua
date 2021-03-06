local targetPath, assetPath = ...

targetPath = targetPath or "NudgeCell.rbxm"
local ext = os.split(targetPath, "fext")
if ext ~= ".rbxm" and ext ~= ".rbxmx" then
	print(string.format("incompatable extension %q", ext))
	return
end
print("Building", targetPath)

-- Add each module in dir as a child to target.
local function addModules(dir, target)
	for _, f in ipairs(fs.dir(dir)) do
		if not f.IsDir and os.split(f.Name, "fext") == ".lua" then
			local script = fs.read(os.join(dir, f.Name))
			script.Parent = target
		end
	end
end

-- Read plugin config file.
local config = fs.read("plugin.json")

-- Create plugin root.
local plugin = DataModel.new()
local folder = Instance.new("Folder")
folder.Name = "NudgeCell"
folder.Parent = plugin

-- Include main script with version number.
local main = fs.read("src/Main.script.lua")
main.Source = types.ProtectedString("-- v" .. config.Version .. "\n\n" .. main.Source.Value)
main.Parent = folder

-- Include modules.
fs.read("src/Const.lua").Parent = folder
fs.read("src/Driver.lua").Parent = folder
fs.read("src/Maid.lua").Parent = folder
fs.read("src/Util.lua").Parent = folder

-- Include asset data.
local assets = fs.read("src/Assets.lua")
assets.Parent = folder
if assetPath then
	local data = fs.read("assets/data_dev.lua")
	data.Name = "data"
	data.Parent = assets
else
	fs.read("assets/data.lua").Parent = assets
end

-- Include localization data.
local lion = fs.read("src/Lion.lua")
lion.Parent = folder
addModules("l10n", lion)

-- Include UI models.
local ui = fs.read("src/UI.rbxlx")
ui:Descend("Workspace", "NudgeUI3D").Parent = folder
ui:Descend("StarterGui", "NudgeUI2D").Parent = folder

-- Copy logo to asset directory.
if assetPath then
	local dir = os.join(assetPath, "nudgecell")
	fs.mkdir(dir)

	local logo32 = fs.read("assets/logo/logo_32.png", "bin")
	fs.write(os.join(dir, "logo_32.png"), logo32, "bin")
end

-- Write plugin file.
fs.write(targetPath, plugin)
