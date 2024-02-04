------------- Services ------------- 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

------------- Assets ------------- 

local SharedAssets = ReplicatedStorage.SharedAssets
local Modules = SharedAssets.Modules
local Toolbox = Modules.Toolbox

local Util = require(Toolbox.Utilities)

--// Knit
local Knit = require(ReplicatedStorage.KnitPackages.Knit)

local TroopService = Knit.CreateService({
	Name = "TroopService",
	Client = {
		NewTroopSignal = Knit.CreateSignal()	
	},
})

local PlayerDataService = nil

--\\

local TroopDatas = require(Modules.TroopDatas.Datas)

------------- Types ------------- 

type Troop = TroopDatas.Troop

------------- Variables -------------


------------- Private Functions ------------- 


------------- Public Functions -------------

function TroopService:GetTroopData(TroopName: string): Troop
	return TroopDatas[TroopName] or warn("Missing troop data for ".. TroopName)
end

function TroopService:PurchaseTroop(Player: Player, Replica, TroopData: Troop)

	if not self.Client:CanPlayerPurchaseTroop(Player, Replica, TroopData) then
		return warn("Could not purchase troop!")
	end

	Replica:SetValue({"OwnedTroops", TroopData.ID}, os.time())
	Replica:SetValue("Currency", Replica.Data.Currency - TroopData.CostToOwn)

	return true
end

function TroopService:CreateTroop(TroopData: Troop, MetaData: {any})
	----// Troop stuff

	local Owner: Player? = MetaData.Owner
	local TroopName = TroopData.ID
	local CombatStats = TroopData.CombatStats
	local TroopModel: Model = SharedAssets.Models.Troops:FindFirstChild(TroopName):Clone()
	local Humanoid: Humanoid = TroopModel:FindFirstChildWhichIsA("Humanoid", true)


	--// Assign stats
	TroopModel:SetAttribute("NPC", true)
	TroopModel:SetAttribute("Owner", Owner and Owner.Name)
	TroopModel:SetAttribute("Damage", CombatStats.Damage)
	Humanoid.DisplayName = TroopData.DisplayName
	Humanoid.WalkSpeed = CombatStats.WalkSpeed
	Humanoid.MaxHealth = CombatStats.Health
	Humanoid.Health = Humanoid.MaxHealth

	--// Spawn

	TroopModel:PivotTo( MetaData.SpawnLocation or CFrame.new( math.random(-20,20), 5, math.random(-20,20) ) )
	TroopModel.Parent = workspace

	--// Events

	Humanoid.Died:Connect(function()
		
		--// Award killer
		
		local LegacyCreatorTag: ObjectValue? = Humanoid:FindFirstChild("creator")
		local KillersName: string? = not LegacyCreatorTag and TroopModel:GetAttribute("LastDamagedBy")
		local Killer: Player? = (LegacyCreatorTag and LegacyCreatorTag.Value) or (KillersName and table.find(Players:GetPlayers(), KillersName))
		
		if Killer then
			
			local Replica = PlayerDataService:GetProfile(Killer)
			local leaderstats = Killer:FindFirstChild("leaderstats")
			Replica:SetValue("Currency", Replica.Data.Currency + TroopData.Cost * .1 )

			--// Psuedo code to replicate data to leaderboard
			leaderstats.Cash.Value = Replica.Data.Currency
			leaderstats.Kills.Value += 1

		end
		
		--// Award owner
		if Owner then

			local Replica = PlayerDataService:GetProfile(Owner)
			local leaderstats = Owner:FindFirstChild("leaderstats")
			Replica:SetValue("Currency", Replica.Data.Currency + TroopData.Cost * .1 )

			--// Psuedo code to replicate data to leaderboard
			leaderstats.Cash.Value = Replica.Data.Currency

		end
	end)

	--// Init NPC scripts

	for _, Script in pairs(TroopModel:GetDescendants()) do
		if not Script:IsA("Script") then
			continue
		end

		Script.Enabled = true
	end

	----\\
	
	CollectionService:AddTag(TroopModel, "Troops")

	return TroopModel
end

function TroopService:SpawnTroop(Player: Player, Replica, TroopData: Troop)

	if not self.Client:CanPlayerSpawnTroop(Player, Replica, TroopData) then
		return warn("Could not spawn troop!")
	end

	local Character = Player.Character

	local TroopSpawnLocation = ( Character:GetPivot() * CFrame.new( 
		math.random(-100, 100) / 10, math.random(-100, 100) / 10, math.random(-100, 100) / 10
		) ) * CFrame.Angles(0, math.rad( math.random(-180, 180) ), 0)

	return self:CreateTroop(TroopData, {SpawnLocation = TroopSpawnLocation, Owner = Player})
end

--// Client


function TroopService.Client:CanPlayerPurchaseTroop(Player: Player, Replica, TroopData: Troop): boolean
	return Util.PlayerIsValid(Player) and not Replica.Data.OwnedTroops[TroopData.ID]
		and Replica.Data.Currency >= TroopData.CostToOwn
end

function TroopService.Client:CanPlayerSpawnTroop(Player: Player, Replica, TroopData: Troop): boolean
	return Util.CharIsValid(Player) and Replica.Data.OwnedTroops[TroopData.ID]
		and Replica.Data.Currency >= TroopData.Cost 
end

function TroopService.Client:PurchaseTroop(Player: Player, TroopName: string): Troop

	local TroopData: Troop = self.Server:GetTroopData(TroopName)
	local Replica = PlayerDataService:GetProfile(Player)

	return self.Server:PurchaseTroop(Player, Replica, TroopData)
end

function TroopService.Client:SpawnTroop(Player: Player, TroopName: string): Troop

	local TroopData: Troop = self.Server:GetTroopData(TroopName)
	local Replica = PlayerDataService:GetProfile(Player)

	local NewTroop = self.Server:SpawnTroop(Player, Replica, TroopData)

	if NewTroop then
		Replica:SetValue("Currency", Replica.Data.Currency - TroopData.Cost)
	end

	return NewTroop
end

--\\

function TroopService:KnitInit()
	PlayerDataService = Knit.GetService("PlayerDataService")
end

function TroopService:KnitStart()

end


------------- Init -------------

return TroopService