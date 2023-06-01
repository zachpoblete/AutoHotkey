#Include <default-settings>
#Include <globals>
#Include <constants>
#Include <functions>
#Include <classes>

;= =============================================================================
;= Activate
;= =============================================================================

; A_TitleMatchMode = 2:
GroupAdd('ExplorerWins', 'ahk_class CabinetWClass')

; A_TitleMatchMode = 'RegEx':
GroupAdd('PhotoWins', ' ' K_CHARS['LEFT_TO_RIGHT_MARK'] '- Photos$ ahk_exe ApplicationFrameHost.exe')
GroupAdd('ZoomWins', 'ahk_class ^Z ahk_exe Zoom.exe')

^!Tab::  OperateOnActiveGroup('Activate')
^+!Tab:: OperateOnActiveGroup('Close')

OperateOnActiveGroup(action) {
    check('ExplorerWins')

    SetTitleMatchMode('RegEx')
    check('PhotoWins')
    check('ZoomWins')

    SetTitleMatchMode(2)

    processName := WinGetProcessName('A')
    groupName := StrReplace(processName, '.exe')
    groupName := StrReplace(groupName, ' ', '_')

    GroupAdd(groupName, 'ahk_exe ' processName)
    Group%action%(groupName)

    check(groupName) {
        if not WinActive('ahk_group ' groupName) {
            return
        }

        Group%action%(groupName)
        exit
    }
}

;= =============================================================================
;= Characters
;= =============================================================================

;== ============================================================================
;== Hotstrings
;== ============================================================================
; For each Unicode character sent, the hotstring abbreviation is the HTML entity (or something intuitive).

~^z:: {
    if A_PriorHotkey ~= '^:' {
            ; Match hotstrings.
        Send('{Ctrl Down}z{Ctrl Up}')
                ; Send an extra ^z to go back to the abbreviation.
    }
}

#Hotstring EndChars `t

;== ============================================================================
;== Space <-> Underscore
;== ============================================================================

#InputLevel 1
+Space:: Send('_')
+-::     Send('{U+2013}')
        ; En dash.
#InputLevel

;= =============================================================================
;= Disable
;= =============================================================================

^+w:: return

#c:: return

;= =============================================================================
;= Multimedia
;= =============================================================================

;== ============================================================================
;== Media
;== ============================================================================

#HotIf GetKeyState('CapsLock', 'T')
#InputLevel 1
Volume_Mute:: vk13
        ; Pause key.
#InputLevel
#HotIf

Pause:: OneBtnRemote()
OneBtnRemote() {
    static pressCount := 0

    pressCount++
    if pressCount > 2 {
        return
    } else {
        Send('{Media_Play_Pause}')
    }

    period := RegRead('HKEY_CURRENT_USER\Control Panel\Mouse', 'DoubleClickSpeed')
    SetTimer(chooseMediaControl, -period)

    chooseMediaControl() {
        switch pressCount {
        case 2: Send('{Media_Next}')
        case 3: Send('{Media_Prev}')
        }

        pressCount := 0
    }
}

;== ============================================================================
;== Volume
;== ============================================================================

#HotIf GetKeyState('CapsLock', 'T')
$Volume_Up::   DisplayAndSetVolume(1)
$Volume_Down:: DisplayAndSetVolume(-1)

DisplayAndSetVolume(variation) {
    newVol := SoundGetVolume() + variation
    newVol := Round(newVol)
    if variation > 0 or newVol = 1 {
        volDirection := 'Up'
    } else {
        volDirection := 'Down'
    }

    Send('{Volume_' volDirection '}')
            ; Vary volume by 2,
            ; and, importantly, display volume slider (and media overlay).
    SoundSetVolume(newVol)
            ; Override that normal variation of 2.
}

;= =============================================================================
;= Run
;= =============================================================================

;== ============================================================================
;== Directory
;== ============================================================================

#HotIf GetKeyState('NumLock', 'T')
^d:: WinOpenProcessDir()
WinOpenProcessDir() {
    WinExist('A')
    winProcessName := WinGetProcessName()
    winPid := WinGetPid()
    winPath := ProcessGetPath(winPid)
    winDir := RegExReplace(winPath, '\\[^\\]+$')
    Run(winDir)
    WinWaitActive('ahk_exe explorer.exe')
    Send(winProcessName)
}

