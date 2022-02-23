if (H_HORDE_REWARDS == nil) then
	if (modkit == nil) then
		dofilepath("data:scripts/modkit.lua");
	end

	local rewards = {};

	function rewards:getSelectedReward()
		local state = makeStateHandle();
		local selected = state().selected;

		-- modkit.table.printTbl(state(), "tracker state()");
		if (selected and selected ~= -1) then
			local reward = modkit.table.find(_p, function (reward)
				return reward.name == %state().selected;
			end);
			return reward;
		end
	end

	if (horde == nil) then
		horde = {};
	end

	horde.rewards = rewards;

	H_HORDE_REWARDS = 1;
end