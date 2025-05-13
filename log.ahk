#Requires AutoHotkey v2.0

global currentCounter := 0
global logGUI := Gui("+Resize +MinimizeBox +AlwaysOnTop", "Debug")
global logBox := logGUI.Add("ListView", "vLogView w300 h600", ["Time", "Message"])
logBox.ModifyCol(1, 80)
logBox.ModifyCol(2, 300)
logGUI.SetFont("s10")

logMessage(message) {
    global logBox
    time := FormatTime(, "HH:mm:ss")
    rowCount := logBox.GetCount()
    logBox.Add(, time, message)
    logBox.Modify(rowCount, "Vis")
}

resizeGUI(*) {
    logGUI.GetClientPos(,, &ClientWidth, &ClientHeight)
    logBox.Move(0, 0, ClientWidth, ClientHeight)
}

show() {
    resizeGUI()
    logGUI.OnEvent("Size", resizeGUI)
    logGUI.Show("x" (A_ScreenWidth - 410) " y0 w300 h" A_ScreenHeight)
}

loggerHide() {
    logGUI.Hide()
}

loggerQuit() {
    logGUI.Destroy()
}
