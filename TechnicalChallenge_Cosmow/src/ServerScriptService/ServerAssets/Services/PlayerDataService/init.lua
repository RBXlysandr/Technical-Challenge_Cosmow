local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.KnitPackages.Knit)
local ReplicaService = require(script.ReplicaService)
local ProfileService = require(script.ProfileService)

local module = Knit.CreateService({
	Name = "PlayerDataService",
})

local PlayerProfile = {}
PlayerProfile.__index = PlayerProfile
local profileCache = {} -- [player] = {Profile = profile, Replica = replica}

local IS_STUDIO = game:GetService("RunService"):IsStudio()
local FORCE_USER_ID = 0 --// in case you want to force load somebody else's data

local defaultPlayerData = require(script.PlayerDataTemplate)

local gameProfileStore = ProfileService.GetProfileStore(
	"PlayerData1",
	defaultPlayerData
)

local playerProfileClassToken = ReplicaService.NewClassToken("PlayerProfile")

local function connectLeaderstats(profile)
	local leaderstats = script.leaderstats:Clone()
	leaderstats.Cash.Value = profile.Profile.Data.Currency
	leaderstats.Parent = profile._player
end

local function playerAdded(player)
	local userId = player.UserId
	if FORCE_USER_ID and FORCE_USER_ID > 0 and IS_STUDIO then
		userId = FORCE_USER_ID
	end
	if player.UserId < 1 then --// test server creates accounts with negative user ids
		userId = math.random(1, 500)
	end
	
	local profile = gameProfileStore:LoadProfileAsync("player_" .. userId, "ForceLoad")
	if profile ~= nil then
		profile:AddUserId(userId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			local cachedProfile = profileCache[player]
			if cachedProfile then
				--// destroy all player replicas! im doing it like this because i had a game where i had several diff replicas inside the player profile
				for _, v in {"Replica"} do
					if cachedProfile[v] then
						cachedProfile[v]:Destroy()
					end
				end
			end
			profileCache[player] = nil
		end)
		
		if player:IsDescendantOf(game.Players) == true then --// profile successfully loaded
			local player_profile = {
				_player = player,
				Profile = profile,
				Replica = ReplicaService.NewReplica({
					ClassToken = playerProfileClassToken,
					Tags = {Player = player},
					Data = profile.Data,
					Replication = "All",
				}),
			}
			
			setmetatable(player_profile, PlayerProfile)
			profileCache[player] = player_profile
			
			connectLeaderstats(player_profile)
		else
			print(string.format("%s left while their profile was being loaded", player.Name))
			profile:Release()
		end
	else
		print(string.format("Failed to ForceLoad %s's profile", player.Name))
		player:Kick("Sorry, another server in this game may be trying to load your profile at the same time! Wait a minute and rejoin.") 
	end
end

function module:WaitForProfile(player, timeout)
	if not player then
		return nil, warn(string.format("PlayerDataService:WaitForProfile expected Player, got %s\n%s", tostring(player), debug.traceback()))
	end
	
	timeout = timeout or 7
	local waited = 0
	while not profileCache[player] do
		waited += task.wait()
		if waited >= timeout then
			if player.Parent then --// maybe someone left while their profile was loading. we don't want a bunch of infnite yield warnings from that
				warn("Infinite yield possible on " .. player.Name .. "'s Profile")
			end
			return
		end
	end
	
	return profileCache[player]
end

function module:GetProfile(player, timeout)
	if not player then
		return nil, warn(string.format("PlayerDataService:GetProfile expected Player, got %s\n%s", tostring(player), debug.traceback()))
	end
	
	local data = not timeout and profileCache[player] or module:WaitForProfile(player, timeout)
	
	return data and data.Replica, data
end

function PlayerProfile:IsActive()
	return profileCache[self._player] ~= nil
end

function module:KnitInit()
	
end

function module:KnitStart()
	for _, player in game.Players:GetPlayers() do
		task.defer(playerAdded, player)
	end
	game.Players.PlayerAdded:Connect(playerAdded)

	game.Players.PlayerRemoving:Connect(function(player)
		local playerProfile = profileCache[player]
		if playerProfile then
			playerProfile.Profile:Release()
		end
	end)
end

return module