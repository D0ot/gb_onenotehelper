#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.





; Set up our pen constants
global SPEN_NOT_HOVERING := 0x0      ; Pen is moved away from screen.
global SPEN_HOVERING := 0x0          ; Pen is hovering above screen.
global SPEN_TOUCHING := 0x1          ; Pen is touching screen.

global SPEN_BTN_HOVERING := 0x8
global SPEN_BTN_TOUCHING := 0xC

; Respond to the pen inputs
; Fill this section with your favorite AutoHotkey scripts!
; lastInput is the last input that was detected before a state change.
PenCallback(input, lastInput) {

    if(lastInput = SPEN_HOVERING and input = SPEN_BTN_HOVERING)
    {
        ; assume it is "down"
        ; MsgBox, Pressed
        Send, {F13}
    }

    if(lastInput = SPEN_BTN_HOVERING and input = SPEN_HOVERING)
    {
        ; assume it is "up"
        Send, {F14}
    }

    if(lastInput = SPEN_BTN_HOVERING and input = SPEN_BTN_TOUCHING)
    {
        ; assume btn_touching
        Send, {F15}
    }

}

global raw_pen_x
global raw_pen_y


; Include AHKHID
#include AHKHID.ahk

; Set up other constants
; USAGE_PAGE and USAGE might change on different devices...
WM_INPUT := 0xFF
USAGE_PAGE := 13
USAGE := 2

; Set up AHKHID constants
AHKHID_UseConstants()

; Register the pen
AHKHID_AddRegister(1)
AHKHID_AddRegister(USAGE_PAGE, USAGE, A_ScriptHwnd, RIDEV_INPUTSINK)
AHKHID_Register()

; Intercept WM_INPUT
OnMessage(WM_INPUT, "InputMsg")

; Callback for WM_INPUT
; Isolates the bits responsible for the pen states from the raw data.
InputMsg(wParam, lParam) {
    Local type, inputInfo, inputData, raw, proc
    Critical

    type := AHKHID_GetInputInfo(lParam, II_DEVTYPE)

    if (type = RIM_TYPEHID) {
        inputInfo := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)
        inputData := AHKHID_GetInputData(lParam, uData)

        raw := NumGet(uData, 0, "UInt")
        proc := (raw >> 8) & 0x1F

        raw_pen_x := NumGet(uData, 2, "UShort")
        raw_pen_y := NumGet(uData, 4, "UShort")

        LimitPenCallback(proc)
    }
}

; Limits the callback only to when the pen changes state.
; This stop the repetitive firing that goes on when the pen moves around.
LimitPenCallback(input) {
    static lastInput := PEN_NOT_HOVERING

    if (input != lastInput) {
        PenCallback(input, lastInput)
        lastInput := input
    }
}



; following is done by d0ot[at]github
; any questions, feel free to contact me!


; Configurations start
; get it by Windows Spy
global lasso_offset_x := 227
global lasso_offset_y := 125
global earser_offset_x := 357
global earser_offset_y := 125

global pen1_offset_x := 420
global pen1_offset_y := 125

global pen2_offset_x := 490
global pen2_offset_y := 125

global win_title_regex := ".*OneNote"
global program_executable := "OneNoteUWP"

global click_max_interval := 300
global quick_panel_wait := 300
; Configurations end

; Wacom Feel It Constant for GB12
global PEN_X_MAX := 25272
global PEN_Y_MAX := 16848


; for tool switch
global TOOL_NULL := 0
global TOOL_PEN := 1
global TOOL_LASSO := 2
global TOOL_EARSER := 3
global tool_in_use := TOOL_PEN


; for button_timer
global btn_timer_on := 0
global btn_up_count := 0
global btn_down_count := 0
global btn_last_down_count := 0
global btn_last_up_count := 0
global btn_touching := 0


global win_title := "Default"

global gui1Hwnd := 0
global quick_panel_width := 100
Gui, New, +AlwaysOnTop -Caption +Hwndgui1Hwnd
MsgBox, %gui1Hwnd%
Gui, %gui1Hwnd%:Add, Text,, Quick Panel
Gui, %gui1Hwnd%:Add, Button, Default w%quick_panel_width%, Cancel
Gui, %gui1Hwnd%:Add, Button, Default w%quick_panel_width%, Copy
Gui, %gui1Hwnd%:Add, Button, Default w%quick_panel_width%, Paste
Gui, %gui1Hwnd%:Add, Button, Default w%quick_panel_width%, Delete


ButtonCancel:
Gui, %gui1Hwnd%:Hide
return

ButtonCopy:
Gui, %gui1Hwnd%:Hide
Sleep, %quick_panel_wait%
Send, ^c
return


ButtonPaste:
Gui, %gui1Hwnd%:Hide
Sleep, %quick_panel_wait%
Send, ^v
return

ButtonDelete:
Gui, %gui1Hwnd%:Hide
Sleep, %quick_panel_wait%
Send, {Delete Down}{Delete Up}
return


get_pen_pos_x()
{
    return raw_pen_x / PEN_X_MAX * 2160
}

get_pen_pos_y()
{

    return raw_pen_y / PEN_Y_MAX * 1440
}

show_quick_panel()
{
    CoordMode, Mouse, Screen
    qp_x := get_pen_pos_x() - (quick_panel_width / 2)
    qp_y := get_pen_pos_y() - 50
    Gui, %gui1Hwnd%:Show, X%qp_x% Y%qp_y%
}


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

get_win_title_regex(winTitleRegEx)
{
    winTitle := "Not Found"
    SetTitleMatchMode, RegEx
    WinGetTitle, winTitle, %winTitleRegEx% 
    return winTitle
}

; skip the regex match process
apply_click_quick(winTitle, offset_x, offset_y)
{
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

button_timer()
{
    ; if touching down, all previous btn input is assumed to be invalid

    ;MsgBox, Time get
    if(btn_touching = 1)
    {
        SetTimer, button_timer, Off
        btn_timer_on := 0
        return
    }


    if(btn_down_count = btn_last_down_count)
    {
        SetTimer, button_timer, Off
        btn_timer_on := 0


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



; single click for pen
; double click for lasso


; for pen btn down
F13::
;MsgBox, F9 get btn_timer_on = %btn_timer_on%


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
F14::
if (btn_timer_on = 1)
{
    btn_up_count := btn_up_count + 1
}
return

F15::
btn_touching := 1
return

; times of press
; long is 1 for long press
actions(times, long)
{

    if(long = 0)
    {
        ; debug code
        ; MsgBox, times = %times%

        if(times = 1)
        {
            switch_tool()
        }

        if(times = 2)
        {
            ; copy, paste, delete
            show_quick_panel()
        }

        if(times = 3)
        {
        }

    }else
    {

        if(times = 1)
        {
            px := get_pen_pos_x()
            py := get_pen_pos_y()
            CoordMode, Mouse, Screen
            Click, right, %px%, %py%

        }

        if(times = 2)
        {
            Send, #+s
        }

    }
}


; switch pen and lasso
switch_tool()
{
    if(tool_in_use = TOOL_PEN)
    {
        apply_click(win_title_regex, lasso_offset_x, lasso_offset_y)
        tool_in_use := TOOL_LASSO
    }
    else
    {
        apply_click(win_title_regex, pen2_offset_x, pen2_offset_y)
        tool_in_use := TOOL_PEN
    }

}