^+d:: RunSelectedAsDir()
RunSelectedAsDir() {
    dir := GetSelectedElseExit()
    while RegExMatch(dir, '%(.+?)%', &match) {
        env := EnvGet(match[1])
        dir := StrReplace(dir, match[], env)
    }

    Run(dir)
}
#HotIf

;== ============================================================================
;== App
;== ============================================================================

#i:: OpenSettings()
OpenSettings() {
    switch ChordInput() {
    case 'i': Send('{LWin Down}i{LWin Up}')
    case 'v': Run('App volume and device preferences', 'C:\Windows')
    }
}

;= =============================================================================
;= Specific App
;= =============================================================================

#HotIf WinThatUsesCtrlYAsRedoIsActive()
WinThatUsesCtrlYAsRedoIsActive() {
    if WinActive('ahk_exe explorer.exe')
            or WinActive('ahk_exe Messenger.exe')
            or WinActive(' | Tinkercad ahk_exe msedge.exe')
            or WinActive('ahk_exe Spotify.exe') {
        return true
    }

    SetTitleMatchMode('RegEx')
    if WinActive('ahk_exe .EXE$') {
        return true
    }
}

^+z:: Send('{Ctrl Down}y{Ctrl Up}')
^y::  Send('{Ctrl Down}{Shift Down}z{Shift Up}{Ctrl Up}')
#HotIf

#!m:: AppToggleMute()
AppToggleMute() {
    switch ChordInput() {
    case 'z': Send('{Ctrl Down}{Shift Down}{Alt Down}{F13}{Alt Up}{Shift Up}{Ctrl Up}')
    case 'd': Send('{Ctrl Down}{Shift Down}{Alt Down}{F14}{Alt Up}{Shift Up}{Ctrl Up}')
    }
}

/**
 * Open uniqoda.
 */
#+,:: {
    Send('{Blind}{Shift Up}{LWin Up}')
    Send('{Ctrl Down}{Shift Down}{F20}{Shift Up}{Ctrl Up}')
}

;== ============================================================================
;== Adobe Reader
;== ============================================================================

#HotIf ControlClassNnFocused('ahk_exe AcroRd32.exe', '^AVL_AVView', true)
^Left::  Send('{Ctrl Down}{Shift Down}{Left}{Shift Up}{Ctrl Up}{Up}')
^Right:: Send('{Ctrl Down}{Shift Down}{Right}{Shift Up}{Ctrl Up}{Down}')

;~ hk := HkSplit(thisHotkey)
;~ horiz := '{' hk[2] '}'

;~ if horiz = '{Left}' {
;~     oppHoriz := '{Right}'
;~     vert := '{Up}'

;~ } else {
;~     oppHoriz := '{Left}'
;~     vert := '{Down}'
;~ }

;~ Send('{Ctrl Down}{Shift Down}' horiz '{Shift Up}{Ctrl Up}')
;~ selected := GetSelected()

;~ if not StrReplace(selected, ' ') {
;~     Send('{Ctrl Down}{Shift Down}' horiz '{Shift Up}{Ctrl Up}')
;~ }

;~ Sleep(30)
;~ Send(vert oppHoriz)

#HotIf

;== ============================================================================
;== Browsers
;== ============================================================================

;=== ===========================================================================
;=== Vimium C Commands
;=== ===========================================================================

#HotIf WinActive('ahk_exe msedge.exe') and not WinActive(' - Google Docs')
!;::  VimcCmd(1)
        ; LinkHints.activate.
+!;:: VimcCmd(2)
        ; LinkHints.activateEdit.
^!;:: VimcCmd(3)
        ; LinkHints.activateHover.

^!+c:: VimcCmd(4)
        ; LinkHints.activateCopyLinkUrl.
^!c::  VimcCmd(5)
        ; LinkHints.activateCopyLinkText.

^!Left::  VimcCmd(8)
        ; goPrevious.
^!Right:: VimcCmd(9)
        ; goNext.

^F6:: VimcCmd(10)
        ; nextFrame.

