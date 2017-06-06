; ========== Diabetes Log Book ==========
; ~~~~~~~~~~~~ by v ~~ for j ~~~~~~~~~~~~

#NoEnv
#SingleInstance Force
#Persistent

SetWorkingDir %A_ScriptDir%

#Include include/placeholder.ahk

; ========== READ VARS FROM INI ==========
ReadGlobals()

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

Return



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

; ========== GUI POSITION & SIZE ==========
SysGet, MonitorWorkArea, MonitorWorkArea
guiW := 276
guiH := 510
guiX := MonitorWorkAreaRight - guiW - 10
guiY := MonitorWorkAreaBottom - guiH - 33

guiLineWidth := guiW - 29
guiEditWidth := guiW - 60
guiButtonX := guiW - 183

; ========== GUI CONTROLS ==========
Gui Font, s15, Segoe UI Symbol
Gui Add, Text, x16 y+11 w20 h%dHeight%+1, 🕓
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
Gui Add, Edit, xs y+m w%guiEditWidth% h38 Multi vfood hwndhFood +Disabled
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

Gui Add, CheckBox, xs-19 y+15 w13 h13 vbasalCheckBox gbasalCheckBoxLabel
Gui Add, Edit, x+6 yp-7 w%dWidth% h%dHeight% -VScroll Right +Disabled vtotalBasal gtotalBasalLabel
Gui Add, Text, x+m y+-25 h25 +BackgroundTrans c777777 vtotalBasalText, %langBasal%

Gui Add, Text, x16 y+24 w%guiLineWidth% h2 0x10

Gui Font, s15, Segoe UI Symbol
Gui Add, Text, x16 y+9 w20 h%dHeight%, 📝
Gui Font
Gui Font, s10
Gui Add, Edit, x+m yp+2 w%guiEditWidth% h38 Multi Section vnotes hwndhNotes

Gui Add, Text, x16 y+12 w%guiLineWidth% h2 0x10

Gui Add, Button, x%guiButtonX% y+12 w80 h%dHeight% +Default gEnter, %langOK%
Gui Add, Button, x+m w80 h%dHeight% gGuiClose, %langCancel%

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
    GuiControl, Enable, food
    GuiControl, Enable, foodInsulin
    GuiControl, Enable, foodInsulinText
    
    GuiControl,, foodInsulin, % ToComma(ToPoint(foodValue) * insulinFoodFactorMorning)
    GoSub foodInsulinLabel
}
else
{
    GuiControl, Disable, food
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


ToPoint(var, returnZero := false)
{
	if(var == "" && returnZero)
	{
		Return 0
	}
    StringReplace, outputVar, var, `,, ., All
    Return outputVar
}

ToComma(var)
{
	global

    var := Round(insulinUnitStep * var) / insulinUnitStep ; Set precision step - 1/2 or 1/4 etc
    var := RemoveZero(var) ; Remove trailing zeros
    
    StringReplace, outputVar, var, ., `,, All
    Return outputVar
}


RemoveZero(var)
{
    IfNotInString var, .
        Return var
    
    Loop
    {
        StringRight, zeroTest, var, 1
        
        if (zeroTest == "0" || zeroTest == ".")
        {
            StringTrimRight, var, var, 1
        }
        else
        {
            Return var
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



NumpadEnter::
Enter:

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

/*
;Parse a comma separated value (CSV) file - See https://autohotkey.com/board/topic/52762-reading-csv-file/
Loop, read, log\%yearValue%.csv
{
	LineNumber = %A_Index%
	
	; save in array (or use stringsplit)
	Loop, parse, A_LoopReadLine, CSV
	{
		Field%A_Index% := A_LoopField
	}
	
	if (InStr(Field1,surname) && InStr(Field2,forename) && InStr(Field3,dob))
		MsgBox,4160,Register,%Forename% %Surname% %DoB% on Register!`r`rRow Number: %A_Index% in Register.csv file
}
*/

; Format time for writing
FormatTime, dateValue, %dateValue%, dd.MM.yy
FormatTime, timeValue, %timeValue%, HH:mm

; If only placeholder text is shown, leave field empty
if (Placeholder(hFood))
{
	food = 
}
if (Placeholder(hNotes))
{
	notes = 
}

FileAppend,
(

"%dateValue%","%timeValue%","%glucoseValue%","%foodValue%","%foodInsulin%","%correctionInsulin%","%totalBolus%","%totalBasal%","%food%","%notes%"
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