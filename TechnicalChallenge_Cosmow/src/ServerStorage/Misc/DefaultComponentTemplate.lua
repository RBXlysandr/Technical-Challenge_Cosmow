------------- Services ------------- 

local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------- Assets ------------- 

--// Knit
local Knit = require(ReplicatedStorage.KnitPackages.Knit)
local Component = require(Knit.Util.Component)

local DefaultComponentTemplate = Component.new({
	Tag = "DefaultComponentTemplate",
})

--\\


------------- Types ------------- 


------------- Variables -------------


------------- Private Functions ------------- 


------------- Public Functions -------------

--// Knit


function DefaultComponentTemplate:Construct()

end

function DefaultComponentTemplate:Start()

end

function DefaultComponentTemplate:Stop()

end

------------- Init -------------

return DefaultComponentTemplate