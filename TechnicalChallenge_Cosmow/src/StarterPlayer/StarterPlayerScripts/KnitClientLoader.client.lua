------------- Services ------------- 

local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------- Assets ------------- 

local SharedAssets = ReplicatedStorage.SharedAssets

--// Knit

local Knit = require(ReplicatedStorage.KnitPackages.Knit)
local Client: Player = Knit.Player
local PlayerGui: PlayerGui = Client:WaitForChild("PlayerGui")
local Component = require(Knit.Util.Component)

------------- Types -------------

------------- Variables -------------

------------- Functions ------------- 

------------- Events -------------

------------- Init -------------

task.wait(1) --// Give things a bit of time to load

Knit.AddControllers(SharedAssets.Controllers)
Knit.AddControllersDeep(PlayerGui)

Knit.Start({ServicePromises = false}):andThen(function()
	print("Client Knit started")
end):catch(warn)