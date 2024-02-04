------------- Services -------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local h = game:GetService("HttpService")

------------- Assets ------------- 
local SharedAssets = ReplicatedStorage.SharedAssets
local Modules = SharedAssets.Modules

--// Knit
local Knit = require(ReplicatedStorage.KnitPackages.Knit)
local Trove = require(ReplicatedStorage.KnitPackages.Trove)

local TroopsShopUIController = Knit.CreateController({
	Name = "TroopsShopUIController",
})

local ButtonController = nil
local PlayerDataController = nil
local TroopService = nil

--\\

local TroopDatas = require(Modules.TroopDatas.Datas)

local Client: Player = Knit.Player
local PlayerGui: PlayerGui = Client:WaitForChild("PlayerGui")
local ShopGui = PlayerGui:WaitForChild("ShopGui")
local ShopFrame = ShopGui.ShopFrame
local ShopScroller = ShopFrame.ShopScroller

------------- Types ------------- 

type Troop = TroopDatas.Troop

------------- Variables -------------


------------- Private Functions ------------- 

local function GetTroopData(TroopName: string): Troop
	return TroopDatas[TroopName] or warn("Missing troop data for ".. TroopName)
end

------------- Public Functions -------------

function TroopsShopUIController:AdjustTroopShopSlots()
	for _, Slot in pairs(CollectionService:GetTagged("TroopShopSlots")) do

		local TroopName = Slot.Name
		local TroopData: Troop = GetTroopData(TroopName)

		local ClientReplica = PlayerDataController:GetData()
		local ClientData = ClientReplica.Data

		local CanPurchase = TroopService:CanPlayerPurchaseTroop(ClientReplica, TroopData)

		Slot.BackgroundColor3 = CanPurchase and Color3.fromRGB(85, 255, 127) or Slot:GetAttribute("DefaultBackgroundColor")
		Slot.UIStroke.Color = CanPurchase and Color3.fromRGB(54, 163, 80) or Slot.UIStroke:GetAttribute("DefaultStrokeColor")
	end
end

function TroopsShopUIController:NewTroopShopSlot(TroopName: string, TroopData: TroopData): Frame

	local ClientReplica = PlayerDataController:GetData()
	local ClientData = ClientReplica.Data
	
	local NewSlot = SharedAssets.UI.TroopShopSlot:Clone()

	local CanPurchase = TroopService:CanPlayerPurchaseTroop(ClientReplica, TroopData)

	NewSlot:SetAttribute("DefaultBackgroundColor", NewSlot.BackgroundColor3)
	NewSlot.UIStroke:SetAttribute("DefaultStrokeColor", NewSlot.UIStroke.Color)

	NewSlot.BackgroundColor3 = CanPurchase and Color3.fromRGB(85, 255, 127) or NewSlot.BackgroundColor3
	NewSlot.UIStroke.Color = CanPurchase and Color3.fromRGB(54, 163, 80) or NewSlot.UIStroke.Color
	NewSlot.Title.Text = TroopData.DisplayName
	NewSlot.Cost.Text = "$"..tostring(TroopData.CostToOwn)
	NewSlot.Button.Image = TroopData.Image
	NewSlot.LayoutOrder = TroopData.CostToOwn
	NewSlot.Name = TroopName

	CollectionService:AddTag(NewSlot, "TroopShopSlots")

	ButtonController.Button.new(NewSlot.Button, function(Input: Object, Button)

		local CanPurchase = TroopService:CanPlayerPurchaseTroop(ClientReplica, TroopData)

		if not CanPurchase then
			return
		end

		local Result = TroopService:PurchaseTroop(TroopName)

		print("Purchased ".. TroopName ..": ".. tostring(Result))

	end)

	NewSlot.Parent = ShopScroller

	return NewSlot
end

--// Knit

function TroopsShopUIController:KnitInit()
	
	ButtonController = Knit.GetController("ButtonController")
	PlayerDataController = Knit.GetController("PlayerDataController")
end

function TroopsShopUIController:KnitStart()

	TroopService = Knit.GetService("TroopService")

	local ClientReplica = PlayerDataController:GetData()
	local ClientData = ClientReplica.Data

	ClientReplica:ListenToNewKey({"OwnedTroops"}, function(Value, Key)
		self:AdjustTroopShopSlots()
	end)

	ClientReplica:ListenToChange({"Currency"}, function(Value, Key)
		self:AdjustTroopShopSlots()
	end)

	ButtonController.Button.new(ShopFrame.CloseButton, function(Input: Object, Button)
		ShopFrame.Visible = not ShopFrame.Visible
	end)

	for TroopName, TroopData in pairs(TroopDatas) do
		if TroopData.Disabled then
			continue
		end
		
		self:NewTroopShopSlot(TroopName, TroopData)
	end

	self:AdjustTroopShopSlots()
end

------------- Init -------------

return TroopsShopUIController