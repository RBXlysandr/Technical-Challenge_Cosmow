------------- Services -------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------- Assets ------------- 
local SharedAssets = ReplicatedStorage.SharedAssets
local Modules = SharedAssets.Modules

--// Knit
local Knit = require(ReplicatedStorage.KnitPackages.Knit)
local Trove = require(ReplicatedStorage.KnitPackages.Trove)

local ScreenButtonsController = Knit.CreateController({
	Name = "ScreenButtonsController",
})

local ButtonController = nil

--\\

local Client: Player = Knit.Player
local PlayerGui: PlayerGui = Client:WaitForChild("PlayerGui")
local ScreenButtonsGui = PlayerGui:WaitForChild("ScreenButtonsGui")

------------- Types ------------- 


------------- Variables -------------


------------- Private Functions ------------- 


------------- Public Functions -------------

--// Knit

function ScreenButtonsController:KnitInit()
	
	ButtonController = Knit.GetController("ButtonController")
end

function ScreenButtonsController:KnitStart()
	

	ButtonController.Button.new(ScreenButtonsGui.ShopButton, function(Input: Object, Button)
		PlayerGui.ShopGui.ShopFrame.Visible = not PlayerGui.ShopGui.ShopFrame.Visible
	end)
	
	
end

------------- Init -------------

return ScreenButtonsController