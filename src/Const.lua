return {
	-- ID contains identifiers that must be unique in the Studio namespace.
	ID = {
		Toolbar             = "Terrain",
		ToolbarToggleActive = "Nudge_Toolbar_ToggleActive",
		ActionToggleActive  = "Nudge_Action_ToggleActive",
	},
	-- Resolution of terrain cells.
	CellResolution = 4,
	-- Distance from camera to subject cell, in studs.
	SubjectOffset = 12,
	-- Outer radius of selection handle, in studs.
	MaxRadius = math.sqrt(2*((4)/2)^2),
	-- Width of handle, in studs.
	HandleThickness = 1,
	-- Width of ruler, in studs.
	RulerThickness = 0.2,
	-- Cells have occupancy resolution of 1/256.
	CellIncrement = 256,
	-- Number of divisions in snapping mode.
	SnapIncrement = 24,
	-- https://devforum.roblox.com/t/1201458
	FIX_CHA_INPUT = true,
}
