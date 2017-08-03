Global $sVersion = "1.1"
Global $sKeyToSpam = 1 ;//Self-explanatory, default key
Global $nInterval = 50 ;//Default interval between mouseclicks
Global $bPaused = 0

HotKeySet("^+{z}", "PauseHK")
HotKeySet("+{esc}", "ExitS")

Opt('TrayAutoPause', 0)
Opt('TrayMenuMode', 3)
Opt('TrayOnEventMode', 1)

$hTrayAbout = TrayCreateItem("?")
TrayItemSetOnEvent($hTrayAbout, "AboutS")
$hTrayExit = TrayCreateItem("Exit")
TrayItemSetOnEvent($hTrayExit, "ExitS")

$hGUI = GUICreate("Easy Input Tool", 241, 158)
$bClickSpammer = GUICtrlCreateButton("Click Spammer", 15, 20, 140, 40)
$cbClickToSpam = GUICtrlCreateCombo("Left", 163, 21, 60, 22, 0x0003)
GUICtrlSetData(-1, "Right|Middle")
$bKeySpammer = GUICtrlCreateButton("Key Spammer", 15, 70, 210, 40)
GUICtrlCreateLabel("Interval (ms)", 15, 125)
$iInterval = GUICtrlCreateInput("50", 153, 123, 70, 22)
GUICtrlSetTip(-1, "Delay between clicks.")
;$bSingleToDouble = GUICtrlCreateButton("Click to DoubleClick", 20, 120, 200, 40)
GUISetState()

While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $bKeySpammer
			$nInterval = GUICtrlRead($iInterval)
			GUISetState(@SW_HIDE)
			$sKeyToSpam = InputBox("", "Enter key(s) you want to spam.", "1")
			If Not $sKeyToSpam Then
				GUISetState(@SW_SHOW)
			Else
				PauseS(1)
				_SpamKey($sKeyToSpam, $nInterval)
			EndIf
		Case $bClickSpammer
			$nInterval = GUICtrlRead($iInterval)
			HotKeySet(";", "_DecreaseClickDelay")
			HotKeySet("'", "_IncreaseClickDelay")
			$sClickToSpam = GUICtrlRead($cbClickToSpam)
			GUISetState(@SW_HIDE) ;//$GUI_HIDE
			PauseS(1)
			_SpamClick($sClickToSpam, $nInterval)
		Case -3 ;//$GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd


Func _SpamKey($sfKey = "", $nInterval = 50)
	While 1
		Send($sfKey)
		Sleep($nInterval)
	WEnd
EndFunc   ;==>_SpamKey

Func _SpamClick($sClickToSpam, ByRef $nInterval)
	While 1
		Sleep($nInterval)
		MouseClick($sClickToSpam)
	WEnd
EndFunc   ;==>_SpamClick

Func _IncreaseClickDelay()
	$nInterval += 40
EndFunc   ;==>_IncreaseClickDelay

Func _DecreaseClickDelay()
	$nInterval -= 40
EndFunc   ;==>_DecreaseClickDelay

Func PauseHK()
	PauseS()
EndFunc

Func PauseS($bIsFirstRun = 0)
	$bPaused = Not $bPaused
	If $bPaused = True Then
		$sPause = "Paused."
	Else
		$sPause = "Continued."
	EndIf
	If $bIsFirstRun Then
		TrayTip("", "Press Ctrl+Shift+Z to start/stop." & @CRLF & "Press ; to speed up. Press ' to slow down.", 2)
	Else
		TrayTip("", $sPause & " Press Ctrl+Shift+Z to continue.", 2)
	EndIf
	While $bPaused
		Sleep(500)
	WEnd
EndFunc   ;==>PauseS

Func AboutS()
	MsgBox(64, "About", "Easy Input Tool v" & $sVersion & @CRLF & @CRLF & "Try running as Administrator if clicks do not register." & @CRLF & "Credit to evorlet@gmail.com.")
EndFunc	

Func ExitS()
	Exit
EndFunc   ;==>ExitS