^!p::    VimcCmd(11)
        ; togglePinTab.
^+!d::   VimcCmd(12)
        ; duplicateTab.
^!r::    VimcCmd(13)
        ; reopenTab.
^!]::     VimcCmd(14)
        ; removeRightTab.
^+PgUp:: VimcCmd(15)
        ; moveTabLeft.
^+PgDn:: VimcCmd(16)
        ; moveTabRight.

^!d:: VimcCmd(17)
        ; scrollDown.
^!u:: VimcCmd(18)
        ; scrollUp.
!j::  VimcCmd(19)
        ; scrollDown count=3.
!k::  VimcCmd(20)
        ; scrollUp count=3.
!d::  VimcCmd(21)
        ; scrollPageDown.
!u::  VimcCmd(22)
        ; scrollPageUp.
^!j:: VimcCmd(23)
        ; scrollToBottom.
^!k:: VimcCmd(24)
        ; scrollToTop.

!h::  VimcCmd(25)
        ; scrollLeft.
!l::  VimcCmd(26)
        ; scrollRight.
^!h:: VimcCmd(27)
        ; scrollToLeft.
^!l:: VimcCmd(28)
        ; scrollToRight.

VimcCmd(num) {
    if num > 24 {
        Send('{Alt Down}{F' (num - 12) '}{Alt Up}')
    } else if num > 16 {
        Send('{Ctrl Down}{F' (num - 4) '}{Ctrl Up}')
    } else if num > 8 {
        Send('{Shift Down}{F' (num + 4) '}{Shift Up}')
    } else {
        Send('{F' (num + 12) '}')
    }
}
#HotIf

;=== ===========================================================================
;=== Edge
;=== ===========================================================================

#HotIf WinActive('ahk_exe msedge.exe')
^Tab::  Send('{Ctrl Down}{Shift Down}a{Shift Up}{Ctrl Up}')
        ; Search tabs.
^+Tab:: Send('{Ctrl Down}{Shift Down},{Shift Up}{Ctrl Up}')
        ; Toggle vertical tabs.

#HotIf WinActive(' - Google Docs ahk_exe msedge.exe')
Alt Up:: {
    if not InStr(A_PriorKey, 'Alt') {
        return
    }

    Send('{F10}')
}
#HotIf

;== ============================================================================
;== Notion
;== ============================================================================

#HotIf WinActive('ahk_exe Notion.exe')
!Left::  Send('{Ctrl Down}[{Ctrl Up}')
        ; Go back.
!Right:: Send('{Ctrl Down}]{Ctrl Up}')
        ; Go forward.

^+f:: Send('{Ctrl Down}{Shift Down}h{Shift Up}{Ctrl Up}')
        ; Apply last text or highlight color used.
#HotIf

;== ============================================================================
;== Spotify
;== ============================================================================

#HotIf WinActive('ahk_exe Spotify.exe')
/**
 * I switched the keyboard shortcuts for varying the navigation bar and friend activity widths.
 * When you increase the navigation bar width, the cover art grows taller,
 * so assign Down and Up to it,
 * When you increase the friend activity width, the bar grows fatter,
 * so assign Left and Right to it.
 */
+!Down::  Send('{Shift Down}{Alt Down}{Left}{Alt Up}{Shift Up}')
        ; Decrease navigation bar width.
+!Up::    Send('{Shift Down}{Alt Down}{Right}{Alt Up}{Shift Up}')
        ; Increase navigation bar width.
+!Left::  Send('{Shift Down}{Alt Down}{Down}{Alt Up}{Shift Up}')
        ; Increase friend activity width.
+!Right:: Send('{Shift Down}{Alt Down}{Up}{Alt Up}{Shift Up}')
        ; Decrease friend activity width.
#HotIf

;=== ===========================================================================
;=== Spicetify
;=== ===========================================================================

#HotIf WinActive('ahk_exe Spotify.exe')
/**
 * * keyboardShortcut-Quarter.js:
 * *     +!l:: toggleLyrics()
 * *     +!q:: toggleQueue()
 * *     +!m:: openSpicetifyMarketPlace()
 *
 * +!2 goes to Your Podcasts,
 * but because of the Hide Podcasts extension,
 * Your Podcasts isn't listed in Your Library,
 * so +!2 should redirect to Your Artists instead.
 * The same logic applies to +!3 and +!4.
 */
