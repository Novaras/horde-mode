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
	makeGracePeriodRule(60)
);
rules:begin(grace_period_rule);
UI_SetTimerOffset("NewTaskbar", "GameTimer", -60);

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

-- we can use p2 as an ally to control big swarms (poorly microed mass units)
SetAlliance(0, 2);
SetAlliance(2, 0);

-- capital and frigate production disabled to begin with
Player_RestrictBuildOption(0, "Hgn_SY_Production_CapShip");
-- Player_RestrictBuildOption(0, "Hgn_MS_Production_Frigate");
-- Player_RestrictBuildOption(0, "Hgn_C_Production_Frigate");

Player_RestrictBuildOption(0, "hgn_shipyard");

Player_RestrictResearchOption(0, "MothershipHealthUpgrade1");
Player_RestrictResearchOption(0, "MothershipMAXSPEEDUpgrade1");
Player_RestrictResearchOption(0, "MothershipBUILDSPEEDUpgrade1");

-- Player_RestrictResearchOption(0, "HordeShipYardBuffs_MaxHealth");
-- Player_RestrictResearchOption(0, "HordeShipYardBuffs_ProdSpeed");
-- Player_RestrictResearchOption(0, "Fighter_FlakWeapons");
-- Player_RestrictResearchOption(0, "Corvette_FlakWeapons");

-- enemy ships gain self cloaks later, they'll be missing this
Player_RestrictResearchOption(0, "SensDisProbe"); -- they called it 'sensdisprobe' even though its proxys lol
Player_RestrictBuildOption(0, "hgn_ms_module_cloakgenerator");
Player_RestrictBuildOption(0, "hgn_c_module_cloakgenerator");

SobGroup_CreateSubSystem(GLOBAL_MISSION_SHIPS:get('player_initbuilder').own_group, "hgn_ms_module_research");
-- for k, v in globals() do
-- 	print(k .. ": " .. tostring(v));
-- end

-- UI_ShowScreen("HordeModeScreen", ePopup);

Player_GrantResearchOption(0, "Fighter_FlakWeapons");
Player_GrantResearchOption(0, "Corvette_FlakWeapons");