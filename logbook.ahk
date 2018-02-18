; ========== Diabetes Log Book ==========
; ~~~~~~~~~~~~ by v ~~ for j ~~~~~~~~~~~~

#NoEnv
#SingleInstance Force
#Persistent

SetWorkingDir %A_ScriptDir%

#Include include/placeholder.ahk
#Include include/tooltip.ahk
#Include include/DateParse.ahk
#Include include/commapoint.ahk

; ========== READ VARS FROM INI ==========
ReadDatatoArray()
ReadGlobals()

global dataIndex := -1

Hotkey, %programHotkey%, OpenGui

; ========== Reminder TIMER ==========
global timer := 0
global timerDelay := 60000
global hypoActive := false
global hyperActive := false
SetTimer, TimerCount, %timerDelay%

; ========== READ LANG FILE ==========
; See https://autohotkey.com/boards/viewtopic.php?t=14437
if (A_Language == "0407" || A_Language == "0807" || A_Language == "0c07" || A_Language == "1007" || A_Language == "1407")
{
	global language := "german"
}
else
{
	global language := "english"
}

FileRead, lang, include/lang/%language%.lang
loop, parse, lang, `r`n
{
   StringSplit, words, A_LoopField, =
   lang%words1% := words2
}


; ========== TRAY MENU ==========

Menu, tray, NoStandard
Menu, tray, Add, %langExit%, Exit
Menu, tray, Default, %langExit%


;DEBUG
;
Goto, OpenGui
;
Return
;
F5::
Reload
Return
;

OpenGui:

SetTimer, TimerCount, Off

Gui Destroy
GuiShow:
; ========== GUI SETTINGS ==========
Gui -MinimizeBox -MaximizeBox +AlwaysOnTop +OwnDialogs
Gui Font, s13
Gui Color, White

Gui Margin, 8, 8
dHeight := 28
dWidth := dHeight * 2
bHeight := 34

; ========== GUI POSITION & SIZE ==========
SysGet, MonitorWorkArea, MonitorWorkArea
guiW := 276
guiH := 566
guiX := MonitorWorkAreaRight - guiW - 10
guiY := MonitorWorkAreaBottom - guiH - 33

guiLineWidth := guiW - 29
guiEditWidth := guiW - 60
guiButtonX := guiW - 203

; ========== GUI CONTROLS ==========
Gui, Add, Progress, x0 y0 w%guiW% h48 +Disabled Backgroundeeeeee

Gui Font, s12, Segoe UI Symbol
Gui Add, Button, x8 yp+7 w%bHeight% h%bHeight% gLeft vTTLeft, %langLeft%
Gui Add, Button, x+0 w%bHeight% h%bHeight% gRight vTTRight Disabled, %langRight%
Gui Add, Button, x+16 w%bHeight% h%bHeight% gNew vTTNew Disabled, %langNew%
Gui Add, Button, x+24 w%bHeight% h%bHeight% gOpen vTTOpen, %langOpen%
Gui Add, Button, x+0 w%bHeight% h%bHeight% gExport vTTExport Disabled, %langExport%
Gui Add, Button, x+16 w%bHeight% h%bHeight% gSettings vTTSettings, %langSettings%

TTLeft_TT = %langTooltipLeft%
TTRight_TT = %langTooltipRight%
TTNew_TT = %langTooltipNew%
TTOpen_TT = %langTooltipOpen%
TTExport_TT = %langTooltipExport%
TTSettings_TT = %langTooltipSettings%

Gui Font, s15, Segoe UI Symbol
Gui Add, Text, x16 y+18 w20 h%dHeight%+1, 🕓
Gui Font
Gui Font, s13
Gui Add, DateTime, x+m yp+1 w80 h28 vtimeValue 1, HH:mm
Gui Add, DateTime, x+m w128 h28 vdateValue,  

Gui Add, Text, x16 y+12 w%guiLineWidth% h2 0x10

Gui Font, s15, Segoe UI Symbol
Gui Add, Text, x16 y+9 w20 h%dHeight%+1, 💧
Gui Font
Gui Font, s13
Gui Add, Edit, x+m yp+2 w%dWidth% h%dHeight% -VScroll Right vglucoseValue gglucoseLabel
Gui Add, Text, x+m y+-25 h25, %labelGlucoseUnit%

Gui Add, Text, x16 y+12 w%guiLineWidth% h2 0x10

