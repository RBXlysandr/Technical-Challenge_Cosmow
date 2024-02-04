export type Troop = {
	ID: string,
	DisplayName: string,
	CombatStats: {
		Type: string,
		Damage: number,
		Health: number,
		WalkSpeed: number,
	},
	Image: string,
	Cost: number,
	CostToOwn: number,
}

local Datas: { Troop } = {}

--// Allocate
for _, Module in pairs(script:GetDescendants()) do
	if not Module:IsA("ModuleScript") then --// Ensure we only gather modules
		continue
	end
	
	Datas[Module.Name] = require(Module)
end

return Datas