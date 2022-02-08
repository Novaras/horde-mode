dofilepath("data:ui/newui/Styles/HWRM_Style/HWRMDefines.lua")
dofilepath("data:ui/newui/Styles/HWRM_Style/ControlConstructors.lua")

if (modkit == nil) then dofilepath("data:scripts/modkit/table_util.lua"); end

if (PHASE_REWARDS == nil) then dofilepath("data:scripts/custom_code/horde/phase_rewards.lua"); end

local makeButtonCallbackStr = function (dialog_vals_index)
	return "dofilepath(\"data:leveldata/campaign/say_wha/test_mission/lib.lua\"); UI_HideScreen(\"HordeModeScreen\"); SobGroup_SetROE(\"state_tracker\", REWARD_DIALOG_TRACKER_ROE_VALUES." .. dialog_vals_index .. ");";
end

---@class ButtonConfig
---@field name string
---@field text string
---@field label string
---@field onClick function
---@field style string
---@field layout table
---@field hotkey_id integer

--- Returns a table defining a button.
---@param btn_config ButtonConfig
---@return table
local makeButton = function (btn_config)
	name = btn_config.name;
	text = btn_config.text;
	label = btn_config.label or btn_config.text;
	hotkey_id = btn_config.hotkey_id or 0;
	layout = btn_config.layout or BTN_FOOTER_STD_LAYOUT;
	style = btn_config.style or "FEButtonStyle1_Outlined";
	onClick = btn_config.onClick or NOOP;

	local btn = NewMenuButton(name, text, label, hotkey_id, layout, style, onClick);
	btn.Layout.size_WH = { w = 0.45, h = STD_BUTTON_HEIGHT, wr = "par", hr = "scr" };
	return btn;
end;

