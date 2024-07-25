#Include lib
#Include mouse-functions.ahk
#Include fix-x1.ahk

; A low A_WinDelay is very important for MouseRestoreAndMoveWin to be smooth.
#Include default-settings.ahk

/**
 * Press XButton1 + MButton
 * to restore a window and move it using the mouse 🚚.
 */

#HotIf GetKeyState('XButton1', 'P')
!MButton Up:: MouseCloseWinInAltTabMenu()

; What's this hotkey for?
; *MButton Up:: return

*MButton Up:: {
    if thisHotkey and not MouseThisHkIsCorrect(thisHotkey) {
        return
    }
    ; ToolTip(thisHotkey ' and ' A_PriorHotkey)

    ; Click a window to close it when using the X1+W hotkeys:
    if WinActive('Task Switching ahk_class XamlExplorerHostIslandWindow') {
        Click('Middle')
        return
    }

    MouseRestoreAndMoveWin(thisHotkey)
}

MouseCloseWinInAltTabMenu() {
    if WinActive('Task Switching ahk_class XamlExplorerHostIslandWindow') {
        Click('Middle')
    }
}

MouseRestoreAndMoveWin(thisHotkey := "") {
    global G_MouseIsMovingWin := true

    MouseActivateWin()

    if WinActive('ahk_class WorkerW ahk_exe Explorer.EXE') {
        return
    }

    WinExist('A')
    winMinMax := WinGetMinMax()
    if winMinMax = 1 {
        WinRestore()
        moveWinMiddleToMouse()
    }

    CoordMode('Mouse', "Screen")
    MouseGetPos(&mouseStartX, &mouseStartY)

    ; Enable per-monitor DPI awareness so that the window doesn't explode in size
    ; when moving across displays with different DPI settings. See
    ; https://www.autohotkey.com/docs/v2/misc/DPIScaling.htm#Workarounds
    originalDpiAwarenessContext := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

    while GetKeyState('XButton1', 'P')
            ; A loop is used instead of SetTimer to preserve the last found window.
    {
        if SubStr(A_ThisHotkey, 1, -2) = 'MButton & Wheel' {
            break
        }

        WinGetPos(&winX, &winY)
        MouseGetPos(&mouseX, &mouseY)
        changeInMouseX := mouseX - mouseStartX
        changeInMouseY := mouseY - mouseStartY
        winX += changeInMouseX
        winY += changeInMouseY
        WinMove(winX, winY)

        mouseStartX := mouseX
        mouseStartY := mouseY
        Sleep(10)
    }

    G_MouseIsMovingWin := false
    DllCall("SetThreadDpiAwarenessContext", "ptr", originalDpiAwarenessContext, "ptr")

    moveWinMiddleToMouse() {
        WinGetPos(, , &winW, &winH)

        CoordMode('Mouse')
        MouseGetPos(&mouseX, &mouseY)

        WinMove(mouseX - (winW / 2), mouseY - (winH / 2))
    }
}
#HotIf
