ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
delay := 1
*4::
    Send, {Shift up}
    Send, {Shift down}
 Send, {c down}
    Sleep, 10
 Send, {Space down}
 Sleep, 10
 Send, {c up}
 Sleep, 10
 Send, {Space up}
 Sleep, 250
    Send, {Space}
    Send {Shift up}
 Sleep, 12
 Send, {Shift down}
 Sleep, 1000
 Send, {Shift up}
return
F1::Suspend,Toggle