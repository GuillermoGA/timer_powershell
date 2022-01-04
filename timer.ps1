# If you can't run this script tipe in PowerShell
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Now you should be able to run this script


# Enable UI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# Create Form
$Form_Timer                      = New-Object system.Windows.Forms.Form
$Form_Timer.ClientSize           = New-Object System.Drawing.Point(400,100)
$Form_Timer.text                 = "Temporizador"
$Form_Timer.TopMost              = $false
$Form_Timer.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("#9b9b9b")

# Create button Start
$Btn_Start                       = New-Object system.Windows.Forms.Button
$Btn_Start.text                  = "START"
$Btn_Start.width                 = 160
$Btn_Start.height                = 30
$Btn_Start.location              = New-Object System.Drawing.Point(30,10)
$Btn_Start.Font                  = New-Object System.Drawing.Font('Consolas',10)
$Btn_Start.BackColor             = [System.Drawing.ColorTranslator]::FromHtml("#89e224")

# Create button stop
$Btn_Stop                        = New-Object system.Windows.Forms.Button
$Btn_Stop.text                   = "STOP"
$Btn_Stop.width                  = 160
$Btn_Stop.height                 = 30
$Btn_Stop.location               = New-Object System.Drawing.Point(210,10)
$Btn_Stop.Font                   = New-Object System.Drawing.Font('Consolas',10)
$Btn_Stop.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("#e2112d")

# Create label to show time
$Lbl_TimerDisplay                = New-Object System.Windows.Forms.TextBox
$Lbl_TimerDisplay.text           = "01 : 30 : 00"
$Lbl_TimerDisplay.AutoSize       = $false
$Lbl_TimerDisplay.width          = 340
$Lbl_TimerDisplay.height         = 25
$Lbl_TimerDisplay.Anchor         = 'left'
$Lbl_TimerDisplay.location       = New-Object System.Drawing.Point(30,55)
$Lbl_TimerDisplay.Font           = New-Object System.Drawing.Font('Consolas',10)
$Lbl_TimerDisplay.BackColor      = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

# Add buttons and label to form
$Form_Timer.controls.AddRange(@($Btn_Start,$Btn_Stop,$Lbl_TimerDisplay))

# Add events to buttons
$Btn_Start.Add_Click({ Set-StartTime })
$Btn_Stop.Add_Click({ Stop-Timer })


# Create timer object
$timer1 = New-Object 'System.Windows.Forms.Timer'

# Build function that will be executed each time, timer triggers
$timer1_Tick={
    Write-Host $Global:Time
    $Global:Time -= 1

    $Hours = [int][Math]::Truncate($Global:Time/3600)
    $Mins = [int][Math]::Truncate(($Global:Time/60)%60)
    $Secs = [int][Math]::Truncate($Global:Time%60)
    Write-Host "$Hours : $Mins : $Secs"

    $Lbl_TimerDisplay.Text = "{0:D2} : {1:D2} : {2:D2}" -f $Hours, $Mins, $Secs

    if ($Global:Time -le 0) {
        Stop-Computer -Force
    }
}

# Set 1 sec / 1000 ms interval
$timer1.Interval = 1000

# Add function to tick event
$timer1.add_Tick($timer1_Tick)

$Global:Time = 0

# Create function that will be trigger on start button click
function Set-StartTime {
    $HH, $MM, $SS =  $Lbl_TimerDisplay.Text.Split(":")
    $Global:Time = [int]$HH*3600 + [int]$MM*60 + [int]$SS
    $timer1.Enabled = $True
}

# Create function that will be trigger on stop button click
function Stop-Timer {
    $timer1.Enabled = $False
}


Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

# Function to hide original PowerShell console
function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    # 0 means hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

$Form_Timer.Add_Shown({
    $Form_Timer.Activate()
    Hide-Console
})

[void]$Form_Timer.ShowDialog()