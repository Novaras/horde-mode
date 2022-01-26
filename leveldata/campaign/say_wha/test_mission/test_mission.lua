if (modkit == nil) then dofilepath("data:scripts/modkit.lua"); end

rules = modkit.campaign.rules;
map = modkit.campaign.map;

rules:init("data:leveldata/campaign/say_wha/test_mission/test_mission.level");

dofilepath("data:scripts/custom_code/horde/phase_rewards.lua");

---@class Wave
---@field value integer
---@field enemy_types string[]
---@field rewards WaveReward

---@class Phase
---@field waves Wave[]

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

local phase_rules = {};
-- here we set up the phase rules
for index, phase in PHASE_CONFIGS do
	phase_rules[index] = rules:make(
		"phase_" .. index,
		function (state)
			if (state._tick == 1) then
				Subtitle_Message("hello from phase " .. %index, 3);
				modkit.table.printTbl(state, "rule state");
			end
			if (Universe_GameTime() > state._started_gametime + 10) then
				print("gametime " .. Universe_GameTime() .. " is +10 on our start time: " .. state._started_gametime);
				return %index;
			end
		end,
		1
	);
end

local phase_manager_rule = rules:make(
	"phase_manager",
	function (state, rules)
		print("hello from phase manager!");

		if (state.phase_rules == nil) then
			print("manager setting up...");
			modkit.table.printTbl(
				modkit.table.keys(%phase_rules),
				"phase rules"
			);

			state.phase_rules = %phase_rules;

			function state:allFinished()
				return modkit.table.all(
					self.phase_rules,
					---@param rule Rule
					function (rule)
						return rule.status == "returned";
					end
				);
			end

			function state:phaseBegin(rules, index)
				print("beginning phase " .. index);
				local phase_rule = self.phase_rules[index];
				if (phase_rule ~= nil) then
					self.running = "phase_" .. index;
					rules:begin(phase_rule);
					rules:on(
						self.running,
						function ()
							%self:phaseEnded(%rules, %index);
						end
					);
					print("\tpattern: '" .. self.running .. "'");
				else
					print("no such rule: phase_" .. index .. ", do nothing...");
				end
			end

			---@param rules Rules
			function state:phaseEnded(rules, index)
				print("phase " .. index .. " ended, callback triggered! (pattern: '" .. self.running .. "')");
				self:phaseBegin(rules, index + 1);
			end
		end

		if (state:allFinished()) then
			return "yata";
		end

		if (state.running == nil) then
			print("no phase running!");
			state:phaseBegin(rules, 1);
		end
	end,
	1
);

rules:begin(phase_manager_rule);
rules:on(
	phase_manager_rule.id,
	function ()
		Subtitle_Message("all done!", 5);
	end
);