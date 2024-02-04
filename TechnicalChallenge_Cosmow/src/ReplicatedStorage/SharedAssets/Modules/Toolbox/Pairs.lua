--// lysandr (Joey) 8/30/2023 V1
local IsClient = game:GetService("RunService"):IsClient()
local IsServer = game:GetService("RunService"):IsServer()
local Players = game:GetService("Players")
local HTTPS = game:GetService("HttpService")
local Invoker: RemoteFunction = nil

local Pairs = {}

export type Pair = {
	Player1: Player,
	Player2: Player,
	ZiplinePoints: { [Instance]: CFrame },
	Ready: boolean,
	ID: string,
}



Pairs.AllPairs = {}

local function RemovePair(PairToDelete: Pair)
	for Index,QueryPair: Pair in pairs(Pairs.AllPairs) do
		if QueryPair == PairToDelete or QueryPair.ID == PairToDelete.ID then
			table.remove(Pairs.AllPairs,Index)
		end
	end

	PairToDelete = nil
end

function Pairs.NewPair(Player: Player): Pair
	local NewPair = {
		Player1 = Player,
		Player2 = nil,
		ZiplinePoints = {},
		Ready = false,
		ID = HTTPS:GenerateGUID(),
	}

	table.insert(Pairs.AllPairs, NewPair)

	return NewPair
end

function Pairs.Get(Player: Player?): Pair?

	if IsClient then

		Player = Player or Players.LocalPlayer

		return Invoker:InvokeServer("Get",Player)
	end

	for _,Pair: Pair in pairs(Pairs.AllPairs) do
		if Player == Pair.Player1 then 
			return Pair,"Player1" 
		elseif Player == Pair.Player2 then 
			return Pair,"Player2"
		end
	end
end

function Pairs.SwapPlayerIndex(Player: Player): (string?, string?)
	if IsClient then

		Player = Player or Players.LocalPlayer

		return Invoker:InvokeServer("SwapPlayerColor",Player)
	end

	local Pair, Index = Pairs.Get(Player)
	local PairedPlayer, PairedPlayerIndex = Pairs.GetPairedPlayer(Player, Pair)
	local NewIndex = (Index == "Player1" and "Player2") or "Player1"
	
	Pair[NewIndex] = Player
	Pair[Index] = PairedPlayer
	
	return NewIndex, Index
end

function Pairs.GetPairedPlayer(Player: Player, Pair: Pair?): (Player?, string)
	Pair = Pair or Pairs.Get(Player)

	local PairedPlayer, PairedPlayerIndex = nil, nil

	if (Pair.Player1 == Player and Pair.Player2) then
		PairedPlayer = Pair.Player2
		PairedPlayerIndex = "Player2"
	elseif (Pair.Player2 == Player and Pair.Player1) then
		PairedPlayer = Pair.Player1
		PairedPlayerIndex = "Player1"
	end

	return PairedPlayer, PairedPlayerIndex
end


function Pairs.AddPlayerToPair(ExistingPlayer: Player, NewPlayer: Player, ExistingPair: Pair): Pair
	local NewPlayersPair = Pairs.Get(NewPlayer)

	RemovePair(NewPlayersPair)

	local OpenIndex = ExistingPair.Player1 and "Player2" or "Player1"

	ExistingPair[OpenIndex] = NewPlayer

	ExistingPair.Ready = ExistingPair.Player1 and ExistingPair.Player2 and true

	return ExistingPair
end


function Pairs.RemovePlayerFromPair(Player: Player, Pair: Pair?): (Pair?, Player?) --// Only used on player leave
	Pair = Pair or Pairs.Get(Player)

	local RemainingPlayer = Pairs.GetPairedPlayer(Player, Pair)

	RemovePair(Pair)

	if RemainingPlayer then
		Pairs.NewPair(RemainingPlayer)
	end

	return Pair, Pair and RemainingPlayer
end

--// This integrates a self call function for certain functions so that the client can call them and get the server's results...
--// ... without having to setup listeners for each call, see Pairs.Get() for an example

if IsServer and not Invoker then --// If it's the server, DO NOT ALLOW OVERLAP
	Invoker = Instance.new("RemoteFunction")
	Invoker.Name = "Invoker"

	Invoker.OnServerInvoke = function(Player: Player,Key: string,...)
		return Pairs[Key](...)
	end

	Invoker.Parent = script
elseif IsClient then
	Invoker = script:WaitForChild("Invoker")
end

return Pairs