Gui Font, s15, Segoe UI Symbol
Gui Add, Text, x16 y+9 w20 h%dHeight%, 🍎
Gui Font
Gui Font, s13
Gui Add, Edit, x+m yp+2 w%dWidth% h%dHeight% -VScroll Right Section vfoodValue gfoodLabel
Gui Add, Text, x+m y+-25 h25, %labelFoodUnit%
Gui Font, s10
Gui Add, Edit, xs y+m w%guiEditWidth% h38 Multi vfoodText hwndhFood
Gui Font, s13

Gui Add, Text, x16 y+12 w%guiLineWidth% h2 0x10

Gui Font, s15, Segoe UI Symbol
Gui Add, Text, x16 y+9 w20 h%dHeight%, 💉
Gui Font
Gui Font, s13
Gui Add, Edit, x+m yp+2 w%dWidth% h%dHeight% -VScroll Right Section +Disabled vfoodInsulin gfoodInsulinLabel
Gui Add, Text, x+m y+-25 h25 +Disabled vfoodInsulinText, %labelFoodUnit% %langInsulin%
Gui Add, Edit, xs w%dWidth% h%dHeight% -VScroll Right vcorrectionInsulin gcorrectionInsulinLabel
Gui Add, Text, x+m y+-25 h25, %langCorrection%

;Gui Add, Text, x0 y+12 w%guiW% h88 +0x5
Gui, Add, Progress, x0 y+12 w%guiW% h88 +Disabled Backgroundeeeeee

Gui Add, Edit, xs yp+12 w%dWidth% h%dHeight% c000000 -VScroll Right vtotalBolus gtotalBolusLabel
Gui Add, Text, x+m y+-25 h25 +BackgroundTrans vtotalBolusText, %langBolus%
Gui Add, Text, x+20 y+-25 h70 w300 +BackgroundTrans cf65850 vwarnActiveText, 
CheckActive()

Gui Add, CheckBox, xs-19 y+-30 w13 h13 vbasalCheckBox gbasalCheckBoxLabel
Gui Add, Edit, x+6 yp-7 w%dWidth% h%dHeight% -VScroll Right +Disabled vtotalBasal gtotalBasalLabel
Gui Add, Text, x+m y+-25 h25 +BackgroundTrans c777777 vtotalBasalText, %langBasal%

Gui Add, Text, x16 y+24 w%guiLineWidth% h2 0x10

Gui Font, s15, Segoe UI Symbol
Gui Add, Text, x16 y+9 w20 h%dHeight%, 📝
Gui Font
Gui Font, s10
Gui Add, Edit, x+m yp+2 w%guiEditWidth% h38 Multi Section vnotes hwndhNotes

Gui Add, Text, x16 y+12 w%guiLineWidth% h2 0x10

Gui Add, Button, x%guiButtonX% y+12 w90 h%bHeight% +Default gEnter vOK, %langOK%
Gui Add, Button, x+m w90 h%bHeight% gGuiClose, %langCancel%

Placeholder(hFood, langFood)
Placeholder(hNotes, langNotes)

GuiControl, Focus, glucoseValue
Gui Show, x%guiX% y%guiY% w%guiW% h%guiH%, %langLogbook%
Return


; ========== FUNCTIONS ==========
glucoseLabel:
Gui Submit, NoHide

Correction :=

if (Validate("glucoseValue", false) && glucoseValue > 0)
{
    if(glucoseValue > insulinTargetUpper)
    {
        Correction := Mod(glucoseValue, insulinTargetUpper)
        Correction := Ceil(Correction / insulinCorrectionFactor * insulinUnitStep) / insulinUnitStep
        GuiControl,, correctionInsulin, % ToComma(Correction)
    }
    else if(glucoseValue < insulinTargetLower)
    {
        Correction := Mod(glucoseValue-insulinTargetLower, insulinTargetLower)
        Correction := Floor(Correction / insulinCorrectionFactor * insulinUnitStep) / insulinUnitStep
        GuiControl,, correctionInsulin, % ToComma(Correction)
    }
    else
    {
        GuiControl,, correctionInsulin,
    }
}
else
{
    GuiControl,, correctionInsulin,
}
GoSub correctionInsulinLabel
Return


foodLabel:
Gui Submit, NoHide

if (Validate("foodValue") && foodValue > 0)
{
    GuiControl, Enable, foodInsulin
    GuiControl, Enable, foodInsulinText
    
    GuiControl,, foodInsulin, % ToComma(ToPoint(foodValue) * insulinFoodFactorMorning)
    GoSub foodInsulinLabel
}
else
{
    GuiControl, Disable, foodInsulin
    GuiControl, Disable, foodInsulinText
    
    GuiControl,, foodInsulin,
    GoSub foodInsulinLabel
}
Return


