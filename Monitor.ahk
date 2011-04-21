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
 *	@version 8.1.0.01 (09.01.2011)
 */

Monitor_init(m) {
	Global
	
	Monitor[%m%]_aView[1] := 1
	Monitor[%m%]_aView[2] := 1
	Monitor[%m%]_showBar  := Config_showBar
	If (m = 1)
		Monitor[1]_showTaskBar := Config_showTaskBar
	Loop, % Config_viewCount
		View_init(m, A_Index)
	Session_restore("Monitor", m)
	Monitor_getWorkArea(m)
	If (m = 1) And Not Monitor[1]_showTaskBar {
		Manager_hideShow := True
		WinHide, Start ahk_class Button
		WinHide, ahk_class Shell_TrayWnd
		Manager_hideShow := False
	}
	Bar_init(m)
}

Monitor_activateView(v) {
	Local aView, aWndClass, aWndId, wndId, wndIds
	
	If (v = -1)
		v := Monitor[%Manager_aMonitor%]_aView[2]
	Else If (v = ">")
		v := Manager_loop(Monitor[%Manager_aMonitor%]_aView[1], +1, 1, Config_viewCount)
	If (v > 0) And (v <= Config_viewCount) And Not Manager_hideShow And Not (v = Monitor[%Manager_aMonitor%]_aView[1]) {
		aView := Monitor[%Manager_aMonitor%]_aView[1]
		WinGet, aWndId, ID, A
		If WinExist("ahk_id" aWndId) {
			WinGetClass, aWndClass, ahk_id %aWndId%
			If Not (aWndClass = "Progman") And Not (aWndClass = "AutoHotkeyGui") And Not (aWndClass = "DesktopBackgroundClass")
				View[%Manager_aMonitor%][%aView%]_aWndId := aWndId
		}
		Monitor[%Manager_aMonitor%]_aView[2] := aView
		Monitor[%Manager_aMonitor%]_aView[1] := v
		
		Manager_hideShow := True
		StringTrimRight, wndIds, View[%Manager_aMonitor%][%aView%]_wndIds, 1
		Loop, PARSE, wndIds, `;
			If Not (Manager[%A_LoopField%]_tags & (1 << v - 1))
				WinHide, ahk_id %A_LoopField%
		StringTrimRight, wndIds, View[%Manager_aMonitor%][%v%]_wndIds, 1
		Loop, PARSE, wndIds, `;
			WinShow, ahk_id %A_LoopField%
		Manager_hideShow := False
		
		Bar_updateView(Manager_aMonitor, aView)
		Bar_updateView(Manager_aMonitor, v)
		
		View_arrange(Manager_aMonitor, v)
		
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

Monitor_get(x, y) {
	Local m
	
	m := 0
	Loop, % Manager_monitorCount	; Check if the window is on this monitor.
		If (x >= Monitor[%A_Index%]_x && x <= Monitor[%A_Index%]_x+Monitor[%A_Index%]_width && y >= Monitor[%A_Index%]_y && y <= Monitor[%A_Index%]_y+Monitor[%A_Index%]_height) {
			m := A_Index
			Break
		}
	
	Return, m
}

Monitor_getWorkArea(m) {
	Local bbWndClasses, bbWndHeight, bbWndWidth, bbWndX, bbWndY, bTop, monitor, monitorBottom, monitorLeft, monitorRight, monitorTop
	
	If (m = 1) And Monitor[1]_showTaskBar
		SysGet, monitor, MonitorWorkArea, %m%
	Else
		SysGet, monitor, Monitor, %m%
	
	If Config_bbCompatibility {
		If WinExist("ahk_class bbLeanBar")
			bbWndClasses .= "bbLeanBar;"
		If WinExist("ahk_class bbSlit")
			bbWndClasses .= "bbSlit;"
		If WinExist("ahk_class SystemBarEx")
			bbWndClasses .= "SystemBarEx;"
		StringTrimRight, bbWndClasses, bbWndClasses, 1
		Loop, PARSE, bbWndClasses, `;
		{
			WinGetPos, bbWndX, bbWndY, bbWndWidth, bbWndHeight, ahk_class %A_LoopField%
			If (bbWndWidth > bbWndHeight) {			; Horizontal
				If (bbWndY = monitorTop)			; Top
					monitorTop += bbWndHeight
				Else								; Bottom
					monitorBottom -= bbWndHeight
			} Else {								; Vertical
				If (bbWndX = monitorLeft)			; Left
					monitorLeft += bbWndWidth
				Else								; Right
					monitorRight -= bbWndWidth
			}
			; Any other possibilities are not economic (=> usefull).
		}
	}
	
	If Config_topBar {
		bTop := monitorTop
		If Monitor[%m%]_showBar
			monitorTop := monitorTop + Bar_height
	} Else {
		bTop := monitorBottom - Bar_height
		If Monitor[%m%]_showBar
			monitorBottom := monitorBottom - Bar_height
	}
	
	Monitor[%m%]_height := monitorBottom - monitorTop
	Monitor[%m%]_width  := monitorRight - monitorLeft
	Monitor[%m%]_x      := monitorLeft
	Monitor[%m%]_y      := monitorTop
	Monitor[%m%]_barY   := bTop
}

Monitor_moveWindow(m, wndId) {
	Local fX, fY, monitor, wndHeight, wndWidth, wndX, wndY
	
	WinGetPos, wndX, wndY, wndWidth, wndHeight, ahk_id %wndId%
	monitor := Monitor_get(wndX+wndWidth/2, wndY+wndHeight/2)
	If Not (m = monitor) {
		; move the window to the target monitor and scale it, if it does not fit on the monitor
		fX := Monitor[%m%]_width / Monitor[%monitor%]_width
		fY := Monitor[%m%]_height / Monitor[%monitor%]_height
		If (wndX-Monitor[%monitor%]_x+wndWidth > Monitor[%m%]_width) Or (wndY-Monitor[%monitor%]_y+wndHeight > Monitor[%m%]_height)
			Manager_winMove(wndId, Monitor[%m%]_x+fX*(wndX-Monitor[%monitor%]_x), Monitor[%m%]_y+fY*(wndY-Monitor[%monitor%]_y), fX*wndWidth, fY*wndHeight)
		Else
			Manager_winMove(wndId, Monitor[%m%]_x+(wndX-Monitor[%monitor%]_x), Monitor[%m%]_y+(wndY-Monitor[%monitor%]_y), wndWidth, wndHeight)
	}
}

Monitor_setWindowTag(t) {
	Local aView, aWndId, wndId
	
	WinGet, aWndId, ID, A
	If (InStr(Manager_managedWndIds, aWndId ";") And t >= 0 And t <= Config_viewCount) {
		If (t = 0) {
			Loop, % Config_viewCount
				If Not (Manager[%aWndId%]_tags & (1 << A_Index - 1)) {
					View[%Manager_aMonitor%][%A_Index%]_wndIds := aWndId ";" View[%Manager_aMonitor%][%A_Index%]_wndIds
					View[%Manager_aMonitor%][%A_Index%]_aWndId := aWndId
					Bar_updateView(Manager_aMonitor, A_Index)
					Manager[%aWndId%]_tags += 1 << A_Index - 1
				}
		} Else {
			Loop, % Config_viewCount
				If Not (A_index = t) {
					StringReplace, View[%Manager_aMonitor%][%A_Index%]_wndIds, View[%Manager_aMonitor%][%A_Index%]_wndIds, %aWndId%`;, 
					View[%Manager_aMonitor%][%A_Index%]_aWndId := 0
					Bar_updateView(Manager_aMonitor, A_Index)
				}
			
			If Not (Manager[%aWndId%]_tags & (1 << t - 1))
				View[%Manager_aMonitor%][%t%]_wndIds := aWndId ";" View[%Manager_aMonitor%][%t%]_wndIds
			View[%Manager_aMonitor%][%t%]_aWndId := aWndId
			Manager[%aWndId%]_tags := 1 << t - 1
			
			aView := Monitor[%Manager_aMonitor%]_aView[1]
			If Not (t = aView) {
				Manager_hideShow := True
				wndId := SubStr(View[%Manager_aMonitor%][%aView%]_wndIds, 1, InStr(View[%Manager_aMonitor%][%aView%]_wndIds, ";")-1)
				Manager_winActivate(wndId)
				Manager_hideShow := False
				If Config_viewFollowsTagged
					Monitor_activateView(t)
				Else {
					Manager_hideShow := True
					WinHide, ahk_id %aWndId%
					Manager_hideShow := False
					View_arrange(Manager_aMonitor, aView)
					Bar_updateView(Manager_aMonitor, t)
				}
			}
		}
	}
}

