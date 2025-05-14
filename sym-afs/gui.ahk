#Requires AutoHotkey v2.0

class MainWindow {
    static instance := 0
    static hwnd := 0
    width:= 600
    height:= 400
    options:= "+AutoSize +Resize"
    __New() {
        if (MainWindow.instance) {
            throw Error("Only one instance of MainWindow is allowed.")
        }
        MainWindow.instance := this
        MainWindow.hwnd := WinExist("+Resize", "Auto Print Pallet Tags")
        if !MainWindow.hwnd {
            MainWindow.hwnd := Gui(this.options, "Auto Print Pallet Tags")

        }
    }
    show() {
        if !this.hwnd {
            this.hwnd := Gui(this.options, "Auto Print Pallet Tags")
        }
        this.hwnd.Show(this.options)
    }
    static getInstance() {
        return this.instance
    }

    static getHwnd() {
        return this.hwnd
    }
}

Mw := MainWindow()