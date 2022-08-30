-- hierarchy
--[[ MarchingCubesService.lua
     |_ Draw3DTriangle.lua
        |_ Triangle.rbxm
     |_ TriangulationTable.lua
]]

local MarchingCubesService = {}
MarchingCubesService.__index = MarchingCubesService

local MarchingCubesClass = {}
MarchingCubesClass.__index = MarchingCubesClass

-- optimisations
local SetMetatable = setmetatable
local V3 = Vector3.new
local Tick = tick
local Task = task
local TWait = Task.wait
local Table = table
local TableInsert = Table.insert
local Req = require

local TRIANGULATION_TABLE = Req(script.TriangulationTable)
local Draw3DTriangle = Req(script.Draw3DTriangle)

local ISOVALUE = 0

-- Tables For Marching Cubes Algorithm
local midpoints = {
	{0,1}, {1,2}, {2,3}, {3,0},
	{4,5}, {5,6}, {6,7}, {7,4},
	{0,4}, {1,5}, {2,6}, {3,7}
}

local lastTick = Tick()
local lastTime = 1
local stress = 8
local function properWait()
	local tic2 = Tick()
	local tim = tic2-lastTick
	if (tim/stress)<=lastTime then
		lastTime = tim
		lastTick = tic2
		return true
	end
	lastTime = tim
	lastTick = tic2
	TWait()
	return true
end

local function defaultNoiseFunc(x,y,z)
	return math.noise(x/50,y/50,z/50) * 5
end

-- interpolates between 2 positions using 2 values
function MarchingCubesClass:interpolate(pos1, pos2)
	if not self.Smooth then return (pos1 + pos2)/2 end

	local val1 = self.Positions[pos1]
	local val2 = self.Positions[pos2]

	local interpolatedPos = pos1+((ISOVALUE-val1)/(val2-val1))*(pos2-pos1)

	return interpolatedPos
end

function MarchingCubesService.new(args)
	local localPos, localSize, gap, material, color, noiseFunc, smooth = args.LocalPosition, args.LocalSize, args.Gap, args.Material, args.Color, args.NoiseFunc, args.Smooth
	
	local offsets = {
		V3(args.Gap, 0, 0),
		V3(args.Gap, 0, args.Gap),
		V3(0, 0, args.Gap),

		V3(0, args.Gap, 0),
		V3(args.Gap, args.Gap, 0),
		V3(args.Gap, args.Gap, args.Gap),
		V3(0, args.Gap, args.Gap),
	}
	
	local data = {
		LocalPosition = localPos,
		LocalSize = localSize,
		Gap = gap,
		Offsets = offsets,
		Positions = {},
		Material = material,
		Color = color,
		Smooth = smooth
	}
	
	local startX, startZ, startY = localPos.X*gap, localPos.Y*gap, 0
	local endX, endZ, endY = (localSize.X*gap)+startX, (localSize.Z*gap)+startZ, localSize.Y*gap
	
	for x = startX,endX,gap do
		for y = startY,endY,gap do
			for z = startZ,endZ,gap do
				local pos = V3(x,y,z)
				--[[local Part = Instance.new("Part")
				Part.Anchored = true
				Part.Size = Vector3.new(1,1,1)
				Part.Position = pos
				Part.Shape = Enum.PartType.Ball
				Part.Parent = workspace]]
				
				local noise = (noiseFunc or defaultNoiseFunc)(x,y,z)
				data.Positions[pos] = noise
			end
		end
	end
	
	return SetMetatable(data, MarchingCubesClass)
end

function MarchingCubesClass:march(startPos)
	local offsets, positions = self.Offsets, self.Positions

	local currPositions = {
		startPos, startPos+offsets[1], startPos+offsets[2], startPos+offsets[3],
		startPos+offsets[4], startPos+offsets[5], startPos+offsets[6], startPos+offsets[7]
	}

	local index = (positions[startPos] < ISOVALUE and 0 or 1)
		+(positions[startPos+offsets[1]] < ISOVALUE and 0 or 2)
		+(positions[startPos+offsets[2]] < ISOVALUE and 0 or 4)
		+(positions[startPos+offsets[3]] < ISOVALUE and 0 or 8)
		+(positions[startPos+offsets[4]] < ISOVALUE and 0 or 16)
		+(positions[startPos+offsets[5]] < ISOVALUE and 0 or 32)
		+(positions[startPos+offsets[6]] < ISOVALUE and 0 or 64)
		+(positions[startPos+offsets[7]] < ISOVALUE and 0 or 128)
	index = TRIANGULATION_TABLE[index+1]

	if index == 0 or index == 256 then return end

	-- marches the cube
	for count=1,#index/3 do
		local index1 = midpoints[index[(1-3)+(3*count)]+1]
		local index2 = midpoints[index[(2-3)+(3*count)]+1]
		local index3 = midpoints[index[(3-3)+(3*count)]+1]

		if index1 == nil or index2 == nil or index3 == nil then continue end

		local positions1 = {currPositions[index1[1]+1],currPositions[index1[2]+1]}
		local positions2 = {currPositions[index2[1]+1],currPositions[index2[2]+1]}
		local positions3 = {currPositions[index3[1]+1],currPositions[index3[2]+1]}

		Draw3DTriangle(
			self:interpolate(positions1[1], positions1[2]),
			self:interpolate(positions2[1], positions2[2]),
			self:interpolate(positions3[1], positions3[2]),
			self.Material,
			self.Color
		)

		properWait()	
	end

	currPositions = nil
end

function MarchingCubesClass:marchAll()
	local localPos, localSize, gap = self.LocalPosition, self.LocalSize, self.Gap
	
	local startX, startZ, startY = localPos.X*gap, localPos.Y*gap, 0
	local endX, endZ, endY = (localSize.X*gap)+startX, (localSize.Z*gap)+startZ, localSize.Y*gap
	
	for x = startX,endX-gap,gap do
		for y = startY,endY-gap,gap do
			for z = startZ,endZ-gap,gap do
				self:march(V3(x,y,z))
			end
			properWait()
		end
	end
end


return MarchingCubesService
