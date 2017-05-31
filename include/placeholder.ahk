; Placeholder() - by infogulch for AutoHotkey v1.1.05+
; 
; to set up your edit control with a placeholder, call: 
;   Placeholder(hwnd_of_edit_control, "your placeholder text")
; 
; If called with only the hwnd, the function returns True if a 
;   placeholder is being shown, and False if not.
;   isPlc := Placeholder(hwnd_edit)
; 
; to remove the placeholder call with a blank text param
;   Placeholder(hwnd_edit, "")
; 
; http://www.autohotkey.com/forum/viewtopic.php?p=482903#482903
; 

Placeholder(wParam, lParam = "`r", msg = "") {
    static init := OnMessage(0x111, "Placeholder"), list := []
    
    if (msg != 0x111) {
        if (lParam == "`r")
            return list[wParam].shown
        list[wParam] := { placeholder: lParam, shown: false }
        if (lParam == "")
            return "", list.remove(wParam, "")
        lParam := wParam
        wParam := 0x200 << 16
    }
    if (wParam >> 16 == 0x200) && list.HasKey(lParam) && !list[lParam].shown ;EN_KILLFOCUS  :=  0x200 
    {
        GuiControlGet, text, , %lParam%
        if (text == "")
        {
            Gui, Font, Ca0a0a0
            GuiControl, Font, %lParam%
            GuiControl,     , %lParam%, % list[lParam].placeholder
            list[lParam].shown := true
        }
    }
    else if (wParam >> 16 == 0x100) && list.HasKey(lParam) && list[lParam].shown ;EN_SETFOCUS := 0x100 
    {
        Gui, Font, cBlack
        GuiControl, Font, %lParam%
        GuiControl,     , %lParam%
        list[lParam].shown := false
    }
}