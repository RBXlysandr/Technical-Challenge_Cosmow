------------- Services ------------- 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

------------- Assets ------------- 

local ServerAssets = ServerScriptService.ServerAssets
local SharedAssets = ReplicatedStorage.SharedAssets


--// Knit

local Knit = require(ReplicatedStorage.KnitPackages.Knit)
local Component = require(Knit.Util.Component)

------------- Types -------------

------------- Variables -------------

------------- Functions ------------- 

------------- Init -------------

Knit.AddServices(ServerAssets.Services)
Knit.AddServices(SharedAssets.Services)

Knit.Start():andThen(function()
	print("Server Knit started")
end):catch(warn)