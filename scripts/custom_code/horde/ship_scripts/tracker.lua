if (makeStateHandle == nil) then
	dofilepath("data:scripts/modkit/scope_state.lua");
end

if (horde == nil) then
	dofilepath("data:scripts/custom_code/horde/horde.lua");
end

---@class HordeTrackerProto : Ship
---@field human_player Player
---@field rewards { a: _Rew, b: _Rew }
---@field doing_ui '0' | '1'
horde_tracker_proto = {
	rewards = nil,
	guard_types = {
		"hgn_defensefieldfrigate",
		"vgr_commandcorvette",
		"kus_gravwellgenerator",
		"tai_defensefighter",
		"tai_fieldfrigate",
		"tai_gravwellgenerator",
		"kus_cloakgenerator",
		"tai_cloakgenerator"
	}
};

function horde_tracker_proto:manageRewards()
	print("WHAT");
	local reward = horde.rewards:getSelectedReward();
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

---@param wave Wave
function horde_tracker_proto:spawnWaveShips(wave)
	-- clone & convert string entries to table entries
	local conf_enemies_to_spawn = modkit.table.map(
		modkit.table.clone(wave.config.enemy_types),
		function (spawn_info)
			local info = spawn_info;
			if (type(info) == "string") then
				info = {
					type = info,
					spawn_priority = 0
				};
			end
			return modkit.table:merge(
				{
					spawn_priority = 1,
					min_count = 1
				},
				info
			);
		end
	);
	-- modkit.table.printTbl(conf_enemies_to_spawn, "sorting");
	-- now sort by spawn_priority
	sort(conf_enemies_to_spawn, function (spawn_a, spawn_b)
		return spawn_a.spawn_priority < spawn_b.spawn_priority;
	end);

	-- now define spawns
	---@type string[]
	local spawner_volumes = {};
	-- for _, ship in modkit.ships():findType("horde_shipyard") do
	-- 	ship:print();
	-- end
	local player_builder = modkit.ships():findType("horde_shipyard")[1] or modkit.ships():findType("hgn_carrier")[1];
	for i = 1, 8 do
		local vol_pos = {};
		for axis, val in player_builder:position() do
			-- val + ((1 or -1) * [7000, 9000])
			vol_pos[axis] = val + (modkit.math.pow(-1, random(1, 2)) * random(7000, 9000));
		end
		spawner_volumes[i] = Volume_Fresh("_horde_spawn_vol_" .. i, vol_pos, 2000);
	end

	local reactive_value = 0;
	if (wave.config.add_reactive) then
		-- (val - shipyard val) / d
		reactive_value = max(self.human_player:fleetValue() - 3500, 0) / 50;
	end

	-- ok so, here we are spawning ships from the wave's config
	-- we do this (in order) until their cumulative value is >= the config.value
	-- also, when we spawn a ship, we greate a getter fn for it
	-- the getters are added to the superglobal state so anyone can read them
	-- the getters return the ship definition from `modkit.ships()` if possible, else just the spawn group name
	local spawned_getters = {};
	local spawned_value = 0;
	local index_to_spawn = 0;
	local spawned_types = {};
	while(spawned_value < (wave.config.value + reactive_value)) do
		local spawn_config = conf_enemies_to_spawn[index_to_spawn + 1];
		local maxed_out;
		if (spawn_config.max_count and spawned_types[spawn_config.type]) then
			if (spawn_config.max_count <= spawned_types[spawn_config.type]) then
				maxed_out = 1;
			end
		end
		-- print("spawning a " .. spawn_config.type);
		if (maxed_out == nil) then
			for i = 1, (spawn_config.min_count or 1) do
				local spawn_group = SobGroup_Fresh();
				local getSpawned = function ()
					local sg = %spawn_group;
					return modkit.ships():find(function (ship)
						-- print("AreEqual: " .. ship.own_group .. ", " .. %sg .. ": " .. (SobGroup_AreEqual(ship.own_group, %sg) or "nil"));
						return SobGroup_AreEqual(ship.own_group, %sg);
					end) or sg;
				end;
				SobGroup_SpawnNewShipInSobGroup(
					1,
					spawn_config.type,
					"-",
					spawn_group,
					modkit.table.randomEntry(spawner_volumes)[2]
				);
				spawned_value = spawned_value + (spawn_config.custom_price or SobGroup_GetStaticF(spawn_config.type, "buildCost"));

				spawned_types[spawn_config.type] = (spawned_types[spawn_config.type] or 0) + 1;

				modkit.table.push(spawned_getters, getSpawned);
			end
		end
		index_to_spawn = mod(index_to_spawn + 1, modkit.table.length(conf_enemies_to_spawn));
	end

	-- modkit.table.printTbl(spawned_getters, "getters");

	-- getter for the spawned ships (cant access them on the same tick as the spawn call)
	self.getSpawnedWaveShips = function (self)
		print("expensive call");
		-- execute the getters, filter out the ones which didnt produce `Ship` objects
		return modkit.table.filter(
			modkit.table.map(
				%spawned_getters,
				function (getter)
					return getter();
				end
			),
			function (spawned)
				return (spawned and type(spawned) == "table" and spawned.own_group);
			end
		);
	end
	self.spawn_grace_period_end_tick = self:tick() + 2;
	self.spawned_merged = nil;

	local state = makeStateHandle();
	state({
		running_wave = modkit.table:merge(
			wave,
			{
				init = 1 -- tell wave manager this wave is init (spawned the ships)
			}
		)
	});
