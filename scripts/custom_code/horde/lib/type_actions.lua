-- This file just sets up two fields on the HM proto:
-- 1. `action_configs`: configs for various 'actions' a controlled ship type group might perform, including the relevant ship types and the callback to use for those types
-- 2. `actions_by_type`: since we'd need to look up the ship's action every time, we instead just do all these lookups immediately and store them in a big table

-- (the table could be smaller if ships with 'default' behavior didnt have the default fn hooked to them, we could just 'default' to it (as it were))

if (H_HORDE_TYPE_ACTIONS == nil) then
	
	---@alias ShipAction fun(ship: Ship, player_ships: Ship[], control_ships: Ship[])

	---@alias TypeGroupActionConfig { types: string[], action: ShipAction }

	---@type table<string, TypeGroupActionConfig>
	horde_manager.action_configs = {
		guard = {
			types = {
				"hgn_defensefieldfrigate",
				"vgr_commandcorvette",
				"kus_gravwellgenerator",
				"tai_defensefighter",
				"tai_fieldfrigate",
				"tai_gravwellgenerator",
				"kus_cloakgenerator",
				"tai_cloakgenerator"
			},
			action = function (ship, _, control_ships)
				---@alias GuardFilter fun(ship: Ship): Ship[]
				---@alias FilterConfig { guarding_types: string[], filter: GuardFilter }
				---@type FilterConfig[]
				horde_manager.guard_filter_configs = horde_manager.guard_filter_configs or {
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
						guarding_types = horde_manager.guard_types,
						filter = function (ship)
							return ship:isAnyTypeOf(horde_manager.guard_types) == nil;
						end
					}
				};

				local filter_config = modkit.table.find(horde_manager.guard_filter_configs, function (filter_config)
					return modkit.table.includesValue(filter_config.guarding_types, %ship.type_group);
				end);

				if (filter_config == nil) then
					consoleError("Somehow entered guard action callback with a non-guarder ship (could not find a filter config for " .. ship.type_group .. ")");
					---@diagnostic disable-next-line: redundant-return-value
					return nil;
				end

				-- !! TODO?: it would be nice to cache the below result somehow
				-- i.e
				--- ```lua
				--- local guard_targets = horde_manager._targets_cache[ship.id] or ...filter...
				--- if (horde_manager._targets_cache[ship.id] == nil) then
				---    horde_manager._targets_cache[ship.id] = { targets = guard_targets, duration = 10 }
				--- ```
				--- have the cache duration decrease (or use an `age` field) per manager update
	
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
				end
			end,
		},
		default = {
			types = {},
			action = function (ship, player_ships)
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
					---@cast ship Ship
					return ship:isCloaked() == nil;
				end));
			end
		},
	};

	-- we pre-generate a list of actions per ship type, so we don't need to keep checking the ship's type
	-- against a group of types like 'guard_types' (we dont want to keep asking 'what group does this type belong to?' as its costly)

	modkit = modkit or {};
	if (modkit.ship_types == nil) then
		dofilepath("data:scripts/modkit/ship-types.lua");
	end

	horde_manager.actions_by_type = modkit.table.reduce(modkit.ship_types, function (out_tbl, type)
		---@cast out_tbl { [ShipType]: ShipAction }

		local config = modkit.table.find(horde_manager.action_configs, function (group_config)
			return modkit.table.includesValue(group_config.types, %type);
		end) or horde_manager.action_configs.default;

		out_tbl[type] = config.action;

		return out_tbl;
	end, {});

	print("type actions should be set");
	modkit.table.printTbl(horde_manager.actions_by_type or {}, "here");

	H_HORDE_TYPE_ACTIONS = 1;
end