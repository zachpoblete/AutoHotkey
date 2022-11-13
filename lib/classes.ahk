#Include default-settings.ahk
#Include functions.ahk

class C_KeyWait {
    static _states := Map()

    static get(key, options := '') {
        if not (this._states.has(key) and this._states[key].has(options)) {
            return
        }
        return this._states[key][options]
    }

    static set(key, options := '', isWaiting := true) {
        if this._states.has(key) {
            this._states[key][options] := isWaiting
        } else {
            this._states[key] := Map(options, isWaiting)
        }
        if not isWaiting {
            return
        }
        KeyWait(key, options)
        this._states[key][options] := false
    }
}

class C_Hotkey {
    static ctrlTab(hk, shouldPressShift) {
        sendFirstAndLast(thisHotkey) {
            Send('{Ctrl Down}' tab)
            hk := HotkeySplit(thisHotkey)
            KeyWait(hk[1])
            Send('{Ctrl Up}')
        }

        tab := (shouldPressShift)? '{Shift Down}{Tab}{Shift Up}' : '{Tab}'

        HotIf((thisHotkey) => GetKeyState('Ctrl'))
        Hotkey(hk, (thisHotkey) => Send(tab))

        HotIf()
        Hotkey(hk, (thisHotkey) => sendFirstAndLast(thisHotkey))
    }

    class Browser {
        static active() {
            return WinActive('ahk_exe msedge.exe') or WinActive('ahk_exe firefox.exe') or WinActive('ahk_exe chrome.exe')
        }

        static hotIfCondition(hotIfExFn) {
            if HasProp(hotIfExFn, 'call') {
                HotIf((thisHotkey) => this.active() and hotIfExFn())
            } else {
                HotIf((thisHotkey) => this.active())
            }
        }

        static searchSelectedAsUrl(hk, engine := '', hotIfExFn := {}) {
            searchUrlInTab(inNew) {
                url := getUrlFromSelectedElseExit()

                letter := (inNew)? 't' : 'l'
                Send('{Ctrl Down}' letter '{Ctrl Up}')

                SendInstantRaw(url)

                Sleep(10)
                Send('{Enter}')
            }
            runUrl() {
                url := getUrlFromSelectedElseExit()
                Run(url)
            }
            getUrlFromSelectedElseExit() {
                query := GetSelectedElseExit()
                return (engine)? QueryToUrl(query, engine) : query
            }

            this.hotIfCondition(hotIfExFn)
            Hotkey(hk, (thisHotkey) => searchUrlInTab(true))
            Hotkey('+' hk, (thisHotkey) => searchUrlInTab(false))

            HotIf((thisHotkey) => hotIfExFn())
            Hotkey(hk, (thisHotkey) => runUrl())
            HotIf()
        }
    }
}

class C_Timer {
    static _labels := []

    static get(index := 1) {
        if this._labels.has(index) {
            return this._labels[index]
        } else {
            this._labels.insertAt(1, '')
            return
        } 
    }

    static set(fn, periodMs := 250, priority := 0, index := 1) {
        SetTimer(fn, periodMs, priority)

        if not this._labels.has(index) {
            this._labels.insertAt(index, fn)
        }
        if periodMs > 0 {
            this._labels.removeAt(index)
            this._labels.insertAt(index, fn)
        } else if periodMs = 0 {
            this._labels.removeAt(index)
        } else {
            SetTimer(() => this._labels.removeAt(index), periodMs)
        }
    }
}
