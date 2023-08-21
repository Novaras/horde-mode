if (H_HORDE_ENEMIES == nil) then


	--- Uses `actions_by_type` to lookup the correct action for the given `ship`.
	---
	---@param ship Ship the ship to control, i.e manage its guarding or attack behavior
	---@param player_ships Ship[] human player's ships
	---@param control_ships Ship[] all ships controlled by the manager
	function horde_manager:controlShip(ship, player_ships, control_ships)
		self.actions_by_type[ship.type_group](ship, player_ships, control_ships);
	end

	function horde_manager:getNextControlBatch()
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

	function horde_manager:manageEnemies()
		if (self.spawned_merged == nil) then
			local spawned_ships = modkit.table.clone(self:getSpawnedWaveShips());

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

			-- print("cntrl ships len: " .. modkit.table.length(control_ships));
			for _, ship in control_ships do
				self:controlShip(ship, player_ships, self.total_spawned_ships);

				-- need to make sure capship engines dont die (so player cant stall forever)
				-- hp = min(1, max(current_hp, 0.05))
				if (ship:hasSubsystem("Engine")) then
					ship:subsHP("Engine", min(1, max(ship:subsHP("Engine"), 0.05)));
				end
			end
		end
	end

	H_HORDE_ENEMIES = 1;
end