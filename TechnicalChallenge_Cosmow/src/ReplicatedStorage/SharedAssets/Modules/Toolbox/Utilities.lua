local Module = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")


function Module.DrawLaser(FromV3:Vector3,ToV3:Vector3)
	local Distance = (FromV3-ToV3).Magnitude
	local Part = Instance.new("Part")
	Debris:AddItem(Part, 1)
	Part.Material = Enum.Material.SmoothPlastic
	Part.BrickColor = BrickColor.new("Really red")
	Part.Size = Vector3.new(0.5,Distance,0.5)
	Part.CanCollide = false
	Part.CanQuery = false
	Part.CanTouch = false
	Part.Massless = true
	Part.Anchored = true
	Part.CFrame = CFrame.new(FromV3,ToV3) * CFrame.new(0,0,-Distance/2) * CFrame.Angles(math.rad(90),0,0)
	Part.Parent = workspace
	return Part
end

function Module.AttachOnDestroying(Item, Callback)
	if RunService:IsStudio() then

		local Con = nil

		Con = Item.AncestryChanged:Connect(function(_, NewParent: Instance?)

			if NewParent then 
				return 
			end

			if Con then 
				Con:Disconnect() 
			end

			Callback()
		end)
	else

		Item.Destroying:Once(function()
			Callback()
		end)
	end

end

function Module.PlayerIsValid(Player: Player?): boolean
	if not Player or not Player.Parent then 
		return false 
	end

	return true
end

function Module.CharIsValid(Player: Player?): boolean
	if not Module.PlayerIsValid(Player) or not Player.Character or not Player.Character.PrimaryPart 
		or not Player.Character:FindFirstChild("Humanoid") or Player.Character.Humanoid.Health <= 0 then

		return false 

	end
	return true
end

function Module.DisableMovement(Character: Model, Active: boolean)
	local Humanoid: Humanoid? = Character:FindFirstChildWhichIsA("Humanoid")

	if Humanoid then

		if Active then
			Humanoid:SetAttribute("Unique_OriginalWalkSpeed",Humanoid:GetAttribute("Unique_OriginalWalkSpeed") or Humanoid.WalkSpeed) 
			Humanoid:SetAttribute("Unique_OriginalJumpPower",Humanoid:GetAttribute("Unique_OriginalJumpPower") or Humanoid.JumpPower) 
		end

		Humanoid.WalkSpeed = Active and 0 or Humanoid:GetAttribute("Unique_OriginalWalkSpeed")
		Humanoid.JumpPower = Active and 0 or Humanoid:GetAttribute("Unique_OriginalJumpPower")
	else
		warn(Character,"Is missing a Humanoid!")

		Character.PrimaryPart.Anchored = Active
	end
end

function Module.WeldTo(A: BasePart, B: BasePart, Parent: Instance?): WeldConstraint
	local W = Instance.new("WeldConstraint")
	W.Name = A.Name.." > "..B.Name.. " Weld"
	W.Part0 = A
	W.Part1 = B
	W.Parent = Parent or A

	return W
end

function Module.GetProfilePic(UserId: Player | number): string
	return "https://www.roblox.com/headshot-thumbnail/image?userId="..(typeof(UserId) == "number" and UserId or UserId.UserId).."&width=420&height=420&format=png"
end

function Module.GetPlayerFromId(Id: number | string): Player?
	Id = tostring(Id)

	for _,plr in pairs(Players:GetPlayers()) do
		if Id == tostring(plr.UserId) or plr.Name == Id then
			return plr
		end
	end
end

function Module.WaitForDescendant(Ancestor: Instance, DescendantName: string, Timeout: number?): Instance?

	local Descendant = Ancestor:FindFirstChild(DescendantName, true)
	local Stamp = tick()

	Timeout = Timeout or 5

	while not Descendant and tick()-Stamp < Timeout do

		Descendant = Ancestor:FindFirstChild(DescendantName, true)

		if Descendant then 
			break 
		end    

		task.wait()
	end

	if not Descendant then 
		warn("Stall time elapse limit reached waiting for descendant:", DescendantName, Ancestor)
	end

	return Descendant
end

function Module.GetAllPlayerCharacters(): {Model}
	local Characters = {}

	for _, Player: Player in pairs(Players:GetPlayers()) do
		if not Player.Character then 
			continue 
		end

		table.insert(Characters, Player.Character)
	end

	return Characters
end

function Module.CreateExplodingDebris(Position: Vector3, ImitationPart: BasePart?, Amount: number?, Magnitude: number?, Duration: number?): {BasePart}
	local CreatedParts = {}
	Amount = Amount or 15
	local IndividualSize = ImitationPart and ImitationPart.Size / 15

	for loop = 1, Amount do
		local Part = Instance.new("Part")

		Debris:AddItem(Part, Duration or 10)
		Part.Name = "DebrisPart"
		Part.CanTouch = false
		Part.CanQuery = false
		Part.Size = IndividualSize or Vector3.new( math.random(100,500)/100, math.random(100,500)/100, math.random(100,500)/100 )
		Part.BrickColor = BrickColor.Gray()
		Part.Position = Position
		
		table.insert(CreatedParts, Part)

		local Mass = Part.AssemblyMass

		Part.Parent = workspace
		
		local A = Vector3.new( 
			(math.random(1,2) == 1 and Mass or -Mass) * ( math.random(2500,5000)/ 50 ) * ( Magnitude or 1 ),
			(math.random(1,2) == 1 and Mass or -Mass) * ( math.random(2500,5000)/ 50 ) * ( Magnitude or 1 ),
			(math.random(1,2) == 1 and Mass or -Mass) * ( math.random(2500,5000)/ 50 ) * ( Magnitude or 1 )
		)
		
		warn(A)
		
		Part:ApplyImpulse( 
			Vector3.new( 
				(math.random(1,2) == 1 and Mass or -Mass) * ( math.random(2500,5000)/ 50 ) * ( Magnitude or 1 ),
				(math.random(1,2) == 1 and Mass or -Mass) * ( math.random(2500,5000)/ 50 ) * ( Magnitude or 1 ),
				(math.random(1,2) == 1 and Mass or -Mass) * ( math.random(2500,5000)/ 50 ) * ( Magnitude or 1 )
			)
		)
	end
	
	return CreatedParts
end

function Module.HideObject(Object: Instance, Hide: boolean?)

	local Str = "Unique_OriginalTransparency"

	for _, Object in pairs( { Object, unpack( Object:GetDescendants() ) } ) do
		pcall(function()

			Object:SetAttribute(Str, Object:GetAttribute(Str) or Object.Transparency)
			Object.Transparency = (Hide and 1) or Object:GetAttribute(Str) 

		end)
	end
end

function Module.XPcall(Call,...)
	xpcall(Call,
		function(ErrorMessage: string): string
			warn("[Error]:",ErrorMessage,debug.traceback("[Traceback]:"))
			return tostring("[Error]:",ErrorMessage,debug.traceback("[Traceback]:"))
		end,
		...)
end

return Module
