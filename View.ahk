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

View_init(m, v) {
	Global
	
	View[%m%][%v%]_aWndId        := 0
	View[%m%][%v%]_layout[1]     := 1
	View[%m%][%v%]_layout[2]     := 1
	View[%m%][%v%]_layoutAxis[1] := Config_layoutAxis[1]
	View[%m%][%v%]_layoutAxis[2] := Config_layoutAxis[2]
	View[%m%][%v%]_layoutAxis[3] := Config_layoutAxis[3]
	View[%m%][%v%]_layoutMFact   := Config_layoutMFactor
	View[%m%][%v%]_layoutMSplit  := 1
	View[%m%][%v%]_layoutSymbol  := Config_layoutSymbol[1]
	View[%m%][%v%]_wndIds        := ""
}

View_activateWindow(d) {
	Local aWndId, i, j, v, wndId, wndId0, wndIds
	
	WinGet, aWndId, ID, A
	v := Monitor[%Manager_aMonitor%]_aView[1]
	StringTrimRight, wndIds, View[%Manager_aMonitor%][%v%]_wndIds, 1
	StringSplit, wndId, wndIds, `;
	If (wndId0 > 1) {
		Loop, % wndId0
			If (wndId%A_Index% = aWndId) {
				i := A_Index
				Break
			}
		j := Manager_loop(i, d, 1, wndId0)
		wndId := wndId%j%
		WinSet, AlwaysOnTop, On, ahk_id %wndId%
		WinSet, AlwaysOnTop, Off, ahk_id %wndId%
		If Manager[%aWndId%]_isFloating
			WinSet, Bottom, , ahk_id %aWndId%
		Manager_winActivate(wndId)
	}
}

View_arrange(m, v) {
	Local fn, l, wndIds
	
	l := View[%m%][%v%]_layout[1]
	fn := Config_layoutFunction[%l%]
	If fn And (View_getTiledWndIds(m, v, wndIds) Or fn = "tile")
		View_%fn%(m, v, wndIds)
	Else
		View[%m%][%v%]_layoutSymbol := Config_layoutSymbol[%l%]
	Bar_updateLayout(m)
}

View_getTiledWndIds(m, v, ByRef tiledWndIds) {
	Local n, wndIds
	
	StringTrimRight, wndIds, View[%m%][%v%]_wndIds, 1
	Loop, PARSE, wndIds, `;
	{
		If Not Manager[%A_LoopField%]_isFloating {
			n += 1
			tiledWndIds .= A_LoopField ";"
		}
	}
	
	Return, n
}

