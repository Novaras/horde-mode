if (modkit == nil) then dofilepath("data:scripts/modkit.lua"); end

rules = modkit.campaign.rules;
map = modkit.campaign.map;

dofilepath("data:scripts/custom_code/horde/phase_rewards.lua");
dofilepath("data:scripts/custom_code/horde/phase_configs.lua");
dofilepath("data:leveldata/campaign/say_wha/test_mission/lib.lua");

rules:init("data:leveldata/campaign/say_wha/test_mission/test_mission.level");

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