+!2:: Send('{Shift Down}{Alt Down}3{Alt Up}{Shift Up}')
        ; Go to Your Artists.
+!3:: Send('{Shift Down}{Alt Down}4{Alt Up}{Shift Up}')
        ; Go to Your Albums.
+!4:: return
#HotIf

;== ============================================================================
;== Zoom
;== ============================================================================

#HotIf WinActive(K_CLASSES['ZOOM']['MEETING']) and WinWaitActive(K_CLASSES['ZOOM']['TOOLBAR'], , 0.1)
~#Down:: {
    winPid := WinGetPid()
    WinActivate('Zoom ahk_pid ' winPid)
        ; Activate minimized video/control window.
}

#HotIf WinActive(K_CLASSES['ZOOM']['WAIT_HOST']) or WinActive(K_CLASSES['ZOOM']['VID_PREVIEW'])
#Down:: WinMinimize()

#HotIf WinActive(K_CLASSES['ZOOM']['MIN_VID']) or WinActive(K_CLASSES['ZOOM']['MIN_CONTROL'])
/**
 * * Doesn't work when coming from #Down.
 */
#Up:: {
    WinGetPos(, , , &winH)
    ControlClick('x200 y' (winH - 30))
            ; Exit minimized video window.
}

#HotIf WinActive(K_CLASSES['ZOOM']['HOME']) and not Zoom_MeetingWinExist(true)
!F4:: ProcessClose('Zoom.exe')
        ; Can't use WinClose because that minimizes here.
#HotIf

;=== ===========================================================================
;=== Reactions
;=== ===========================================================================

#HotIf Zoom_MeetingWinExist(false)
!=:: Zoom_ThumbsUpReact()
Zoom_ThumbsUpReact() {
    Zoom_OpenReactions()
    Sleep(200)
            ; WinWaitActive(K_CLASSES['ZOOM']['REACTION']) doesn't work fsr.

    CoordMode('Mouse', 'Client')
    CoordMode('Pixel', 'Client')

    WinExist('A')
            ; Reaction window.
    WinGetPos(, , &winW, &winH)
    ImageSearch(&imageX, &imageY, 0, 0, winW, winH, '*50 images\thumbs-up-icon.png')
    ControlClick('x' imageX ' y' imageY)
    WinActivate(K_CLASSES['ZOOM']['MEETING'])
            ; Prevent the activation of the most recent window when the reaction disappears.
}

