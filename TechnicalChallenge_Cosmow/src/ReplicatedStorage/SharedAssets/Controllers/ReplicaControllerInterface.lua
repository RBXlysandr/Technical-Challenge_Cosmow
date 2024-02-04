local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedAssets = ReplicatedStorage:WaitForChild("SharedAssets")
local Modules = SharedAssets:WaitForChild("Modules")
local Knit = require(ReplicatedStorage.KnitPackages.Knit)
local ReplicaController = require(Modules:WaitForChild("Madwork").ReplicaController)

--[[
	ReplicaService docs:
	"All .NewReplicaSignal and .ReplicaOfClassCreated() listeners should be connected
	before calling .RequestData()! - refrain from connecting listeners afterwards!"
	
	Previously I was calling RequestData in PlayerDataController:KnitInit *before*
	connecting ReplicaOfClassCreated listeners, which caused race conditions.
	
	This module will connect all ReplicaOfClassCreated listeners before calling
	RequestData.
--]]

local module = Knit.CreateController({
	Name = "ReplicaControllerInterface",
})

local EXPECTED_PROFILE_LISTENERS = {
	"PlayerProfile",
	--"Trade",
}

local registeredListeners = {}

function module:Register(replicaClassName, callback)
	ReplicaController.ReplicaOfClassCreated(replicaClassName, callback)
	table.insert(registeredListeners, replicaClassName)
end

function module:KnitStart()
	task.defer(function()
		while #registeredListeners < #EXPECTED_PROFILE_LISTENERS do
			task.wait()
		end
		ReplicaController.RequestData()
	end)
end

function module:KnitInit()

end

return module