# If you can't run this script tipe in PowerShell
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Now you should be able to run this script

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form_Timer                      = New-Object system.Windows.Forms.Form
$Form_Timer.ClientSize           = New-Object System.Drawing.Point(400,100)
$Form_Timer.text                 = "Temporizador"
$Form_Timer.TopMost              = $false
$Form_Timer.BackColor            = [System.Drawing.ColorTranslator]::FromHtml("#9b9b9b")

$Btn_Start                       = New-Object system.Windows.Forms.Button
$Btn_Start.text                  = "START"
$Btn_Start.width                 = 160
$Btn_Start.height                = 30
$Btn_Start.location              = New-Object System.Drawing.Point(30,10)
$Btn_Start.Font                  = New-Object System.Drawing.Font('Consolas',10)
$Btn_Start.BackColor             = [System.Drawing.ColorTranslator]::FromHtml("#89e224")

$Btn_Stop                        = New-Object system.Windows.Forms.Button
$Btn_Stop.text                   = "STOP"
$Btn_Stop.width                  = 160
$Btn_Stop.height                 = 30
$Btn_Stop.location               = New-Object System.Drawing.Point(210,10)
$Btn_Stop.Font                   = New-Object System.Drawing.Font('Consolas',10)
$Btn_Stop.BackColor              = [System.Drawing.ColorTranslator]::FromHtml("#e2112d")

$Lbl_TimerDisplay                = New-Object System.Windows.Forms.TextBox
$Lbl_TimerDisplay.text           = "01 : 30 : 00"
$Lbl_TimerDisplay.AutoSize       = $false
$Lbl_TimerDisplay.width          = 340
$Lbl_TimerDisplay.height         = 25
$Lbl_TimerDisplay.Anchor         = 'left'
$Lbl_TimerDisplay.location       = New-Object System.Drawing.Point(30,55)
$Lbl_TimerDisplay.Font           = New-Object System.Drawing.Font('Consolas',10)
$Lbl_TimerDisplay.BackColor      = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")

$Form_Timer.controls.AddRange(@($Btn_Start,$Btn_Stop,$Lbl_TimerDisplay))

$Btn_Start.Add_Click({ Set-StartTime })
$Btn_Stop.Add_Click({ Stop-Timer })

$timer1 = New-Object 'System.Windows.Forms.Timer'

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

$timer1.Interval = 1000 # 1 Sec
$timer1.add_Tick($timer1_Tick)

$Global:Time = 0

#Write your logic code here
function Set-StartTime {
    $HH, $MM, $SS =  $Lbl_TimerDisplay.Text.Split(":")
    $Global:Time = [int]$HH*3600 + [int]$MM*60 + [int]$SS
    $timer1.Enabled = $True
}

function Stop-Timer {
    $timer1.Enabled = $False
}


Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

function Hide-Console
{
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

$Form_Timer.Add_Shown({
    $Form_Timer.Activate()
    Hide-Console
})

[void]$Form_Timer.ShowDialog()