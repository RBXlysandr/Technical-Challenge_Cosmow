------------- Services ------------- 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

------------- Assets ------------- 

local SharedAssets = ReplicatedStorage.SharedAssets
local Modules = SharedAssets.Modules

--// Knit
local Knit = require(ReplicatedStorage.KnitPackages.Knit)

local MockConsole = Knit.CreateService({
	Name = "MockConsole",
	Client = {},
})

local PlayerDataService = nil
local TroopService = nil
--\\

local TroopDatas = require(Modules.TroopDatas.Datas)

------------- Types ------------- 

type Troop = TroopDatas.Troop

------------- Variables -------------


------------- Private Functions ------------- 


------------- Public Functions -------------

function MockConsole:KnitInit()
	PlayerDataService = Knit.GetService("PlayerDataService")
	TroopService = Knit.GetService("TroopService")
end

function MockConsole:KnitStart()

	--// Periodically spawn enemies
	--// Psuedo code, not realistic
	
	local TroopDataTable = {}
	
	for _, TroopData in pairs(TroopDatas) do
		table.insert(TroopDataTable, TroopData)	
	end
	
	local Stamp = tick()
	
	for loop = 1, 5 do
		TroopService:CreateTroop(TroopDataTable[math.random(1, #TroopDataTable)], {}) 
	end

	task.spawn(function()
		while true do
			TroopService:CreateTroop(TroopDataTable[math.random(1, #TroopDataTable)], {}) 
			
			task.wait( 
				math.max(1, 10 - ( (tick() - Stamp) / 20 ) )
			)
		end
	end)

	--// Passive income to all players

	while task.wait(1) do
		for _, Player in pairs(Players:GetPlayers()) do

			task.spawn(function()

				local Replica = PlayerDataService:GetProfile(Player)

				Replica:SetValue("Currency", Replica.Data.Currency + 10)

				--// Psuedo code to replicate data to leaderboard
				Player.leaderstats.Cash.Value = Replica.Data.Currency

			end)

		end
	end


end


------------- Init -------------

return MockConsole