!e:: Zoom_OpenReactions()
Zoom_OpenReactions() {
    if not WinExist(K_CLASSES['ZOOM']['MEETING']) {
        return
    }
    if WinExist(K_CLASSES['ZOOM']['REACTION']) {
        WinActivate()
        return
    }

    if not WinActive() {
            ; Check if the meeting window isn't active.
        WinActivate()
    }

    if not ControlGetVisible(K_CONTROLS['ZOOM']['MEETING_CONTROLS']) {
        ControlShow(K_CONTROLS['ZOOM']['MEETING_CONTROLS'])
    }

    ControlGetPos(&controlX, &controlY, &controlW, &controlH, K_CONTROLS['ZOOM']['MEETING_CONTROLS'])

    loop {
        try {
            iconClick('reactions')
        } catch {
        } else {
            return
        }

        if A_Index = 1 {
            Send('{Tab}')
                    ; Maybe the reason the icon wasn't found was because there was a dotted rectangle surrounding it,
                    ; so Send('{Tab}') to move the rectangle to a different item.
            continue
        }

        try {
            iconClick('more')
        } catch {
            exit
        } else {
            break
        }
    }

    Sleep(150)

    /**
     * I want my coordinates to be relative to the menu window
     * because that's where the Reactions menu item is,
     * but fsr, when I activate or ControlClick the window, I lose it.
     * As a work around, use Click,
     * and make it relative to the virtual screen.
     * Do the same with ImageSearch.
     */

    CoordMode('Mouse')
    CoordMode('Pixel')

    MouseGetPos(&mouseX, &mouseY)
    ImageSearch(&imageX, &imageY, 0, 0, G_VirtualScreenW, G_VirtualScreenH, '*50 images\reactions-menu-item.png')

    Click(imageX ' ' imageY)
    Sleep(10)
    MouseMove(mouseX, mouseY)

    iconClick(imageFileName) {
        ImageSearch(&imageX, &imageY, controlX, controlY, controlX + controlW, controlY + controlH, '*50 images\' imageFileName '-icon.png')
        ControlClick('x' imageX ' y' imageY)
    }
}
#HotIf

;= =============================================================================
;= Keys
;= =============================================================================

;== ============================================================================
;== BackSpace
;== ============================================================================

#HotIf ControlClassNnFocused('A', '^Edit\d+$', true)
        or ControlClassNnFocused('ahk_exe AcroRd32.exe', '^AVL_AVView', true)
        or WinActive('ahk_exe mmc.exe')
/**
 * ^BS doesn't natively work because it produces a control character,
 * so work around that.
 */
^BS:: {
    if GetSelected() {
        Send('{Del}')
    } else {
        Send('{Ctrl Down}{Shift Down}{Left}')
        Sleep(0)
                ; For Premiere Pro.
        Send('{Del}{Shift Up}{Ctrl Up}')
                ; Delete last word typed.
    }
}
#HotIf

+BS::  Send('{Del}')
^+BS:: Send('{Ctrl Down}{Del}{Ctrl Up}')

;== ============================================================================
;== Modifiers
;== ============================================================================

;=== ===========================================================================
;=== F13 - F24
;=== ===========================================================================

MapF13UntilF24()
MapF13UntilF24() {
    HotIf((thisHotkey) => GetKeyState('CapsLock', 'T'))
    loop 12 {
        if A_Index < 3 {
            num := A_Index + 22
        } else {
            num := A_Index + 10
        }

        Hotkey('*F' (A_Index), remap.bind(num))
    }
    HotIf

    remap(num, thisHotkey) => Send('{Blind}{F' num '}')
}

;=== ===========================================================================
;=== Mask
;=== ===========================================================================

#^+Alt::
#^!Shift::
#+!Ctrl::
^+!LWin::
^+!RWin:: {
    MaskMenu()
}

#HotIf not OfficeAppIsActive()
OfficeAppIsActive() {
    SetTitleMatchMode('RegEx')
    return WinActive('ahk_exe .EXE$')
}

Alt:: MaskAlt()
MaskAlt() {
    SetKeyDelay(-1)
    SendEvent('{Blind}{Alt DownR}')
    MaskMenu()
    KeyWait('Alt')
    SendEvent('{Blind}{Alt Up}')
}
#HotIf

;=== ===========================================================================
;=== NumLock
;=== ===========================================================================

DoOnNumLockToggle()

#InputLevel 1
!CapsLock:: SendEvent('{NumLock}')
^Pause::    SendEvent('{NumLock}')
        ; This hotkey exists because when Ctrl is down,
        ; NumLock produces the key code of Pause (while Pause produces CtrlBreak).
#InputLevel

~*NumLock:: DoOnNumLockToggle()

DoOnNumLockToggle() {
    NumLockIndicatorFollowMouse()
    C_InsertInputRightOfCaret.toggle()
}

/**
 * Display ToolTip while NumLock is on.
 */
NumLockIndicatorFollowMouse() {
    Sleep(10)

    if GetKeyState('NumLock', 'T') {
        SetTimer(toolTipNumLock, 10)
    } else {
        SetTimer(toolTipNumLock, 0)
        ToolTip()
    }

    toolTipNumLock() => ToolTip('NumLock On')
}

;== ============================================================================
;== Remaps in Other Programs
;== ============================================================================

/**
 * (In order of decreasing input level)
 * * RAKK Lam-Ang Pro FineTuner:
 * *     Fn::         CapsLock
 * *     CapsLock::   BS
 * *     BS::         `
 * *     `::          NumLock
 * *
 * *     Ins::        Home
 * *     Home::       PgUp
 * *     PgUp::       Ins
 * *
 * * KeyTweak:
 * *     AppsKey::    RWin
 * *
 * * PowerToys:
 * *     ScrollLock:: AppsKey
 */
