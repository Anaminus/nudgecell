local Util = {}

local Terrain = workspace.Terrain

-- Find the most common non-air material in a 3x3x3 area.
function Util.sampleMaterial(output, region)
	local range = 3
	local min = region.CFrame.Position - region.Size*range/2
	local max = region.CFrame.Position + region.Size*range/2
	region = Region3.new(min, max):ExpandToGrid(4)
	local mat, occ = Terrain:ReadVoxels(region, 4)
	local samples = {}
	local max, maxm = 0, Enum.Material.Air
	for x = 1, mat.Size.X do
		for y = 1, mat.Size.Y do
			for z = 1, mat.Size.Z do
				local m = mat[x][y][z]
				samples[m] = (samples[m] or 0) + 1
				if samples[m] >= max and m ~= Enum.Material.Air then
					max = samples[m]
					maxm = m
				end
			end
		end
	end
	return maxm
end

-- Intersection of a ray and a plane.
--
-- https://geomalgorithms.com/a05-_intersect-1.html
function Util.rayPlane(ray, plane)
	local u = ray.Direction
	local w = ray.Origin - plane.Origin
	local d = plane.Direction:Dot(u)
	local n = -plane.Direction:Dot(w)
	if math.abs(d) < 1e-6 then
		if n == 0 then
			return nil -- segment in plane
		end
		return nil -- no intersection
	end
	local si = n/d
	if si < 0 then
		return nil -- no intersection
	end
	return ray.Origin + si*u
end

return Util