HordeModeScreen = {
	size = {0, 0, 800, 600},
	stylesheet = "HW2StyleSheet",
	pixelUVCoords = 1,

	Layout = {
		pos_XY = {	x=0.0, y=0.0, xr="px", yr="px",},
		size_WH = {w = 1, h = 1, wr = "scr", hr = "scr",},
	},

	RootElementSettings = {
		backgroundColor = COLOR_FULLSCREEN_DARKEN,
	},
	;
	{
		type = "Frame",

		arrangetype = "vert",
		arrangedir = 1,
		name = "m_frmDialogRoot",
		Layout = {
			pivot_XY = { 0.5, 0.5 },
			pos_XY = {	x=0.5, y=0.5, xr="par", yr="par",},
		},
		cursorType = "Normal",
		autosize=1,
		giveParentMouseInput = 1, --?
		;
		{
			type = "RmWindow",
			WindowTemplate = PANEL_WINDOWSTYLE,

			TitleText =	"Select a boon", --Bentusi Exchange
			name = "m_frmDialogWindow",
			-- SubtitleText = "$4913",	--Choose//
			Layout = {
				pos_XY = {	x=0.5, y=0.5, xr="px", yr="px",},
				size_WH = {w = 0.6, h = 0.5, wr = "scr", hr = "scr",},
			},
			arrangetype = "vert",
			;
			{
				type = "Frame",
				BackgroundGraphic = BORDER_GRAPHIC_FRAME,
				backgroundColor = COLOR_BACKGROUND_PANEL,
				Layout = {
					size_WH = {w = 1, h = 1, wr = "par", hr = "par",},
				},
				arrangetype = "horiz",
				;
				{ -- left margin (Layout margins are really weird)
					type = "Frame",
					Layout = {
						size_WH = {w = 0.025, h = 1, wr = "par", hr = "par",},
					},
				},
				{ -- this is the left side boon
					type = "Frame",
					BackgroundGraphic = {
						texture = "DATA:\\Ship\\Icons\\HordeModeTest.tga",
						textureUV = {0,0,256,256},
						color = OUTLINECOLOR,
					},
					Layout = {
						size_WH = {w = 0.45, h = 1, wr = "par", hr = "par",},
						pad_LT = { l = 0.05, t = 32, lr = "par", tr = "px" }
					},
					arrangetype = "vert",
					;
					{
						type = "TextLabel",
						name = "m_lblBoonTitle_1",
						Layout = {
							margin_RB = { r = 0, b = 24, rr = "px", br = "px" }
						},
						autosize=1,
						Text = {
							text = "Option A",
							-- textStyle = "IGHeading1",
							font = "Heading3Font",
							color = "FEColorHeading3",
							hAlign = "Center",
							pixels = 48 * 1.5,
						},
						giveParentMouseInput = 1,
						--backgroundColor = {0,255,0,255},
					},
					{
						type = "TextLabel",
						name = "lbl_option_a",
						Layout = {
							margin_RB = { r = 0, b = 24, rr = "px", br = "px" }
						},
						autosize = 1,
						Text = {
							text = "god help us all",
							textStyle = "FEHelpTipTextStyle",
							vAlign = "Top",
						},
						giveParentMouseInput = 1,
						--backgroundColor = {0,255,255,255},
					},
				},
				{ -- seperator
					type = "Frame",
					Layout = {
						size_WH = {w = 0.05, h = 1, wr = "par", hr = "par",},
					},
				},
				{ -- right side boon
					type = "Frame",
					BackgroundGraphic = {
						texture = "DATA:\\Ship\\Icons\\HordeModeTest.tga",
						textureUV = {0,0,256,256},
						color = OUTLINECOLOR,
					},
					Layout = {
						size_WH = {w = 0.45, h = 1, wr = "par", hr = "par",},
						pad_LT = { l = 0.05, t = 32, lr = "par", tr = "px" }
					},
					arrangetype = "vert",
					;
					{
						type = "TextLabel",
						name = "m_lblBoonTitle_2",
						Layout = {
							margin_RB = { r = 0, b = 24, rr = "px", br = "px" }
						},
						autosize=1,
						Text = {
							text = "Option B",
							-- textStyle = "IGHeading1",
							font = "Heading3Font",
							color = "FEColorHeading3",
							hAlign = "Center",
							pixels = 48 * 1.5,
						},
						giveParentMouseInput = 1,
						--backgroundColor = {0,255,0,255},
					},
					{
						type = "TextLabel",
						name = "lbl_option_b",
						Layout = {
							margin_RB = { r = 0, b = 24, rr = "px", br = "px" }
						},
						autosize = 1,
						Text = {
							text = "+6000RU\n+20% Station Health\t+10% Sensors Range",
							textStyle = "FEHelpTipTextStyle",
							vAlign = "Top",
						},
						giveParentMouseInput = 1,
						--backgroundColor = {0,255,255,255},
					},
				},
				{ -- right margin (Layout margins are really weird)
					type = "Frame",
					Layout = {
						size_WH = {w = 0.025, h = 1, wr = "par", hr = "par",},
					},
				},
			},
		},
		{
			type = "Frame",

			Layout = {
				-- margin_LT = { l = 0, t = PANEL_SPACING_VERT, lr = "scr", tr = "scr" },
				-- pad_LT = { l = PANEL_PAD_HORIZ, t = PANEL_PAD_VERT, lr = "scr", tr = "scr" },
				-- pad_RB = { r = PANEL_PAD_HORIZ, b = PANEL_PAD_VERT, rr = "scr", br = "scr" },
				-- pos_XY = {	x=0.5, y=0.5, xr="px", yr="px",},
				size_WH = {w = 0.6, h = 0.08, wr = "scr", hr = "scr",},
			},

			-- autosize=1,

			BackgroundGraphic = BORDER_GRAPHIC_FRAME,
			backgroundColor = COLOR_BACKGROUND_PANEL,

			arrangetype = "horiz",

			;
			{ -- left margin (Layout margins are really weird)
				type = "Frame",
				Layout = {
					size_WH = {w = 0.025, h = 1, wr = "par", hr = "par",},
				},
			},
			-- NewMenuButton("m_btnAccept_A", "Accept Option A", "Option A", 0, BTN_LAYOUT, "FEButtonStyle1_Outlined"),
			makeButton({ name = "m_btnAccept_A", text = "Accept Option A", onClick = makeButtonCallbackStr("option_a") }),
			{ -- seperator
				type = "Frame",
				Layout = {
					size_WH = {w = 0.05, h = 1, wr = "par", hr = "par",},
				},
			},
			-- NewMenuButton("m_btnAccept_B", "Accept Option B", "Option B", 0, BTN_FOOTER_STD_LAYOUT, "FEButtonStyle1_Alert_Outlined_Chipped"),
			makeButton({ name = "m_btnAccept_B", text = "Accept Option B", onClick = makeButtonCallbackStr("option_b") }),
			{ -- right margin (Layout margins are really weird)
				type = "Frame",
				Layout = {
					size_WH = {w = 0.025, h = 1, wr = "par", hr = "par",},
				},
			},
		},
	},
}

