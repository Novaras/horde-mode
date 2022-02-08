-- this ship is sued to track state between scopes
-- - mission scope
-- - UI scope
-- - ship scripts scope
-- in order for these to share info with eachother, various attributes of this ship are used to encode this information
-- the health is used to track the phase reward dialogue result
-- the position is used to track { phase_index, wave_index, _ }

if (REWARD_DIALOG_TRACKER_ROE_VALUES == nil) then
	dofilepath("data:leveldata/campaign/say_wha/test_mission/lib.lua");
end

if (PHASE_REWARDS == nil) then
	dofilepath("data:scripts/custom_code/horde/phase_rewards.lua");
end

---@class HordeTrackerProto : Ship
horde_tracker_proto = {
};

function horde_tracker_proto:update()
	print("tracker health: " .. self:HP());

	if (self.init == nil) then
		self:ROE(PassiveROE);
		self.init = 1;
		self.player_carrier = GLOBAL_SHIPS:find(function (ship)
			return ship.type_group == "hgn_carrier";
		end);
	end

	-- ROE is set in `hordemodescreen.lua` by the dialogue buttons
	-- OffensiveROE = option A
	-- DefensiveROE = option B
	-- PassiveROE = idle
	if (self:ROE() ~= PassiveROE) then
		print("ok, seems like the ui set our ROE");
		self:issueRewards();
		self:ROE(PassiveROE); -- reset
	end

	self:manageEnemies();
end

function horde_tracker_proto:issueRewards()
	---@param rewards RewardOption
	local issueOptionRewards = function (rewards)
		local player = GLOBAL_PLAYERS:get(0);

		if (rewards.rus) then
			print("adding rus: " .. rewards.rus);
			player:RU(player:RU() + rewards.rus);
		end

		if (rewards.power_ups) then
			print("adding rewards");
			modkit.table.printTbl(rewards.power_ups);
			for _, power in rewards.power_ups do
				print("looks like we got a powerup: " .. power.effect .. ", fraction is " .. power.fraction);
				for _, ship in player:ships() do
					local current_val = ship:multiplier(power.effect);
					ship:multiplier(power.effect, current_val + power.fraction);
				end
			end
		end

		if (rewards.build_options) then
			for _, option in rewards.build_options do
				Player_UnrestrictBuildOption(0, option);
			end
		end
	end

	-- 1 / i = Hc
	-- i = round(1 / Hc)
	local phase_reward_options = PHASE_REWARDS[modkit.math.round(1 / self:HP())];
	modkit.table.printTbl(phase_reward_options, "reward options?");

	if (self:ROE() == REWARD_DIALOG_TRACKER_ROE_VALUES.option_a) then
		print("tracker judges option A selected from dialogue");
		issueOptionRewards(phase_reward_options.option_a);
	elseif (self:ROE() == REWARD_DIALOG_TRACKER_ROE_VALUES.option_b) then
		print("tracker judges option B selected from dialogue");
		issueOptionRewards(phase_reward_options.option_b);
	end
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
		if (ship:isFighter() == nil) then
			print("control for " .. ship.own_group .. "(a " .. ship.type_group .. ")");
			print("\tcommand is " .. ship:currentCommand() .. " (COMMAND_Idle is " .. COMMAND_Idle .. ")");
		end

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