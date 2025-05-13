; Ultra-Precise Keypress Script - Maximum Timing Accuracy
#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
#KeyHistory 0
Process, Priority,, Realtime  ; Highest possible process priority
Thread, Priority, 100
SetBatchLines, -1
SetKeyDelay, -1, -1, -1  ; Maximum precision key delay
SendMode, Input  ; Fastest send mode
SetDefaultMouseSpeed, 0
#MaxThreadsPerHotkey 2

; Global precision configuration
global isActive := false
global holdTime := 344.44
global isHolding := false
global timingDiagnostics := false

; Advanced timing variables
global freq := 0
global systemOverhead := 0
global targetTime := holdTime
global adjustment := 0
global timingSamples := []
global lastCalibrationTime := 0

; Precision constants
global calibrationIterations := 50  ; High number of iterations for extreme precision
global outlierThreshold := 0.2      ; Extremely strict outlier filtering
global movingAvgWindow := 15        ; Larger window for more stable averaging
global calibrationInterval := 120000 ; Recalibrate every 2 minutes
global spinlockThreshold := 0.005   ; Ultra-short duration threshold
global adaptiveOverhead := true     ; Enable dynamic overhead adjustment

; Initialize performance counter and system
InitializeScript() {
    ; Request highest timer resolution
    DllCall("Winmm\timeBeginPeriod", "UInt", 1)
    
    ; Initialize performance counter frequency
    DllCall("QueryPerformanceFrequency", "Int64*", freq)
    
    ; Set processor affinity to first core for consistency
    SetCPUAffinity()
    
    ; Perform initial precision calibration
    ShowPopup("Performing ultra-precise calibration...")
    systemOverhead := CalibrateOverhead()
    ShowPopup("Calibration complete. Overhead: " . Round(systemOverhead, 4) . "ms")
    
    ; Record calibration time
    DllCall("QueryPerformanceCounter", "Int64*", lastCalibrationTime)
    
    ; Intensive warmup routine
    PerformWarmup()
}

; Lock to first processor core for timing consistency
SetCPUAffinity() {
    ProcessID := DllCall("GetCurrentProcessId")
    hProcess := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", false, "UInt", ProcessID)
    DllCall("SetProcessAffinityMask", "Ptr", hProcess, "Ptr", 1)
    DllCall("CloseHandle", "Ptr", hProcess)
}

