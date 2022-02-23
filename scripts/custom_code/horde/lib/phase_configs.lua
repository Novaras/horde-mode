---@type table<integer, Phase>
PHASE_CONFIGS = {
	[1] = {
		waves = {
			[1] = {
				value = 2000,
				enemy_types = {
					"tai_multiguncorvette",
					{
						type = "tur_ionarrayfrigate",
						custom_price = 1001
					},
					"vgr_commandcorvette"
				},
			},
			[2] = {
				value = 2100,
				enemy_types = {
					{
						type = "tai_attackbomber",
						min_count = 6
					},
					{
						type = "vgr_assaultfrigate",
						spawn_priority = 1
					},
					{
						type = "tai_defensefighter",
						min_count = 3
					},
					"vgr_interceptor"
				},
			},
			[3] = {
				value = 3200,
				enemy_types = {
					"kus_assaultfrigate",
					"tai_assaultfrigate",
					{
						type = "tai_defensefighter",
						min_count = 3
					},
					"kad_multibeamfrigate"
				}
			}
		}
	},
	[2] = {
		waves = {
			[1] = {
				value = 5000,
				enemy_types = {
					"vgr_commandcorvette",
					"vgr_bomber",
					"vgr_lancefighter",
					{
						type = "vgr_interceptor",
						custom_price = 200
					}
				}
			},
			[2] = {
				value = 6000,
				enemy_types = {
					{
						type = "kus_missiledestroyer",
						max_count = 1
					},
					"tai_gravwellgenerator",
					"vgr_heavymissilefrigate",
					"vgr_commandcorvette"
				}
			},
			[3] = {
				value = 8000,
				add_reactive = 1,
				enemy_types = {
					{
						type = "kus_heavycruiser",
						min_count = 1,
						max_count = 1
					},
					"tai_ioncannonfrigate",
					"tai_defensefighter",
					"kus_dronefrigate",
					"kus_gravwellgenerator",
					"tai_fieldfrigate",
					"kus_ioncannonfrigate"
				}
			}
		}
	},
	[3] = {
		waves = {
			[1] = {
				value = 10000,
				add_reactive = 1,
				enemy_types = {
					"vgr_destroyer",
					"kus_missiledestroyer",
					"vgr_lasercorvette",
					"tur_ionarrayfrigate",
					"vgr_commandcorvette",
					"tai_gravwellgenerator"
				}
			},
			[2] = {
				value = 11000,
				add_reactive = 1,
				enemy_types = {
					{
						type = "kad_advancedswarmer",
						min_count = 30
					},
					"tai_defensefighter",
					"kad_multibeamfrigate",
					{
						type = "kad_p2mothership",
						min_count = 1,
						max_count = 2
					}
				}
			},
			[3] = {
				value = 15000,
				add_reactive = 1,
				enemy_types = {
					{
						type = "hgn_dreadnaught",
						min_count = 1,
						max_count = 1
					},
					"kpr_mover",
					{
						type = "kpr_attackdroid",
						custom_price = 400
					},
					"tai_multiguncorvette",
					"tai_heavycorvette",
					"kus_gravwellgenerator",
					"vgr_commandcorvette"
				}
			}
		}
	},
	[4] = {
		waves = {
			[1] = {
				value = 20000,
				add_reactive = 1,
				enemy_types = {
					"kus_dronefrigate",
					"tai_assaultfrigate",
					"tai_fieldfrigate",
					"tai_ioncannonfrigate",
					"kus_ioncannonfrigate",
					"kus_assaultfrigate",
					"vgr_heavymissilefrigate",
					"vgr_assaultfrigate",
					"kad_multibeamfrigate",
					"tur_ionarrayfrigate"
				}
			},
			[2] = {
				value = 20000,
				enemy_types = {
					"tai_defensefighter",
					"vgr_lasercorvette",
					"vgr_missilecorvette",
					"kpr_mover",
					"kus_heavycorvette",
					"tai_heavycorvette",
					"kus_multiguncorvette",
					"vgr_commandcorvette",
					{
						type = "vgr_battlecruiser",
						max_count = 1
					}
				}
			},
			[3] = {
				value = 40000,
				enemy_types = {
					{
						type = "kpr_sajuuk",
						min_count = 1,
						max_count = 1
					},
					"vgr_bomber",
					"kus_attackbomber",
					"tai_interceptor",
					"vgr_commandcorvette",
					"tai_defensefighter",
					{
						type = "kad_advancedswarmer",
						custom_price = 100
					},
					"kpr_destroyerm10",
				}
			}
		}
	}
};