Monitor_toggleBar() {
	Global
	
	Monitor[%Manager_aMonitor%]_showBar := Not Monitor[%Manager_aMonitor%]_showBar
	Bar_toggleVisibility(Manager_aMonitor)
	Monitor_getWorkArea(Manager_aMonitor)
	View_arrange(Manager_aMonitor, Monitor[%Manager_aMonitor%]_aView[1])
	Manager_winActivate(Bar_aWndId)
}

Monitor_toggleTaskBar() {
	Global Manager_aMonitor, Manager_hideShow, Monitor[1]_aView[1], Monitor[1]_showBar, Monitor[1]_showTaskBar
	
	If (Manager_aMonitor = 1) {
		Monitor[1]_showTaskBar := Not Monitor[1]_showTaskBar
		Manager_hideShow := True
		If Not Monitor[1]_showTaskBar {
			WinHide, Start ahk_class Button
			WinHide, ahk_class Shell_TrayWnd
		} Else {
			WinShow, Start ahk_class Button
			WinShow, ahk_class Shell_TrayWnd
		}
		Manager_hideShow := False
		Monitor_getWorkArea(1)
		Bar_move(1)
		View_arrange(1, Monitor[1]_aView[1])
	}
}

Monitor_toggleWindowTag(t) {
	Local aWndId, wndId
	
	WinGet, aWndId, ID, A
	If (InStr(Manager_managedWndIds, aWndId ";") And t >= 0 And t <= Config_viewCount) {
		If (Manager[%aWndId%]_tags & (1 << t - 1)) {
			If Not ((Manager[%aWndId%]_tags - (1 << t - 1)) = 0) {
				Manager[%aWndId%]_tags -= 1 << t - 1
				StringReplace, View[%Manager_aMonitor%][%t%]_wndIds, View[%Manager_aMonitor%][%t%]_wndIds, %aWndId%`;, 
				Bar_updateView(Manager_aMonitor, t)
				If (t = Monitor[%Manager_aMonitor%]_aView[1]) {
					Manager_hideShow := True
					WinHide, ahk_id %aWndId%
					Manager_hideShow := False
					wndId := SubStr(View[%Manager_aMonitor%][%t%]_wndIds, 1, InStr(View[%Manager_aMonitor%][%t%]_wndIds, ";")-1)
					Manager_winActivate(wndId)
					View_arrange(Manager_aMonitor, t)
				}
			}
		} Else {
			View[%Manager_aMonitor%][%t%]_wndIds := aWndId ";" View[%Manager_aMonitor%][%t%]_wndIds
			View[%Manager_aMonitor%][%t%]_aWndId := aWndId
			Bar_updateView(Manager_aMonitor, t)
			Manager[%aWndId%]_tags += 1 << t - 1
		}
	}
}
