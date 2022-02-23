dofilepath("data:ui/newui/Styles/HWRM_Style/HWRMDefines.lua")
dofilepath("data:ui/newui/Styles/HWRM_Style/ControlConstructors.lua")

UI_LoadUILibrary("data:ui/newui/horde/hordemodescreencode.lua");

if (modkit == nil) then dofilepath("data:scripts/modkit/table_util.lua"); end

if (PHASE_REWARDS == nil) then dofilepath("data:scripts/custom_code/horde/lib/reward_configs.lua"); end

---@class ButtonConfig
---@field name string
---@field text string
---@field label string
---@field onClick function
---@field style string
---@field layout table
---@field hotkey_id integer
---@field custom_num number

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
	custom_data = btn_config.custom_num;

	local btn = NewMenuButton(name, text, label, hotkey_id, layout, style, onClick);
	btn.Layout.size_WH = { w = 0.45, h = STD_BUTTON_HEIGHT, wr = "par", hr = "scr" };
	btn.customData = custom_data;
	return btn;
end;

local makeLabelsFromRewards = function()
	local labels = {};
	for _, R in _p do
		modkit.table.push(labels, {
			type = "Frame",
			Layout = {
				size_WH = { w = 0, h = 0, wr = "px", hr = "px" }
			},
			enabled = 0, -- if enabled, is either a or b
			hidden = 1 -- if not hidden, must be b
			;
			{
				type = "TextLabel",
				name = R.name,
				autosize=1,
				Text = {
					text = "",
					pixels = 0,
				},
				giveParentMouseInput = 1,
				--backgroundColor = {0,255,0,255},
			}
		});
	end
	return labels;
end

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

	onShow = "HordeModeScreenOnShow()",
	onHide = "HordeModeScreenOnHide()"
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
			name = "hordescreen_root",
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
						name = "reward_a_desc",
						wrapping = 1,
						Layout = {
							margin_RB = { r = 0, b = 24, rr = "px", br = "px" },
							size_WH = { w = 1, h = 1, wr = "par", hr = "par" }
						},
						Text = {
							text = "A",
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
						pad_LT = { l = 0.05, t = 32, lr = "par", tr = "px" },
						pad_RB = { r = 0.05, b = 0, rr = "par", br = "px" },
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
						name = "reward_b_desc",
						wrapping = 1,
						Layout = {
							margin_RB = { r = 0, b = 24, rr = "px", br = "px" },
							size_WH = { w = 1, h = 1, wr = "par", hr = "par" }
						},
						Text = {
							text = "B",
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
			makeButton({ name = "btn_a", text = "Accept Option A", onClick = "HordeRewardBtnClick('a')", custom_num = 0 }),
			{ -- seperator
				type = "Frame",
				Layout = {
					size_WH = {w = 0.05, h = 1, wr = "par", hr = "par",},
				},
			},
			-- NewMenuButton("m_btnAccept_B", "Accept Option B", "Option B", 0, BTN_FOOTER_STD_LAYOUT, "FEButtonStyle1_Alert_Outlined_Chipped"),
			makeButton({ name = "btn_b", text = "Accept Option B", onClick = "HordeRewardBtnClick('b')", custom_num = 0 }),
			{ -- right margin (Layout margins are really weird)
				type = "Frame",
				Layout = {
					size_WH = {w = 0.025, h = 1, wr = "par", hr = "par",},
				},
			},
		},
		{ -- hidden frame we use to store state with
			type = "Frame",
			Layout = {
				size_WH = { w = 0, h = 0, wr = "px", hr = "px" }
			}
			;
			makeLabelsFromRewards(),
			{
				type = "DropDownListBox",
				name  = "selectme",
				backgroundColor = COLOR_LISTITEM,
				BackgroundGraphic = BORDER_GRAPHIC_BUILDFRAME_HORIZ,
				dropDownListBoxStyle = "IGDropDownListBoxStyle",
				autosize = 1,
				
				Layout = {		
					--pos_XY = { y = 0.0, yr = "par" },							
					size_WH = {	w = 200, h = DROPDOWN_HEIGHT, wr = "px", hr = "scr" },
				},

				visible = 1,
				
	
				ListBox = {
					type = "ListBox",
					name = "selectme_lb",
					Layout = {							
						size_WH = {	w = 1, h = 1.0, wr = "par", hr = "px" },										
					},
					backgroundColor = "IGColorBackground1",
					BackgroundGraphic = BORDER_GRAPHIC_BUILDFRAME_HORIZ,
					onItemSelect  = "AIMenu_SelectPlayer(%c1)",

					ItemToClone = {
						type = "TextListBoxItem",
						buttonStyle = "FEListBoxItemButtonStyle",
						resizeToListBox = 1,
						Text = {
							textStyle = "FEListBoxItemTextStyle",
							text = "",
						},
					},

				},
	
				helpTip = "Select CPU to Debug", -- SELECT BUILD SHIP
			}
		},
	},
}

