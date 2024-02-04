local Module = {}

local Modules = script.Parent
local Instances = require(Modules.Instances)

--// Converts passed args to Vector3
function Module.ConvertToVector3(A: any): Vector3 
	local B = typeof(A)

	A = ( B == "Instance" and A:IsA("Model") and A.PrimaryPart and A:GetPivot().Position ) or
		( B == "Instance" and A:IsA("Model") and not A.PrimaryPart and A.WorldPivot.Position )  or
		( B == "Instance" and A:IsA("BasePart") and A.Position ) or
		( B == "CFrame" and A.Position ) or
		( B == "Vector3" and A )

	assert(A,"ConvertToV3 Error: Could not identify/convert")

	return A
end

function Module.IsBehind(A: CFrame, B: CFrame): boolean
	return Module.GetMagnitude(A*CFrame.new(0,0,-1),B) > Module.GetMagnitude(A,B)
end

function Module.GetMagnitude(A: Vector3 | Vector2, B: Vector3 | Vector2): number
	return (Module.ConvertToVector3(A)-Module.ConvertToVector3(B)).Magnitude
end

function Module.QuadBezierLerp(a, b, c): Vector3
	return a + ( b - a ) * c
end

function Module.CalculateQuadezier(DeltaTime: number, Origin: Vector3, Height: Vector3, Goal: Vector3)
	--local Point1 = QuadBezierLerp(Origin, Height, DeltaTime)
	--local Point2 = QuadBezierLerp(Height, Goal, DeltaTime)
	return Module.QuadBezierLerp( Module.QuadBezierLerp(Origin, Height, DeltaTime) , Module.QuadBezierLerp(Height, Goal, DeltaTime) , DeltaTime)
end

function Module.QuadraticBezierCurve(Origin: Vector3, Middle: Vector3, Goal: Vector3, SmoothForDistance: boolean?, DebugMode: boolean?): {Vector3}
	local Increment = (SmoothForDistance and .05 / math.max(1, ( Origin - Middle - Goal ).Magnitude / 100 )) or .05
	local Points = {Origin}

	for loop = 0, 1, Increment do
		table.insert(Points, Module.CalculateQuadraticBezier(loop, Origin, Middle, Goal) )
	end

	table.insert(Points, Goal)

	if DebugMode then
		for _, Point in pairs(Points) do

			local Part = Instance.new("Part")

			--Debris:AddItem(Part, 15)

			Part.Size = (
				Point == Origin and Vector3.one*2 or 
					Point == Goal and Vector3.one*2 or 
					Vector3.one
			)

			Part.Color = (
				Point == Origin and Color3.fromRGB(0, 0, 255) or 
					Point == Goal and Color3.fromRGB(85, 255, 127) or 
					Color3.fromRGB(255, 170, 0)
			)
			Part.Name = "Yarr"
			Part.Transparency = .5
			Part.Anchored = true
			Part.CFrame = CFrame.new(Point)
			Part.Parent = workspace
		end
	end

	return Points
end

function Module.GetTrajectory(Force: Vector3, Origin: Vector3, Goal: Vector3, Segments: number?, RayParams: RaycastParams?, DebugMode: boolean): ({Vector3}, Vector3)
	local Points = {}
	local Ceiling = Origin
	local Midpoint = Origin:Lerp(Goal, .5)
	local LastPoint = Origin

	Segments = math.max(1, Segments or 1)

	for Time = 0, 1, .1 / Segments do
		local Point = Origin + (Force * Time)  
		Point = Vector3.new(Point.X, 
			Origin.Y + (Force.Y * Time) - ((workspace.Gravity / 2) * Time * Time),
			Point.Z)

		--// Collision check
		if RayParams then
			local Result = workspace:Raycast(LastPoint, (Point-LastPoint), RayParams)

			if Result and Result.Position then

				if DebugMode then
					--		Util.DrawLaser(LastPoint, Result.Position)
				end

				break
			end
		end

		Ceiling = Point.Y > Ceiling.Y and Point or Ceiling --// We want to get the highest point of the entire calculated trajectory

		LastPoint = Point
		table.insert(Points, Point)

	end

	Ceiling = Vector3.new(Midpoint.X, Ceiling.Y, Midpoint.Z)

	return Points, Ceiling
end

--// g as Gravity, v0 as Velocity,  x0 as Origin position, t1 as time, g as Gravity (duh)
function Module.GetBeamTrajectoryData(v0: Vector3, x0: Vector3, t1: number, g: number?): (number, number, CFrame, CFrame)
	g = Vector3.new(0, -(g or workspace.Gravity), 0)
	
	--// Bezier points
	local c = 0.5*0.5*0.5
	local p3 = 0.5*g*t1*t1 + v0*t1 + x0
	local p2 = p3 - (g*t1*t1 + v0*t1)/3
	local p1 = (c*g*t1*t1 + 0.5*v0*t1 + x0 - c*(x0+p3))/(3*c) - p2
	
	--// Curve sizes
	local curve0 = (p1 - x0).magnitude
	local curve1 = (p2 - p3).magnitude
	
	--// CFrame
	local b = (x0 - p3).unit
	local r1 = (p1 - x0).unit
	local u1 = r1:Cross(b).unit
	local r2 = (p2 - p3).unit
	local u2 = r2:Cross(b).unit
	b = u1:Cross(r1).unit

	local cf0 = CFrame.new(
		(x0.x), (x0.y), (x0.z),
		r1.x, u1.x, b.x,
		r1.y, u1.y, b.y,
		r1.z, u1.z, b.z)

	local cf1 = CFrame.new(
		(p3.x), (p3.y), (p3.z),
		r2.x, u2.x, b.x,
		r2.y, u2.y, b.y,
		r2.z, u2.z, b.z)

	return curve0, -curve1, cf0, cf1
end


function Module.VisualizeTrajectory(TrajectoryBeam: Beam, Projectile: BasePart)
	
	assert(TrajectoryBeam.Attachment0 and TrajectoryBeam.Attachment1, "Trajectory beam MUST have assigned Attachment0 & Attachment1!") 
	
	local Ata0, Ata1 = TrajectoryBeam.Attachment0, TrajectoryBeam.Attachment1
	local Origin, Goal = Ata0.WorldPosition, Ata1.WorldPosition
	
	local Force, TravelTime, Goal  = Module.GetForceNeeded(Origin, Goal, Projectile)
	local CurveSize0, CurveSize1, CFrame0, CFrame1 = Module.GetBeamTrajectoryData(Force, Origin, TravelTime)
	
	TrajectoryBeam.CurveSize0 = CurveSize0
	TrajectoryBeam.CurveSize1 = CurveSize1

	Ata0.WorldCFrame = CFrame0
	Ata1.WorldCFrame =  CFrame1
	
end

function Module.GetForceNeeded(Origin: Vector3, Goal: Vector3, Projectile: BasePart?, MaxDistance: number?): (Vector3, number, Vector3, Vector3?)

	if MaxDistance then
		local Distance = (Origin - Goal).Magnitude
		local Direction = (Origin - Goal).Unit
		Goal = Origin - Direction * math.min(MaxDistance, Distance)
	end

	local Direction = Goal - Origin
	local TravelTime = math.log(1.001 + Direction.Magnitude * 0.01)
	local Force = Direction / TravelTime + Vector3.new(0, workspace.Gravity * TravelTime * 0.5, 0)

	return Force, TravelTime, Goal, Projectile and Force * Projectile.AssemblyMass or Force
end

return Module