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
 *	@version 8.1.0.01 (25.08.2010)
 */

Bar_init(m) {
	Local GuiN, h, i, text, w, wndTitle, x1, x2, y, y1
	
	h  := Bar_height
	x1 := Monitor[%m%]_x
	x2 := Monitor[%m%]_x + Monitor[%m%]_width
	y  := Monitor[%m%]_barY
	y1 := (Bar_height - 1.5 * Config_fontSize) / 2
	
	; The x-position and width of the sub-windows left of the window title are set from the left.
	Loop, % Config_viewCount + 1 {																; tags
		i := A_Index
		text := ""
		wndTitle := "BUGN_BAR_" m "_" i
		GuiN := (m - 1) * (Config_viewCount + 6) + i
		Gui, %GuiN%: Default
		IfWinExist, %wndTitle%
			Gui, Destroy
		Gui, +LastFound -Caption +ToolWindow +AlwaysOnTop
		If (i = Config_viewCount + 1) {
			Gui, +LabelBar_layoutGui
			Gui, Color, %Config_selBgColor1%
			Gui, Font, c%Config_selFgColor1% s%Config_fontSize%, %Config_fontName%
			text := " ??? "
			w := Bar_getTextWidth(text)	 
			Gui, Add, Text, x0 y%y1% w%w% h%h% -Wrap Center vBar[%m%][%i%] gBar_layoutGuiClick, %text%
		} Else {
			Gui, +LabelBar_tagGui
			Gui, Color, %Config_normBgColor1%
			Gui, Font, c%Config_normFgColor1% s%Config_fontSize%, %Config_fontName%
			text := " " i " "
			w := Bar_getTextWidth(text)	 
			Gui, Add, Text, x0 y%y1% w%w% h%h% -Wrap Center vBar[%m%][%i%] gBar_tagGuiClick, %text%
		}
		If Monitor[%m%]_showBar
			Gui, Show, +NoActivate x%x1% y%y% w%w% h%h%, %wndTitle%
		Else
			Gui, Show, +NoActivate Hide x%x1% y%y% w%w% h%h%, %wndTitle%
		x1 += w
	}
	
	; The x-position and width of the sub-windows right of the window title are set from the right.
	Loop, 4 {
		i := Config_viewCount + 7 - A_Index
		wndTitle := "BUGN_BAR_" m "_" i
		GuiN := (m - 1) * (Config_viewCount + 6) + i
		Gui, %GuiN%: Default
		IfWinExist, %wndTitle%
			Gui, Destroy
		Gui, +LastFound -Caption +ToolWindow +Disabled +AlwaysOnTop
		Gui, Color, %Config_normBgColor2%
		Gui, Font, c%Config_normFgColor2% s%Config_fontSize%, %Config_fontName%
		w := 0
		If (i = Config_viewCount + 6) {															; command gui
			Gui, -Disabled
			Gui, Color, %Config_selBgColor1%
			Gui, Font, c%Config_selFgColor1% s%Config_fontSize%, %Config_fontName%
			w := Bar_getTextWidth(" ?? ")
			Gui, Add, Text, x0 y%y1% w%w% h%h% Center gBar_toggleCommandGui vBar[%m%][%i%], %A_SPACE%#!%A_SPACE%
		} Else If (i = Config_viewCount + 5) And Config_readinTime {							; time
			w  := Bar_getTextWidth(" ??:?? ")
			If Config_readinBat And Config_readinAny() {
				Gui, Color, %Config_normBgColor4%
				Gui, Font, c%Config_normFgColor4% s%Config_fontSize%, %Config_fontName%
			} Else If Config_readinBat Or Config_readinAny() {
				Gui, Color, %Config_normBgColor3%
				Gui, Font, c%Config_normFgColor3% s%Config_fontSize%, %Config_fontName%
			}
			Gui, Add, Text, x0 y%y1% w%w% h%h% Center vBar[%m%][%i%], %A_SPACE%??:??%A_SPACE%
		} Else If (i = Config_viewCount + 4) And Config_readinAny() {							; any
			text := Config_readinAny()
			w += Bar_getTextWidth(text)
			If Config_readinBat {
				Gui, Color, %Config_normBgColor3%
				Gui, Font, c%Config_normFgColor3% s%Config_fontSize%, %Config_fontName%
			}
			Gui, Add, Text, x0 y%y1% w%w% h%h% Center vBar[%m%][%i%], %text%
		} Else If (i = Config_viewCount + 3) And Config_readinBat {								; battery level
			w := Bar_getTextWidth(" BAT: ???% ")
			Gui, Add, Text, x0 y%y1% w%w% h%h% Center vBar[%m%][%i%], %A_SPACE%BAT: ???`%%A_SPACE%
		}
		x2 -= w
		If Monitor[%m%]_showBar
			Gui, Show, +NoActivate x%x2% y%y% w%w% h%h%, %wndTitle%
		Else
			Gui, Show, +NoActivate Hide x%x2% y%y% w%w% h%h%, %wndTitle%
	}
	
	; The window title bar is assigned the remaining space.
	i := Config_viewCount + 2
	wndTitle := "BUGN_BAR_" m "_" i
	GuiN := (m - 1) * (Config_viewCount + 6) + i
	Gui, %GuiN%: Default
	IfWinExist, %wndTitle%
		Gui, Destroy
	Gui, +LastFound -Caption +ToolWindow +Disabled +AlwaysOnTop
	Gui, Color, %Config_normBgColor1%
	Gui, Font, c%Config_normFgColor1% s%Config_fontSize%, %Config_fontName%
	w := x2 - x1
	Bar_titleWidth := w
	Gui, Add, Text, x0 y%y1% w%w% h%h% vBar[%m%][%i%], 
	If Monitor[%m%]_showBar
		Gui, Show, +NoActivate x%x1% y%y% w%w% h%h%, %wndTitle%
	Else
		Gui, Show, +NoActivate Hide x%x1% y%y% w%w% h%h%, %wndTitle%
}

Bar_initCmdGui() {	
	Global Bar[0][0], Bar[0][0]H, Bar[0][0]W, Bar_cmdGuiIsVisible, Config_addRunCommands, Config_fontName, Config_fontSize, Config_normBgColor1, Config_normFgColor1
	
	Bar_cmdGuiIsVisible := False
	wndTitle := "BUGN_BAR_0_0"
	Gui, 99: Default
	Gui, +LabelBar_cmdGui
	IfWinExist, %wndTitle%
		Gui, Destroy
	Gui, +LastFound -Caption +ToolWindow +AlwaysOnTop
	Gui, Color, %Config_normBgColor1%
	Gui, Font, c%Config_normFgColor1% s%Config_fontSize%, %Config_fontName%
	Gui, Add, TreeView, Background%Config_normBgColor1% c%Config_normFgColor1% x0 y0 r23 w300 -ReadOnly vBar[0][0] gBar_cmdGuiEnter
	GuiControl, -Redraw, Bar[0][0]
	itemId10 := TV_Add("Run")
	  TV_Add("Press <F2> to enter a command.", itemId10)
	If Config_addRunCommands {
		StringSplit, runCmd, Config_addRunCommands, `;
		Loop, % runCmd0
			TV_Add(runCmd%A_Index%, itemId10)
	}
	itemId20 := TV_Add("Window")
	  itemId21 := TV_Add("set tag", itemId20)
	    TV_Add("all", itemId21)
	    TV_Add("Press <F2> to enter a number.", itemId21)
	  itemId22 := TV_Add("toggle tag", itemId20)
	    TV_Add("Press <F2> to enter a number.", itemId22)
	  TV_Add("move to top", itemId20)
	  TV_Add("move up", itemId20)
	  TV_Add("move down", itemId20)
	  TV_Add("toggle floating", itemId20)
	  TV_Add("toggle decor", itemId20)
	  TV_Add("close", itemId20)
	  TV_Add("move by key", itemId20)
	  TV_Add("resize by key", itemId20)
	  TV_Add("activate next", itemId20)
	  TV_Add("activate prev", itemId20)
	  TV_Add("move to next monitor", itemId20)
	  TV_Add("move to prev monitor", itemId20)
	itemId30 := TV_Add("Layout")
	  TV_Add("set last", itemId30)
	  TV_Add("set 1st (tile)", itemId30)
	  TV_Add("set 2nd (monocle)", itemId30)
	  TV_Add("set 3rd (floating)", itemId30)
	  TV_Add("rotate layout axis", itemId30)
	  TV_Add("rotate master axis", itemId30)
	  TV_Add("rotate stack axis", itemId30)
	  TV_Add("mirror tile layout", itemId30)
	  TV_Add("increase master split", itemId30)
	  TV_Add("decrease master split", itemId30)
	  TV_Add("increase master factor", itemId30)
	  TV_Add("decrease master factor", itemId30)
	itemId40 := TV_Add("View")
	  itemId41 := TV_Add("activate", itemId40)
	    TV_Add("last", itemId41)
	    TV_Add("Press <F2> to enter a number.", itemId41)
	  TV_Add("move to next monitor", itemId40)
	  TV_Add("move to prev monitor", itemId40)
	itemId50 := TV_Add("Monitor")
	  TV_Add("toggle bar", itemId50)
	  TV_Add("toggle task bar", itemId50)
	  TV_Add("activate next", itemId50)
	  TV_Add("activate prev", itemId50)
	TV_Add("Reload")
	TV_Add("Quit")
	GuiControl, +Redraw, Bar[0][0]
	Gui, Add, Button, Y0 Hidden Default gBar_cmdGuiEnter, OK
	GuiControlGet, Bar[0][0], Pos
	Gui, Show, Hide w%Bar[0][0]W% h%Bar[0][0]H%, %wndTitle%
}

Bar_cmdGuiEscape:
	Bar_cmdGuiIsVisible := False
	Gui, Cancel
	WinActivate, ahk_id %Bar_aWndId%
Return

Bar_cmdGuiEnter:
	If (A_GuiControl = "OK") Or (A_GuiControl = "BAR[0][0]" And A_GuiControlEvent = "DoubleClick") {
		Bar_selItemId[1] := TV_GetSelection()
		If Not TV_GetChild(Bar_selItemId[1]) {
			Bar_selItemId[2] := TV_GetParent(Bar_selItemId[1])
			Bar_selItemId[3] := TV_GetParent(Bar_selItemId[2])
			TV_GetText(Bar_command[1], Bar_selItemId[1])
			TV_GetText(Bar_command[2], Bar_selItemId[2])
			TV_GetText(Bar_command[3], Bar_selItemId[3])
		} Else
			Bar_command[1] := ""
		Bar_cmdGuiIsVisible := False
		Gui, Cancel
		WinActivate, ahk_id %Bar_aWndId%
		Bar_evaluateCommand()
	}
Return

Bar_evaluateCommand() {
	Global Bar_command[1], Bar_command[2], Bar_command[3], Config_viewCount
	
	If (Bar_command[1]) {
		If (Bar_command[2] = "Run")
			Run, %Bar_command[1]%
		Else If (Bar_command[3] = "Window") {
			If (Bar_command[2] = "set tag") {
				If (Bar_command[1] = "all")
					Monitor_setWindowTag(0)
				Else If (RegExMatch(Bar_command[1], "[0-9]+") And Bar_command[1] <= Config_viewCount)
					Monitor_setWindowTag(Bar_command[1])
			} Else If (Bar_command[2] = "toggle tag")
				If (RegExMatch(Bar_command[1], "[0-9]+") And Bar_command[1] <= Config_viewCount)
					Monitor_toggleWindowTag(Bar_command[1])
		} Else If (Bar_command[2] = "Window") {
			If (Bar_command[1] = "move to top")
				View_shuffleWindow(0)
			Else If (Bar_command[1] = "move up")
				View_shuffleWindow(-1)
			Else If (Bar_command[1] = "move down")
				 View_shuffleWindow(+1)
			Else If (Bar_command[1] = "toggle floating")
				 View_toggleFloating()
			Else If (Bar_command[1] = "toggle decor")
				 Manager_toggleDecor()
			Else If (Bar_command[1] = "close")
				 Manager_closeWindow()
			Else If (Bar_command[1] = "move by key")
				 Manager_moveWindow()
			Else If (Bar_command[1] = "resize by key")
				 Manager_sizeWindow()
			Else If (Bar_command[1] = "activate next")
				 View_activateWindow(+1)
			Else If (Bar_command[1] = "activate prev")
				 View_activateWindow(-1)
			Else If (Bar_command[1] = "move to next monitor")
				 Manager_setWindowMonitor(+1)
			Else If (Bar_command[1] = "move to prev monitor")
				 Manager_setWindowMonitor(-1)
		} Else If (Bar_command[2] = "Layout") {
			If (Bar_command[1] = "set last")
				View_setLayout(-1)
			Else If (Bar_command[1] = "set 1st (tile)")
				View_setLayout(1)
			Else If (Bar_command[1] = "set 2nd (monocle)")
				View_setLayout(2)
			Else If (Bar_command[1] = "set 3rd (floating)")
				View_setLayout(3)
			Else If (Bar_command[1] = "rotate layout axis")
				View_rotateLayoutAxis(1, +1)
			Else If (Bar_command[1] = "rotate master axis")
				View_rotateLayoutAxis(2, +1)
			Else If (Bar_command[1] = "rotate stack axis")
				View_rotateLayoutAxis(3, +1)
			Else If (Bar_command[1] = "mirror tile layout")
				View_rotateLayoutAxis(1, +2)
			Else If (Bar_command[1] = "increase master split")
				View_setMSplit(+1)
			Else If (Bar_command[1] = "decrease master split")
				View_setMSplit(-1)
			Else If (Bar_command[1] = "increase master factor")
				View_setMFactor(+0.05)
			Else If (Bar_command[1] = "decrease master factor")
				View_setMFactor(-0.05)
		} Else If (Bar_command[3] = "View") {
			If (Bar_command[2] = "activate") {
				If (Bar_command[1] = "last")
					Monitor_activateView(-1)
				Else If (RegExMatch(Bar_command[1], "[0-9]+") And Bar_command[1] <= Config_viewCount)
					Monitor_activateView(Bar_command[1])
			}
		} Else If (Bar_command[2] = "View") {
			If (Bar_command[1] = "move to next monitor")
				Manager_setViewMonitor(+1)
			Else If (Bar_command[1] = "move to prev monitor")
				Manager_setViewMonitor(-1)
		} Else If (Bar_command[2] = "Monitor") {
			If (Bar_command[1] = "toggle bar")
				Monitor_toggleBar()
			Else If (Bar_command[1] = "toggle task bar")
				Monitor_toggleTaskBar()
			Else If (Bar_command[1] = "activate next")
				Manager_activateMonitor(+1)
			Else If (Bar_command[1] = "activate prev")
				Manager_activateMonitor(-1)
		} Else If (Bar_command[1] = "Reload")
			Reload
		Else If (Bar_command[1] = "Quit")
			ExitApp
		
		Bar_command[1] := ""
		Bar_command[2] := ""
		Bar_command[3] := ""
	}
}

Bar_getBatteryStatus(ByRef batteryLifePercent, ByRef acLineStatus) {
	VarSetCapacity(powerStatus, 1+1+1+1+4+4)
	success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
	If (ErrorLevel != 0 OR success = 0) {
		MsgBox 16, Power Status, Can't get the power status...
		Return
	}
	acLineStatus	   := Bar_getInteger(powerStatus, 0, false, 1)
	batteryLifePercent := Bar_getInteger(powerStatus, 2, false, 1)

	If acLineStatus = 0
		acLineStatus = off
	Else If acLineStatus = 1
		acLineStatus = on
	Else If acLineStatus = 255
		acLineStatus = ?

	If batteryLifePercent = 255
		batteryLifePercent = ???
}
; PhiLho: AC/Battery status (http://www.autohotkey.com/forum/topic7633.html)

Bar_getHeight() {
	Global Bar[0][0], Bar[0][0]H, Bar[0][0]W, Bar_height, Config_fontName, Config_fontSize, Config_normFgColor1
	
	wndTitle := "BUGN_BAR_0_0"
	Gui, 99: Default
	Gui, Font, c%Config_normFgColor1% s%Config_fontSize%, %Config_fontName%
	Gui, Add, ComboBox, r9 x0 y0 vBar[0][0], |
	GuiControlGet, Bar[0][0], Pos
	Bar_height := Bar[0][0]H
	Gui, Destroy
}

Bar_getInteger(ByRef @source, _offset = 0, _bIsSigned = false, _size = 4) {
	Loop %_size%		; Build the integer by adding up its bytes.
		result += *(&@source + _offset + A_Index-1) << 8*(A_Index-1)
	If (!_bIsSigned OR _size > 4 OR result < 0x80000000)
		Return result	; Signed vs. unsigned doesn't matter in these cases.
	; Otherwise, convert the value (now known to be 32-bit & negative) to its signed counterpart:
	return -(0xFFFFFFFF - result + 1)
}
; PhiLho: AC/Battery status (http://www.autohotkey.com/forum/topic7633.html)

Bar_getSystemTimes() {	; Total CPU Load
	Static oldIdleTime, oldKrnlTime, oldUserTime
	Static newIdleTime, newKrnlTime, newUserTime

	oldIdleTime := newIdleTime
	oldKrnlTime := newKrnlTime
	oldUserTime := newUserTime

	DllCall("GetSystemTimes", "int64P", newIdleTime, "int64P", newKrnlTime, "int64P", newUserTime)
	sysTime := SubStr("  " . Round((1-(newIdleTime-oldIdleTime)/(newKrnlTime-oldKrnlTime+newUserTime-oldUserTime))*100), -2)
	Return, sysTime		; system time in percent
}
; Sean: CPU LoadTimes (http://www.autohotkey.com/forum/topic18913.html)

Bar_getTextWidth(x, reverse=False) {
	Global Config_fontSize
	
	If reverse {		; "reverse" calculates the number of characters to a given width.
		w := x
		i := w / (Config_fontSize - 1)
		If (Config_fontSize = 7 Or (Config_fontSize > 8 And Config_fontSize < 13))
			i := w / (Config_fontSize - 2)
		Else If (Config_fontSize > 12 And Config_fontSize < 18)
			i := w / (Config_fontSize - 3)
		Else If (Config_fontSize > 17)
			i := w / (Config_fontSize - 4)
		textWidth := i
	} Else {			; "else" calculates the width to a given string.
		textWidth := StrLen(x) * (Config_fontSize - 1)
		If (Config_fontSize = 7 Or (Config_fontSize > 8 And Config_fontSize < 13))
			textWidth := StrLen(x) * (Config_fontSize - 2)
		Else If (Config_fontSize > 12 And Config_fontSize < 18)
			textWidth := StrLen(x) * (Config_fontSize - 3)
		Else If (Config_fontSize > 17)
			textWidth := StrLen(x) * (Config_fontSize - 4)
	}
	
	Return, textWidth
}

Bar_layoutGuiClick:
	Manager_winActivate(Bar_aWndId)
	If (A_GuiEvent = "Normal") {
		If Not (SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) = Manager_aMonitor)
			Manager_activateMonitor(SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) - Manager_aMonitor)
		View_setLayout(-1)
	}
Return

Bar_layoutGuiContextMenu:
	Manager_winActivate(Bar_aWndId)
	If (A_GuiEvent = "RightClick") {
		If Not (SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) = Manager_aMonitor)
			Manager_activateMonitor(SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) - Manager_aMonitor)
		View_setLayout(">")
	}
