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
				value = 1000,
				enemy_types = {
					"vgr_interceptor",
					"tai_multiguncorvette"
				},
				rewards = WAVE_REWARDS[0]
			},
			[2] = {
				value = 1500,
				enemy_types = {
					"hgn_assaultfrigate",
					"kus_attackbomber",
					"kus_lightcorvette"
				},
				rewards = WAVE_REWARDS[1]
			},
		},
	},
	[2] = {
		waves = {
			[1] = {
				value = 4000,
				enemy_types = {
					"tai_destroyer"
				},
				rewards = WAVE_REWARDS[2]
			}
		},
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

for id, ship in GLOBAL_MISSION_SHIPS:all() do
	ship:print();
end
