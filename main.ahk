#Requires AutoHotkey v2.0
#Include ./log.ahk
#Include ./excel.ahk
#Include ./triceps.ahk
#Include ./control.ahk

global filepath := A_ScriptDir "\AutoReplenishments.xlsx"

main()

main() {
    xl := ""
    wb := ""
    internalOpen := false

    try {
        result := MsgBox("Auto Print Pallet Tags::`n`nPlease ensure the Auto_Replenishment file is up to date with the tags you want to print and that Triceps is open to the Pallet Corrections Form", "Auto Print Pallet Tags", "OKCancel")
        if (result = "Cancel")
            return

        show()
        logMessage("Logging Que")
        logMessage("Opening Workbook")

        x := openXL(filepath)
        wb := x[1], xl := x[2], internalOpen := x[3]

        logMessage("Extracting Print Que...")
        list := extractList(wb)

        result := MsgBox("Looks like you've got " list.Length " tags to print.`n`nAre you sure you want to print?", "OKCancel")
        if (result = "Cancel")
            return

        logMessage("Begin Printing...")
        printArr(list)

        logMessage("Printing Complete")
        result := MsgBox("Printing Successful`n`nWould you like to submit the print jobs?", "OKCancel")
        if (result = "OK")
            closeForm()

    } catch as e {
        logMessage("ERROR: " e.Message)
        MsgBox "ERROR:`n`nThere was an error, check the debug screen" 
    } finally {
        if (internalOpen) {
            try {
                logMessage("Closing workbook and Excel...")
                wb.Close(false)
                xl.Quit()
            } catch as  e {
                logMessage("ERROR during cleanup: " e.Message)
            }
        } else {
            logMessage("Excel was already open — leaving untouched.")
        }
        wb := ""
        xl := ""
        hideControlPanel()
        logMessage("Complete")
    }
}