Return

Bar_loop:
	Bar_updateStatus()
Return

Bar_move(m) {
	Local i, text, w, wndTitle, x1, x2, y
	
	x1 := Monitor[%m%]_x
	x2 := Monitor[%m%]_x + Monitor[%m%]_width
	y  := Monitor[%m%]_barY
	
	; The x-position and width of the sub-windows left of the window title are set from the left.
	Loop, % Config_viewCount + 1 {																; tags
		i := A_Index
		text := ""
		wndTitle := "BUGN_BAR_" m "_" i
		If (i = Config_viewCount + 1) {
			text := " ??? "
		} Else {
			text := " " i " "
		}
		w := Bar_getTextWidth(text)	 
		WinMove, %wndTitle%, , %x1%, %y%
		x1 += w
	}
	
	; The x-position and width of the sub-windows right of the window title are set from the right.
	Loop, 4 {
		i := Config_viewCount + 7 - A_Index
		wndTitle := "BUGN_BAR_" m "_" i
		w := 0
		If (i = Config_viewCount + 6) {															; command gui
			w := Bar_getTextWidth(" ?? ")
		} Else If (i = Config_viewCount + 5) And Config_readinTime {							; time
			w  := Bar_getTextWidth(" ??:?? ")
		} Else If (i = Config_viewCount + 4) And Config_readinAny() {							; any
			text := Config_readinAny()
			w += Bar_getTextWidth(text)
		} Else If (i = Config_viewCount + 3) And Config_readinBat {								; battery level
			w := Bar_getTextWidth(" BAT: ???% ")
		}
		x2 -= w
		WinMove, %wndTitle%, , %x2%, %y%
	}
	
	; The window title bar is assigned the remaining space.
	wndTitle := "BUGN_BAR_" m "_" Config_viewCount + 2
	w := x2 - x1
	Bar_titleWidth := w
	WinMove, %wndTitle%, , %x1%, %y%
}