foodInsulinLabel:
Gui Submit, NoHide

if (Validate("foodInsulin") || foodInsulin == "")
{
    CalcBolus()
}
else
{
    GuiControl,, totalBolus,
}
Return


correctionInsulinLabel:
Gui Submit, NoHide

if (Validate("correctionInsulin", false, true) || correctionInsulin == "")
{
    CalcBolus()
}
else
{
    GuiControl,, totalBolus,
}
Return


totalBolusLabel:
Gui Submit, NoHide

Validate("totalBolus")
Return


totalBasalLabel:
Gui Submit, NoHide

Validate("totalBasal")
Return


basalCheckBoxLabel:
Gui Submit, NoHide

if (basalCheckBox == 1)
{
    GuiControl, Enable, totalBasal
    Gui, Font, c000000 s13
    GuiControl, Font, totalBasalText
	GuiControl, MoveDraw, totalBasalText
    Gui, Font, s10
	
	SetBasal()
}
else
{
    GuiControl, Disable, totalBasal
	Gui, Font, c7777777 s13
    GuiControl, Font, totalBasalText
	GuiControl, MoveDraw, totalBasalText
    Gui, Font, s10
	
	GuiControl, Text, totalBasal, 
}
Return



; ========== FUNCTIONS ==========

CalcBolus()
{
	global
	
	Gui Submit, NoHide
	
	GuiControl,, totalBolus, % ToComma(ToPoint(foodInsulin, true) + ToPoint(correctionInsulin, true))
}


SetBasal()
{
	global

	FormatTime, timeValue, %timeValue%, HHmm
	
	if ((timeValue >= 0400 && timeValue < 1100))
	{
		; Morning
		GuiControl, Text, totalBasal, %insulinBasalMorning%
	}
	else if ((timeValue >= 1100 && timeValue < 1700))
	{
		; Midday
		if (insulinBasalMidday == "" || insulinBasalMidday == 0)
		{
			GuiControl, Text, totalBasal, %insulinBasalMorning%
		}
		else
		{
			GuiControl, Text, totalBasal, %insulinBasalMidday%
		}
	}
	else
	{
		; Evening
		GuiControl, Text, totalBasal, %insulinBasalEvening%
	}
}


; See https://autohotkey.com/boards/viewtopic.php?p=99447#p99447
Validate(label, checkComma := false, allowNegative := false)
{
	global

    var := %label%
    
    if (var != "")
    {
        validVar := RegExReplace(var,"[^0-9,]+")
		
		if (allowNegative)
		{
			validVar := RegExReplace(var,"[^0-9,-]+")
		}
        
        ; validVar := ToComma(Round(insulinUnitStep * ToPoint(validVar)) / insulinUnitStep)
        
        falseSpace := RegExMatch(var,"[\s\.]+")
        
        StringSplit,splitNum,var,`,
    
        if (splitNum0 <= 2 && validVar == var && !falseSpace)
        {
            ; Return VALID
            Gui, Font, c000000 s13
            GuiControl, Font, %label%
            Gui, Font, s10
            Return true
        }
    }
    
    ; Return NOT VALID
    Gui, Font, cf65850 s13
    GuiControl, Font, %label%
    Gui, Font, s10
    Return false
}


CheckActive()
{
	global
	
	time := A_now
	time += -3, hours
	
	warnActive := 
	
	if (dataArray._MaxIndex() > 0)
	{
		Loop % dataArray._MaxIndex() 
		{
			
			if(dataArray[dataArray._MaxIndex() - A_Index + 1,7] && dataArray[dataArray._MaxIndex() - A_Index + 1,7] > 0)
			{
				
				j := DateParse(dataArray[dataArray._MaxIndex() - A_Index + 1,1] . " " . dataArray[dataArray._MaxIndex() - A_Index + 1,2]) . "00"
				
				if (j > time)
				{
					warnActive = % warnActive . "" . dataArray[dataArray._MaxIndex() - A_Index + 1,2] . " 💉" . dataArray[dataArray._MaxIndex() - A_Index + 1,7] . "`n"
				}
				else
				{
					break
				}
			}
		}
	}
	
	GuiControl, Text, warnActiveText, %warnActive%
	
}


ReadDatatoArray()
{
	global
	
	dataArray := Object()
	
	FormatTime, yearValue, %dateValue%, yyyy
	
	ifExist, log\%yearValue%.csv
	{
	
		Loop, read, log\%yearValue%.csv
		{
			LineNumber = %A_Index%
			
			Loop, parse, A_LoopReadLine, CSV
			{
				dataArray[LineNumber, A_Index] := A_LoopField
				
			}
		}
	
	}
	
}


