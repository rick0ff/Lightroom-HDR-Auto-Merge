!+^j:: ;Hotkey
SetTitleMatchMode, 2
SetTitleMatchMode, slow
#SingleInstance force
WinActivate, Lightroom Classic ;switch to Lightroom as active window
WinGetTitle, WindowTitle, A ;get Title of the window, save to "WindowTitle" variable
WinGet, LRPid, PID , WindowTitle ;get ID of LR for later checks
LRClassNNPicsSelected = AfxWnd140u19
AmountOfLoopsErrorSelection := 3 ; for check effectively selected pictures vs. bracket size
CounterHDRMerged := 0

ErrorCount = 0
ProgressPercent = 0
ClosedMergeErrors = 0
URLToGithub = https://github.com/rick0ff/LR-HDR-Auto-Merge

; ===== DEFAULTS =====
DefaultBracketSize = 3
DefaultAmountHDR = 10
DefaultSleepSecs = 5
DefaultEndAction = 6


Gui, Add, Text,, Bracket size (pictures to be merged to each HDR):
Gui, Add, Text,, Amount of HDRs (loop size):
Gui, Add, Text,, Wait time between HDRs (in sec):
Gui, Add, Text,, Flag keypress for end action (optional`; 0-9):
Gui, Add, Text,, Keep showing progress:
Gui, Add, Text,, Keep checking for merging errors and skip them`n(keeps the merging queues going on instead of stopping):

Gui, Add, Text,,
Gui, Add, Text,,
Gui, Add, Link,, Click <a href="%URLToGithub%">here</a> to open the manual/project page.
Gui, Add, Edit,ym
Gui, Add, UpDown, vBracketSize, %DefaultBracketSize%   ; The ym option starts a new column of controls. Variable is BracketSize, the "v" is omitted when calling.
Gui, Add, Edit
Gui, Add, UpDown, vAmountHDRs, %DefaultAmountHDR% 
Gui, Add, Edit
Gui, Add, UpDown, vSleepSecs, %DefaultSleepSecs%
Gui, Add, Edit, vEndAction, %DefaultEndAction%
Gui, Add, Checkbox, vShowProgress Checked,
Gui, Add, Text,,
Gui, Add, Checkbox, vSkipMergingErrors Checked,
Gui, Add, Button, Default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
GuiControl, Focus, OK ;preselects the button to hit enter
Gui, Show,, Lightroom HDR Auto Merge ;title
return  ;
GuiClose: ;if clicked x of window
ExitApp
ButtonOK:
Gui, Submit  ; Save the input from the user to each control's associated variable.


MsgBox, 1, Start Looping?, So the script will loop as follows `n    Bracket Size: %BracketSize%`n    Amount HDRs: %AmountHDRs%`n    Sleep: %SleepSecs%s.`n    End Action: %EndAction%`nOK?
	
IfMsgBox Cancel
    return

SetTimer, WaitIfUnresponsive, 200
if (SkipMergingErrors){ ; skips merging errors if option is selected
	SetTimer, CloseErrorWindows, 200, 10 ; higher priority (+10)
}

Loop, %AmountHDRs%
{	
	if(ShowProgress){ ;Show and update progress bar, if option enabled
		ProgressPercent := Round((CounterHDRMerged / AmountHDRs)*100)
		Progress, b w200 x20, %CounterHDRMerged% / %AmountHDRs%, Progress LR-Merges, Title
		Progress, %ProgressPercent%
	}
	
	DeselectAndStartOver() ; wait until only 1 picture is selected
	CounterErrorSelection := 0 ;resets for every loop
	
	;loop to select the correct amount of images
	while (AmountOfLoopsErrorSelection > CounterErrorSelection){
		WinGetText, AllWindowText, %WindowTitle% ;get text of whole window
		
		;parse text for number of selected photos
		PosStartOfCount := RegExMatch(AllWindowText, " / <b>") + 6 ; 6 characters = " / <b>"
		PosEndOfCount := RegExMatch(AllWindowText, " selected</b>")
		LengthCut := PosEndOfCount - PosStartOfCount
		AmountSelectedPicsFromString := SubStr(AllWindowText, PosStartOfCount, LengthCut)
		
		if (AmountSelectedPicsFromString = 1){ ;OK
			Send,{Shift down}
			Loop, % BracketSize - 1 ;select bracket size
			{
				Send {Right}
				Sleep, 500
			}
			Send {Shift up}
			Loop, %SleepSecs%
				{	
					Sleep, 1000
				}
			break
		}else if(AmountSelectedPicsFromString != BracketSize) { ; too many pics selected and deselect everything and start over
			CounterErrorSelection++
			Sleep, 5000
			DeselectAndStartOver()
			
			
			
		}else if (AmountOfLoopsErrorSelection == CounterErrorSelection){ ; too many trials, quits script. Issue, use "if"-Message to debug
			MsgBox, 0, Error with Selection, The amount of selected images has gone wrong. Script stopped after %CounterErrorSelection% attempts.
			return
		}else{ ; number from old selection or something entirely different still active
			CounterErrorSelection++
			Sleep, 5000
			TrayTip, Error #1 Selection!=1, There is more or less than 1 pictures selected, , 34
			HideTrayTip()	
		}
	}
	

	
	CounterErrorSelection := 0 ;resets for every loop
	while (AmountOfLoopsErrorSelection > CounterErrorSelection){
		WinGetText, AllWindowText, %WindowTitle%
		PosStartOfCount := RegExMatch(AllWindowText, " / <b>") + 6 ; 6 characters = " / <b>"
		PosEndOfCount := RegExMatch(AllWindowText, " selected</b>")
		LengthCut := PosEndOfCount - PosStartOfCount
		AmountSelectedPicsFromString := SubStr(AllWindowText, PosStartOfCount, LengthCut)
		
		; check if selected images equals bracket size
		if (BracketSize = AmountSelectedPicsFromString) { ; OK
			if WinActive("Error"){
				MsgBox, 0, Error detected and script cancelled
				return
			}
			if WinActive(WindowTitle){ ; OK
			}else{
				MsgBox, 0, Error detected, Lightroom window not active anymore (in the foreground)
				return
			}
			
			; sends Ctrl+Shift+H for queuing HDR command
			Send,{Ctrl down}{Shift down}h{Ctrl up}{Shift up} 
			
			;sends EndAction if defined
			if (EndAction != "") {
				Send,%EndAction% ; marks the single pics with end action
			}else{}
			break
		}else if (AmountOfLoopsErrorSelection == CounterErrorSelection){ ; too many trials, quits script. Issue, use "if"-Message to debug
			MsgBox, 0, Error with Selection, The amount of selected images has gone wrong. Script stopped after %CounterErrorSelection% attempts.
			return
		}else{ 
			CounterErrorSelection++
			;Send, {Enter}
			TrayTip, Error #2 Selection!=Bracket Size, Attempt: %CounterErrorSelection%`nThere are more or less  pictures selected than the size of the bracket, , 34
			HideTrayTip()
			Sleep, 3000
		}
	}
	
	
	Loop, %SleepSecs%
	{	
		Sleep, 1000
	}
	
	;check what window is active
	if WinActive("Error"){
		MsgBox, 0, Error detected and script cancelled
		return
	}
	if WinActive(WindowTitle){ ;OK
	}else{
		MsgBox, 0, Error detected, Lightroom window not active anymore (in the foreground)
		return
	}
	CounterHDRMerged++
	; if ( Mod(CounterHDRMerged, 5) == 0){ ; notify every 5 successful merges about status
		; TrayTip, Status MergeHDRs, %CounterHDRMerged%/%AmountHDRs% HDRs merged, , 33
		; HideTrayTip()
	; }
	
}