Bar_tagGuiClick:
	Manager_winActivate(Bar_aWndId)
	If (A_GuiEvent = "Normal") {
		If Not (SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) = Manager_aMonitor)
			Manager_activateMonitor(SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) - Manager_aMonitor)
		Monitor_activateView(SubStr(A_GuiControl, InStr(A_GuiControl, "][")+2, 1))
	}
Return

Bar_tagGuiContextMenu:
	Manager_winActivate(Bar_aWndId)
	If (A_GuiEvent = "RightClick") {
		If Not (SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) = Manager_aMonitor)
			Manager_setWindowMonitor(SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) - Manager_aMonitor)
		Monitor_setWindowTag(SubStr(A_GuiControl, InStr(A_GuiControl, "][")+2, 1))
	}
Return

Bar_toggleCommandGui:
	If Not Bar_cmdGuiIsVisible
		If Not (SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) = Manager_aMonitor)
			Manager_activateMonitor(SubStr(A_GuiControl, 5, InStr(A_GuiControl, "][")-5) - Manager_aMonitor)
	Bar_toggleCommandGui()
Return

Bar_toggleCommandGui() {
	Local wndId, x, y
	
	Gui, 99: Default
	If Bar_cmdGuiIsVisible {
		Bar_cmdGuiIsVisible := False
		Gui, Cancel
		Manager_winActivate(Bar_aWndId)
	} Else {
		Bar_cmdGuiIsVisible := True
		x := Monitor[%Manager_aMonitor%]_x + Monitor[%Manager_aMonitor%]_width - Bar[0][0]W
		y := Monitor[%Manager_aMonitor%]_y
		Gui, Show
		WinMove, BUGN_BAR_0_0, , %x%, %y%
		WinGet, wndId, ID, BUGN_BAR_0_0
		Manager_winActivate(wndId)
		GuiControl, Focus, % Bar[0][0]
	}
}

