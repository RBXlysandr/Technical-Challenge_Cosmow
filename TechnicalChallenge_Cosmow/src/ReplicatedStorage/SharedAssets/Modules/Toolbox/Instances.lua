local Module = {}

local Debris = game:GetService("Debris")

--// Template: {11229420035,1,Victim.PrimaryPart,false,5,500,(math.random(800,1200)/1000),5,true})
function Module.CreateSound(ID: {string} | {number} | number | string, Volume: number, Parent: Instance?, Lifetime: number? | string?,
	 PlayNow: boolean | number?, IsLooped: boolean?, MinDist: number?, MaxDist: number?, PlaybackSpeed:number?): Sound

	if typeof(ID) == "table" then 

		if #ID <= 0 then 
			return 
		end

		ID = ID[math.random(1,#ID)] 
	end

	local Sound = Instance.new("Sound")

	Sound.SoundId = typeof(ID) == "string" and ID or "rbxassetid://"..ID
	Sound.Volume = Volume or Sound.Volume
	Sound.Looped = IsLooped or Sound.Looped
	Sound.RollOffMinDistance = MinDist or Sound.RollOffMinDistance
	Sound.RollOffMaxDistance = MaxDist or Sound.RollOffMaxDistance
	Sound.PlaybackSpeed = PlaybackSpeed or Sound.PlaybackSpeed
	Sound.Parent = Parent

	coroutine.wrap(function()

		if not Sound.IsLoaded then
			
			Sound.Loaded:Wait()
			
		end

		if PlayNow and typeof(PlayNow) == "number" then 

			task.delay(PlayNow,function()

				if not Sound or not Sound.Parent then 
					return 
				end

				Sound:Play() 

			end)

		elseif PlayNow then

			Sound:Play()

		end

		if typeof(Lifetime) == "number" then

			Debris:AddItem(Sound, Lifetime)

		elseif Lifetime == "Length" then

			Debris:AddItem(Sound, Sound.TimeLength * Sound.PlaybackSpeed)

		end

	end)()

	return Sound
end

function Module.CreateAttachment(Origin: Vector3 | CFrame, Parent: Instance?, Lifetime: number?): Attachment
	
	local Ata = Instance.new("Attachment")

	if Lifetime then 
		Debris:AddItem(Ata,Lifetime) 
	end
	
	Ata.Parent = Parent or workspace.Terrain
	Ata.WorldCFrame = typeof(Origin) == "CFrame" and Origin or CFrame.new(Origin)
	
	return Ata
end

return Module