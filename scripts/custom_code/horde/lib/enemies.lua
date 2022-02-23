if (H_HORDE_ENEMIES == nil) then
	---@param ship Ship
	---@param player_ships Ship[]
	function horde_manager:smartAttackManage(ship, player_ships, control_ships)
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

	H_HORDE_ENEMIES = 1;
end