Bar_toggleVisibility(m) {
	Local GuiN
	
	Loop, % Config_viewCount + 6 {
		GuiN := (m - 1) * (Config_viewCount + 6) + A_Index
		If Monitor[%m%]_showBar {
			If Not (GuiN = 99) Or Bar_cmdGuiIsVisible
				Gui, %GuiN%: Show
		} Else
			Gui, %GuiN%: Cancel
	}
}

Bar_updateLayout(m) {
	Local aView, GuiN, i
	
	aView := Monitor[%m%]_aView[1]
	i := Config_viewCount + 1
	GuiN := (m - 1) * (Config_viewCount + 6) + i
	GuiControl, %GuiN%: , Bar[%m%][%i%], % View[%m%][%aView%]_layoutSymbol
}

Bar_updateStatus() {
	Local anyContent, anyText, b1, b2, b3, GuiN, i, m
	
	Loop, % Manager_monitorCount {
		m := A_Index
		If Config_readinBat {
			Bar_getBatteryStatus(b1, b2)
			b3 := SubStr("  " b1, -2)
			i := Config_viewCount + 3
			GuiN := (m - 1) * (Config_viewCount + 6) + i
			Gui, %GuiN%: Default
			If (b1 < 10) And (b2 = "off") {				; change the color, if the battery level is below 10%
				Gui, Color, %Config_selBgColor3%
				Gui, Font, c%Config_selFgColor3%
			} Else If (b2 = "off") {					; change the color, if the pc is not plugged in
				Gui, Color, %Config_selBgColor2%
				Gui, Font, c%Config_selFgColor2%
			} Else {
				Gui, Color, %Config_normBgColor2%
				Gui, Font, c%Config_normFgColor2%
			}
			GuiControl, Font, Bar[%m%][%i%]
			GuiControl, , Bar[%m%][%i%], % " BAT: " b3 "% "
		}
		anyText := Config_readinAny()
		If anyText {
			i := Config_viewCount + 4
			GuiN := (m - 1) * (Config_viewCount + 6) + i
			GuiControlGet, anyContent, , Bar[%m%][%i%]
			If Not (anyText = anyContent)
				GuiControl, %GuiN%: , Bar[%m%][%i%], % anyText
		}
		If Config_readinTime {
			i := Config_viewCount + 5
			GuiN := (m - 1) * (Config_viewCount + 6) + i
			GuiControl, %GuiN%: , Bar[%m%][%i%], % " " A_Hour ":" A_Min " "
		}
	}
}

