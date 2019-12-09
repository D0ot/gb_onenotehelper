#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


Gui, +Resize
Gui, Add, StatusBar
Gui, Show



; Set up our pen constants
global SPEN_NOT_HOVERING := 0x0      ; Pen is moved away from screen.
global SPEN_HOVERING := 0x0          ; Pen is hovering above screen.
global SPEN_TOUCHING := 0x1          ; Pen is touching screen.

global SPEN_BTN_HOVERING := 0x8
global SPEN_BTN_TOUCHING := 0xC


global raw_input := 0

; Respond to the pen inputs
; Fill this section with your favorite AutoHotkey scripts!
; lastInput is the last input that was detected before a state change.
PenCallback(input, lastInput) {

    if(lastInput = SPEN_HOVERING and input = SPEN_BTN_HOVERING)
    {
        ; assume it is "down"
        ; MsgBox, Pressed
        ; Send, {F9}
        MsgBox, raw_input = %raw_input%
    }

    if(lastInput = SPEN_BTN_HOVERING and input = SPEN_HOVERING)
    {
        ; assume it is "up"
        Send, {F10}
    }

    if(lastInput = SPEN_BTN_HOVERING and input = SPEN_BTN_TOUCHING)
    {
        ; assume btn_touching
        Send, {F11}
    }

}

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

        raw_input := raw

        raw := NumGet(uData, 0, "UInt")
        proc := (raw >> 8) & 0x1F

        ; correct
        raw_x := NumGet(uData, 2, "UShort")

        ; correct
        raw_y := NumGet(uData, 4, "UShort")

        ; correct 
        raw_pressure := NumGet(uData, 6, "UShort")

        ; correct
        raw_height := NumGet(uData, 8, "UShort")

        raw_k1 := NumGet(uData, 10, "Char")
        raw_k2 := NumGet(uData, 11, "Char")
        raw_k3 := NumGet(uData, 12, "Char")
        


        SB_SetText(raw_x . " | " . raw_y . " | " . raw_pressure . " | " . raw_height )
        ;SB_SetText(raw_k1 . " | " . raw_k2 . " | " . raw_k3)
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