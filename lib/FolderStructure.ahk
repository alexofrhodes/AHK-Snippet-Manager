; initial idea in AHK V1: https://www.autohotkey.com/board/topic/13239-nested-and-sorted-folder-structure-for-menus/
; creates a menu with submenus of a folder structure in recursive way
; adds icons to all menu entries: https://www.autohotkey.com/boards/viewtopic.php?t=77201
; creates a list of all file paths within the folders, using `n between entries
; - menuObj: the menu object to be filled
; - FolderPath: path to the folder that should be added to the menu
; - HandlerFunctionName: the name of the function to be called when the menu entry is selected
; returns a list of all file paths within the folder, separated by `n

; @TODO Save to new folder

AddFolderStructureToMenu(menuObj, FolderPath, extensions, HandlerFunctionName) {
	Local i := 0, FolderList := "", FileList := "", PathList := "", iconIndex := 0

    ; Add button to save selection
    menuObj.Add("Save Selection", (*) => SaveSelection(FolderPath))
    menuObj.SetIcon("Save Selection", "icons\clip.ico")
	
    menuObj.Add("Save to New Folder", (*) => SaveSelectionToNewFolder(FolderPath))
    menuObj.SetIcon("Save to New Folder", "icons\clipNew.ico")

	
    ; Add button to open folder
    menuObj.Add("Open Folder", (*) => OpenFolder(FolderPath))
    menuObj.SetIcon("Open Folder", "icons\openfolder.ico")

	; menuObj.Add("Cancel", DoNothing)
	; menuObj.SetIcon("Cancel","icons\cancel.ico")

	menuObj.add
	
	; 1) create folder menu entries
	Loop Files FolderPath "\*", "D"
		FolderList .= (FolderList == "") ? A_LoopFileName : "`n" . A_LoopFileName

	FolderList := Sort(FolderList)

	Loop Parse FolderList, "`n" {
		subMenuObj := Menu(), i++
		PathList .= AddFolderStructureToMenu(subMenuObj, FolderPath . "\" . A_LoopField, extensions, HandlerFunctionName)
		menuObj.Add(A_LoopField, subMenuObj)
		hIcon := DllCall("Shell32\ExtractAssociatedIcon", "Ptr", 0, "Str", FolderPath . "\" . A_LoopField, "ShortP", &iconIndex, "Ptr")
		menuObj.SetIcon(A_LoopField, "HICON:" . hIcon)
	}

	
	menuObj.add

	; 2) create file menu entries
	Loop Files, FolderPath . "\*", "F"
	{
		if HasVal(extensions, A_LoopFileExt) || (extensions == "*")
		{
			i++
			filePath := FolderPath . "\" . A_LoopFileName
			PathList .= filePath . "`n"
			menuObj.Add(A_LoopFileName, %HandlerFunctionName%.Bind(filePath))
			hIcon := DllCall("Shell32\ExtractAssociatedIcon", "Ptr", 0, "Str", filePath, "ShortP", &iconIndex, "Ptr")
			menuObj.SetIcon(A_LoopFileName, "HICON:" . hIcon)
		}
	}

	; 3) if folder has no containing files or folders, create disabled submenu "(Empty)"
	if (i == 0) {
		handlerFunction := %HandlerFunctionName%.Bind("")
		menuObj.Add("(Empty)", (*) => handlerFunction())
		menuObj.Disable("(Empty)")
	}

	return PathList
}
	

OpenFolder(folderPath, *){
	run folderPath
}

SaveSelection(folderPath, *) {
    tmp := A_Clipboard
    A_Clipboard := ""
    Send("{Ctrl down}c{Ctrl up}")
    Sleep(100)
    text := "`n" A_Clipboard

    ; Prompt user for filename
    ib := InputBox("(filename.extension)", "Save As", , A_Now ".txt")

    ; Exit if canceled or empty filename
    if ib.Result != "Ok" || ib.Value = ""
        return

    ; Save the file
    FileAppend(text, folderPath "\" ib.Value)

    ; Restore clipboard content
    A_Clipboard := tmp
}

SaveSelectionToNewFolder(folderPath,  *) {
    ; Prompt user for new folder name
    ib := InputBox("Folder Selection", "Enter the new folder name:", , "")

    ; Exit if canceled or empty folder name
    if ib.Result != "Ok" || ib.Value = ""
        return

    NewFolderPath := folderPath "\" ib.Value

    ; Create folder if it doesn't exist
    if !DirExist(NewFolderPath)
        DirCreate(NewFolderPath)

    ; Exit if folder creation failed
    if !DirExist(NewFolderPath)
        return

    ; Prompt user for filename
    ib := InputBox("(filename.extension)", "Save As", , A_Now ".txt")

    ; Exit if canceled or empty filename
    if ib.Result != "Ok" || ib.Value = ""
        return

    ; Copy selected text to clipboard
    tmp := A_Clipboard
    A_Clipboard := ""
    Send("^c") ; Simulate Ctrl+C to copy
    Sleep(100)
    text := "`n" A_Clipboard

    ; Save file in the new folder
    FileAppend(text, NewFolderPath "\" ib.Value)

    ; Restore clipboard content
    A_Clipboard := tmp
}



HasVal(haystack, needle) {
    if !(IsObject(haystack)) || (haystack.Length = 0)
        return 0
    for index, value in haystack
        if (value = needle)
            return index
    return 0
}

DoNothing(*){
	return
}
