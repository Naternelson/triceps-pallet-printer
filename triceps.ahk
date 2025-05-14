#Requires AutoHotkey v2.0

#Include ./log.ahk
#Include ./control.ahk

printPalletTag(palletId) {
    if (!ControlExists("ThunderRT6TextBox30", "ahk_class ThunderRT6MDIForm")) {
        MsgBox("Looks like you don't have the Pallet Corrections Form up.`nOpen it in Triceps:`n`tMain Menu -> B -> C")
        throw Error("Triceps is Not Ready")
    }
    WinActivate("ahk_class ThunderRT6MDIForm")
    ControlSend(palletId "{Enter}", "ThunderRT6TextBox30", "ahk_class ThunderRT6MDIForm")
    Sleep 100
    ControlSend("{F3}", "ThunderRT6TextBox30", "ahk_class ThunderRT6MDIForm")
}

closeForm() {
    WinActivate("ahk_class ThunderRT6MDIForm")
    ControlSend("{F1}", "ThunderRT6TextBox30", "ahk_class ThunderRT6MDIForm")
}

ControlExists(control, winTitle) {
    try {
        ControlGetHwnd(control, winTitle)
        return true
    } catch {
        return false
    }
}

printArr(palletIds := [], log := true, saveDb := true, skip := false) {
    global controlState
    showControlPanel()
    i := 1

    while (i <= palletIds.Length) {
        p := palletIds[i]
        loop {
            if (controlState = "pause") {
                Sleep 100
                continue
            } else if (controlState = "quit") {
                logMessage("Printing aborted by user.")
                break 2
            } else if (controlState = "step") {
                controlState := "pause"
                break
            } else if (controlState = "back") {
                i := Max(i - 1, 1)
                logMessage("Back -")
                controlState := "pause"
                break
            } else if (controlState = "run") {
                break
            }
            Sleep 50
        }

        if (log)
            logMessage(Format("{:0.0f}", p))
        printPalletTag(p)
        Sleep 500

        ; if (saveDb) {
        ;     addPalletId(p)
        ; }

        i++
    }

    ; if (saveDb) {
    ;     save()
    ; }

    hideControlPanel()
}
