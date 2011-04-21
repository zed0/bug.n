/**
 *	bug.n - tiling window management
 *	Copyright � 2010-2011 joten
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

Manager_init() {
	Local NONCLIENTMETRICS, sizeOfNONCLIENTMETRICS
	
	; Windows ui
	If Config_selBorderColor {
		SetFormat, integer, hex
		Manager_normBorderColor := DllCall("GetSysColor", "Int", 10)
		SetFormat, integer, d
		DllCall("SetSysColors", "Int", 1, "Int*", 10, "UInt*", Config_selBorderColor)
	}
	If (Config_borderWidth > 0) Or (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA) {
		sizeOfNONCLIENTMETRICS := VarSetCapacity(NONCLIENTMETRICS, 344, 0)
		NumPut(sizeOfNONCLIENTMETRICS, NONCLIENTMETRICS, 0, "UInt")
		dllcall("SystemParametersInfo", UInt, 0x0029, UInt, sizeOfNONCLIENTMETRICS, UInt, &NONCLIENTMETRICS, UInt, 0)
		Manager_borderWidth := NumGet(NONCLIENTMETRICS, 4, "Int")
		Manager_borderPadding := NumGet(NONCLIENTMETRICS, 340, "Int")
		If (Config_borderWidth > 0)
			NumPut(Config_borderWidth, NONCLIENTMETRICS, 4, "Int")
		If (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA)
			NumPut(Config_borderPadding, NONCLIENTMETRICS, 340, "Int")
		dllcall("SystemParametersInfo", UInt, 0x002a, UInt, sizeOfNONCLIENTMETRICS, UInt, &NONCLIENTMETRICS, UInt, 0)
	}
	
	Bar_getHeight()
	Manager_aMonitor := 1
	SysGet, Manager_monitorCount, MonitorCount
	Loop, % Manager_monitorCount
		Monitor_init(A_Index)
	Bar_initCmdGui()
	
	Manager_focus			:= False
	Manager_hideShow		:= False
	Bar_hideTitleWndIds		:= ""
	Manager_allWndIds		:= ""
	Manager_managedWndIds	:= ""
	Manager_sync()
	
	Loop, % Manager_monitorCount {
		View_arrange(A_Index, Monitor[%A_Index%]_aView[1])
		Bar_updateView(A_Index, Monitor[%A_Index%]_aView[1])
	}
	Bar_updateStatus()
	Bar_updateTitle()
	
	Manager_registerShellHook()
	SetTimer, Bar_loop, %Config_readinInterval%
}

Manager_activateMonitor(d) {
	Local aView, aWndClass, aWndId, v, wndId
	
	If (Manager_monitorCount > 1) {
		aView := Monitor[%Manager_aMonitor%]_aView[1]
		WinGet, aWndId, ID, A
		If WinExist("ahk_id" aWndId) {
			WinGetClass, aWndClass, ahk_id %aWndId%
			If Not (aWndClass = "Progman") And Not (aWndClass = "AutoHotkeyGui") And Not (aWndClass = "DesktopBackgroundClass")
				View[%Manager_aMonitor%][%aView%]_aWndId := aWndId
		}
		
		Manager_aMonitor := Manager_loop(Manager_aMonitor, d, 1, Manager_monitorCount)
		v := Monitor[%Manager_aMonitor%]_aView[1]
		wndId := View[%Manager_aMonitor%][%v%]_aWndId
		If Not (wndId And WinExist("ahk_id" wndId)) {
			If View[%Manager_aMonitor%][%v%]_wndIds
				wndId := SubStr(View[%Manager_aMonitor%][%v%]_wndIds, 1, InStr(View[%Manager_aMonitor%][%v%]_wndIds, ";")-1)
			Else
				wndId := 0
		}
		Manager_winActivate(wndId)
	}
}

Manager_applyRules(wndId, ByRef isManaged, ByRef m, ByRef tags, ByRef isFloating, ByRef isDecorated, ByRef hideTitle) {
	Local wndClass, wndHeight, wndStyle, wndTitle, wndWidth, wndX, wndY
	Local rule0, rule1, rule2, rule3, rule4, rule5, rule6, rule7, rule8, rule9
	
	isManaged   := True
	m           := 0
	tags        := 0
	isFloating  := False
	isDecorated := False
	hideTitle   := False
	
	WinGetClass, wndClass, ahk_id %wndId%
	WinGetTitle, wndTitle, ahk_id %wndId%
	WinGetPos, wndX, wndY, wndWidth, wndHeight, ahk_id %wndId%
	WinGet, wndStyle, Style, ahk_id %wndId%
	If wndClass And wndTitle And Not (wndX < -4999) And Not (wndY < -4999) {
		Loop, % Config_rulesCount {
			StringSplit, rule, Config_rules[%A_index%], `;
			If RegExMatch(wndClass . ";" . wndTitle, rule1 . ";" . rule2) And (rule3 = "" Or wndStyle & rule3) {	; The last matching rule is returned.
				isManaged   := rule4
				m           := rule5
				tags        := rule6
				isFloating  := rule7
				isDecorated := rule8
				hideTitle   := rule9
			}
		}
		If (m = 0)
			m := Manager_aMonitor
		If (m > Manager_monitorCount)	; If the specified monitor is out of scope, set it to the max. monitor.
			m := Manager_monitorCount
		If (tags = 0)
			tags := 1 << Monitor[%m%]_aView[1] - 1
	} Else {
		isManaged := False
		If wndTitle
			hideTitle := True
	}
}

Manager_cleanup() {
	Local aWndId, m, sizeOfNONCLIENTMETRICS, NONCLIENTMETRICS, wndIds
	
	WinGet, aWndId, ID, A
	
	; Reset border color, padding and witdh.
	If Config_selBorderColor
		DllCall("SetSysColors", "Int", 1, "Int*", 10, "UInt*", Manager_normBorderColor)
	If (Config_borderWidth > 0) Or (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA) {
		sizeOfNONCLIENTMETRICS := VarSetCapacity(NONCLIENTMETRICS, 344, 0)
		NumPut(sizeOfNONCLIENTMETRICS, NONCLIENTMETRICS, 0, "UInt")
		dllcall("SystemParametersInfo", UInt, 0x0029, UInt, sizeOfNONCLIENTMETRICS, UInt, &NONCLIENTMETRICS, UInt, 0)
		If (Config_borderWidth > 0)
			NumPut(Manager_borderWidth, NONCLIENTMETRICS, 4, "Int")
		If (Config_borderPadding >= 0 And A_OSVersion = WIN_VISTA)
			NumPut(Manager_borderPadding, NONCLIENTMETRICS, 340, "Int")
		dllcall("SystemParametersInfo", UInt, 0x002a, UInt, sizeOfNONCLIENTMETRICS, UInt, &NONCLIENTMETRICS, UInt, 0)
	}
	
	; Show borders and title bars.
	StringTrimRight, wndIds, Manager_managedWndIds, 1
	Manager_hideShow := True
	Loop, PARSE, wndIds, `;
	{
		WinShow, ahk_id %A_LoopField%
		If Not Config_showBorder
			WinSet, Style, +0x40000, ahk_id %A_LoopField%
		WinSet, Style, +0xC00000, ahk_id %A_LoopField%
	}
	
	; Show the task bar.
	WinShow, Start ahk_class Button
	WinShow, ahk_class Shell_TrayWnd
	Manager_hideShow := False
	
	; Reset windows position and size.
	Monitor[1]_showTaskBar := True
	Loop, % Manager_monitorCount {
		m := A_Index
		Monitor[%m%]_showBar := False
		Monitor_getWorkArea(m)
		Loop, % Config_viewCount
			View_arrange(m, A_Index)
	}
	WinSet, AlwaysOnTop, On, ahk_id %aWndId%
	WinSet, AlwaysOnTop, Off, ahk_id %aWndId%
}

Manager_closeWindow() {
	WinGet, aWndId, ID, A
	WinClose, ahk_id %aWndId%
	WinWaitClose, ahk_id %aWndId%, 1
}

Manager_getWindowInfo() {
	Local text, v, aWndClass, aWndHeight, aWndId, aWndProcessName, aWndStyle, aWndTitle, aWndWidth, aWndX, aWndY
	
	WinGet, aWndId, ID, A
	WinGetClass, aWndClass, ahk_id %aWndId%
	WinGetTitle, aWndTitle, ahk_id %aWndId%
	WinGet, aWndProcessName, ProcessName, ahk_id %aWndId%
	WinGet, aWndStyle, Style, ahk_id %aWndId%
	WinGetPos, aWndX, aWndY, aWndWidth, aWndHeight, ahk_id %aWndId%
	text := "ID: " aWndId "`nclass:`t" aWndClass "`ntitle:`t" aWndTitle
	If InStr(Bar_hiddenWndIds, aWndId)
		text .= " (hidden)"
	text .= "`nprocess:`t" aWndProcessName "`nstyle:`t" aWndStyle "`nmetrics:`tx: " aWndX ", y: " aWndY ", width: " aWndWidth ", height: " aWndHeight "`ntags:`t" Manager[%aWndId%]_tags
	If Manager[%aWndId%]_isFloating
		text .= " (floating)"
	MsgBox, , bug.n: Window Information, % text
}

Manager_getWindowList() {
	Local text, v, aWndId, wndIds, aWndTitle
	
	v := Monitor[%Manager_aMonitor%]_aView[1]
	aWndId := View[%Manager_aMonitor%][%v%]_aWndId
	WinGetTitle, aWndTitle, ahk_id %aWndId%
	text := "Active Window`n" aWndId ":`t" aWndTitle
	
	StringTrimRight, wndIds, View[%Manager_aMonitor%][%v%]_wndIds, 1
	text .= "`n`nWindow List"
	Loop, PARSE, wndIds, `;
	{
		WinGetTitle, wndTitle, ahk_id %A_LoopField%
		text .= "`n" A_LoopField ":`t" wndTitle
	}
	
	MsgBox, , bug.n: Window List, % text
}

Manager_loop(index, increment, lowerBound, upperBound) {
	index += increment
	If (index > upperBound)
		index := lowerBound
	If (index < lowerBound)
		index := upperBound
	If (upperBound = 0)
		index := 0
	
	Return, index
}

Manager_manage(wndId) {
	Local a, c0, hideTitle, isDecorated, isFloating, isManaged, m, tags, wndControlList0, wndX, wndY, wndWidth, wndHeight, wndProcessName
	
	If Not InStr(Manager_allWndIds, wndId ";")
		Manager_allWndIds .= wndId ";"
	Manager_applyRules(wndId, isManaged, m, tags, isFloating, isDecorated, hideTitle)
	
	WinGet, wndProcessName, ProcessName, ahk_id %wndId%
	If (wndProcessName = "chrome.exe") {
		WinGet, wndControlList, ControlList, ahk_id %wndId%
		StringSplit, c, wndControlList, `n
		If (c0 <= 1)
			isManaged := False
	}

	
	If isManaged {
		Monitor_moveWindow(m, wndId)

		Manager_managedWndIds .= wndId ";"
		Manager[%wndId%]_tags        := tags
		Manager[%wndId%]_isDecorated := isDecorated
		Manager[%wndId%]_isFloating  := isFloating
		
		Loop, % Config_viewCount
			If (Manager[%wndId%]_tags & 1 << A_Index - 1) {
				View[%m%][%A_Index%]_wndIds := wndId ";" View[%m%][%A_Index%]_wndIds
				Bar_updateView(m, A_Index)
			}
		
		If Not Config_showBorder
			WinSet, Style, -0x40000, ahk_id %wndId%
		If Not Manager[%wndId%]_isDecorated
			WinSet, Style, -0xC00000, ahk_id %wndId%
		
		a := Manager[%wndId%]_tags & 1 << Monitor[%m%]_aView[1] - 1
		If a {
			Manager_aMonitor := m
			Manager_winActivate(wndId)
		} Else {
			Manager_hideShow := True
			WinHide, ahk_id %wndId%
			Manager_hideShow := False
		}
	}
	
	If hideTitle And Not InStr(Bar_hideTitleWndIds, wndId)
		Bar_hideTitleWndIds .= wndId . ";"
	Else If Not hideTitle
		StringReplace, Bar_hideTitleWndIds, Bar_hideTitleWndIds, %wndId%`;, 
	
	Return, a
}

Manager_maximizeWindow() {
	Local aWndId, l, v
	
	WinGet, aWndId, ID, A
	v := Monitor[%Manager_aMonitor%]_aView[1]
	l := View[%Manager_aMonitor%][%v%]_layout[1]
	If Not Manager[%aWndId%]_isFloating And Not (Config_layoutFunction[%l%] = "")
		View_toggleFloating()
	WinSet, Top,, ahk_id %aWndId%
	
	Manager_winMove(aWndId, Monitor[%Manager_aMonitor%]_x, Monitor[%Manager_aMonitor%]_y, Monitor[%Manager_aMonitor%]_width, Monitor[%Manager_aMonitor%]_height)
}

Manager_moveWindow() {
	Local aWndId, l, SC_MOVE, v, WM_SYSCOMMAND
	
	WinGet, aWndId, ID, A
	v := Monitor[%Manager_aMonitor%]_aView[1]
	l := View[%Manager_aMonitor%][%v%]_layout[1]
	If Not Manager[%aWndId%]_isFloating And Not (Config_layoutFunction[%l%] = "")
		View_toggleFloating()
	WinSet, Top,, ahk_id %aWndId%
	
	WM_SYSCOMMAND = 0x112
	SC_MOVE	   = 0xF010
	SendMessage, WM_SYSCOMMAND, SC_MOVE, , , ahk_id %aWndId%
}

Manager_onShellMessage(wParam, lParam) {
	Local a, aWndHeight, aWndId, aWndWidth, aWndX, aWndY, flag, m, tags, wndClass, wndTitle
	
	SetFormat, integer, hex
	lParam := lParam+0
	SetFormat, integer, d
	
	WinGetClass, wndClass, ahk_id %lParam%
	WinGetTitle, wndTitle, ahk_id %lParam%
	
	If (wParam = 1 Or wParam = 2 Or wParam = 4 Or wParam = 6) And lParam And Not Manager_hideShow And Not Manager_focus {
		If Not (wParam = 4) {
			Sleep, %Config_shellMsgDelay%
			If (wndClass = "wndclass_desked_gsk")
				Sleep, %Config_shellMsgDelay%
		}
		
		If (wParam = 1 Or wParam = 6) And Not InStr(Manager_allWndIds, lParam . ";")
			a := Manager_manage(lParam)
		Else {
			flag := True
			a := Manager_sync(tags)
			If tags
				a := False
		}
		If a {
			View_arrange(Manager_aMonitor, Monitor[%Manager_aMonitor%]_aView[1])
			Bar_updateView(Manager_aMonitor, Monitor[%Manager_aMonitor%]_aView[1])
		}
		
		If flag {
			WinGet, aWndId, ID, A
			If (Manager_monitorCount > 1) {
				WinGetPos, aWndX, aWndY, aWndWidth, aWndHeight, ahk_id %aWndId%
				m := Monitor_get(aWndX+aWndWidth/2, aWndY+aWndHeight/2)
				If m
					Manager_aMonitor := m
			}
		}
		
		If tags
			Loop, % Config_viewCount
				If (tags & 1 << A_Index - 1) {
					Monitor_activateView(A_Index)
					Break
				}
		
		Bar_updateTitle()
	}
}

Manager_registerShellHook() {
	Gui, +LastFound
	hWnd := WinExist()
	DllCall("RegisterShellHookWindow", uInt, hWnd)	; Minimum operating systems: Windows 2000 (http://msdn.microsoft.com/en-us/library/ms644989(VS.85).aspx)
	msgNum := DllCall("RegisterWindowMessage", str, "SHELLHOOK")
	OnMessage(msgNum, "Manager_onShellMessage")
}
; SKAN: How to Hook on to Shell to receive its messages? (http://www.autohotkey.com/forum/viewtopic.php?p=123323#123323)

Manager_setViewMonitor(d) {
	Local aView, m, v, wndIds
	
	If (Manager_monitorCount > 1) {
		m := Manager_loop(Manager_aMonitor, d, 1, Manager_monitorCount)
		v := Monitor[%m%]_aView[1]
		aView := Monitor[%Manager_aMonitor%]_aView[1]
		If View[%Manager_aMonitor%][%aView%]_wndIds {
			View[%m%][%v%]_wndIds := View[%Manager_aMonitor%][%aView%]_wndIds View[%m%][%v%]_wndIds
			
			StringTrimRight, wndIds, View[%Manager_aMonitor%][%aView%]_wndIds, 1
			Loop, PARSE, wndIds, `;
			{
				Loop, % Config_viewCount {
					StringReplace, View[%Manager_aMonitor%][%A_Index%]_wndIds, View[%Manager_aMonitor%][%A_Index%]_wndIds, %A_LoopField%`;, 
					View[%Manager_aMonitor%][%A_Index%]_aWndId := 0
				}
				
				Monitor_moveWindow(m, A_LoopField)
				Manager[%A_LoopField%]_tags := 1 << v - 1
			}
			View_arrange(Manager_aMonitor, aView)
			Loop, % Config_viewCount
				Bar_updateView(Manager_aMonitor, A_Index)
			
			Manager_aMonitor := m
			View_arrange(m, v)
			Bar_updateTitle()
			Bar_updateView(m, v)
		}
	}
}

Manager_setWindowMonitor(d) {
	Local aWndId, v
	
	WinGet, aWndId, ID, A
	If (Manager_monitorCount > 1 And InStr(Manager_managedWndIds, aWndId ";")) {
		Loop, % Config_viewCount {
			StringReplace, View[%Manager_aMonitor%][%A_Index%]_wndIds, View[%Manager_aMonitor%][%A_Index%]_wndIds, %aWndId%`;, 
			If (aWndId = View[%Manager_aMonitor%][%A_Index%]_aWndId)
				View[%Manager_aMonitor%][%A_Index%]_aWndId := 0
			Bar_updateView(Manager_aMonitor, A_Index)
		}
		View_arrange(Manager_aMonitor, Monitor[%Manager_aMonitor%]_aView[1])
		
		Manager_aMonitor := Manager_loop(Manager_aMonitor, d, 1, Manager_monitorCount)
		Monitor_moveWindow(Manager_aMonitor, aWndId)
		v := Monitor[%Manager_aMonitor%]_aView[1]
		Manager[%aWndId%]_tags := 1 << v - 1
		View[%Manager_aMonitor%][%v%]_wndIds := aWndId ";" View[%Manager_aMonitor%][%v%]_wndIds
		View[%Manager_aMonitor%][%v%]_aWndId := aWndId
		View_arrange(Manager_aMonitor, v)
		Bar_updateTitle()
		Bar_updateView(Manager_aMonitor, v)
	}
}

Manager_sizeWindow() {
	Local aWndId, l, SC_SIZE, v, WM_SYSCOMMAND
	
	WinGet, aWndId, ID, A
	v := Monitor[%Manager_aMonitor%]_aView[1]
	l := View[%Manager_aMonitor%][%v%]_layout[1]
	If Not Manager[%aWndId%]_isFloating And Not (Config_layoutFunction[%l%] = "")
		View_toggleFloating()
	WinSet, Top,, ahk_id %aWndId%
	
	WM_SYSCOMMAND = 0x112
	SC_SIZE	   = 0xF000
	SendMessage, WM_SYSCOMMAND, SC_SIZE, , , ahk_id %aWndId%
}

Manager_sync(ByRef tags = 0) {
	Local a, aWndId, flag, shownWndIds, v, visibleWndIds, wndId
	
	Loop, % Manager_monitorCount {
		v := Monitor[%A_Index%]_aView[1]
		shownWndIds .= View[%A_Index%][%v%]_wndIds
	}
	; check all visible windows against the known windows
	WinGet, wndId, List, , , 
	Loop, % wndId {
		If Not InStr(shownWndIds, wndId%A_Index% ";") {
			If Not InStr(Manager_managedWndIds, wndId%A_Index% ";") {
				flag := Manager_manage(wndId%A_Index%)
				If flag
					a := flag
			} Else {
				aWndId := wndId%A_Index%
				tags := Manager[%aWndId%]_tags
			}
		}
		visibleWndIds := visibleWndIds wndId%A_Index% ";"
	}
	
	; check, if a window, that is known to be visible, is actually not visible
	StringTrimRight, shownWndIds, shownWndIds, 1
	Loop, PARSE, shownWndIds, `;
	{
		If Not InStr(visibleWndIds, A_LoopField) {
			flag := Manager_unmanage(A_LoopField)
			If flag
				a := flag
		}
	}
	
	Return, a
}

Manager_toggleDecor() {
	Local aWndId
	
	WinGet, aWndId, ID, A
	Manager[%aWndId%]_isDecorated := Not Manager[%aWndId%]_isDecorated
	If Manager[%aWndId%]_isDecorated
		WinSet, Style, +0xC00000, ahk_id %aWndId%
	Else
		WinSet, Style, -0xC00000, ahk_id %aWndId%
}

Manager_unmanage(wndId) {
	Local a
	
	a := Manager[%wndId%]_tags & 1 << Monitor[%Manager_aMonitor%]_aView[1] - 1
	Loop, % Config_viewCount
		If (Manager[%wndId%]_tags & 1 << A_Index - 1) {
			StringReplace, View[%Manager_aMonitor%][%A_Index%]_wndIds, View[%Manager_aMonitor%][%A_Index%]_wndIds, %wndId%`;, 
			Bar_updateView(Manager_aMonitor, A_Index)
		}
	Manager[%wndId%]_tags        :=
	Manager[%wndId%]_isDecorated :=
	Manager[%wndId%]_isFloating  :=
	StringReplace, Bar_hideTitleWndIds, Bar_hideTitleWndIds, %wndId%`;, 
	StringReplace, Manager_allWndIds, Manager_allWndIds, %wndId%`;, 
	StringReplace, Manager_managedWndIds, Manager_managedWndIds, %wndId%`;, 
	
	Return, a
}

Manager_winActivate(wndId) {
	Global Config_bbCompatibility, Config_mouseFollowsFocus
	
	If Not wndId {
		flag := True
		If Config_bbCompatibility
			WinGet, wndId, ID, ahk_class DesktopBackgroundClass
		Else
			WinGet, wndId, ID, Program Manager
	}
	If Config_mouseFollowsFocus {
		WinGetPos, wndX, wndY, wndWidth, wndHeight, ahk_id %wndId%
		DllCall("SetCursorPos", int, Round(wndX+wndWidth/2), int, Round(wndY+wndHeight/2))
	}
	WinActivate, ahk_id %wndId%
	If flag
		Bar_updateTitle()
}

Manager_winMove(wndId, x, y, width, height) {
	WinRestore, ahk_id %wndId%
	WM_ENTERSIZEMOVE = 0x0231
	WM_EXITSIZEMOVE  = 0x0232
	SendMessage, WM_ENTERSIZEMOVE, , , , ahk_id %wndId%
	WinMove, ahk_id %wndId%, , %x%, %y%, %width%, %height%
	SendMessage, WM_EXITSIZEMOVE, , , , ahk_id %wndId%

	WinGet, wndProcessName, ProcessName, ahk_id %wndId%
	If (wndProcessName= "putty.exe") {
		WinSet, Style, 0x150B0000, ahk_id %wndId%
	}
}
