if (horde_manager == nil) then
	if (modkit == nil) then
		dofilepath("data:scripts/modkit.lua");
	end

	---@class HordeManagerProto : Ship
	---@field human_player Player
	---@field rewards? { a: _Rew, b: _Rew }
	---@field doing_ui 0|1
	---@field guard_types string[]
	horde_manager = {
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
		},
		actions_by_type = {}
	};
	doscanpath("data:scripts/custom_code/horde/lib/", "*.lua");

	function horde_manager:update()
		-- print("manager tick " .. self:tick());

		if (self.init == nil) then
			self.doing_ui = 0;
			self.human_player = GLOBAL_PLAYERS:get(0);
			
			dofilepath("./type_actions.lua");
			
			print("GO");
			self.init = 1;
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

	modkit.compose:addShipProto("horde_manager", horde_manager);

	print("horde init");
end