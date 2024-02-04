------------- Services -------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

------------- Assets ------------- 
local SharedAssets = ReplicatedStorage.SharedAssets
local Modules = SharedAssets.Modules

--// Knit
local Knit = require(ReplicatedStorage.KnitPackages.Knit)
local Trove = require(ReplicatedStorage.KnitPackages.Trove)

local TroopsFrameController = Knit.CreateController({
	Name = "TroopsFrameController",
})

local ButtonController = nil
local PlayerDataController = nil
local TroopService = nil

--\\

local TroopDatas = require(Modules.TroopDatas.Datas)

local Client: Player = Knit.Player
local PlayerGui: PlayerGui = Client:WaitForChild("PlayerGui")
local TroopsGui = PlayerGui:WaitForChild("TroopsGui")
local TroopsFrame = TroopsGui.TroopsFrame
local TroopsScroller = TroopsFrame.TroopsScroller


------------- Types ------------- 

type Troop = TroopDatas.Troop

------------- Variables -------------


------------- Private Functions ------------- 

local function GetTroopData(TroopName: string): Troop
	return TroopDatas[TroopName] or warn("Missing troop data for ".. TroopName)
end

------------- Public Functions -------------
function TroopsFrameController:OnNewTroop(Troop: Model)
	if not Troop:GetAttribute("NPC") then
		return
	end

	local Owner = Troop:GetAttribute("Owner")
	local Highlight = SharedAssets.VFX.EntityHighlight:Clone()

	local Friendly = Owner == Client.Name

	Highlight.FillColor = Friendly and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255,0,0)
	Highlight.OutlineColor = Friendly and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255,0,0)

	Highlight.Parent = Troop
end

function TroopsFrameController:AdjustTroopsFrameSlots()
	for _, Slot in pairs(CollectionService:GetTagged("TroopsFrameSlots")) do

		local TroopName = Slot.Name
		local TroopData: Troop = GetTroopData(TroopName)

		local ClientReplica = PlayerDataController:GetData()
		local ClientData = ClientReplica.Data

		local CanPurchase = TroopService:CanPlayerSpawnTroop(ClientReplica, TroopData)

		Slot.BackgroundColor3 = CanPurchase and Color3.fromRGB(85, 255, 127) or Slot:GetAttribute("DefaultBackgroundColor")
		Slot.UIStroke.Color = CanPurchase and Color3.fromRGB(54, 163, 80) or Slot.UIStroke:GetAttribute("DefaultStrokeColor")
	end
end


function TroopsFrameController:NewTroopSlot(TroopName: string): Frame

	local ClientReplica = PlayerDataController:GetData()
	local ClientData = ClientReplica.Data

	local TroopData: Troop = GetTroopData(TroopName)
	local NewSlot = SharedAssets.UI.TroopsFrameSlot:Clone()

	local CanPurchase = TroopService:CanPlayerSpawnTroop(ClientReplica, TroopData)

	NewSlot:SetAttribute("DefaultBackgroundColor", NewSlot.BackgroundColor3)
	NewSlot.UIStroke:SetAttribute("DefaultStrokeColor", NewSlot.UIStroke.Color)

	NewSlot.BackgroundColor3 = CanPurchase and Color3.fromRGB(85, 255, 127) or NewSlot.BackgroundColor3
	NewSlot.UIStroke.Color = CanPurchase and Color3.fromRGB(54, 163, 80) or NewSlot.UIStroke.Color
	NewSlot.Title.Text = TroopData.DisplayName
	NewSlot.Cost.Text = "$"..tostring(TroopData.Cost)
	NewSlot.Button.Image = TroopData.Image
	NewSlot.LayoutOrder = TroopData.Cost
	NewSlot.Name = TroopName

	CollectionService:AddTag(NewSlot, "TroopsFrameSlots")

	ButtonController.Button.new(NewSlot.Button, function(Input: Object, Button)

		local CanPurchase = TroopService:CanPlayerSpawnTroop(ClientReplica, TroopData)

		if not CanPurchase then
			return
		end

		local Result = TroopService:SpawnTroop(TroopName)

		print("Spawned ".. TroopName ..": ".. tostring(Result))

	end)

	NewSlot.Parent = TroopsScroller

	return NewSlot
end

--// Knit

function TroopsFrameController:KnitInit()
	
	ButtonController = Knit.GetController("ButtonController")
	PlayerDataController = Knit.GetController("PlayerDataController")
end

function TroopsFrameController:KnitStart()

	TroopService = Knit.GetService("TroopService")

	local ClientReplica = PlayerDataController:GetData()
	local ClientData = ClientReplica.Data

	ClientReplica:ListenToNewKey({"OwnedTroops"}, function(Value, Key)
		self:NewTroopSlot(Key)
		self:AdjustTroopsFrameSlots()
	end)

	ClientReplica:ListenToChange({"Currency"}, function(Value, Key)
		self:AdjustTroopsFrameSlots()
	end)
	
	--// Just here to prove use of Signal haha
	TroopService.NewTroopSignal:Connect(function(Troop: Model, Owner: Player?)
		--// Do stuff when a troop is added
	end)

	workspace.ChildAdded:Connect(function(...)
		task.wait(.1)

		self:OnNewTroop(...)
	end)

	for _, Troop: Model in pairs(workspace:GetChildren()) do
		pcall(function()
			self:OnNewTroop(Troop)
		end)
	end

	for TroopName,_ in pairs(ClientData.OwnedTroops) do
		self:NewTroopSlot(TroopName)
	end

end

------------- Init -------------

return TroopsFrameController