dofilepath('data:scripts/modkit/scope_state.lua');
state = makeStateHandle();


function HordeModeScreenOnShow()
	print("show horde screen");

	--Universe_Pause(1, 1.5);
end

function HordeModeScreenOnHide()
	print("NOW HORDE MODE SCREEN IS HIDDEN, MY WORD");

	--Universe_Pause(0, 0);
end

function HordeRewardBtnClick(which)
	print("selected: " .. which);
	state({
		selected = state().rewards[which],
		selections = modkit.table:merge(
			(state().selections or {}),
			{
				state().rewards[which]
			}
		)
	});
	UI_HideScreen('HordeModeScreen');
end