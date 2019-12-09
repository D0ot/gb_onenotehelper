; FOLLOWING IS DONE BY d0ot[at]github

; Configurations start
; get it by Windows Spy
global lasso_offset_x := 227
global lasso_offset_y := 125
global earser_offset_x := 357
global earser_offset_y := 125

global pen1_offset_x := 420
global pen1_offset_y := 125

global win_title_regex := ".*OneNote"
global program_executable := "OneNoteUWP"

global click_max_interval := 300
; Configurations end

; Wacom Feel It Constant for GB12
global PEN_X_MAX := 25272
global PEN_Y_MAX := 16848



global last_input_time

apply_click(winTitleRegEx, offset_x, offset_y)
{
    winTitle := "Not Found"
    SetTitleMatchMode, RegEx
    WinGetTitle, winTitle, %winTitleRegEx% 
    WinGetPos, x, y, w, h, %winTitle%
    click_x := x + offset_x
    click_y := y + offset_y
    CoordMode, Mouse, Screen
    click, %click_x%, %click_y%
}

select_draw(offset_x, offset_y)
{
    Send, {Alt Down}d{Alt Up}
    Sleep, 100
    apply_click(win_title_regex, offset_x, offset_y)
}


global btn_timer_on := 0

global btn_up_count := 0
global btn_down_count := 0
global btn_last_down_count := 0
global btn_last_up_count := 0

global btn_touching := 0

button_timer()
{
    if(btn_down_count = btn_last_down_count)
    {
        SetTimer, button_timer, Off
        btn_timer_on := 0

        ; if touching down, all btn donw input is assumed to be invalid
        if(btn_touching = 1)
        {
            return
        }

        ; btn_down_count times press and release
        if(btn_up_count = btn_down_count)
        {

            ; debug code
            ; MsgBox, %btn_down_count% times, not long;
            actions(btn_down_count, 0)

        }
        else
        {
            ; btn_down_count times press and
            ; btn_up_count times release
            ; long press detected
            
            ; debug code
            ; MsgBox, %btn_down_count% times, long;

            actions(btn_down_count, 1)
        }

    }else
    {
        btn_last_down_count := btn_down_count
        btn_last_up_count := btn_up_count
    }
}


#^e::
SetTitleMatchMode, RegEx
if WinExist(win_title_regex)
{
    WinActivate, %win_title_regex%
    select_draw(earser_offset_x, earser_offset_y)
}
else
{
    MsgBox, OneNote is not running.
}
return 

#^l::
SetTitleMatchMode, RegEx
if WinExist(win_title_regex)
{

    WinActivate, %win_title_regex%
    select_draw(lasso_offset_x, lasso_offset_y)
}
else
{
    MsgBox, OneNote is not running.
    Run, %program_executable%
}
return


; single click for pen
; double click for lasso


; for pen btn down
F9::    
MsgBox, F9
if (btn_timer_on = 0)
{
    btn_down_count := 1
    btn_down_last_count := 1
    btn_up_count := 0
    btn_last_up_count := 0

    btn_touching := 0

    btn_timer_on := 1
    SetTimer, button_timer, %click_max_interval%
}
else
{
    btn_down_count := btn_down_count + 1
}
return

; for pen btn up
F10::
MsgBox, F10
if (btn_timer_on = 1)
{
    btn_up_count := btn_up_count + 1
}

F11::
btn_touching := 1


; times of press
; long is 1 for long press
actions(times, long)
{


    if(long = 0)
    {
        if(times = 1)
        {
            MsgBox, There will be a menu
        }

        if(times = 2)
        {
            apply_click(win_title_regex, pen1_offset_x, pen1_offset_y)
            return
        }

        if(times = 3)
        {
            Send, #+s
            return
        }

    }else
    {

        if(times = 1)
        {
            apply_click(win_title_regex, lasso_offset_x, lasso_offset_y)
        }

    }
}

return

Gui, New, +AlwaysOnTop -Caption +LastFound +Hwndgui1Hwnd
MsgBox, %gui1Hwnd%
Gui, %gui1Hwnd%:Add, Text,, Quick Panel
Gui, %gui1Hwnd%:Add, Button, Default w100, Copy
Gui, %gui1Hwnd%:Add, Button, Default w100, Paste
Gui, %gui1Hwnd%:Add, Button, Default w100, Delete

F8::
Gui, %gui1Hwnd%:Show
return

ButtonCopy:
Gui, %gui1Hwnd%:Hide
Send, {CtrlDown}c{CtrlUp}}
return


ButtonPaste:
Gui, %gui1Hwnd%:Hide
Send, {CtrlDown}v{CtrlUp
return

ButtonDelete:
Gui, %gui1Hwnd%:Hide
Send, {Delete Down}{Delete Up}
return

