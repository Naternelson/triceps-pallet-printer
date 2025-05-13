#Requires AutoHotkey v2.0

openXL(filepath) {
    MsgBox(filepath)
    xl := ComObject("Excel.Application")
    try {
        for wb in xl.Workbooks {
            if (wb.FullName = filepath) {
                return [wb, xl, false]
            }
        }
    } catch as e {
        ; 
    }

    wb := xl.Workbooks.Open(filepath)
    xl.Visible := true
    return [wb, xl, true]
}

extractList(wb) {
    sheet := wb.Sheets(1)
    colData := []
    row := 2
    while (true) {
        cell := sheet.Cells(row, 1).Value
        if (cell = "" || cell = 0)
            break
        colData.Push(cell)
        row++
    }
    return colData
}