end

function horde_tracker_proto:manageWave()
	---@type Wave
	local state = makeStateHandle();
	local wave = state().running_wave;
	if (wave and type(wave) == "table") then
		if (wave.init == nil) then
			self:spawnWaveShips(wave);
		elseif (self:tick() > self.spawn_grace_period_end_tick and self.spawned_merged) then
			local count = self.total_spawned_count or 0;
			print("len: " .. count);
			-- print("gt: " .. Universe_GameTime() .. " vs scheduled: " .. (wave.started_gametime + (wave.config.duration or 180)));
			
			if (
				wave.finished ~= 1 and
				(
					count == 0 or
					Universe_GameTime() > (wave.started_gametime + (wave.config.duration or 180))
				)
			) then
				wave.finished = 1;
				state({
					running_wave = wave
				});
			end
		end
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
	state({ rewards = {
		a = reward_a.name,
		b = reward_b.name
	} });
end

function horde_tracker_proto:showUIIfWaiting()
	local phases_paused = makeStateHandle()().awaiting_ui;
	if (phases_paused == 1) then
		local sy = modkit.table.find(self.human_player:ships(), function (ship)
			return ship.type_group == "horde_shipyard";
		end);
		if (sy) then
			makeStateHandle()({
				ui_player_shipyard_health_str = "[HP: <c=ff005e>" .. sy:HP() .. "</c> / <c=ff005e>" .. sy:maxActualHP() .. "</c>]"
			});
		end

		print("tracker showing ui screen");
		self:pickRewards();
		-- modkit.table.printTbl(makeStateHandle()(), "state on show");
		UI_ShowScreen("HordeModeScreen", ePopup);

		UI_SetTextLabelText("HordeModeScreen", "reward_a_desc", self.rewards.a.description);
		UI_SetTextLabelText("HordeModeScreen", "reward_b_desc", self.rewards.b.description);
		self.doing_ui = 1;
		print("done..?");
	end
	return self.doing_ui;
end

function horde_tracker_proto:update()
	print("tracker tick " .. self:tick());

	if (self.init == nil) then
		self.init = 1;
		self.doing_ui = 0;
		self.human_player = GLOBAL_PLAYERS:get(0);

		print("GO");
		-- Player_GrantResearchOption(0, "pulsar_emp");
	end

	-- if (Player_HasResearch(0, "Bomber_Cloaking") == 1) then
	-- 	for _, ship in modkit.ships():all() do
	-- 		if (ship.player.id == 0 and ship:isAnyTypeOf({ "hgn_attackbomber", "hgn_pulsarcorvette" })) then
				
	-- 		end
	-- 	end
	-- end

	if (self.doing_ui == 0) then
		self:showUIIfWaiting();
		self:manageWave();
		if (self.spawn_grace_period_end_tick and self:tick() > self.spawn_grace_period_end_tick and self.getSpawnedWaveShips and mod(self:tick(), 3) == 0) then
			self:manageEnemies();
		end
	else
		self:manageRewards();
	end
end