;show summary after batch finished
Sleep, 500
Progress, Off ;stop showing progess
MsgBox, 0, Loop Job Finished, Loop Job finished`n    Amount HDRs: %AmountHDRs%`n    Bracket Size: %BracketSize%`n    Sleep: %SleepSecs%s.`n    Closed merge Errors: %ClosedMergeErrors%`n

; ==== Functions ====
WaitIfUnresponsive:
if WinActive(WindowTitle) && WinActive("Not Responding"){
	Sleep, 500
}
return

CloseErrorWindows:
if WinExist("Error"){
	WinActivate
	Sleep, 500
	Send, {Enter}
	ClosedMergeErrors++
}
; if ( Mod(A_TimeSinceThisHotkey, 60000) <= 100){ ;notify every 1min
	; TimeRunning := A_TimeSinceThisHotkey / 60000 ;in mins
	; TrayTip, Status Error Surveillance, %TimeRunning%, , 33
	; HideTrayTip()
; }
return

DeselectAndStartOver(){
	Send, {Ctrl down}d{Ctrl up} ; deselect everything
	Send, {Left} ; select the first picture
	Sleep, 1000
}

HideTrayTip() {
    TrayTip  ; Attempt to hide it the normal way.
    if SubStr(A_OSVersion,1,3) = "10." {
        Menu Tray, NoIcon
        Sleep, 200  ; It may be necessary to adjust this sleep.
        Menu Tray, Icon
    }
}

Esc::ExitApp  ; Exit script with Escape key