
---@alias PowerEffect RuntimeShipMultiplier

---@class PowerUp
---@field effect PowerEffect
---@field fraction number

---@class RewardOption
---@field description string
---@field rus? integer
---@field technology? string[]
---@field power_ups? PowerUp[]
---@field build_options? string[]
---@field research_options? string[]

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


--- Returns the icon data associated with this class ('type') of ship, in a format insertable to
--- UI code.
---
--- `uvRect` is the { topleft x, topleft y, bottomright x, bottomright_y } coordinates of the rectangle
--- defining which section of the source texture to use.
---
---@param ship_class string
---@return { uvRect: number[], texture: string }
function UI_GetShipClassIconData(ship_class)
	local coord_indices = {
		fighter = 0,
		corvette = 1,
		frigate = 2,
		capital = 3,
		platform = 4,
		utility = 5,
		resource = 5,
	};
	local index = coord_indices[ship_class];

	return {
		uvRect = { 0, index * 64, 64, (index + 1) * 64 },
		texture = "data:ui\\NewUI\\Styles\\HWRM_Style\\FacilityIcons.tga"
	};
end

function GetHordeShipYardHealthStr()
	dofilepath("data:scripts/modkit/scope_state.lua");
	local str = "<<awaiting init>>";
	if (dostring) then
		str = makeStateHandle()().ui_player_shipyard_health_str or str;
	end
	return str;
end

local weaponfire_icon_layout = {
	texture = "data:ui\\newui\\taskbar\\commandicons\\cmd_ico_burstattack.dds",
	uvRect = { 0, 128, 128, 256 }
};

local attack_reticle_icon_layout = {
	texture = "data:ui\\newui\\taskbar\\commandicons\\cmd_ico_aggressive.dds",
	uvRect = { 0, 128, 128, 256 }
};

local cloak_tech_icon_layout = {
	texture = "data:ui\\newui\\taskbar\\commandicons\\cmd_ico_cloak.dds",
	uvRect = { 0, 128, 128, 256 }
};

local repair_tech_icon_layout = {
	texture = "data:ui/newui/taskbar/commandicons/cmd_ico_repair.dds",
	uvRect = { 0, 128, 128, 256 }
}

---@class SpawnInfo
---@field type string
---@field player integer
---@field count integer

---@class _Rew
---@field name string
---@field requires? { subsystems: string, rewards: string }
---@field description? string
---@field icon? { uvRect: number[], texture: string }
---@field build_options? string[]
---@field research_options? string[]
---@field research_grant? string[]
---@field rus? integer
---@field spawn? SpawnInfo[]
---@field callbacks? function[]

-- <c=ff005e> for hp
-- <c=ffd500> for production
-- <c=ff2222> for atk/cmd
-- <c=22ffff> tech
-- <c=eeeeee> for cloak

---@type _Rew[]
_p = {
	-- {
	-- 	name = "frigate_production",
	-- 	requires = {
	-- 		subsystems = "hgn_ms_module_research or hgn_ms_module_researchadvanced or hgn_c_module_research or hgn_c_module_researchadadvanced"
	-- 	},
	-- 	description = "Enables the production of frigates",
	-- 	icon = UI_GetShipClassIconData("frigate"),
	-- 	build_options = {
	-- 		"hgn_ms_production_frigate",
	-- 		"hgn_c_production_frigate"
	-- 	},
	-- 	spawn = {}
	-- },
	{
		name = "capital_production",
		requires = {
			subsystems = "hgn_ms_module_research or hgn_ms_module_researchadvanced or hgn_c_module_research or hgn_c_module_researchadadvanced"
		},
		description = "Enables the production of capital ships",
		icon = UI_GetShipClassIconData("capital"),
		build_options = {
			"hgn_sy_production_capship"
		}
	},
	{
		name = "shipyard_buffs",
		description = "Upgrades the shipyard:\n\n+ 50% <c=ffd500>Production Speed</c>\n+ 50% <c=ff005e>Max Health</c> " .. GetHordeShipYardHealthStr(),
		icon = UI_GetShipClassIconData("capital"),
		research_grant = {
			"HordeShipYardBuffs_MaxHealth",
			"HordeShipYardBuffs_ProdSpeed"
		},
	},
	{
		name = "command_vettes",
		description = "Spawns six <c=ff2222>Command Corvettes</c> under your control",
		icon = attack_reticle_icon_layout,
		spawn = {
			{
				type = "vgr_commandcorvette",
				player = 0,
				count = 6
			}
		},
	},
	{
		name = "anti_fighter_flak",
		requires = {
			subsystems = "hgn_c_production_fighter or hgn_ms_production_fighter or hgn_c_production_corvette or hgn_ms_production_corvette"
		},
		description = "Interceptor and gunship weapons fire <c=22ffff>AOE flak missiles</c>",
		icon = weaponfire_icon_layout,
		research_grant = {
			"Fighter_FlakWeapons",
			"Corvette_FlakWeapons"
		}
	},
	{
		name = "alive_ships_dmg_up",
		description = "For all <b>currently alive ships</b>:\n- <c=ff2222>+200% Damage</c>\n- <c=11ff22>+20% Speed</c>",
		icon = attack_reticle_icon_layout,
		callbacks = {
			function ()
				local ships = modkit.ships():all();
				for _, ship in ships do
					if (ship.player.id == 0) then
						ship:damageMult(ship:damageMult() * 3);
						ship:speed(ship:speed() * 1.2);
					end
				end
			end
		}
	},
	{
		name = "cloak_techs",
		description = "Unlock <c=eeeeee>cloaking</c> technologies",
		icon = cloak_tech_icon_layout,
		research_options = {
			"SensDisProbe"
		},
		build_options = {
			"hgn_ms_module_cloakgenerator",
			"hgn_c_module_cloakgenerator"
		}
	},
	{
		name = "bomber_cloaks",
		description = "Bombers gain:\n- unlimited energy <c=eeeeee>cloaks</c>\n- while <c=eeeeee>cloaked</c>, regenerate <c=ff005e>2%</c> per second",
		icon = cloak_tech_icon_layout,
		research_grant = {
			"bomber_cloaks"
		}
	},
	{
		name = "pulsar_emp",
		description = "Pulsars gain:\n- <c=ff2222>+20% Damage</c>\n- Pulses gain <c=88aaff>EMP effects</c>",
		icon = cloak_tech_icon_layout,
		research_grant = {
			"pulsar_emp"
		}
	},
	{
		name = "delayed_healing",
		description = "Destroyers & Battleruisers <c=ff005e>heal for 50% of recent damage</c> if their health isn't reduced again <b>within 12s</b>",
		icon = repair_tech_icon_layout,
		research_grant = {
			"delayed_healing"
		}
	}
};
