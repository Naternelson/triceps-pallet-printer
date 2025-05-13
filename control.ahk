global controlState := "pause"
global controlGUI

showControlPanel() {
    global controlGUI, controlState

    if (IsSet(controlGUI)) {
        controlGUI.Show()
        return
    }
    
    controlGUI := Gui("+AlwaysOnTop", "Control Panel")
    controlGUI.SetFont("s9")
    controlGUI.Add("Button", "w80", "▶️ Run").OnEvent("Click", (*) => (
        controlState := "run"
    ))

    controlGUI.Add("Button", "x+10 w80", "⏸ Pause").OnEvent("Click", (*) => (
        controlState := "pause"
    ))

    controlGUI.Add("Button", "x+10 w80", "⏭ Step").OnEvent("Click", (*) => (
        controlState := "step"
    ))

    controlGUI.Add("Button", "x+10 w80", "⏮ Back").OnEvent("Click", (*) => (
        controlState := "back"
    ))

    controlGUI.Add("Button", "x+10 w80", "❌ Quit").OnEvent("Click", (*) => (
        controlState := "quit"
    ))

    controlGUI.Show("x" (A_ScreenWidth - 750) " y" (A_ScreenHeight - 120))
}

hideControlPanel() {
    global controlGUI
    if (IsSet(controlGUI)) {
        controlGUI.Hide()
    }
}
