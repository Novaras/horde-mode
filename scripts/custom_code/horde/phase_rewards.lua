---@alias PowerEffect RuntimeShipMultiplier

---@class PowerUp
---@field effect PowerEffect
---@field fraction number

---@class WaveReward
---@field description string
---@field rus integer
---@field technology string[]
---@field power_ups PowerUp[]
---@field tier '1'|'2'|'3'|'4'|'5'

---@type WaveReward[]
WAVE_REWARDS = {
	[0] = {
		description = "500 ru (t1)",
		rus = 500,
		tier = 1,
	},
	[1] = {
		description = "300ru + 5% dmg (t1)",
		rus = 300,
		power_ups = {
			{
				effect = "WeaponDamage",
				fraction = 0.05,
			}
		},
		tier = 1,
	},
	[2] = {
		description = "1000ru + 5% dmg + 5% build speed (t2)",
		rus = 1000,
		power_ups = {
			{
				effect = "WeaponDamage",
				fraction = 0.05
			},
			{
				effect = "BuildSpeed",
				fraction = 0.05
			}
		},
		tier = 2
	}
};