Bar_updateTitle() {
	Local aWndId, aWndTitle, content, GuiN, i, m, title
	
	WinGet, aWndId, ID, A
	WinGetTitle, aWndTitle, ahk_id %aWndId%
	If InStr(Bar_hideTitleWndIds, aWndId . ";")
		aWndTitle := ""
	If Manager[aWndId]_isFloating
		aWndTitle := "~ " aWndTitle
	If (Manager_monitorCount > 1)
		aWndTitle := "[" Manager_aMonitor "] " aWndTitle
	title := " " . aWndTitle . " "
	
	If (Bar_getTextWidth(title) > Bar_titleWidth) {		; shorten the window title if its length exceeds the width of the bar
		i := Bar_getTextWidth(Bar_titleWidth, True) - 6
		StringLeft, title, aWndTitle, i
		title := " " . title . " ... "
	}
	
	i := Config_viewCount + 2
	Loop, % Manager_monitorCount {
		m := A_Index
		GuiN := (m - 1) * (Config_viewCount + 6) + i
		If (m = Manager_aMonitor) {
			GuiControlGet, content, , Bar[%m%][%i%]
			If Not (title = content)
				GuiControl, %GuiN%: , Bar[%m%][%i%], % title
		} Else
			GuiControl, %GuiN%: , Bar[%m%][%i%],  
	}
	Bar_aWndId := aWndId
}

Bar_updateView(m, v) {
	Local bgColor, fgColor, GuiN, i, wndId0, wndIds
	
	If (v = Monitor[%m%]_aView[1]) {
		bgColor := Config_selBgColor2
		fgColor := Config_selFgColor2
	} Else {
		StringTrimRight, wndIds, View[%m%][%v%]_wndIds, 1
		StringSplit, wndId, wndIds, `;
		If (wndId0 > 9)
			i := 10
		Else If (wndId0 > 0)
			i := wndId0 + 1
		Else
			i := 1
		bgColor := Config_normBgColor%i%
		fgColor := Config_normFgColor%i%
	}
	GuiN := (m - 1) * (Config_viewCount + 6) + v
	Gui, %GuiN%: Default
	Gui, Color, %bgColor%
	Gui, Font, c%fgColor%
	GuiControl, Font, Bar[%m%][%v%]
	GuiControl, , Bar[%m%][%v%], %v%
}
