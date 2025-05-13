#Requires AutoHotkey v2.0

tricepsPath := "\\fwfiler1\apps\Triceps\Triceps.exe"
siteParam := "SITE=FARR0101"
loginIdHwnd := "ThunderRT6TextBox30"

init() {
    global tricepsPID
    tricepsPID := 0
    Run('"' tricepsPath '" ' siteParam, , , &tricepsPID)
    if !tricepsPID {
        MsgBox "Failed to start Triceps."
        ExitApp
    }
    try {
        login()
        sleep 1000
        setPrinter()
        sleep 100
        navToPalletCorrections()
        sleep 100
        showPrintGui()
        msgbox "Pallet Labels Printed."
    } catch as e {
        MsgBox "Error during initialization: " e.Message
        ExitApp
    }

}

init()

; Run Triceps and get its PID

findCtrl(searchHwnd, timeout := 30000, textMatch := unset) {
    start := A_TickCount
    interval := 500

    loop {
        winList := WinGetList()
        for hwnd in winList {
            if WinGetPID(hwnd) == tricepsPID {
                if IsSet(textMatch) {
                    try {
                        visibleText := WinGetText(hwnd)
                        if !InStr(visibleText, textMatch)
                            continue
                    } catch Error {
                        continue
                    }
                }
                try {
                    controls := WinGetControls(hwnd)
                    for ctrl in controls {
                        if InStr(ctrl, searchHwnd) {
                            return {
                                found: true,
                                control: ctrl,
                                hwnd: hwnd
                            }
                        }
                    }
                } catch Error {
                    continue
                }
            }
        }

        if (A_TickCount - start > timeout) {
            return {
                found: false,
                control: "",
                hwnd: "",
                error: "Timeout after " timeout " ms"
            }
        }

        Sleep interval
    }
}

login() {
    form := "logon"
    employeeIdField := findCtrl("ThunderRT6TextBox2", 5000, form)
    passwordField := findCtrl("ThunderRT6TextBox1", 5000, form)
    loginButton := findCtrl("ThunderRT6CommandButton1", 5000, form)
    ControlSetText("19490", employeeIdField.control, employeeIdField.hwnd)
    ControlClick(passwordField.control, passwordField.hwnd)
    ControlSetText("19490", passwordField.control, passwordField.hwnd)
    sleep 100
    ControlSend("{Enter}", passwordField.control, passwordField.hwnd)
}

navToPalletCorrections() {
    mdiHwnd := WinExist("ahk_class ThunderRT6MDIForm")

    owner := DllCall("GetWindow", "Ptr", mdiHwnd, "UInt", 4, "Ptr")  ; GW_OWNER = 4

    ; Send the F1 key
    sendVirtualKey(owner, 0x70)  ; F1
    Sleep 200

    ; Send Alt+M
    sendAltCombo(owner, 0x4D)  ; M
    Sleep 150

    ; Then 'b' and 'c'
    sendVirtualKey(owner, 0x42) ; B
    Sleep 100
    sendVirtualKey(owner, 0x43) ; C

}

setPrinter(printerId := 000, printerCtrl := "ThunderRT6TextBox2") {
    form := "TW2087"
    printerField := findCtrl(printerCtrl, , form)

    if !printerField.found {
        MsgBox "Printer control not found."
        return
    }
    ControlSetText(printerId, printerField.control, printerField.hwnd)
    ControlSend("{Enter}", printerField.control, printerField.hwnd)
    sleep 100
    ControlSend("{F1}", printerField.control, printerField.hwnd)
}

OnExit(closeTriceps)

closeTriceps(ExitReason?, ExitCode?) {
    ;Example: kill process or write a shutdown log
    if IsSet(tricepsPID) {
        try ProcessClose(tricepsPID)
    }
}

^q:: ExitApp ; Ctrl+Q to exit

sendVirtualKey(hwnd, vkCode) {
    WM_KEYDOWN := 0x0100
    WM_KEYUP := 0x0101
    PostMessage(WM_KEYDOWN, vkCode, 0, , hwnd)
    Sleep 50
    PostMessage(WM_KEYUP, vkCode, 0, , hwnd)
}

sendAltCombo(hwnd, vkCode) {
    WM_SYSKEYDOWN := 0x0104
    WM_SYSKEYUP := 0x0105
    lParam := 0x20000000  ; Alt flag

    PostMessage(WM_SYSKEYDOWN, vkCode, lParam, , hwnd)
    Sleep 50
    PostMessage(WM_SYSKEYUP, vkCode, lParam, , hwnd)
}

printPalletLabel(palletId) {
    pallet := lookupPallet(palletId)

    if pallet.error {
        MsgBox "Error looking up pallet: " pallet.message
        return
    }
    ControlSend("{F3}", pallet.field.control, pallet.field.hwnd)
}

lookupPallet(palletId) {
    form := 'TW1621'
    palletField := findCtrl("ThunderRT6TextBox30", 5000, form)
    if !palletField.found {
        return {
            error: true,
            message: "Pallet field not found."
        }
    }
    ControlSetText(palletId, palletField.control, palletField.hwnd)
    ControlSend("{Enter}", palletField.control, palletField.hwnd)
    return {
        error: false,
        message: "Pallet found.",
        field: palletField
    }
}

showPrintGui() {
    global

    myGui := Gui(" +Resize", "Pallet Label Printer")
    myGui.SetFont("s10", "Segoe UI")

    myGui.AddText("w100", "Pallet ID:")
    palletInput := myGui.AddEdit("vPalletID w200")

    printButton := myGui.AddButton("default w100", "Print")
    statusText := myGui.AddText("w300 cGray", "")  ; Status bar / feedback

    cb(*) {
        palletId := palletInput.Text
        if palletId = "" {
            statusText.Text := "Please enter a Pallet ID."
            return
        }
        statusText.Text := "Printing..."
    }
    printButton.OnEvent("Click", cb)
    myGui.Show("AutoSize Center")
}