---@param ship Ship
---@param player_ships Ship[]
function horde_tracker_proto:smartAttackManage(ship, player_ships, control_ships)
	-- local player_enemy_ships = modkit.ships():filter(function (ship)
	-- 	return ship.player.id == 1;
	-- end);

	if (ship:isAnyTypeOf(self.guard_types)) then -- do guard behavior instead
		---@alias GuardFilter fun(ship: Ship): Ship[]
		---@alias FilterConfig { guarding_types: string[], filter: GuardFilter }
		---@type FilterConfig[]
		self.guard_filter_configs = self.guard_filter_configs or {
			gravwell = {
				guarding_types = { "kus_gravwellgenerator", "tai_gravwellgenerator" },
				filter = function (ship)
					return ship:isAnyTypeOf({ 
						"kus_missiledestroyer",
						"tai_missiledestroyer",
						"hgn_torpedofrigate",
						"kus_assaultfrigate",
						"tai_assaultfrigate"
					}) or ship:isAnyFamilyOf({
						"bigcapitalship",
						"smallcapitalship",
						"frigate"
					});
				end
			},
			default = {
				guarding_types = self.guard_types,
				filter = function (ship)
					return ship:isAnyTypeOf(%self.guard_types) == nil;
				end
			}
		};

		---@type FilterConfig
		local filter_config = modkit.table.find(self.guard_filter_configs, function (filter_config)
			return modkit.table.includesValue(filter_config.guarding_types, %ship.type_group);
		end);
		---@type Ship[]
		local guard_targets = modkit.table.filter(control_ships, filter_config.filter);
		if (guard_targets) then
			-- for _, ship in guard_targets do
			-- 	ship:print();
			-- end
			guard_targets = modkit.table.pack(guard_targets);
			-- sort by distance
			sort(guard_targets, function (a, b)
				return %ship:distanceTo(a) < %ship:distanceTo(b);
			end);
		end
		local guard_target = guard_targets[1]; -- best target only
		if (guard_target) then
			local max_threshold = 15000;
			local out_of_pos_threshold = 600;
			if (guard_target:isFighter() or guard_target:isCorvette()) then
				out_of_pos_threshold = 1200;
			end
			if (ship:distanceTo(guard_target) > max_threshold) then
				ship:position(modkit.table.map(guard_target:position(), function (axis, index)
					return axis + (modkit.math.pow(-1, index) * 300);
				end));
			elseif (ship:distanceTo(guard_target) > out_of_pos_threshold) then
				local speedup = 1;
				local g = SobGroup_Fresh();
				Player_FillProximitySobGroup(g, 0, ship.own_group, 5000);
				if (SobGroup_Count(g) == 0) then
					speedup = min(3, max(1, ship:distanceTo(guard_target) / out_of_pos_threshold))
				end
				-- print(ship.own_group .. " speedup: " .. speedup);
				ship:speed(speedup);
				ship:move(guard_target);
			else
				ship:speed(1);
				ship:guard(guard_target);
				if (ship:isAnyTypeOf({ "kus_cloakgenerator", "tai_cloakgenerator" })) then
					ship:cloak(0);
				elseif (ship.type_group == "hgn_defensefieldfrigate") then
					ship:canDoAbility(AB_DefenseField, 1);
				end
			end
		else
			ship:kamikazi(player_ships);
			ship:HP(ship:HP() - 0.05);
		end
	else -- no special attack behavior
		if (ship:canHyperspace() == 1) then
			local chance = max(0.01, (1 - ship:HP()) / 10);
			if (random() < chance) then
				if (ship:distanceTo(ship:commandTargets(COMMAND_Attack)) > 8000 or ship:isBeingCaptured()) then
					print(ship.own_group .. " deciding to jump!");
					local pos = modkit.ships(ship:commandTargets(COMMAND_Attack)):avgPosition();
					for axis, value in pos do
						if (axis == 2) then
							pos[axis] = 1000;
						else
							-- station pos +- [1000 - 1750]
							pos[axis] = value + modkit.math.pow(-1, random(1, 2)) * random(1000, 1750);
						end
					end
					-- modkit.table.printTbl(pos, "jumping to pos");
					ship:hyperspace(pos);
				end
			end
		end

		ship:attack(modkit.table.filter(player_ships, function (ship)
			return ship:isCloaked() == 0;
		end));
	end
end

function horde_tracker_proto:getNextControlBatch()
	self.control_batch_size = self.control_batch_size or 80;
	local max_index = self.total_spawned_count;

	local start_index = mod(min(self.last_batch_index or 0, max_index), max_index) + 1;
	local finish_index = min(start_index + self.control_batch_size, max_index);
	local batch = {};
	-- print("si: " .. start_index);
	-- print("fi: " .. finish_index);
	-- for k, v in self.total_spawned_ships do
	-- 	print(k);
	-- 	v:print();
	-- 	print("--");
	-- end
	for i = start_index, finish_index do
		batch[i] = self.total_spawned_ships[i];
	end

	self.last_batch_index = finish_index;
	return batch;
end

-- here we control the phase enemies
function horde_tracker_proto:manageEnemies()
	if (self.spawned_merged == nil) then
		local spawned_ships = modkit.table.clone(self:getSpawnedWaveShips());
		self.getSpawnedWaveShips = function (self)
			return %spawned_ships;
		end
		self.total_spawned_ships = modkit.table.pack(modkit.table:merge(
			self.total_spawned_ships,
			spawned_ships
		));
		self.total_spawned_count = modkit.table.length(self.total_spawned_ships);

		self.spawned_merged = 1;
	end

	if (self.total_spawned_ships) then
		self.total_spawned_ships = modkit.table.pack(modkit.table.filter(self.total_spawned_ships, function (ship)
			return ship:alive() == 1;
		end));
		self.total_spawned_count = modkit.table.length(self.total_spawned_ships);
	end

	if (self.total_spawned_count > 0) then
		local player_ships = self.human_player:ships();
		local control_ships = self:getNextControlBatch();
		print("cntrl ships len: " .. modkit.table.length(control_ships));
		for _, ship in control_ships do
			self:smartAttackManage(ship, player_ships, self.total_spawned_ships);

			-- need to make sure capship engines dont die (so player cant stall forever)
			-- hp = min(1, max(current_hp, 0.05))
			if (ship:hasSubsystem("Engine")) then
				ship:subsHP("Engine", min(1, max(ship:subsHP("Engine"), 0.05)));
			end
		end
	end
end

modkit.compose:addShipProto("horde_tracker", horde_tracker_proto);