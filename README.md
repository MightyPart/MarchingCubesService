# MarchingCubesService

I created a module that can easily create caves in seconds. At the moment its basically just a tech demo that I may or may not improve on or add to at a later date.

Images of what can be generated:

![image](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/9/2/a/92ad05d7e5eb8277d382d95977d52d9177e6def1.jpeg)
![image](https://devforum-uploads.s3.dualstack.us-east-2.amazonaws.com/uploads/original/4X/5/2/1/5210d2607a7224fade23e5ab3b9d97e28f819d08.jpeg)

- - -

Install it here: https://www.roblox.com/library/10758841638/MarchingCubesService

- - -

# How It Works

It samples points in 3d space and each point is given a unique perlin noise value. Then it marches over the points uses the noise values to create a cave like stucture.

- - -

# How to use it

Example 1
```lua
local MarchingCubesService = require(game:GetService("ReplicatedStorage").MarchingCubesService)

local marching = MarchingCubesService.new{
	LocalPosition=Vector2.new(0,0), -- the x and z coords of where the caves will be created
	LocalSize=Vector3.new(60,60,60), -- the size of the caves
	Gap=6 -- the distance in studs between the sample points, this also affects the scale
}
marching:marchAll()
```

Example 2
```lua
local MarchingCubesService = require(game:GetService("ReplicatedStorage").MarchingCubesService)

local function noise(x,y,z)
	return math.noise(x/40,y/40,z/40)
end

local marching = MarchingCubesService.new{
	LocalPosition=Vector2.new(0,0), -- the x and z coords of where the caves will be created
	LocalSize=Vector3.new(30,30,30), -- the size of the caves
	Gap=10, -- the distance in studs between the sample points, this also affects the scale
	Material=Enum.Material.Grass, -- the material of the caves
	Color=Color3.fromRGB(111, 126, 62), -- the color of the caves
	Smooth=true, -- disables interpolation resulting in the caves being less smooth
	NoiseFunc=noise -- the function used for calculating the noise of a given point. Must accept "x,y,z" as arguements.
}
marching:marchAll()
```
