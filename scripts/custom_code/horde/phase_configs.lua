---@type table<integer, Phase>
PHASE_CONFIGS = {
	[1] = {
		waves = {
			[1] = {
				value = 1500,
				enemy_types = {
					"tai_defender",
					"kus_attackbomber",
					"kus_heavycorvette"
				},
			},
			[2] = {
				value = 1500,
				enemy_types = {
					"hgn_assaultfrigate",
					"kus_attackbomber",
					"kus_lightcorvette"
				},
			},
			[3] = {
				value = 2250,
				enemy_types = {
					"kus_assaultfrigate",
					"tai_assaultfrigate",
					"hgn_interceptor",
					"tai_defensefighter"
				}
			}
		},
		rewards = PHASE_REWARDS[1]
	},
	[2] = {
		waves = {
			[1] = {
				value = 4000,
				enemy_types = {
					"tai_destroyer",
					"vgr_commandcorvette",
					"kus_assaultfrigate",
					"vgr_heavymissilefrigate"
				}
			},
			[2] = {
				value = 5000,
				enemy_types = {
					"kus_missiledestroyer",
					"tai_gravwellgenerator",
					"vgr_heavymissilefrigate",
					"vgr_commandcorvette",
					"hgn_torpedofrigate"
				}
			},
			[3] = {
				value = 7500,
				enemy_types = {
					"kus_heavycruiser",
					"tai_destroyer",
					"hgn_ioncannonfrigate",
					"tai_defender",
					"kus_defender",
					"kus_gravwellgenerator",
					"tai_fieldfrigate"
				}
			}
		},
		rewards = PHASE_REWARDS[2]
	}
};