---@alias PowerEffect RuntimeShipMultiplier

---@class PowerUp
---@field effect PowerEffect
---@field fraction number

---@class RewardOption
---@field description string
---@field rus integer
---@field technology string[]
---@field power_ups PowerUp[]
---@field build_options string[]
---@field research_options string[]

---@class PhaseReward
---@field option_a RewardOption
---@field option_b RewardOption

---@type PhaseReward[]
PHASE_REWARDS = {
	[1] = {
		option_a = {
			description = "+1000 ru\n+10% movespeed",
			rus = 1000,
			power_ups = {
				{
					effect = "MaxSpeed",
					fraction = 0.05
				}
			},
		},
		option_b = {
			description = "+1000 ru\n+Capital Ship Production",
			build_options = {
				"Hgn_SY_Production_CapShip"
			}
		}
	},
	[2] = {
		option_a = {
			description = "+500 ru\n+5% dmg",
			rus = 500,
			power_ups = {
				{
					effect = "WeaponDamage",
					fraction = 0.05,
				}
			},
		},
		option_b = {
			description = "+750 ru\n+5% movespeed",
			rus = 750,
			power_ups = {
				{
					effect = "MaxSpeed",
					fraction = 0.05
				}
			}
		}
	}
};