ReadGlobals()
{
	global
	AutoTrim On

	IniRead, general, settings.ini, general
	loop, parse, general, `r`n
	{
	   StringSplit, words, A_LoopField, =
	   general%words1% := words2
	}

	IniRead, labels, settings.ini, label
	loop, parse, labels, `r`n
	{
	   StringSplit, words, A_LoopField, =
	   label%words1% := words2
	}

	IniRead, insulin, settings.ini, insulin
	loop, parse, insulin, `r`n
	{
	   StringSplit, words, A_LoopField, =
	   insulin%words1% := words2
	}
	
	IniRead, program, settings.ini, program
	loop, parse, program, `r`n
	{
	   StringSplit, words, A_LoopField, =
	   program%words1% := words2
	}
	
	; convert insulin step
	insulinUnitStep := 1 / insulinUnitStep
	SetFormat Float, 0.2
	
	Return
}


; ========== CALLS ==========

TimerCount:
	timer += 1
	
	if (programReminderGeneral > 0 && timer >= programReminderGeneral)
	{
		TrayTip, %langReminder%, %langReminderText%,, 33
		timer = 0
	}
	else if (hyperActive && programReminderAfterHyper > 0 && timer >= programReminderAfterHyper)
	{
		TrayTip, %langHyperglycemia% %langReminder%, %langReminderText%,, 33
		timer = 0
	}
	else if (hypoActive && programReminderAfterHypo > 0 && timer >= programReminderAfterHypo)
	{
		TrayTip, %langHypoglycemia% %langReminder%, %langReminderText%,, 33
		timer = 0
	}
Return






New:
; Reset all controls

GuiControl,Text,OK, %langOk%
GuiControl,Enable,OK

GuiControl,Disable,TTNew
GuiControl,Disable,TTRight
GuiControl,Enable,TTLeft

GuiControl,,timeValue, %A_Now%
GuiControl,,dateValue, %A_Now%

GuiControl,,glucoseValue

GuiControl,,foodValue

GuiControl,,foodText

GuiControl,,foodInsulin

GuiControl,,correctionInsulin

GuiControl,,totalBolus

GuiControl,,basalCheckBox, 0
GuiControl,,totalBasal

CheckActive()

GuiControl,,notes

GuiControl,Enable,timeValue
GuiControl,Enable,dateValue
GuiControl,Enable,glucoseValue
GuiControl,Enable,foodValue
GuiControl,Enable,foodText
GuiControl,Disable,foodInsulin
GuiControl,Disable,foodInsulinLabel
GuiControl,Enable,correctionInsulin
GuiControl,Enable,totalBolus
GuiControl,Enable,basalCheckBox
GuiControl,Disable,totalBasal
GuiControl,Enable,notes

Placeholder(hFood, langFood)
Placeholder(hNotes, langNotes)

GuiControl, Focus, glucoseValue

dataIndex := -1

Return



Left:

if(dataIndex == -1)
{
	dataIndex := dataArray._MaxIndex()
	
	GuiControl,Enable,TTNew
	GuiControl,Enable,TTRight
	
	GuiControl,Text,OK, %langChange%
	GuiControl,Disable,OK
}
else if(dataIndex > 0)
{
	dataIndex -= 1
	
	if(dataIndex <= 1)
	{
		GuiControl,Disable,TTLeft
	}
}

showData()

Return



Right:

if(dataIndex < dataArray._MaxIndex())
{
	dataIndex += 1
	
	if(dataIndex > 0)
	{
		GuiControl,Enable,TTLeft
	}
	
	showData()
}
else if(dataIndex == dataArray._MaxIndex())
{
	Goto, New
}

Return


