if (modkit == nil) then dofilepath("data:scripts/modkit.lua"); end

---@class WaveConfig
---@field value integer
---@field enemy_types table<integer, string | { type: string, min_count: integer }>
---@field duration? integer
---@field add_reactive? bool

---@class Wave
---@field init bool
---@field finished bool
---@field config WaveConfig
---@field index integer
---@field spawnedShips fun(): Ship[]
---@field started_gametime number

---@class Phase
---@field waves WaveConfig[]

phase_rules = {};
wave_rules = {};

--- Returns a function which is used as the rule for the wave given by `index`.
---
---@param wave_index integer
---@param wave WaveConfig
---@return RuleFn
function makeWaveRule(wave_index, wave)
	---@type RuleFn
	return function (res, rej, state)
		local global_state = makeStateHandle();
		---@type Wave|-1
		local running_wave = global_state().running_wave;
		if (running_wave == -1) then
			global_state({
				running_wave = {
					index = %wave_index,
					config = %wave,
					started_gametime = Universe_GameTime()
				}
			});
			Subtitle_Message("hello from wave " .. %wave_index, 3);
		else
			if (running_wave.finished) then
				global_state({
					running_wave = -1
				});
				res(1);
			end
		end
	end
end

--- Returns a function which is used as the rule for the given phase.
---
---@param phase_index integer
---@param phase Phase
---@param wave_manager_rule Rule
---@return RuleFn
function makePhaseRule(phase_index, phase, wave_manager_rule)
	---@type RuleFn
	return function (res, rej, state, rules)
		if (state._tick == 1) then
			Subtitle_Message("hello from phase " .. %phase_index, 3);
			modkit.table.printTbl(state, "rule state");

			wave_rules = {};
			for index, wave in %phase.waves do
				wave_rules[index] = rules:make(
					makeWaveRule(index, wave),
					{
						name = "wave_" .. index .. "_" .. %phase_index,
						interval = 1
					}
				);
			end

			modkit.table.printTbl(wave_rules, "wave_rules (GLOBAL)");

			rules:begin(%wave_manager_rule);
			rules:on(
				%wave_manager_rule.id,
				function ()
					Subtitle_Message("all waves complete!", 3);
				end
			);
		end

		if (%wave_manager_rule.status == "resolved") then
			res(1);
		end
	end
end

---@return RuleFn
function makeWaveManagerRule()
	return function (res, rej, state)
		---@class WaveManagerState: RuleState
		---@field running_wave string
		---@field wave_rules Rule[]
		---@field allFinished fun(self: WaveManagerState): bool
		---@field waveBegin fun(self: WaveManagerState, rules: Rules, index: integer)
		---@field waveEnded fun(self: WaveManagerState, rules: Rules, index: integer)

		---@cast state WaveManagerState
		if (state.wave_rules == nil) then
			print("wave manager setting up...");
			modkit.table.printTbl(
				wave_rules,
				"wave rules"
			);

			state.wave_rules = wave_rules;

			function state:allFinished()
				return modkit.table.all(
					self.wave_rules,
					---@param rule Rule
					function (rule)
						return rule.status == "resolved";
					end
				);
			end

			function state:waveBegin(rules, index)
				print("beginning wave " .. index);
				---@type Rule
				local wave_rule = self.wave_rules[index];
				if (wave_rule ~= nil) then
					self.running_wave = wave_rule.id;
					rules:begin(wave_rule);
					rules:on(
						wave_rule.api_name,
						function ()
							%self:waveEnded(%rules, %index);
						end
					);
					print("\tpattern: '" .. self.running_wave .. "'");
				else
					print("no such rule, do nothing...");
				end
			end

			---@param rules Rules
			function state:waveEnded(rules, index)
				print("wave " .. index .. " ended, callback triggered! (pattern: '" .. self.running_wave .. "')");
				self:waveBegin(rules, index + 1);
			end
		end

		if (state:allFinished()) then
			res("woop");
		end

		if (state.running_wave == nil) then
			print("no wave running!");
			makeStateHandle()({
				running_wave = -1
			});
			state:waveBegin(rules, 1);
		end
	end