; Ultra-precise overhead calibration
CalibrateOverhead() {
    iterations := calibrationIterations
    validSamples := []
    
    ; Ensure frequency is initialized
    if (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", freq)
    
    ; First pass - collect raw samples
    Loop, %iterations% {
        DllCall("QueryPerformanceCounter", "Int64*", startTime)
        SendInput, {Numpad0 down}{Numpad0 up}
        DllCall("QueryPerformanceCounter", "Int64*", endTime)
        overhead := (endTime - startTime) * 1000 / freq
        validSamples.Push(overhead)
        Sleep, 10
    }
    
    ; Calculate median for robust reference
    tempArray := validSamples.Clone()
    Sort(tempArray)
    median := tempArray[Floor(tempArray.Length()/2)]
    
    ; Advanced statistical filtering
    filteredSamples := []
    for i, sample in validSamples {
        ; Extremely strict outlier rejection
        if (Abs(sample - median) < outlierThreshold)
            filteredSamples.Push(sample)
    }
    
    ; Fallback to robust estimation if too many samples filtered
    if (filteredSamples.Length() < iterations * 0.5) {
        ; Use trimmed mean approach
        Sort(validSamples)
        trimCount := Floor(validSamples.Length() * 0.2)
        trimmedSamples := []
        
        for i, sample in validSamples {
            if (i > trimCount && i <= validSamples.Length() - trimCount)
                trimmedSamples.Push(sample)
        }
        
        filteredSamples := trimmedSamples
    }
    
    ; Calculate average with extreme precision
    totalOverhead := 0
    for i, overhead in filteredSamples
        totalOverhead += overhead
    
    ; Add minute safety margin and apply dynamic scaling
    calculatedOverhead := filteredSamples.Length() > 0 
        ? totalOverhead / filteredSamples.Length() 
        : median
    
    return calculatedOverhead + 0.02
}

; Robust sorting for statistical calculations
Sort(arr) {
    n := arr.Length()
    
    Loop, % n - 1 {
        swapped := false
        
        Loop, % n - A_Index {
            if (arr[A_Index] > arr[A_Index + 1]) {
                temp := arr[A_Index]
                arr[A_Index] := arr[A_Index + 1]
                arr[A_Index + 1] := temp
                swapped := true
            }
        }
        
        if (!swapped)
            break
    }
    
    return arr
}

; Ultra-Precise Spinlock Sleep
UltraPreciseSleep(ms) {
    if (!freq)
        DllCall("QueryPerformanceFrequency", "Int64*", freq)

    ticksPerMs := freq / 1000
    targetTicks := ms * ticksPerMs

    DllCall("QueryPerformanceCounter", "Int64*", startTime)
    endTime := startTime + targetTicks

    ; Pure aggressive spinlock
    Loop {
        DllCall("QueryPerformanceCounter", "Int64*", currentTime)
        if (currentTime >= endTime)
            break
    }
}

; Show diagnostic popups
ShowPopup(message) {
    MouseGetPos, xpos, ypos
    ToolTip, %message%, xpos + 20, ypos + 20
    SetTimer, RemoveToolTip, -1000
}

RemoveToolTip() {
    ToolTip
}

; Advanced statistical adjustment
CalculateAdjustment(samples) {
    if (samples.Length() < 3)
        return 0
    
    ; Deep copy of samples
    tempArray := []
    for i, sample in samples
        tempArray.Push(sample)
    
    Sort(tempArray)
    
    ; Ultra-strict outlier removal
    trimCount := Floor(tempArray.Length() * 0.15)
    if (trimCount > 0) {
        Loop, %trimCount% {
            tempArray.RemoveAt(1)
            tempArray.RemoveAt(tempArray.Length())
        }
    }
    
    ; Precise statistical calculation
    total := 0
    for i, sample in tempArray
        total += sample
    
    avgTime := total / tempArray.Length()
    
    ; Variance calculation
    varianceSum := 0
    for i, sample in tempArray
        varianceSum += (sample - avgTime) ** 2
    variance := varianceSum / tempArray.Length()
    
    ; Adaptive adjustment factor
    dynamicFactor := variance > 0.5 ? 0.3 : (variance > 0.2 ? 0.5 : 0.7)
    
    ; Calculate raw adjustment
    rawAdjustment := targetTime - avgTime
    
    ; Apply strict limits
    maxAdjustment := holdTime * 0.1  ; Limit to 10% of target time
    if (maxAdjustment < 0.05)
        maxAdjustment := 0.05
    if (maxAdjustment > 5)
        maxAdjustment := 5
    
    ; Bound the adjustment
    if (rawAdjustment > maxAdjustment)
        rawAdjustment := maxAdjustment
    else if (rawAdjustment < -maxAdjustment)
        rawAdjustment := -maxAdjustment
    
    return rawAdjustment * dynamicFactor
}

; Intensive warmup routine
PerformWarmup() {
    ShowPopup("Performing ultra-precise warmup...")
    
    Loop, 20 {
        SendInput, {Numpad0 down}
        UltraPreciseSleep(3)
        SendInput, {Numpad0 up}
        Sleep, 10
    }
    
    ShowPopup("Warmup complete")
}

; Periodic recalibration check
CheckPeriodicRecalibration() {
    DllCall("QueryPerformanceCounter", "Int64*", currentTime)
    timeSinceLastCal := (currentTime - lastCalibrationTime) * 1000 / freq
    
    ; Recalibrate if interval exceeded
    if (timeSinceLastCal > calibrationInterval) {
        if (!isHolding && !GetKeyState("e", "P")) {
            ShowPopup("Performing precision recalibration...")
            systemOverhead := CalibrateOverhead()
            lastCalibrationTime := currentTime
            ShowPopup("Recalibration complete. Overhead: " . Round(systemOverhead, 4) . "ms")
        }
    }
}

; Toggle script activation
F1::
    isActive := !isActive
    ShowPopup(isActive ? "🟢 Ultra-Precise ON" : "🔴 Ultra-Precise OFF")
    SoundBeep, % (isActive ? 800 : 500), 150
    
    if (isActive) {
        ; Reset timing data
        timingSamples := []
        adjustment := 0
        
        ; Enable hotkeys
        Hotkey, *e, CustomE, On
        Hotkey, *e Up, CustomE_Up, On
    } else {
        ; Disable hotkeys
        Hotkey, *e, Off
        Hotkey, *e Up, Off
    }
return

; Adjust hold time
^Up:: holdTime += 0.01, holdTime := Round(holdTime, 2), targetTime := holdTime, ShowPopup("Hold Time: " . holdTime . "ms")
^+Up:: holdTime += 0.1, holdTime := Round(holdTime, 2), targetTime := holdTime, ShowPopup("Hold Time: " . holdTime . "ms")
^Down:: holdTime := Max(0.01, holdTime - 0.01), holdTime := Round(holdTime, 2), targetTime := holdTime, ShowPopup("Hold Time: " . holdTime . "ms")
^+Down:: holdTime := Max(0.01, holdTime - 0.1), holdTime := Round(holdTime, 2), targetTime := holdTime, ShowPopup("Hold Time: " . holdTime . "ms")

; Custom input for hold time
^e::
    InputBox, newValue, Set Hold Time, Enter precise hold time in ms:, , 200, 130, , , , , %holdTime%
    if (!ErrorLevel && newValue is number) {
        holdTime := newValue
        targetTime := holdTime
        adjustment := 0
        timingSamples := []
        ShowPopup("Hold Time set to: " . holdTime . "ms")
    }
return

; Toggle timing diagnostics
!t:: 
    timingDiagnostics := !timingDiagnostics
    ShowPopup(timingDiagnostics ? "Timing Diagnostics ON" : "Timing Diagnostics OFF")
    timingSamples := []
return

; Main keypress function
CustomE:
    if (!isActive || isHolding)
        return

    isHolding := true
    
    ; Periodic recalibration check
    CheckPeriodicRecalibration()

    while (GetKeyState("e", "P") && isActive) {
        ; Diagnostic timing initialization
        if (timingDiagnostics && !freq)
            DllCall("QueryPerformanceFrequency", "Int64*", freq)

        ; Capture start time for diagnostics
        if (timingDiagnostics)
            DllCall("QueryPerformanceCounter", "Int64*", pressStartTime)

        ; Apply timing adjustments
        adjustedHoldTime := holdTime
        if (timingSamples.Length() >= 3)
            adjustedHoldTime += adjustment

        ; Compensate for system overhead
        adjustedHoldTime -= systemOverhead
        
        ; Ensure minimum timing
        if (adjustedHoldTime < 0.005)
            adjustedHoldTime := 0.005

        ; Send keypress
        SendInput, {e down}
        
        ; Ultra-precise sleep
        UltraPreciseSleep(adjustedHoldTime)
        
        SendInput, {e up}

        ; Timing diagnostics
        if (timingDiagnostics) {
            DllCall("QueryPerformanceCounter", "Int64*", pressEndTime)
            actualTime := (pressEndTime - pressStartTime) * 1000 / freq
            
            ; Validate and process timing
            if (actualTime > 0 && actualTime < holdTime * 3) {
                timingSamples.Push(actualTime)
                
                ; Maintain fixed sample window
                if (timingSamples.Length() > movingAvgWindow)
                    timingSamples.RemoveAt(1)
                    
                ; Calculate adjustment
                adjustment := CalculateAdjustment(timingSamples)
                
                ; Show diagnostic popup
                ShowPopup("Target: " . holdTime . "ms | Actual: " . Round(actualTime, 3) . "ms | Adj: " . Round(adjustment, 3) . "ms")
            }
        }
        
        ; Periodic auto-tuning
        if (adaptiveOverhead && Mod(A_TickCount, 2000) < 50)
            systemOverhead := CalibrateOverhead()
        
        Sleep, 1
    }

    ; Clean up
    isHolding := false
    SendInput, {e up}
return

CustomE_Up:
    isHolding := false
return

; Helper function for maximum
Max(a, b) {
    return (a > b) ? a : b
}

; Clean exit
^Esc::
    ; Clean up timer resolution
    DllCall("Winmm\timeEndPeriod", "UInt", 1)
    ExitApp
return

; Initialize the script
InitializeScript()