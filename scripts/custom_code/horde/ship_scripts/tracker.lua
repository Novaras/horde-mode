if (makeStateHandle == nil) then
	dofilepath("data:scripts/modkit/scope_state.lua");
end

if (REWARD_DIALOG_TRACKER_ROE_VALUES == nil) then
	dofilepath("data:leveldata/campaign/say_wha/test_mission/lib.lua");
end

if (PHASE_REWARDS == nil) then
	dofilepath("data:scripts/custom_code/horde/phase_rewards.lua");
end

---@class HordeTrackerProto : Ship
---@field human_player Player
---@field rewards { a: _Rew, b: _Rew }
---@field doing_ui '0' | '1'
horde_tracker_proto = {
	rewards = nil
};

---@return _Rew
function horde_tracker_proto:getSelectedReward()
	local state = makeStateHandle();
	local selected = state().selected;

	modkit.table.printTbl(state(), "tracker state()");
	if (selected and selected ~= -1) then
		local r = modkit.table.find(_p, function (R)
			return R.name == %state().selected;
		end);

		if (r) then
			state({ selected = -1 });
		end
		return r;
	end
end

function horde_tracker_proto:pickRewards()
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

	---@type _Rew
	local reward_a = modkit.table.randomEntry(_p)[2];
	if (dostring(meetsReqs(reward_a.requires, 'subsystem')) ~= 1) then
		print("\ttehcnically illegal");
	end

	local reward_b = modkit.table.randomEntry(_p)[2];
	while(reward_a.name == reward_b.name) do
		reward_b = modkit.table.randomEntry(_p)[2];
	end
	if (dostring(meetsReqs(reward_b.requires, 'subsystem')) ~= 1) then
		print("\ttehcnically illegal");
	end

	self.rewards = {
		a = reward_a,
		b = reward_b
	};

	local state = makeStateHandle();
	state({ rewards = {
		a = reward_a.name,
		b = reward_b.name
	} });
end

function horde_tracker_proto:showUIIfWaiting()
	local phases_paused = makeStateHandle()().awaiting_ui;
	if (phases_paused == 1) then
		print("tracker showing ui screen");
		self:pickRewards();
		UI_ShowScreen("HordeModeScreen", ePopup);

		UI_SetTextLabelText("HordeModeScreen", "reward_a_desc", self.rewards.a.description);
		UI_SetTextLabelText("HordeModeScreen", "reward_b_desc", self.rewards.b.description);
		self.doing_ui = 1;
	end
	return self.doing_ui;
end

function horde_tracker_proto:update()
	print("tracker health: " .. self:HP());

	if (self.init == nil) then
		self.init = 1;
		self.doing_ui = 0;
		self.human_player = GLOBAL_PLAYERS:get(0);
	end

	if (self.doing_ui == 0) then
		self:showUIIfWaiting();
	end

	local reward = self:getSelectedReward();
	if (reward) then
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
				self.human_player:grantResearchOption(grant);
			end
		end

		if (reward.spawn) then
			print("spawn ships");
			for _, spawn_data in reward.spawn do
				for i = 1, spawn_data.count do
					SobGroup_SpawnNewShipInSobGroup(
						spawn_data.player,
						spawn_data.type,
						"-",
						SobGroup_Fresh(DEFAULT_SOBGROUP),
						Volume_Fresh("-", { 0 + (50 * i), 1200, 0 })
					);
				end
			end
		end

		self.doing_ui = 0;
		self.rewards = -1;
		makeStateHandle()({
			awaiting_ui = 0,
			rewards = -1;
		});
	end

	self:manageEnemies();
end

-- ---@param ship Ship
-- function horde_tracker_proto:smartAttackManage(ship)
-- 	if (ship:isAnyTypeOf({
-- 		""
-- 	})) then
		
-- 	end
-- end

-- here we control the phase enemies
function horde_tracker_proto:manageEnemies()
	local player_ships = GLOBAL_SHIPS:filter(function (ship)
		return ship.player.id == 0;
	end);
	local player_enemy_ships = GLOBAL_SHIPS:filter(function (ship)
		return ship.player.id == 1;
	end);

	local guard_types = {
		"hgn_defensefieldfrigate",
		"vgr_commandcorvette",
		"kus_gravwellgenerator",
		"tai_defensefighter",
		"tai_fieldfrigate",
		"tai_gravwellgenerator"
	};

	for _, ship in player_enemy_ships do
		-- if (ship:isFighter() == nil) then
		-- 	print("control for " .. ship.own_group .. "(a " .. ship.type_group .. ")");
		-- 	print("\tcommand is " .. ship:currentCommand() .. " (COMMAND_Idle is " .. COMMAND_Idle .. ")");
		-- end

		if (modkit.table.includesValue(guard_types, ship.type_group)) then
			local attackers = modkit.table.filter(player_enemy_ships, function (target_ship)
				return modkit.table.includesValue(%guard_types, target_ship.type_group) == nil;
			end);
			if (modkit.table.length(attackers) == 0) then
				ship:HP(ship:HP() - 0.1);
			else
				ship:guard(attackers);
			end
		else
			ship:attack(player_ships);
		end

		if (ship:canHyperspace() == 1) then
			if (random() < 0.1) then
				if (ship:distanceTo(ship:commandTargets(COMMAND_Attack)) > 2000 or ship:isBeingCaptured()) then
					print(ship.own_group .. " deciding to jump!");
					local pos = {};
					for axis, value in SobGroup_GetPosition(SobGroup_FromShips(DEFAULT_SOBGROUP, ship:commandTargets(COMMAND_Attack))) do
						if (axis == 2) then
							pos[axis] = 1000;
						else
							-- station pos +- [1000 - 1750]
							pos[axis] = value + modkit.math.pow(-1, random(1, 2)) * random(1000, 1750);
						end
					end
					modkit.table.printTbl(pos, "jumping to pos");
					ship:hyperspace(pos);
				end
			end
		end

		-- need to make sure capship engines dont die (so player cant stall forever)
		if (ship:hasSubsystem("Engine")) then
			ship:subsHP("Engine", min(1, ship:subsHP("Engine") + 0.05));
		end
	end
end

modkit.compose:addShipProto("horde_tracker", horde_tracker_proto);