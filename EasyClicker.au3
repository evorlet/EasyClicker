#include <GUIConstantsEx.au3>

Global $sVersion = "1.4"
Global $sKeyToSpam = 1 ;//Self-explanatory, default key
Global $nInterval = 50 ;//Default interval between mouseclicks & button presses
Global $bPaused = 0, $bHold = False
Global $sPauseHotkey = "+^{z}", $sStartHotkey = "+^{x}"

HotKeySet("+{esc}", "ExitS")

Opt('TrayAutoPause', 0)
Opt('TrayMenuMode', 3)
Opt('TrayOnEventMode', 1)

$hTrayAbout = TrayCreateItem("?")
TrayItemSetOnEvent($hTrayAbout, "AboutS")
$hTrayExit = TrayCreateItem("Exit (Shift+Esc)")
TrayItemSetOnEvent($hTrayExit, "ExitS")

$hGUI = GUICreate("Easy Input Tool", 241, 158)
$bClickSpammer = GUICtrlCreateButton("Click Spammer", 15, 20, 140, 40)
$cbClickToSpam = GUICtrlCreateCombo("Left", 163, 21, 60, 22, 0x0003)
GUICtrlSetData(-1, "Right|Middle")
GUICtrlSetTip(-1, "Mouse button to click")
$bKeySpammer = GUICtrlCreateButton("Key Spammer", 15, 70, 210, 40)
$cbHold = GUICtrlCreateCheckbox("Hold", 15, 122)
GUICtrlSetTip(-1, "Hold down a key/mouse button instead of tapping it.")
GUICtrlCreateLabel("Interval (ms)", 105, 125)
$iInterval = GUICtrlCreateInput("50", 173, 123, 50, 22)
GUISetState()

While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $bKeySpammer
			$nInterval = GUICtrlRead($iInterval)
			If Not StringRegExp($nInterval, "\A(\d)+\Z") Then
				MsgBox(48, "Error", "Interval must be a number.")
				ContinueLoop
			EndIf
			HotKeySet($sPauseHotkey, "PauseHK")
			If GUICtrlRead($cbHold) = $GUI_CHECKED Then
				$sSpecialKeys = "Special keys: CTRL,SHIFT,ALT"
				$sDefaultKey = "CTRL"
			Else
				$sSpecialKeys = "Special keys: ^(Ctrl) +(Shift) !(Alt). Put them in brackets for literal characters. Example: +a = Shift+a, " & "{" & "+}a = +a"
				$sDefaultKey = "1"
			EndIf
			$sKeyToSpam = InputBox("Easy Input Tool", "Enter key(s) you want to spam." & @CRLF & @CRLF & $sSpecialKeys, $sDefaultKey, "", 250, 180)
			If GUICtrlRead($cbHold) = $GUI_CHECKED Then
				If StringLen($sKeyToSpam) > 1 And Not StringRegExp($sKeyToSpam, "\A(CTRL|SHIFT|ALT)\Z") Then
					MsgBox(64, "Easy Input Tool", "Only 1 key can be held down at a time.")
					ContinueLoop
				Else
					$bHold = True
				EndIf
			Else
				$bHold = False
			EndIf
			If $sKeyToSpam Then
				HotKeySet(";", "_DecreaseClickDelay")
				HotKeySet("'", "_IncreaseClickDelay")
				HotKeySet($sStartHotkey, "_SpamKeyHK")
				TrayTip("", "Press Ctrl+Shift+X to start." & @CRLF & "Press Ctrl+Shift+Z to Pause/Unpause.", 2)
				If $bHold = False Then GUISetState(@SW_HIDE)
			EndIf
			Case $bClickSpammer
			$nInterval = GUICtrlRead($iInterval)
			If Not StringRegExp($nInterval, "\A(\d)+\Z") Then
				MsgBox(48, "Error", "Interval must be a number.")
				ContinueLoop
			EndIf
			HotKeySet($sPauseHotkey, "PauseHK")
			HotKeySet(";", "_DecreaseClickDelay")
			HotKeySet("'", "_IncreaseClickDelay")
			$sClickToSpam = GUICtrlRead($cbClickToSpam)
			If GUICtrlRead($cbHold) = $GUI_CHECKED Then
				$bHold = True
			Else
				$bHold = False
				GUISetState(@SW_HIDE) ;//$GUI_HIDE
			EndIf
			HotKeySet($sStartHotkey, "_SpamClickHK")
			TrayTip("", "Press Ctrl+Shift+X to start." & @CRLF & "Press Ctrl+Shift+Z to Pause/Unpause", 2) 
		Case -3 ;//$GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd

Func _SpamKeyHK()
	If $bHold = True Then Send("{" & $sKeyToSpam & "up}")
	_SpamKey($sKeyToSpam, $nInterval, $bHold)
EndFunc	

Func _SpamKey($sfKey, ByRef $nInterval, $bHold = False)
	Sleep(250)
	If $bHold = True Then
		Send("{" & $sfKey & "down}")
		Return
	EndIf
	While 1
		Sleep($nInterval)
		If StringRegExp($sfKey, "(;|')") Then;//Case string to spam contains interval control keys, separated for better performance.
			HotKeySet(";")
			HotKeySet("'")
			Send($sfKey)
			HotKeySet(";", "_DecreaseClickDelay")
			HotKeySet("'", "_IncreaseClickDelay")
		Else
			Send($sfKey)
		EndIf
	WEnd
EndFunc   ;==>_SpamKey

Func _SpamClickHK()
	MouseUp($sClickToSpam)
	_SpamClick($sClickToSpam, $nInterval, $bHold)
EndFunc

Func _SpamClick($sClickToSpam, ByRef $nInterval, $bHold = False)
	If $bHold = True Then
		MouseDown($sClickToSpam)
		Return
	EndIf	
	While 1
		Sleep($nInterval)
		MouseClick($sClickToSpam)
	WEnd
EndFunc   ;==>_SpamClick

Func _IncreaseClickDelay()
	$nInterval += 40
	TrayTip("", "Interval: " & $nInterval & " ms.", 2)
EndFunc   ;==>_IncreaseClickDelay

Func _DecreaseClickDelay()
	$nInterval -= 40
	TrayTip("", "Interval: " & $nInterval & " ms.", 2)
EndFunc   ;==>_DecreaseClickDelay

Func PauseHK()
	PauseS()
EndFunc   ;==>PauseHK

Func PauseS($bIsFirstRun = 0)
	$bPaused = Not $bPaused
	If $bPaused = True Then
		$sPause = "Paused."
	Else
		$sPause = "Continued."
	EndIf
	If $bIsFirstRun Then
		TrayTip("", "Press Ctrl+Shift+Z to start/stop." & @CRLF & "Press ; to speed up. Press ' to slow down.", 3)
	Else
		TrayTip("", $sPause & " Press Ctrl+Shift+Z to continue.", 2)
	EndIf
	While $bPaused
		Sleep(300)
	WEnd
EndFunc   ;==>PauseS

Func AboutS()
	MsgBox(64, "Easy Input Tool v" & $sVersion, "Press Ctrl+Shift+Z to start/stop." & @CRLF & "Press ; to speed up. Press ' to slow down." & @CRLF & @CRLF & "Try running as Administrator if clicks do not register." & @CRLF & @CRLF & "evorlet@gmail.com")
EndFunc   ;==>AboutS

Func ExitS()
	Exit
EndFunc   ;==>ExitS