View_monocle(m, v, wndIds) {
	Local wndId0
	
	StringTrimRight, wndIds, wndIds, 1
	StringSplit, wndId, wndIds, `;
	Loop, % wndId0
	   Manager_winMove(wndId%A_Index%, Monitor[%m%]_x, Monitor[%m%]_y, Monitor[%m%]_width, Monitor[%m%]_height)
	View[%m%][%v%]_layoutSymbol := "[" wndId0 "]"
}

View_rotateLayoutAxis(i, d) {
	Local f, l, v
	
	v := Monitor[%Manager_aMonitor%]_aView[1]
	l := View[%Manager_aMonitor%][%v%]_layout[1]
	If (Config_layoutFunction[%l%] = "tile") And (i = 1 Or i = 2 Or i = 3) {
		If (i = 1) {
			If (d = +2)
				View[%Manager_aMonitor%][%v%]_layoutAxis[%i%] *= -1
			Else {
				f := View[%Manager_aMonitor%][%v%]_layoutAxis[%i%] / Abs(View[%Manager_aMonitor%][%v%]_layoutAxis[%i%])
				View[%Manager_aMonitor%][%v%]_layoutAxis[%i%] := f * Manager_loop(Abs(View[%Manager_aMonitor%][%v%]_layoutAxis[%i%]), d, 1, 2)
			}
		} Else
			View[%Manager_aMonitor%][%v%]_layoutAxis[%i%] := Manager_loop(View[%Manager_aMonitor%][%v%]_layoutAxis[%i%], d, 1, 3)
		View_arrange(Manager_aMonitor, v)
	}
}

View_setLayout(l) {
	Local v
	
	v := Monitor[%Manager_aMonitor%]_aView[1]
	If (l = -1)
		l := View[%Manager_aMonitor%][%v%]_layout[2]
	If (l = ">")
		l := Manager_loop(View[%Manager_aMonitor%][%v%]_layout[1], +1, 1, Config_layoutCount)
	If (l > 0) And (l <= Config_layoutCount) {
		If Not (l = View[%Manager_aMonitor%][%v%]_layout[1]) {
			View[%Manager_aMonitor%][%v%]_layout[2] := View[%Manager_aMonitor%][%v%]_layout[1]
			View[%Manager_aMonitor%][%v%]_layout[1] := l
		}
		View_arrange(Manager_aMonitor, v)
	}
}

View_setMFactor(d) {
	Local l, mfact, v
	
	v := Monitor[%Manager_aMonitor%]_aView[1]
	l := View[%Manager_aMonitor%][%v%]_layout[1]
	If (Config_layoutFunction[%l%] = "tile") {
		mfact := 0
		If (d >= 1.05)
			mfact := d
		Else
			mfact := View[%Manager_aMonitor%][%v%]_layoutMFact + d
		If (mfact >= 0.05 And mfact <= 0.95) {
			View[%Manager_aMonitor%][%v%]_layoutMFact := mfact
			View_arrange(Manager_aMonitor, v)
		}
	}
}

View_setMSplit(d) {
	Local l, n, v, wndIds
	
	v := Monitor[%Manager_aMonitor%]_aView[1]
	l := View[%Manager_aMonitor%][%v%]_layout[1]
	If (Config_layoutFunction[%l%] = "tile") {
		n := View_getTiledWndIds(Manager_aMonitor, v, wndIds)
		View[%Manager_aMonitor%][%v%]_layoutMSplit := Manager_loop(View[%Manager_aMonitor%][%v%]_layoutMSplit, d, 1, n)
		View_arrange(Manager_aMonitor, v)
	}
}

View_shuffleWindow(d) {
	Local aWndId, i, j, l, search, v, wndId0, wndIds
	
	WinGet, aWndId, ID, A
	v := Monitor[%Manager_aMonitor%]_aView[1]
	l := View[%Manager_aMonitor%][%v%]_layout[1]
	If (Config_layoutFunction[%l%] = "tile" And InStr(Manager_managedWndIds, aWndId ";")) {
		View_getTiledWndIds(Manager_aMonitor, v, wndIds)
		StringTrimRight, wndIds, wndIds, 1
		StringSplit, wndId, wndIds, `;
		If (wndId0 > 1) {
			Loop, % wndId0
				If (wndId%A_Index% = aWndId) {
					i := A_Index
					Break
				}
			If (d = 0 And i = 1)
				j := 2
			Else
				j := i + d
			If (j > 0 And j <= wndId0) {
				If (j = i) {
					StringReplace, View[%Manager_aMonitor%][%v%]_wndIds, View[%Manager_aMonitor%][%v%]_wndIds, %aWndId%`;, 
					View[%Manager_aMonitor%][%v%]_wndIds := aWndId ";" View[%Manager_aMonitor%][%v%]_wndIds
				} Else {
					search := wndId%j%
					StringReplace, View[%Manager_aMonitor%][%v%]_wndIds, View[%Manager_aMonitor%][%v%]_wndIds, %aWndId%, SEARCH
					StringReplace, View[%Manager_aMonitor%][%v%]_wndIds, View[%Manager_aMonitor%][%v%]_wndIds, %search%, %aWndId%
					StringReplace, View[%Manager_aMonitor%][%v%]_wndIds, View[%Manager_aMonitor%][%v%]_wndIds, SEARCH, %search%
				}
				View_arrange(Manager_aMonitor, v)
			}
		}
	}
}

View_tile(m, v, wndIds) {
	Local axis1, axis2, axis3, h1, h2, i, mfact, msplit, n1, n2, sym1, sym3, w1, w2, wndId0, x1, x2, y1, y2
	
	axis1  := View[%m%][%v%]_layoutAxis[1]
	axis2  := View[%m%][%v%]_layoutAxis[2]
	axis3  := View[%m%][%v%]_layoutAxis[3]
	mfact  := View[%m%][%v%]_layoutMFact
	msplit := View[%m%][%v%]_layoutMSplit
	
	StringTrimRight, wndIds, wndIds, 1
	StringSplit, wndId, wndIds, `;
	If (msplit > wndId0)
		If (wndId0 < 1)
			View[%m%][%v%]_layoutMSplit := 1
		Else
			View[%m%][%v%]_layoutMSplit := wndId0
	
	; layout symbol
	sym1 := "="
	If (axis2 = Abs(axis1))
		sym1 := "|"
	If (axis2 = 3)
		If (wndId0 = 0)
			sym1 := 0
		Else
			sym1 := msplit
	sym3 := "="
	If (axis3 = Abs(axis1))
		sym3 := "|"
	If (axis3 = 3)
		If (wndId0 = 0)
			sym3 := 0
		Else
			sym3 := wndId0 - msplit
	If (axis1 < 0)
		If (msplit = 1)
			View[%m%][%v%]_layoutSymbol := sym3 "[]"
		Else
			View[%m%][%v%]_layoutSymbol := sym3 "[" sym1
	Else
		If (msplit = 1)
			View[%m%][%v%]_layoutSymbol := "[]" sym3
		Else
			View[%m%][%v%]_layoutSymbol := sym1 "]" sym3
	
	If (wndId0 > 0) {
		; master and stack area
		h1 := Monitor[%m%]_height
		h2 := Monitor[%m%]_height
		w1 := Monitor[%m%]_width
		w2 := Monitor[%m%]_width
		x1 := Monitor[%m%]_x
		x2 := Monitor[%m%]_x
		y1 := Monitor[%m%]_y
		y2 := Monitor[%m%]_y
		If (Abs(axis1) = 1 And wndId0 > msplit) {
			w1 *= mfact
			w2 -= w1
			If (axis1 < 0)
				x1 += w2
			Else
				x2 += w1
		} Else If (Abs(axis1) = 2 And wndId0 > msplit) {
			h1 *= mfact
			h2 -= h1
			If (axis1 < 0)
				y1 += h2
			Else
				y2 += h1
		}
		
		; master
		If (axis2 != 1 Or w1 / msplit < 161)
			n1 := 1
		Else
			n1 := msplit
		If (axis2 != 2 Or h1 / msplit < Bar_height)
			n2 := 1
		Else
			n2 := msplit
		Loop, % msplit {
			Manager_winMove(wndId%A_Index%, x1, y1, w1 / n1, h1 / n2)
			If (n1 > 1)
				x1 += w1 / n1
			If (n2 > 1)
				y1 += h1 / n2
		}
		
		; stack
		If (wndId0 > msplit) {
			If (axis3 != 1 Or w2 / (wndId0 - msplit) < 161)
				n1 := 1
			Else
				n1 := wndId0 - msplit
			If (axis3 != 2 Or h2 / (wndId0 - msplit) < Bar_height)
				n2 := 1
			Else
				n2 := wndId0 - msplit
			Loop, % wndId0 - msplit {
				i := msplit + A_Index
				Manager_winMove(wndId%i%, x2, y2, w2 / n1, h2 / n2)
				If (n1 > 1)
					x2 += w2 / n1
				If (n2 > 1)
					y2 += h2 / n2
			}
		}
	}
}

View_toggleFloating() {
	Local aWndId, l, v
	
	WinGet, aWndId, ID, A
	v := Monitor[%Manager_aMonitor%]_aView[1]
	l := View[%Manager_aMonitor%][%v%]_layout[1]
	If (Config_layoutFunction[%l%] And InStr(Manager_managedWndIds, aWndId ";")) {
		Manager[%aWndId%]_isFloating := Not Manager[%aWndId%]_isFloating
		View_arrange(Manager_aMonitor, v)
	}
}
