local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedAssets = ReplicatedStorage:WaitForChild("SharedAssets")
local Modules = SharedAssets:WaitForChild("Modules")
local Knit = require(ReplicatedStorage.KnitPackages.Knit)
local ReplicaController = require(Modules:WaitForChild("Madwork").ReplicaController)
local ReplicaControllerInterface

local module = Knit.CreateController({
	Name = "PlayerDataController",
})

local myReplica

function module:WaitForMyReplica()
	while not myReplica do
		task.wait()
	end
	return myReplica
end

function module:GetData()
	return module:WaitForMyReplica()
end

function module:KnitStart()
	
	ReplicaControllerInterface:Register("PlayerProfile", function(replica)
		if replica.Tags.Player == Knit.Player then
			myReplica = replica

			--replica:ListenToNewKey({"Inventory"}, function(value, key)
			--	--print("New inventory stuff", key,  value)

			--	replica:ListenToNewKey("Inventory." .. key .. ".State", function(value, key)
			--		print("new state", value, key)
			--	end)
			--end)
		end
	end)

	Knit.Player.Chatted:Connect(function(msg)
		if msg == "printdata" then
			print(module:GetData().Data)
		end
	end)
end

function module:KnitInit()
	ReplicaControllerInterface = Knit.GetController("ReplicaControllerInterface")
end

return module