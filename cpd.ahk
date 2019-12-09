#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

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
