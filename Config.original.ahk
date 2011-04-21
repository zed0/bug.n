/**
 *	bug.n - tiling window management
 *	Copyright © 2010-2011 joten
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public License
 *	along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *	@version 8.1.0.01 (20.01.2011)
 */

Config_init() {
	Local layout0, layout1, layout2, layout[1], layout[2], layout[3]
	
	; status bar
	Config_showBar			:= True							; If false, the bar is hidden. It can be made visible or hidden by hotkey (see below).
	Config_topBar			:= True							; If false, the bar is at the bottom.
	
	Config_fontName			:= "Lucida Console"				; A monospace font is preferable for bug.n to calculate the correct width of the bar and its elements (sub-windows).
	Config_fontSize			:= 8							; Font size in pixel.
	
	Config_normBgColor		:= "f0f0f0;d8d8d8;c0c0c0;a8a8a8;909090;787878;606060;484848;303030;181818"	; Normal background colour of bar elements; format: RRGGBB. The ten values are needed for indicating the number of windows per view (by default: darker colour means more windows) and distinct status information.
	Config_normFgColor		:= "000000;000000;000000;000000;000000;ffffff;ffffff;ffffff;ffffff;ffffff"	; Normal foreground colour of bar elements.
	Config_selBgColor		:= "99b4d1;3399ff;ff9933"		; Background colour of 'selected' or highlighted bar elements (format: RRGGBB). The first colour is used for the layout and command symbol, the second for selected tags and dereasing battery level and the third color is only used for alarming battery level.
	Config_selFgColor		:= "000000;ffffff;000000"		; Foreground colour of 'selected' or highlighted bar elements.
	
	Config_readinBat		:= False						; If true, the system battery status is read in and displayed in the status bar. This only makes sense, if you have a system battery (notebook).
	Config_readinCpu		:= False						; If true, the current CPU load is read in and displayed in the status bar.
	Config_readinDate		:= True							; If true, the current date is read in (format: "WW, DD. MMM. YYYY") and displayed in the status bar.
	Config_readinTime		:= True							; If true, the current time is read in (format: "HH:MM") and displayed in the status bar.
	Config_readinInterval	:= 30000						; Time in milliseconds after which the above status values are refreshed.
	
	; command gui
	Config_addRunCommands	:= ""							; A semicolon separated list of commands, which can be run by AutoHotkey (i. e, "Run, <command>"), e. g. "cmd;explorer D:\;http://www.autohotkey.com"). Each command will be shown in the command GUI under the "Run" item.
	
	; Windows ui elements
	Config_bbCompatibility	:= False						; If true, bug.n looks for BlackBox components (bbLeanBar, bbSlit and SystemBarEx) when calculating the work area. It is assumed that the virtual desktop functionality of BlackBox and NOT bug.n is used (=> Hiding and showing windows is detected and acted upon).
	Config_borderWidth		:= 0							; If > 0, the window border width is set to the integer value Config_borderWidth.
	Config_borderPadding	:= -1							; If >= 0, the window border padding is set to the integer value Config_borderPadding (only for Windows >= Vista).
	Config_showTaskBar		:= False						; If false, the task bar is hidden. It can be made visible or hidden by hotkey (see below).
	Config_showBorder		:= True							; If false, the window borders are hidden; therefor windows cannot be resized manually by dragging the border, even if using the according hotkey.
	Config_selBorderColor	:= ""							; Border colour of the active window; format: 0x00BBGGRR (e. g. "0x006A240A", if = "", the system's window border colour is not changed).
															; Config_borderWidth, Config_borderPadding and Config_selBorderColor are especially usefull, if you are not allowed to set the design in the system settings.	
	; window arrangement
	Config_viewCount			:= 9						; The total number of views. This has effects on the displayed groups in the bar, and should not be exceeded in the hotkeys below.
	layout[1]					:= "[]=;tile"				; The layout symbol and arrange function (the first entry is set as the default layout, no layout function means floating behavior)
	layout[2]					:= "[M];monocle"
	layout[3]					:= "><>;"
	Config_layoutCount			:= 3						; Total number of layouts defined above.
	Config_layoutAxis[1]		:= 1						; The layout axis: 1 = x, 2 = y; negative values mirror the layout, setting the master area to the right / bottom instead of left / top.
	Config_layoutAxis[2]		:= 2						; The master axis: 1 = x (from left to right), 2 = y (from top to bottom), 3 = z (monocle).
	Config_layoutAxis[3]		:= 2						; The stack axis:  1 = x (from left to right), 2 = y (from top to bottom), 3 = z (monocle).
	Config_layoutMFactor		:= 0.6						; The factor for the size of the master area, which is multiplied by the monitor size.
	Config_mouseFollowsFocus	:= True						; If true, the mouse pointer is set over the focused window, if a window is activated by bug.n.
	Config_shellMsgDelay		:= 350						; The time bug.n waits after a shell message (a window is opened, closed or the focus has been changed); if there are any problems recognizing, when windows are opened or closed, try to increase this number.
	Config_viewFollowsTagged	:= False					; If true, the view is set to, if a window is tagged with a single tag.
	
	; Config_rules[i]	:= "<class (regular expression string)>;<title (regular expression string)>;<window style (hexadecimal number or blank)>;<is managed (1 = True or 0 = False)>;<monitor (0 <= integer <= total number of monitors, 0 means the currently active monitor)>;<tags (binary mask as integer >= 0, e. g. 17 for 1 and 5, 0 means the currently active tag)>;<is floating (1 = True or 0 = False)>;<is decorated (1 = True or 0 = False)>;<hide title (1 = True or 0 = False)>" (";" is not allowed as a character)
	Config_rules[1]		:= ".*;.*;;1;0;0;0;0;0"				; At first you may set a default rule (.*;.*;) for a default monitor, view and / or showing window title bars.
	Config_rules[2]		:= ".*;.*;0x80000000;0;0;0;1;1;1"	; Pop-up windows (style WS_POPUP=0x80000000) will not be managed, are floating and the titles are hidden.
	Config_rules[3]		:= "SWT_Window0;.*;;1;0;0;0;0;0"	; Windows created by Java (SWT) e. g. Eclipse have the style WS_POPUP, but should excluded from the above rule.
	Config_rules[4]		:= "Xming;.*;;1;0;0;0;0;0"			; Xming windows have the style WS_POPUP, but should be excluded from the above rule.
	Config_rules[5]		:= "_sp;_sp;;1;0;0;1;0;1"
	Config_rules[6]		:= "MozillaDialogClass;.*;;1;0;0;1;1;0"
	Config_rules[7]		:= "MsiDialog(No)?CloseClass;.*;;1;0;0;1;1;0"
	Config_rules[8]		:= "gdkWindowToplevel;GIMP-Start;;1;0;0;1;1;0"
	Config_rules[9]		:= "gdkWindowToplevel;GNU Image Manipulation Program;;1;0;0;1;1;0"
	Config_rules[10]	:= "gdkWindowToplevel;Werkzeugkasten;;1;0;0;1;1;0"
	Config_rules[11]	:= "gdkWindowToplevel;Ebenen, .* - Pinsel, Muster, .*;;1;0;0;1;1;0"
	Config_rules[12]	:= "gdkWindowToplevel;Toolbox;;1;0;0;1;1;0"
	Config_rules[13]	:= "gdkWindowToplevel;Layers, Channels, Paths, .*;;1;0;0;1;1;0"
	Config_rulesCount	:= 13								; This variable has to be set to the total number of active rules above.
	
	; session management
	Config_autoSaveSession := False							; Automatically save the current state of monitors, views, layouts (active view, layout, axes, mfact and msplit) to te session file (set below) when quitting bug.n.
	If Not Config_sessionFilePath							; The file path, to which the session is saved. This target directory must be writable by the user (%A_ScriptDir% is the diretory, in which "Main.ahk" or the executable of bug.n is saved).
		Config_sessionFilePath := A_ScriptDir "\Session.ini"
	
	Session_restore("Config")
	StringSplit, Config_normBgColor, Config_normBgColor, `;
	StringSplit, Config_normFgColor, Config_normFgColor, `;
	StringSplit, Config_selBgColor, Config_selBgColor, `;
	StringSplit, Config_selFgColor, Config_selFgColor, `;
	Loop, % Config_layoutCount {
		StringSplit, layout, layout[%A_Index%], `;
		Config_layoutFunction[%A_Index%] := layout2
		Config_layoutSymbol[%A_Index%]   := layout1
	}
	If (Config_viewCount > 9)
		Config_viewCount := 9
}

Config_readinAny() {										; Add information to the variable "text" in this function to display it in the status bar.
	Global Config_readinCpu, Config_readinDate
	
	text := ""
	If Config_readinCpu
		text .= " CPU: " Bar_getSystemTimes() "% "
	If Config_readinDate And Config_readinCpu
		text .= "|"
	If Config_readinDate
		text .= " " A_DDD ", " A_DD ". " A_MMM ". " A_YYYY " "
	
	Return, text
}

/**
 *	key definitions
 *
 *	format: <modifier><key>::<function>(<argument>)
 *	modifier: ! = Alt (Mod1Mask), ^ = Ctrl (ControlMask), + = Shift (ShiftMask), # = LWin (Mod4Mask)
 */

#Down::View_activateWindow(+1)			; Activate the next window in the active view.
#Up::View_activateWindow(-1)			; Activate the previous window in the active view.
#+Down::View_shuffleWindow(+1)			; Move the active window to the next position in the window list of the view.
#+Up::View_shuffleWindow(-1)			; Move the active window to the previous position in the window list of the view.
#+Enter::View_shuffleWindow(0)			; Move the active window to the first position in the window list of the view.
#c::Manager_closeWindow()				; Close the active window.
#+d::Manager_toggleDecor()				; Show / Hide the title bar of the active window.
#+f::View_toggleFloating()				; Toggle the floating status of the active window (i. e. dis- / regard it when tiling).
#+m::Manager_moveWindow()				; Move the active window by key (only floating windows).
#+s::Manager_sizeWindow()				; Resize the active window by key (only floating windows).
#+x::Manager_maximizeWindow()			; Move and resize the active window to the size of the work area (only floating windows).
#i::Manager_getWindowInfo()				; Get information for the active window (id, title, class, process name, style, geometry, tags and floating state).
#+i::Manager_getWindowList()			; Get a window list for the active view (id, title and class).

#Tab::View_setLayout(-1)				; Set the previously set layout. You may also use View_setLayout(">") for setting the next layout in the layout array.
#f::View_setLayout(3)					; Set the 3rd defined layout (i. e. floating layout in the default configuration).
#m::View_setLayout(2)					; Set the 2nd defined layout (i. e. monocle layout in the default configuration).
#t::View_setLayout(1)					; Set the 1st defined layout (i. e. tile layout in the default configuration).
#Left::View_setMFactor(-0.05)			; Reduce the size of the master area in the active view (only for the "tile" layout).
#Right::View_setMFactor(+0.05)			; Enlarge the size of the master area in the active view (only for the "tile" layout).
#^t::View_rotateLayoutAxis(1, +1)		; Rotate the layout axis (i. e. 2 -> 1 = vertical layout, 1 -> 2 = horizontal layout, only for the "tile" layout).
#^Enter::View_rotateLayoutAxis(1, +2)	; Mirror the layout axis (i. e. -1 -> 1 / 1 -> -1 = master on the left / right side, -2 -> 2 / 2 -> -2 = master at top / bottom, only for the "tile" layout).
#^Tab::View_rotateLayoutAxis(2, +1)		; Rotate the master axis (i. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 = y-axis = vertical stack, 2 -> 3 = z-axis = monocle, only for the "tile" layout).
#^+Tab::View_rotateLayoutAxis(3, +1)	; Rotate the stack axis (i. e. 3 -> 1 = x-axis = horizontal stack, 1 -> 2 = y-axis = vertical stack, 2 -> 3 = z-axis = monocle, only for the "tile" layout).
#^Left::View_setMSplit(+1)				; Move the master splitter, i. e. decrease the number of windows in the master area (only for the "tile" layout).
#^Right::View_setMSplit(-1)				; Move the master splitter, i. e. increase the number of windows in the master area (only for the "tile" layout).

#BackSpace::Monitor_activateView(-1)	; Activate the previously activated view. You may also use Monitor_activateView(">") for activating the next / adjacent view.
#+0::Monitor_setWindowTag(0)			; Tag the active window with all tags (1 ... Config_viewCount).
#1::Monitor_activateView(1)				; Activate the view (choose one out of 1 ... Config_viewCount).
#+1::Monitor_setWindowTag(1)			; Tag the active window (choose one tag out of 1 ... Config_viewCount).
#^1::Monitor_toggleWindowTag(1)			; Add / Remove the tag (1 ... Config_viewCount) for the active window, if it is not / is already set.
#2::Monitor_activateView(2)
#+2::Monitor_setWindowTag(2)
#^2::Monitor_toggleWindowTag(2)
#3::Monitor_activateView(3)
#+3::Monitor_setWindowTag(3)
#^3::Monitor_toggleWindowTag(3)
#4::Monitor_activateView(4)
#+4::Monitor_setWindowTag(4)
#^4::Monitor_toggleWindowTag(4)
#5::Monitor_activateView(5)
#+5::Monitor_setWindowTag(5)
#^5::Monitor_toggleWindowTag(5)
#6::Monitor_activateView(6)
#+6::Monitor_setWindowTag(6)
#^6::Monitor_toggleWindowTag(6)
#7::Monitor_activateView(7)
#+7::Monitor_setWindowTag(7)
#^7::Monitor_toggleWindowTag(7)
#8::Monitor_activateView(8)
#+8::Monitor_setWindowTag(8)
#^8::Monitor_toggleWindowTag(8)
#9::Monitor_activateView(9)
#+9::Monitor_setWindowTag(9)
#^9::Monitor_toggleWindowTag(9)

#.::Manager_activateMonitor(+1)			; Activate the next monitor in a multi-monitor environment.
#,::Manager_activateMonitor(-1)			; Activate the previous monitor in a multi-monitor environment.
#+.::Manager_setWindowMonitor(+1)		; Set the active window to the active view on the next monitor in a multi-monitor environment.
#+,::Manager_setWindowMonitor(-1)		; Set the active window to the active view on the previous monitor in a multi-monitor environment.
#^+.::Manager_setViewMonitor(+1)		; Set all windows of the active view on the active view of the next monitor in a multi-monitor environment.
#^+,::Manager_setViewMonitor(-1)		; Set all windows of the active view on the active view of the previous monitor in a multi-monitor environment.

#+Space::Monitor_toggleBar()			; Hide / Show the bar (bug.n status bar) on the active monitor.
#Space::Monitor_toggleTaskBar()			; Hide / Show the task bar.
#s::Session_save()						; Save the current state of monitors, views, layouts.
#y::Bar_toggleCommandGui()				; Open the command GUI for executing programmes or bug.n functions.
#+r::Reload								; For resetting the confguration or debugging.
#+q::ExitApp							; Quit bug.n, restore the default Windows UI and show all windows.
