if (modkit == nil) then dofilepath("data:scripts/modkit.lua"); end

rules = modkit.campaign.rules;
map = modkit.campaign.map;

dofilepath("data:scripts/custom_code/horde/phase_rewards.lua");
dofilepath("data:leveldata/campaign/say_wha/test_mission/lib.lua");

rules:init("data:leveldata/campaign/say_wha/test_mission/test_mission.level");

---@type table<integer, Phase>
local PHASE_CONFIGS = {
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

-- here we set up the phase rules
for index, phase in PHASE_CONFIGS do
	local wave_manager_rule = rules:make(
		"wave_manager_" .. index,
		makeWaveManagerRule(),
		1
	);
	phase_rules[index] = rules:make(
		"phase_" .. index,
		makePhaseRule(index, phase, wave_manager_rule),
		1
	);
end

local grace_period_rule = rules:make(
	"grace_period",
	function ()
		if (Universe_GameTime() > 20) then
			return 1;
		end
	end,
	0.5
);
rules:begin(grace_period_rule);

rules:on(
	grace_period_rule.id,
	function ()
		local phase_manager_rule = rules:make(
			"phase_manager",
			makePhaseManagerRule(),
			1
		);
		rules:begin(phase_manager_rule);
		rules:on(
			phase_manager_rule.id,
			function ()
				Subtitle_Message("all phases complete!", 5);
			end
		);
	end
)

SetAlliance(0, 2);
SetAlliance(2, 0);

Player_RestrictBuildOption(0, "Hgn_SY_Production_CapShip");

Player_RestrictResearchOption(0, "MothershipHealthUpgrade1");
Player_RestrictResearchOption(0, "MothershipMAXSPEEDUpgrade1");
Player_RestrictResearchOption(0, "MothershipBUILDSPEEDUpgrade1");
