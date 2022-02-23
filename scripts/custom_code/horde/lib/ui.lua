if (H_HORDE_UI == nil) then
	function horde_manager:showUIIfWaiting()
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

			print("manager showing ui screen");
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

	H_HORDE_UI = 1;
end