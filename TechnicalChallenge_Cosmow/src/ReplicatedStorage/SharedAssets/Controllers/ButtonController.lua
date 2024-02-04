------------- Services ------------- 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

------------- Assets ------------- 

local SharedAssets = ReplicatedStorage.SharedAssets
local Modules = SharedAssets.Modules
local Toolbox = Modules.Toolbox

local Util = require(Toolbox.Utilities)
local Instances = require(Toolbox.Instances)

--// Knit
local Knit = require(ReplicatedStorage.KnitPackages.Knit)

local ButtonController = Knit.CreateController({
	Name = "ButtonController",
	Button = {},
})

local Client: Player = Knit.Player
--\\

------------- Types ------------- 


------------- Variables -------------

--// Settings
local DEFAULT_CLICK_SOUND = 6324790483
--\\

------------- Private Functions ------------- 

------------- Public Functions -------------


--// Knit

function ButtonController:KnitInit()
	local Button: {} = self.Button

	Button.__index = Button

	function Button.new(Object: GuiObject, OnClick: any)

		local NewButton = setmetatable({}, Button)
		local Mouse = Client:GetMouse()

		NewButton.Object = Object
		NewButton.LastClicked = tick()
		NewButton.ClickCooldown = .2
		NewButton.ClickSound = DEFAULT_CLICK_SOUND
		NewButton.Disabled = false

		NewButton.OnClickConnection = Object.InputEnded:Connect(function(Input: InputObject, ...)
			if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch and Input.KeyCode ~= Enum.KeyCode.ButtonA then
				return
			end
			
			NewButton:OnClick(Input, OnClick, ...)
		end)

		NewButton.OnMouseEnterConnection = Object.MouseEnter:Connect(function(...)
			NewButton:OnMouseEnter(...)
		end)

		NewButton.OnMouseLeaveConnection = Object.MouseLeave:Connect(function(...)
			NewButton:OnMouseLeave(...)
		end)

		return NewButton
	end

	function Button:OnMouseEnter()
		if not UserInputService.KeyboardEnabled or self.Disabled then
			return
		end

		--// Animate
	end

	function Button:OnMouseLeave()
		if not UserInputService.KeyboardEnabled or self.Disabled then
			return
		end
		
		--// Animate
	end

	function Button:OnClick(Input: InputObject, OnClick)

		if self.Disabled or tick() - self.LastClicked < self.ClickCooldown then
			return
		end

		if self.ClickSound then
			Instances.CreateSound(self.ClickSound, .5, Client, "Length", true)
		end

		OnClick(Input, self)
	end

	function Button:Disconnect()
		for Index, Value in pairs(self) do
			if typeof(Value) ~= "RBXScriptConnection" then
				continue
			end

			Value:Disconnect()
			Value = nil
		end
	end
end

function ButtonController:KnitStart()
end



------------- Init -------------

return ButtonController