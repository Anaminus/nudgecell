local Const = require(script.Parent.Const)
local Lion = require(script.Parent.Lion)
local Assets = require(script.Parent.Assets)
local Driver = require(script.Parent.Driver)
local Maid = require(script.Parent.Maid)
local Util = require(script.Parent.Util)

local Terrain = workspace.Terrain
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local driver = Driver.new(plugin)

local toolbar = driver.Plugin:CreateToolbar(Const.ID.Toolbar)
local toolbarToggleActive = toolbar:CreateButton(
	Const.ID.ToolbarToggleActive,
	Lion.Toolbar_ToggleActive_Tooltip(),
	Assets.Icon(32),
	Lion.Toolbar_ToggleActive_Text()
)
toolbarToggleActive.ClickableWhenViewportHidden = false

driver.Maid.toolbarToggleActive = toolbarToggleActive.Click:Connect(function()
	if driver.Plugin:IsActivated() then
		driver:Deactivate()
	else
		driver:Activate(true)
	end
end)

function driver:OnActivated()
	local maid = Maid.new()
	self.Maid.activeMaid = maid

	toolbarToggleActive:SetActive(true)
	function maid.setActive()
		toolbarToggleActive:SetActive(false)
	end

	local mouse = self.Plugin:GetMouse()
	local camera = workspace.CurrentCamera
	maid.cameraChanged = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		camera = workspace.CurrentCamera
	end)

	local ui2d = script.Parent.NudgeUI2D:Clone()
	local ui3d = script.Parent.NudgeUI3D:Clone()
	maid:TaskEach(ui2d, ui3d)

	local label = ui2d.Label
	local box = ui3d.TargetBox
	local handleUI = ui3d.Handle
	local handleUId = ui3d.HandleDimmed
	local ruler = ui3d.Ruler
	local minTick = ui3d.MinTick
	local maxTick = ui3d.MaxTick
	local curTick = ui3d.CurTick

	ruler.Adornee = Terrain
	ruler.Visible = false
	minTick.Visible = false
	minTick.Adornee = Terrain
	maxTick.Visible = false
	maxTick.Adornee = Terrain
	curTick.Visible = false
	curTick.Adornee = Terrain
	label.Size = UDim2.new(0,20,0,20)
	handleUI.Adornee = Terrain
	handleUI.Radius = Const.MaxRadius
	handleUI.InnerRadius = Const.MaxRadius-Const.HandleThickness
	handleUId.Adornee = Terrain
	handleUId.Radius = Const.MaxRadius
	handleUId.InnerRadius = Const.MaxRadius-Const.HandleThickness

	local hovering = false
	local dragging = false

	-- Rotation part of camera CFrame.
	local function cameraRotation()
		local cf = camera.CFrame
		return (cf-cf.Position)
	end

	local function updateLabelPosition(pos, angle)
		local p = camera:WorldToViewportPoint(pos)
		if angle then
			-- Place next to tick position, offset according to the angle of the ruler.
			local offset = Vector2.new(math.sin(angle), math.cos(angle))*30
			-- Include additional offset on X axis to account for width of label.
			label.Position = UDim2.fromOffset(p.X-10-offset.X-math.sin(angle)*20,p.Y-10-offset.Y)
			return
		end
		label.Position = UDim2.fromOffset(p.X-10,p.Y-10)
	end

	local function updateHandleStyle()
		if hovering then
			handleUI.Transparency = 0.7
			handleUId.Transparency = 0.7
		else
			handleUI.Transparency = 0.8
			handleUId.Transparency = 0.8
		end
	end

	local function isSnapping()
		return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
	end

	local function updateRuler(origin, angle, dist, offset, click, snap)
		local camRot = cameraRotation()
		local rot = camRot*CFrame.Angles(0,0,angle)
		origin = CFrame.new(origin)*rot*CFrame.new(offset,0,0)
		local target = CFrame.new(origin.Position)*rot*CFrame.new(dist,0,0)

		local rulerRot = CFrame.lookAt(origin.Position, target.Position, camRot.UpVector)
		rulerRot = (rulerRot-rulerRot.Position)
		ruler.Size = Vector3.new(0, Const.RulerThickness, dist-0.05)
		ruler.CFrame = CFrame.new((origin.Position+target.Position)/2)*rulerRot
		minTick.CFrame = CFrame.new(origin.Position)*rulerRot
		maxTick.CFrame = CFrame.new(target.Position)*rulerRot
		local ray = Ray.new(origin.Position,rulerRot.LookVector)
		local p = ray:ClosestPoint(click)
		local d = (target.Position-origin.Position).Magnitude
		local n = (p-origin.Position).Magnitude/d
		n = math.clamp(n, 0, 1)
		if snap then
			n = math.floor(n*Const.SnapIncrement)/Const.SnapIncrement
		else
			n = math.floor(n*Const.CellIncrement)/Const.CellIncrement
		end
		if n == 0 then
			p = origin.Position
		else
			p = (p-origin.Position).Unit*n*d+origin.Position
		end
		curTick.CFrame = CFrame.new(p)*rulerRot
		return n, p
	end

	local probe = Vector3.new()
	local region = Region3.new()
	local tmat, tocc = {{{Enum.Material.Air}}}, {{{0}}}
	local angle = 0
	local dist = 0
	local offset = 0
	local function move()
		local click = camera:ViewportPointToRay(mouse.X, mouse.Y, 0)
		local clickOnPlane = Util.rayPlane(click, Ray.new(probe, cameraRotation().LookVector))
		if clickOnPlane == nil then
			return
		end
		local snapping = isSnapping()
		local occ, tickPos = updateRuler(probe, angle, dist, offset, clickOnPlane, snapping)
		updateLabelPosition(tickPos, angle)

		if snapping then
			label.Text = string.format("%d/%d",occ*Const.SnapIncrement,Const.SnapIncrement)
		else
			label.Text = string.format("%.3g",occ)
		end
		tocc[1][1][1] = occ
		Terrain:WriteVoxels(region, 4, tmat, tocc)
	end

	local size = Vector3.new(0.5,0.5,0.5)
	local function update()
		if dragging then
			move()
			return
		end
		local cell = Terrain:WorldToCell((camera.CFrame * CFrame.new(0,0,-Const.SubjectOffset)).Position)
		probe = (cell+size)*Const.CellResolution
		region = Region3.new(probe-size, probe+size):ExpandToGrid(4)
		tmat, tocc = Terrain:ReadVoxels(region, Const.CellResolution)
		local occ = tocc[1][1][1]
		box.CFrame = CFrame.new(probe)

		handleUI.CFrame = CFrame.new(probe)*cameraRotation()
		if Const.FIX_CHA_INPUT then
			handleUI.CFrame *= CFrame.Angles(math.rad(0.01),0,0)
		end
		handleUId.CFrame = handleUI.CFrame

		if tocc.Size ~= Vector3.new(1,1,1) then
			label.Text = "?"
			return
		end
		label.Text = string.format("%.3g",occ)
		updateLabelPosition(probe)
	end

	local function down()
		if dragging then
			return
		end
		dragging = true

		box.Parent = nil
		ruler.Visible = true
		minTick.Visible = true
		maxTick.Visible = true
		curTick.Visible = true
		handleUI.Visible = false
		handleUId.Visible = false

		if tmat[1][1][1] == Enum.Material.Air then
			tmat[1][1][1] = Util.sampleMaterial(tmat[1][1], region)
		end

		local probe2D = camera:WorldToViewportPoint(probe)
		local click = camera:ViewportPointToRay(mouse.X, mouse.Y, 0)
		local clickOnPlane = Util.rayPlane(click, Ray.new(probe, cameraRotation().LookVector))
		local length = (clickOnPlane-probe).Magnitude
		angle = math.atan2(probe2D.Y-mouse.Y,mouse.X-probe2D.X)
		dist = Const.CellResolution/2
		offset = length-(tocc[1][1][1])*dist
		local _, tickPos = updateRuler(probe, angle, dist, offset, clickOnPlane, isSnapping())
		updateLabelPosition(tickPos, angle)

		local function up()
			if not dragging then
				return
			end
			maid.handleUp = nil
			maid.handleMove = nil
			maid.setWaypoint = nil

			ruler.Visible = false
			minTick.Visible = false
			maxTick.Visible = false
			curTick.Visible = false
			handleUI.Visible = true
			handleUId.Visible = true
			box.Parent = ui3d

			dragging = false

			update()
			updateHandleStyle()
		end

		maid.handleMove = mouse.Move:Connect(move)
		maid.handleUp = mouse.Button1Up:Connect(up)
		function maid.setWaypoint()
			ChangeHistoryService:SetWaypoint("Nudge terrain cell")
		end

		updateHandleStyle()
		move()
	end

	local function enter()
		hovering = true
		updateHandleStyle()
	end

	local function leave()
		hovering = false
		updateHandleStyle()
	end

	maid.update = camera:GetPropertyChangedSignal("CFrame"):Connect(update)
	maid.handleDown = handleUId.MouseButton1Down:Connect(down)
	maid.handleEnter = handleUId.MouseEnter:Connect(enter)
	maid.handleLeave = handleUId.MouseLeave:Connect(leave)

	ui2d.Parent = CoreGui
	ui3d.Parent = CoreGui

	updateHandleStyle()
	update()
end

function driver:OnDeactivated()
	self.Maid.activeMaid = nil
end
