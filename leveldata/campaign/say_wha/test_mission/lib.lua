if (modkit == nil) then dofilepath("data:scripts/modkit.lua"); end

REWARD_DIALOG_TRACKER_ROE_VALUES = {
	option_a = OffensiveROE,
	option_b = DefensiveROE
};

---@class Wave
---@field value integer
---@field enemy_types string[]

---@class Phase
---@field waves Wave[]

phase_rules = {};
wave_rules = {};

--- Returns a function which is used as the rule for the wave given by `index`.
---
---@param wave_index integer
---@param wave Wave
---@return RuleFn
function makeWaveRule(wave_index, wave)
	---@type RuleFn
	return function (state)
		if (state.total_spawned_group == nil) then
			Subtitle_Message("hello from wave " .. %wave_index, 2);
			print("wave " .. %wave_index .. " start...");

			state.total_spawned_group = SobGroup_Fresh("_wave_total_spawned_" .. %wave_index);

			local player_carrier = GLOBAL_MISSION_SHIPS:get("player_initbuilder");

			local ships_to_spawn = {};
			local current_value = 0;
			while(current_value < %wave.value) do
				print("\tcurrent val: " .. current_value);
				local ship_type = %wave.enemy_types[random(1, modkit.table.length(%wave.enemy_types))];
				local ship_value = SobGroup_GetStaticF(ship_type, "buildCost");
				print("\tsv: " .. ship_value);
				if (current_value + ship_value < %wave.value * 1.1) then
					modkit.table.push(ships_to_spawn, ship_type);
					current_value = current_value + ship_value;
				else
					break;
				end
			end

			-- todo: config should be able to define its own definite volumes, random should be a fallback
			local spawner_volumes = {};
			local vol_count = max(1, floor(modkit.table.length(ships_to_spawn) / 2));
			for i = 1, vol_count do
				local vol_pos = {};
				for axis, val in player_carrier:position() do
					if (axis ~= 1) then -- dont offset vertically
						-- val + ((1 or -1) * [7000, 9000])
						vol_pos[axis] = val + (modkit.math.pow(-1, random(1, 2)) * random(7000, 9000));
					end
				end
				spawner_volumes[i] = Volume_Fresh("_horde_spawn_vol_" .. i, vol_pos);
			end

			for _, ship_type in ships_to_spawn do
				local group = SobGroup_Fresh("_horde_spawn_group");
				local vol = modkit.table.randomEntry(spawner_volumes)[2];

				SobGroup_SpawnNewShipInSobGroup(1, ship_type, "_horde_squad", group, vol);
				SobGroup_SobGroupAdd(state.total_spawned_group, group);
			end
		end

		if (state.total_spawned_group) then
			print("spawned group count: " .. SobGroup_CountByPlayer(state.total_spawned_group, 1));

			if (
				Universe_GameTime() > state._started_gametime + (60 * 3) or
				SobGroup_CountByPlayer(state.total_spawned_group, 1) == 0
			) then
				return 1;
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
	return function (state, rules)
		if (state._tick == 1) then
			Subtitle_Message("hello from phase " .. %phase_index, 3);
			modkit.table.printTbl(state, "rule state");

			wave_rules = {};
			for index, wave in %phase.waves do
				wave_rules[index] = rules:make(
					"wave_" .. index .. "_" .. %phase_index,
					makeWaveRule(index, wave),
					1
				);
			end

			rules:begin(%wave_manager_rule);
			rules:on(
				%wave_manager_rule.id,
				function ()
					Subtitle_Message("all waves complete!", 3);
				end
			);
		end

		-- print("from phase rule");
		-- print("screen active?");
		-- print(UI_IsScreenActive("HordeModeScreen"));
		-- print("hmm");
		-- print(SobGroup_GetHealth("state_tracker"));
		-- if (SobGroup_GetHealth("state_tracker") == REWARD_DIALOG_VALUES.option_a) then
		-- 	print("we chose option A!");
		-- elseif (SobGroup_GetHealth("state_tracker") == REWARD_DIALOG_VALUES.option_b) then
		-- 	print("we chose option B!");
		-- end
		-- print("\n\n");

		if (%wave_manager_rule.status == "returned") then
			return 1;
		end
	end
end


function makeWaveManagerRule()
	---@type RuleFn
	return function (state)
		if (state.wave_rules == nil) then
			print("wave manager setting up...");
			modkit.table.printTbl(
				modkit.table.keys(wave_rules),
				"wave rules"
			);

			state.wave_rules = wave_rules;

			function state:allFinished()
				return modkit.table.all(
					self.wave_rules,
					---@param rule Rule
					function (rule)
						return rule.status == "returned";
					end
				);
			end

			function state:waveBegin(rules, index)
				print("beginning wave " .. index);
				---@type Rule
				local wave_rule = self.wave_rules[index];
				if (wave_rule ~= nil) then
					self.running = wave_rule.id;
					rules:begin(wave_rule);
					rules:on(
						self.running,
						function ()
							%self:waveEnded(%rules, %index);
						end
					);
					print("\tpattern: '" .. self.running .. "'");
				else
					print("no such rule, do nothing...");
				end
			end

			---@param rules Rules
			function state:waveEnded(rules, index)
				print("wave " .. index .. " ended, callback triggered! (pattern: '" .. self.running .. "')");
				self:waveBegin(rules, index + 1);
			end
		end

		if (state:allFinished()) then
			return "yata";
		end

		if (state.running == nil) then
			print("no wave running!");
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
	return function (state, rules)
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
						return rule.status == "returned";
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

					-- modkit.table.printTbl({ index, 0, 0 }, "TRACKER POS SET TO");
					-- local vol = Volume_Fresh("tracker_hs_vol", { index, 0, 0 });
					-- SobGroup_ExitHyperSpace("state_tracker", vol);

					-- print("proof:");
					-- modkit.table.printTbl(SobGroup_GetPosition("state_tracker"));
					print("phase " .. index .. " begun, set the tracker HP to " .. 1 / index);
					SobGroup_SetHealth("state_tracker", 1);
					SobGroup_SetHealth("state_tracker", 1 / index);

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
				UI_SetTextLabelText("HordeModeScreen", "lbl_option_a", PHASE_REWARDS[index].option_a.description);
				UI_SetTextLabelText("HordeModeScreen", "lbl_option_b", PHASE_REWARDS[index].option_b.description);
				UI_ShowScreen("HordeModeScreen", eTransition);
				Universe_Pause(1, 1.5);
			end
		end

		if (state:allFinished()) then
			return "yata";
		end

		print("init: " .. (state.initialised or "nil"));
		print("running id: " .. (state.running_index or "nil"));

		if (state.initialised == 1 and state.running_index == nil) then -- init but no phase = waiting for UI result
			
			if (UI_IsScreenActive("HordeModeScreen") == 0) then -- above but no active screen = UI result available
				print("UI result available!");
				Universe_Pause(0, 1.5);
				state:phaseBegin(rules);
			else
				print("awaiting UI result");
			end
		end

		if (state.initialised == nil) then
			state.initialised = 1;
			state.power_ups = {
				max_speed = 1,
				weapon_damage = 1
			};
			print("no phase running!");
			state:phaseBegin(rules);
		end
	end
end