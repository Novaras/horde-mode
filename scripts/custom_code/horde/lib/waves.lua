if (H_HORDE_WAVES == nil) then
	function horde_manager:manageWave()
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

	---@param wave Wave
	function horde_manager:spawnWaveShips(wave)
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

	H_HORDE_WAVES = 1;
end