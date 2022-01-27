if (modkit == nil) then dofilepath("data:scripts/modkit.lua"); end

---@class Wave
---@field value integer
---@field enemy_types string[]
---@field rewards WaveReward

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

			local player_station = GLOBAL_MISSION_SHIPS:get("player_station");

			local ships_to_spawn = {};
			local current_value = 0;
			while(current_value < %wave.value) do
				print("\tcurrent val: " .. current_value);
				local ship_type = %wave.enemy_types[random(1, modkit.table.length(%wave.enemy_types))];
				local ship_value = SobGroup_GetStaticF(ship_type, "buildCost");
				print("\tsv: " .. ship_value);
				if (current_value + ship_value < %wave.value) then
					modkit.table.push(ships_to_spawn, ship_type);
					current_value = current_value + ship_value;
				else
					break;
				end
			end

			-- todo: config should be able to define its own definite volumes, random should be a fallback
			local spawner_volumes = {};
			local vol_count = max(1, floor(modkit.table.length(ships_to_spawn) / 4));
			for i = 1, vol_count do
				local vol_pos = {};
				for axis, val in player_station:position() do
					if (axis ~= 1) then -- dont offset vertically
						-- val + (1 or -1 * 8000)
						vol_pos[axis] = val + (modkit.math.pow(-1, random(1, 2)) * 7000);
					end
				end
				spawner_volumes[i] = Volume_Fresh("_horde_spawn_vol_" .. i, vol_pos);
			end

			for _, ship_type in ships_to_spawn do
				local group = SobGroup_Fresh("_horde_spawn_group");
				local vol = modkit.table.randomEntry(spawner_volumes)[2];

				SobGroup_SpawnNewShipInSobGroup(1, ship_type, "_horde_squad", group, vol);
				SobGroup_Attack(1, group, player_station.own_group);
				player_station:HP(0.9);
				SobGroup_SobGroupAdd(state.total_spawned_group, group);
			end
		end

		if (state.total_spawned_group) then
			if (SobGroup_Count(state.total_spawned_group) == 0) then
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

--- Returns a function which is used as the rule for the phase manager.
---
---@return RuleFn
function makePhaseManagerRule()
	---@type RuleFn
	return function (state, rules)
		print("hello from phase manager!");

		if (state.phase_rules == nil) then
			print("manager setting up...");
			modkit.table.printTbl(
				modkit.table.keys(phase_rules),
				"phase rules"
			);

			state.phase_rules = phase_rules;

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
	end
end