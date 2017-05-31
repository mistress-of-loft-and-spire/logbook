; ========== Diabetes Log Book ==========
; ~~~~~~~~~~~~ by v ~~ for j ~~~~~~~~~~~~

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

#Include include/placeholder.ahk

; ========== READ VARS FROM INI ==========
AutoTrim On

SetFormat Float, 0.2
global globalHalfStep := 2

global globalCorrectionStep := 40
global globalOptimalLower := 100
global globalOptimalUpper := 160

global globalBEFactor := 1.5


GoSub, GuiShow ; TEMPTEMPTMEPTMEPM




#D::
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
guiH := 556
guiX := MonitorWorkAreaRight - guiW - 10
guiY := MonitorWorkAreaBottom - guiH - 33

guiLineWidth := guiW - 29
guiEditWidth := guiW - 60
guiButtonX := guiW - 183

; ========== GUI CONTROLS ==========
Gui Font, s15
Gui Add, Text, x16 y+8 w20 h%dHeight%+1, 🕓
Gui Font, s13
Gui Add, DateTime, x+m w84 h28, HH:mm
Gui Add, DateTime, x+m w124 h28,  

Gui Add, Text, x16 y+12 w%guiLineWidth% h2 0x10

Gui Font, s15
Gui Add, Text, x16 y+12 w20 h%dHeight%+1, 💧
Gui Font, s13
Gui Add, Edit, x+m w%dWidth% h%dHeight% -VScroll Right vglucoseValue gglucoseLabel
Gui Add, Text, x+m y+-25 h25, mmol/dl

Gui Add, Text, x16 y+12 w%guiLineWidth% h2 0x10

Gui Font, s15
Gui Add, Text, x16 y+12 w20 h%dHeight%, 🍎
Gui Font, s13
Gui Add, Edit, x+m w%dWidth% h%dHeight% -VScroll Right Section vbeValue gbeLabel
Gui Add, Text, x+m y+-25 h25, BE
Gui Font, s10
Gui Add, Edit, xs y+m w%guiEditWidth% h38 Multi vfood hwndhFood +Disabled
Gui Font, s13

Gui Add, Text, x16 y+12 w%guiLineWidth% h2 0x10

Gui Font, s15
Gui Add, Text, x16 y+12 w20 h%dHeight%, 💉
Gui Font, s13
Gui Add, Edit, x+m w%dWidth% h%dHeight% -VScroll Right Section +Disabled vbeInsulin gbeInsulinLabel
Gui Add, Text, x+m y+-25 h25 +Disabled vbeInsulinText, BE Insulin
Gui Add, Edit, xs w%dWidth% h%dHeight% -VScroll Right vcorrectionInsulin gcorrectionInsulinLabel
Gui Add, Text, x+m y+-25 h25, Korrektur

;Gui Add, Text, x0 y+12 w%guiW% h88 +0x5
Gui, Add, Progress, x0 y+12 w%guiW% h88 +Disabled Backgroundeeeeee

Gui Add, Edit, xs yp+12 w%dWidth% h%dHeight% c000000 -VScroll Right +Disabled vtotalInsulin
Gui Add, Text, x+m y+-25 h25 +BackgroundTrans, Bolus

Gui Add, CheckBox, xs-19 y+15 w13 h13
Gui Add, Edit, x+6 yp-7 w%dWidth% h%dHeight% -VScroll Right +Disabled vtotalBasal
Gui Add, Text, x+m y+-25 h25 +BackgroundTrans c777777, Basal

Gui Add, Text, x16 y+24 w%guiLineWidth% h2 0x10

Gui Font, s15
Gui Add, Text, x16 y+12 w20 h%dHeight%, 📝
Gui Font, s10
Gui Add, Edit, x+m w%guiEditWidth% h38 Multi Section vnotes hwndhNotes
Gui Add, Edit, y+m w%guiEditWidth% h38 Multi Section vhealth hwndhHealth

Gui Add, Text, x16 y+12 w%guiLineWidth% h2 0x10

Gui Add, Button, x%guiButtonX% y+12 w80 h%dHeight% +Default gEnter, &OK
Gui Add, Button, x+m w80 h%dHeight% gGuiClose, Abbrechen

Placeholder(hFood, "Essen")
Placeholder(hNotes, "Besonderes")
Placeholder(hHealth, "Gesundheit")

GuiControl, Focus, glucoseValue
Gui Show, x%guiX% y%guiY% w%guiW% h%guiH%, Diabetes Log
Return


; ========== FUNCTIONS ==========
glucoseLabel:
Gui Submit, NoHide

Correction :=

if (Validate("glucoseValue", false) && glucoseValue > 0)
{
    if(glucoseValue > globalOptimalUpper)
    {
        Correction := Mod(glucoseValue, globalOptimalUpper)
        Correction := Ceil(Correction / globalCorrectionStep * globalHalfStep) / globalHalfStep
        GuiControl,, correctionInsulin, % ToComma(Correction)
    }
    else if(glucoseValue < globalOptimalLower)
    {
        Correction := Mod(glucoseValue-globalOptimalLower, globalOptimalLower)
        Correction := Floor(Correction / globalCorrectionStep * globalHalfStep) / globalHalfStep
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


beLabel:
Gui Submit, NoHide

if (Validate("beValue") && beValue > 0)
{
    GuiControl, Enable, food
    GuiControl, Enable, beInsulin
    GuiControl, Enable, beInsulinText
    
    GuiControl,, beInsulin, % ToComma(ToPoint(beValue) * globalBEFactor)
    GoSub beInsulinLabel
}
else
{
    GuiControl, Disable, food
    GuiControl, Disable, beInsulin
    GuiControl, Disable, beInsulinText
    
    GuiControl,, beInsulin,
    GoSub beInsulinLabel
}
Return


beInsulinLabel:
Gui Submit, NoHide

if (Validate("beInsulin") && beInsulin > 0)
{
    GuiControl,, totalInsulin, % ToComma(ToPoint(beInsulin) + ToPoint(correctionInsulin))
}
else
{
    GuiControl,, totalInsulin,
}
Return


correctionInsulinLabel:
Gui Submit, NoHide

if (Validate("correctionInsulin"))
{
    GuiControl,, totalInsulin, % ToComma(ToPoint(beInsulin) + ToPoint(correctionInsulin))
}
else
{
    GuiControl,, totalInsulin,
}
Return


; See https://autohotkey.com/boards/viewtopic.php?p=99447#p99447
Validate(label, checkComma := false)
{
    var := %label%
    
    if (var != "")
    {
        validVar := RegExReplace(var,"[^0-9,]+")
        
        ; validVar := ToComma(Round(globalHalfStep * ToPoint(validVar)) / globalHalfStep)
        
        falseSpace := RegExMatch(var,"[\s\.]+")
        
        StringSplit,splitNum,var,`,
    
        if (splitNum0 <= 2 && validVar = var && !falseSpace)
        {
            ; Return VALID
            Gui, Font, c s13
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
    Return
}


ToPoint(var)
{
    StringReplace, outputVar, var, `,, ., All
    Return outputVar
}


ToComma(var)
{
    var := Round(globalHalfStep * var) / globalHalfStep ; Set precision step - 1/2 or 1/4 etc
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


NumpadEnter::
Enter:
    
Return


GuiEscape:
GuiClose:
    ExitApp