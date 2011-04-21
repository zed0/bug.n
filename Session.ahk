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
 *	@version 8.1.0.01 (11.08.2010)
 */

Session_restore(section, m=0) {
	Local var, var0, var1, var2
	
	If FileExist(Config_sessionFilePath) {
		If (section = "Config") {
			Loop, READ, %Config_sessionFilePath%
				If (SubStr(A_LoopReadLine, 1, 7) = "Config_") {
					StringSplit, var, A_LoopReadLine, =
					%var1% := var2
				}
		} Else If (section = "Monitor") {
			Loop, READ, %Config_sessionFilePath%
				If (SubStr(A_LoopReadLine, 1, 10+StrLen(m)) = "Monitor[" m "]_" Or SubStr(A_LoopReadLine, 1, 7+StrLen(m)) = "View[" m "][") {
					StringSplit, var, A_LoopReadLine, =
					%var1% := var2
				}
		}
	}
}

Session_save() {
	Local m, text
	
	text := "; bug.n - tiling window management`n; @version " VERSION " (" A_DD "." A_MM "." A_YYYY ")`n`n"
	If FileExist(Config_sessionFilePath) {
		Loop, READ, %Config_sessionFilePath%
			If (SubStr(A_LoopReadLine, 1, 7) = "Config_")
				text .= A_LoopReadLine "`n"
		text .= "`n"
	}
	FileDelete, %Config_sessionFilePath%
	
	If Not (Monitor[1]_showTaskBar = Config_showTaskBar)
		text .= "Monitor[1]_showTaskBar=" Monitor[1]_showTaskBar "`n`n"
	Loop, % Manager_monitorCount {
		m := A_Index
		If Not (Monitor[%m%]_aView[1] = 1)
			text .= "Monitor[" m "]_aView[1]=" Monitor[%m%]_aView[1] "`n"
		If Not (Monitor[%m%]_aView[2] = 1)
			text .= "Monitor[" m "]_aView[2]=" Monitor[%m%]_aView[2] "`n"
		If Not (Monitor[%m%]_showBar = Config_showBar)
			text .= "Monitor[" m "]_showBar=" Monitor[%m%]_showBar "`n"
		Loop, % Config_viewCount {
			If Not (View[%m%][%A_Index%]_layout[1] = 1)
				text .= "View[" m "][" A_Index "]_layout[1]=" View[%m%][%A_Index%]_layout[1] "`n"
			If Not (View[%m%][%A_Index%]_layout[2] = 1)
				text .= "View[" m "][" A_Index "]_layout[2]=" View[%m%][%A_Index%]_layout[2] "`n"
			If Not (View[%m%][%A_Index%]_layoutAxis[1] = Config_layoutAxis[1])
				text .= "View[" m "][" A_Index "]_layoutAxis[1]=" View[%m%][%A_Index%]_layoutAxis[1] "`n"
			If Not (View[%m%][%A_Index%]_layoutAxis[2] = Config_layoutAxis[2])
				text .= "View[" m "][" A_Index "]_layoutAxis[2]=" View[%m%][%A_Index%]_layoutAxis[2] "`n"
			If Not (View[%m%][%A_Index%]_layoutAxis[3] = Config_layoutAxis[3])
				text .= "View[" m "][" A_Index "]_layoutAxis[3]=" View[%m%][%A_Index%]_layoutAxis[3] "`n"
			If Not (View[%m%][%A_Index%]_layoutMFact = Config_layoutMFactor)
				text .= "View[" m "][" A_Index "]_layoutMFact=" View[%m%][%A_Index%]_layoutMFact "`n"
			If Not (View[%m%][%A_Index%]_layoutMSplit = 1)
				text .= "View[" m "][" A_Index "]_layoutMSplit=" View[%m%][%A_Index%]_layoutMSplit "`n"
		}
	}
	
	FileAppend, %text%, %Config_sessionFilePath%
}
