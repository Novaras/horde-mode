if (H_HORDE_REWARDS == nil) then
	function horde_manager:pickRewards()
		local meetsReqs = function (reqs, type)
			if (reqs == nil or reqs[type] == nil) then
				return "return nil;";
			end
			---@type Ship[]
			local builders = modkit.table.filter(%self.human_player:ships(), function (ship)
				return ship:canBuild() == 1;
			end);
			local predicates = {
				subsystem = function (match)
					return modkit.table.find(%builders, function (builder)
						return builder:hasSubsystem(%match);
					end);
				end
			};
			local predicate = predicates[type];
	
			local pattern_exec = "" .. (reqs[type] or "");
			pattern_exec = gsub(pattern_exec, " and ", " & ");
			pattern_exec = gsub(pattern_exec, " or ", " | ");
			-- here we are constructing a LUA logic expression which will tell us the truthiness of the supplied pattern
			-- (we construct something like: "return 1 and nil and nil or (1 and 1)")
			pattern_exec = gsub(pattern_exec, "([%w_]+)", function(match)
				print("match: " .. match);
				if (%predicate(match)) then
					return "1";
				end
				return "nil";
			end);
			pattern_exec = gsub(pattern_exec, " & ", " and ");
			pattern_exec = gsub(pattern_exec, " | ", " or ");
			pattern_exec = gsub(pattern_exec, "^%s*(.-)%s*$", "%1");
			print("return " .. pattern_exec);
			return "return " .. pattern_exec;
		end
	
		local state = makeStateHandle();
	
		---@type _Rew
		local reward_a = modkit.table.randomEntry(_p)[2];
		if (state().selections) then
			while (modkit.table.includesValue(state().selections, reward_a.name)) do
				reward_a = modkit.table.randomEntry(_p)[2];
			end
		end
		if (dostring(meetsReqs(reward_a.requires, 'subsystem')) ~= 1) then
			print("\ttehcnically illegal");
		end
	
		local reward_b = modkit.table.randomEntry(_p)[2];
		if (state().selections) then
			while (modkit.table.includesValue(state().selections, reward_b.name) or (reward_a.name == reward_b.name)) do
				reward_b = modkit.table.randomEntry(_p)[2];
			end
		end
		if (dostring(meetsReqs(reward_b.requires, 'subsystem')) ~= 1) then
			print("\ttechnically illegal");
		end
	
		self.rewards = {
			a = reward_a,
			b = reward_b
		};
	
		local state = makeStateHandle();
		state({
			rewards = {
				a = reward_a.name,
				b = reward_b.name
			}
		});
	end

	function horde_manager:getSelectedReward()
		local state = makeStateHandle();
		local selected = state().selected;

		if (selected and selected ~= -1) then
			local reward = modkit.table.find(_p, function (reward)
				return reward.name == %state().selected;
			end);
			return reward;
		end
	end

	function horde_manager:manageRewards()
		print("WHAT");
		local reward = self:getSelectedReward();
		if (reward) then
			-- modkit.table.printTbl(reward, "REWARD");
			if (reward.build_options) then
				print("apply build opts");
				for _, opt in reward.build_options do
					print("\topt: " .. opt);
					self.human_player:restrictBuildOption(opt, 0);
				end
			end

			if (reward.research_options) then
				print("apply res opts");
				for _, opt in reward.research_options do
					print("\topt: " .. opt);
					self.human_player:restrictResearchOption(opt, 0);
				end
			end

			if (reward.research_grant) then
				print("apply grants");
				for _, grant in reward.research_grant do
					print("\tgrant: " .. grant);
					if (self.human_player:hasResearch(grant) == nil) then
						self.human_player:grantResearchOption(grant);
					end
				end
			end

			if (reward.spawn) then
				print("spawn ships");
				for _, spawn_data in reward.spawn do
					-- modkit.table.printTbl(spawn_data, "spawn data");
					for i = 1, spawn_data.count do
						SobGroup_SpawnNewShipInSobGroup(
							spawn_data.player,
							spawn_data.type,
							"-",
							SobGroup_Fresh(DEFAULT_SOBGROUP),
							Volume_Fresh("-", { 0 + (50 * i), 1200, 0 }, 1000)
						);
					end
				end
			end

			if (reward.callbacks) then
				for _, callback in reward.callbacks do
					callback();
				end
			end

			self.doing_ui = 0;
			self.rewards = -1;
			local state = makeStateHandle();
			state(state(), { omit = { "rewards", "selected" }, override = { awaiting_ui = 0 } });
			-- modkit.table.printTbl(makeStateHandle()(), "state after rew");
		end
	end

	H_HORDE_REWARDS = 1;
end