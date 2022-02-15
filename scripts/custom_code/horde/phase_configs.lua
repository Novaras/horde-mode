---@type table<integer, Phase>
PHASE_CONFIGS = {
	[1] = {
		waves = {
			[1] = {
				value = 2000,
				enemy_types = {
					"tai_multiguncorvette",
					"tur_ionarrayfrigate"
				},
			},
			[2] = {
				value = 2200,
				enemy_types = {
					"kus_lightcorvette",
					"hgn_assaultfrigate",
					"kus_attackbomber"
				},
			},
			[3] = {
				value = 2750,
				enemy_types = {
					"kus_assaultfrigate",
					"tai_assaultfrigate",
					"hgn_interceptor",
					"tai_defensefighter",
					"kad_multibeamfrigate"
				}
			}
		}
	},
	[2] = {
		waves = {
			[1] = {
				value = 4200,
				enemy_types = {
					"tai_destroyer",
					"vgr_commandcorvette",
					"kus_assaultfrigate",
					"vgr_heavymissilefrigate"
				}
			},
			[2] = {
				value = 6000,
				enemy_types = {
					"kus_missiledestroyer",
					"tai_gravwellgenerator",
					"vgr_heavymissilefrigate",
					"vgr_commandcorvette",
					"hgn_torpedofrigate"
				}
			},
			[3] = {
				value = 8000,
				add_reactive = 1,
				enemy_types = {
					{
						type = "kus_heavycruiser",
						min_count = 1
					},
					"tai_destroyer",
					"hgn_ioncannonfrigate",
					"tai_defender",
					"kus_defender",
					"kus_gravwellgenerator",
					"tai_fieldfrigate"
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
					"hgn_destroyer",
					"vgr_destroyer",
					"kus_missiledestroyer",
					"kad_multibeamfrigate",
					"vgr_commandcorvette",
					"kus_gravwellgenerator"
				}
			},
			[2] = {
				value = 10000,
				add_reactive = 1,
				enemy_types = {
					{
						type = "kad_advancedswarmer",
						min_count = 30,
						custom_price = 50
					},
					"tai_defensefighter",
					"kus_attackbomber",
					"tai_attackbomber"
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
					"kpr_attackdroid",
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
					"kus_assaultfrigate"
				}
			},
			[2] = {
				value = 20000,
				enemy_types = {
					"tai_defensefighter",
					"vgr_lasercorvette",
					"kpr_mover",
					"tur_standardcorvette",
					"tai_heavycorvette",
					"kus_multiguncorvette"
				}
			},
			[3] = {
				value = 40000,
				enemy_types = {
					{
						type = "kpr_sajuuk",
						min_count = 1,
						custom_price = 25000
					},
					"hgn_attackbomber",
					"kus_attackbomber",
					"tai_interceptor",
					"vgr_commandcorvette",
					"tai_defensefighter",
					{
						type = "kad_advancedswarmer",
						custom_price = 10
					},
					"kpr_destroyerm10",
				}
			}
		}
	}
};