showData()
{
	global

	GuiControl,,timeValue, % DateParse(dataArray[dataIndex,1] . " " . dataArray[dataIndex,2]) . "00"
	GuiControl,,dateValue, % DateParse(dataArray[dataIndex,1] . " " . dataArray[dataIndex,2]) . "00"
	
	GuiControl,Text,glucoseValue, % dataArray[dataIndex,3]

	GuiControl,,foodValue, % dataArray[dataIndex,4]

	GuiControl,,foodText, % dataArray[dataIndex,9]

	GuiControl,,foodInsulin, % dataArray[dataIndex,5]

	GuiControl,,correctionInsulin, % dataArray[dataIndex,6]

	GuiControl,,totalBolus, % dataArray[dataIndex,7]

	if(dataArray[dataIndex,8] && dataArray[dataIndex,8] > 0)
	{
		setBasalCheckBox := 1
		
		Gui, Font, c000000 s13
		GuiControl, Font, totalBasalText
		GuiControl, MoveDraw, totalBasalText
		Gui, Font, s10
	}
	else
	{
		setBasalCheckBox := 0
		
		Gui, Font, c7777777 s13
		GuiControl, Font, totalBasalText
		GuiControl, MoveDraw, totalBasalText
		Gui, Font, s10
	}
	
	GuiControl,,basalCheckBox, % setBasalCheckBox
	GuiControl,,totalBasal,  % dataArray[dataIndex,8]
	
	GuiControl, Text, warnActiveText, 

	GuiControl,,notes, % dataArray[dataIndex,10]
	
	Gui, Font, c000000 s10
    GuiControl, Font, foodText
	GuiControl, Font, notes
    Gui, Font, s10
	
	GuiControl,Disable,timeValue
	GuiControl,Disable,dateValue
	GuiControl,Disable,glucoseValue
	GuiControl,Disable,foodValue
	GuiControl,Disable,foodText
	GuiControl,Disable,foodInsulin
	GuiControl,Disable,correctionInsulin
	GuiControl,Disable,totalBolus
	GuiControl,Disable,basalCheckBox
	GuiControl,Disable,totalBasal
	GuiControl,Disable,notes
}



Export:
FormatTime, yearValue, %dateValue%, yyyy
Run, C:\Windows\Notepad.exe "log\%yearValue%.csv"
Return



Open:
FormatTime, yearValue, %dateValue%, yyyy
Run, C:\Windows\Notepad.exe "log\%yearValue%.csv"
Return



Settings:
RunWait, C:\Windows\Notepad.exe "settings.ini"
ReadGlobals()
msgbox, Settings Updated!
Return






NumpadEnter::
Enter:

/*
if(dataIndex != -1)
{

	GuiControl,Enable,timeValue
	GuiControl,Enable,dateValue
	GuiControl,Enable,glucoseValue
	GuiControl,Enable,foodValue
	GuiControl,Enable,foodText
	GuiControl,Disable,foodInsulin
	GuiControl,Disable,foodInsulinLabel
	GuiControl,Enable,correctionInsulin
	GuiControl,Enable,totalBolus
	GuiControl,Enable,basalCheckBox
	GuiControl,Disable,totalBasal
	GuiControl,Enable,notes
	Return
}
*/

Gui Submit, NoHide

FormatTime, yearValue, %dateValue%, yyyy

ifNotExist, log\%yearValue%.csv
{
	FileCreateDir, log
	
	FileAppend,
(
"%generalName%",,,"%labelFoodUnit% %langFactor%",,"%langCorrectionFactor% / %langShortInsulinUnit%",,"%langBasal%",,
,,,"%insulinFoodFactorMorning% / %insulinFoodFactorMidday% / %insulinFoodFactorEvening%",,"%insulinCorrectionFactor%",,"%insulinBasalMorning% / %insulinBasalMidday% / %insulinBasalEvening%",,
,,,,,,,,,
"%langBolus%: %generalBolusName%",,,"%langBolusEffectiveDuration%: %insulinBolusDuration%",,,,,,
"%langBasal%: %generalBasalName%",,,"%langTargetRange%: %insulinTargetLower% - %insulinTargetUpper%",,,,,,
,,,,,,,,,
%langDate%,%langTime%,%langGlucose% (%labelGlucoseUnit%),%labelFoodUnit%,%labelFoodUnit% %langInsulin%,%langCorrection%,%langBolus%,%langBasal%,%langFood%,%langNotes%
,,,,,,,,,
), log\%yearValue%.csv
}

; Format time for writing
FormatTime, dateValue, %dateValue%, dd.MM.yy
FormatTime, timeValue, %timeValue%, HH:mm

; If only placeholder text is shown, leave field empty
if (Placeholder(hFood))
{
	foodText = 
}
if (Placeholder(hNotes))
{
	notes = 
}

FileAppend,
(

"%dateValue%","%timeValue%","%glucoseValue%","%foodValue%","%foodInsulin%","%correctionInsulin%","%totalBolus%","%totalBasal%","%foodText%","%notes%"
), log\%yearValue%.csv

; Reset reminder timer

timer = 0
hypoActive := false
hyperActive := false

if (glucoseValue < insulinTargetLower)
{
	hypoActive := true
}
else if (glucoseValue > insulinTargetUpper)
{
	hyperActive := true
}


GuiEscape:
GuiClose:
	Gui Destroy
	
SetTimer, TimerCount, %timerDelay%
Return

Exit:
    ExitApp