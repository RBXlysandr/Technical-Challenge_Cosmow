------------- Services ------------- 

local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------- Assets ------------- 

--// Knit
local Knit = require(ReplicatedStorage.KnitPackages.Knit)

local Service = Knit.CreateService({
	Name = "Service",
	Client = {},
})
--\\


------------- Types ------------- 


------------- Variables -------------


------------- Private Functions ------------- 


------------- Public Functions -------------

function Service:KnitInit()

end

function Service:KnitStart()

end


------------- Init -------------

return Service