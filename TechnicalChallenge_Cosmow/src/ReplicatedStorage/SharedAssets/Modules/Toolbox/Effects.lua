local Module = {}

local Modules = script.Parent
local Instances = require(Modules.Instances)
local Debris = game:GetService("Debris")

function Module.EmitSoundAt(Location: Vector3 | BasePart, Duration: number, SoundData: {}): (Sound, Attachment)
	
	local Anchor:any = typeof(Location) == "Instance" and Location or Instances.CreateAttachment(Location , workspace.Terrain, Duration)
	SoundData[3] = Anchor
	
	return Instances.CreateSound(unpack(SoundData)),Anchor
end

function Module.EmitParticleAt(ParticleToClone: ParticleEmitter, Location: CFrame | BasePart, Duration: number?, 
	Emit: number?): (ParticleEmitter, Attachment)

	local Emitter = ParticleToClone:Clone()
	Duration = Duration or Emitter.Lifetime.Max

	local Anchor:any = typeof(Location) == "Instance" and Location 
		or Instances.CreateAttachment(Location.Position, workspace.Terrain, Duration)

	Debris:AddItem(Emitter,Duration)

	Emitter.Parent = Anchor

	if Emit then
		
		Emitter:Emit(Emit or Emitter.Rate)
		
	else
		
		Emitter.Enabled = true
		
		task.delay(math.max(.1,Duration-Emitter.Lifetime.Max),function()
			
			if not Emitter or not Emitter.Parent then 
				return 
			end

			Emitter.Enabled = false
			
		end)
		
	end

	return Emitter,Anchor
end


return Module