end


phase_manager_state = {};

--- Returns a function which is used as the rule for the phase manager.
---
---@return RuleFn
function makePhaseManagerRule()
	---@type RuleFn
	return function (res, rej, state, rules)
		print("hello from phase manager!");
		state = phase_manager_state;

		if (state.phase_rules == nil) then
			print("manager setting up...");
			modkit.table.printTbl(
				modkit.table.keys(phase_rules),
				"phase rules"
			);

			state.phase_rules = phase_rules;
			state.next_phase_index = 1;

			function state:allFinished()
				return modkit.table.all(
					self.phase_rules,
					---@param rule Rule
					function (rule)
						return rule.status == "resolved";
					end
				);
			end

			function state:phaseBegin(rules, index)
				index = index or self.next_phase_index;
				print("beginning phase " .. index);
				local phase_rule = self.phase_rules[index];
				if (phase_rule ~= nil) then
					self.running_index = index;
					self.running_pattern = "phase_" .. index;
					self.next_phase_index = index + 1;

					rules:begin(phase_rule);
					rules:on(
						self.running_pattern,
						function ()
							%self:phaseEnded(%rules, %index);
						end
					);
					print("\tpattern: '" .. self.running_pattern .. "'");
				else
					print("no such rule: phase_" .. index .. ", do nothing...");
				end
			end

			---@param rules Rules
			function state:phaseEnded(rules, index)
				print("phase " .. index .. " ended, callback triggered! (pattern: '" .. self.running_pattern .. "')");
				self.running_pattern = nil;
				self.running_index = nil;

				makeStateHandle()({
					awaiting_ui = 1
				});

				-- UI_SetTextLabelText("HordeModeScreen", "lbl_option_a", reward_a.description);
				-- UI_SetTextLabelText("HordeModeScreen", "lbl_option_b", reward_b.description);

				-- makeStateHandle()({
				-- 	rewards = {
				-- 		a = reward_a.name,
				-- 		b = reward_b.name
				-- 	}
				-- });

				-- UI_ShowScreen("HordeModeScreen", eTransition);
				-- Universe_Pause(1, 1.5);
			end
		end

		if (state:allFinished()) then
			return "yata";
		end

		print("init: " .. (state.initialised or "nil"));
		print("running id: " .. (state.running_index or "nil"));

		if (state.initialised == 1 and state.running_index == nil) then -- init but no phase = waiting for UI result
			local globalStateHnd = makeStateHandle();
			if (UI_IsScreenActive("HordeModeScreen") == 0 and globalStateHnd().awaiting_ui == 0) then -- above but no active screen = UI result available
				print("UI result available!");

				-- here we init a grace period between phases
				-- if not init, set to now + 20
				if (globalStateHnd().awaiting_ui_gt == nil) then
					globalStateHnd({
						awaiting_ui_gt = Universe_GameTime() + 20
					});
				end
				-- if gt > whatever we set, period is ended
				modkit.table.printTbl(globalStateHnd(), "stateHnd");
				if (Universe_GameTime() > globalStateHnd().awaiting_ui_gt) then
					state:phaseBegin(rules);
					globalStateHnd({ omit = { "awaiting_ui_gt" }});
				end
			else
				print("awaiting UI result");
			end
		end

		if (state.initialised == nil) then
			makeStateHandle()({
				awaiting_ui = 0
			});
			state.initialised = 1;
			print("no phase running!");
			state:phaseBegin(rules);
		end
	end
end

function makeGracePeriodRule(period)
	return function (res, rej, state)
		-- modkit.table.printTbl(state);
		if (state._tick == 1) then
			UI_SetTimerOffset("NewTaskbar", "GameTimer", -%period);
		end
		if (state._tick == 50) then
			Subtitle_Message("<c=33ffff>WELCOME TO HORDE MODE!</c>", 5);
		end

		if (Universe_GameTime() >= %period) then
			res(1);
		end
	end;
end