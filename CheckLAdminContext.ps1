# For: Cobalt Stike Admin Checks 
# @Killswitch-GUI
# Ref: http://stackoverflow.com/questions/18674801/administrative-privileges
# http://www.fixitscripts.com/problems/script-to-detect-current-user-and-determine-if-that-user-is-a-local-admin-or-not

function Invoke-LocalAdminCheck { 
<#
        .SYNOPSIS
        Checks to see if current user is the local Admin group and returns a string to console for Cobalt strike to grab. 
        This Allows me to automat Bypass UAC and Getsystem

        .PARAMETER Initial
        Decalre if the commmand was run from the CS terminal or on intial load of agent.
        
        .PARAMETER LogFilePath
        Specifies the path to the log file.

        .PARAMETER LogLevel
        Specifies the log level (e.g., Info, Warning, Error).

        .PARAMETER LogFormat
        Specifies the log format (e.g., Text, JSON).
    #>
    [cmdletbinding()]
    param(
        [Parameter(Position=0,ValueFromPipeline=$true)]
        [String[]]
        $Initial,

        [Parameter(Position=1)]
        [String]
        $LogFilePath = "C:\Logs\LocalAdminCheck.log",

        [Parameter(Position=2)]
        [String]
        $LogLevel = "Info",

        [Parameter(Position=3)]
        [String]
        $LogFormat = "Text"
    )
    process {
        Try {
            $User = [Security.Principal.WindowsIdentity]::GetCurrent()
            $IsAdmin = (New-Object Security.Principal.WindowsPrincipal $User).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
            $SecondCheck = Get-SecondCheck -LogFilePath $LogFilePath -LogLevel $LogLevel -LogFormat $LogFormat
            If ($IsAdmin -or $SecondCheck)
                    {
                    If ($Initial)
                        {
                        write-output "[!] Agent-Started-in-LocalAdmin-Context"
                        }
                    Else
                        {
                         write-output "[!] Currently-in-LocalAdmin-Context"
                        }
                    }
             Else
                    {
                    write-output "[!] Current-User-Not-LocalAdmin-Context"
                    }
            Log-Message -Message "LocalAdminCheck completed successfully." -LogFilePath $LogFilePath -LogLevel $LogLevel -LogFormat $LogFormat
        }
        Catch {
            write-output "Error occurred during LocalAdminCheck."
            Log-Message -Message "Error occurred during LocalAdminCheck: $_" -LogFilePath $LogFilePath -LogLevel "Error" -LogFormat $LogFormat
        }
    }
}

function Get-SecondCheck { 
<#
        .SYNOPSIS
        Checks to see if current user is the local Admin group and returns a string to console for Cobalt strike to grab. 
        This Allows me to automat Bypass UAC and Getsystem

        .PARAMETER Initial
        Decalre if the commmand was run from the CS terminal or on intial load of agent.
        
        .PARAMETER LogFilePath
        Specifies the path to the log file.

        .PARAMETER LogLevel
        Specifies the log level (e.g., Info, Warning, Error).

        .PARAMETER LogFormat
        Specifies the log format (e.g., Text, JSON).
    #>
    [cmdletbinding()]
    param(
        [Parameter(Position=0)]
        [String]
        $LogFilePath = "C:\Logs\LocalAdminCheck.log",

        [Parameter(Position=1)]
        [String]
        $LogLevel = "Info",

        [Parameter(Position=2)]
        [String]
        $LogFormat = "Text"
    )
    process {
        Try {
            $admUsers = @()
            $curUser = $env:username
            $strComputer = "."
            $computer = [ADSI]("WinNT://" + $strComputer + ",computer")
            $Group = $computer.psbase.children.find("Administrators")
            $members= $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
            ForEach($user in $members) {
                $admUsers += $user
                }
            if(($admUsers -contains $curUser) -eq $True) {
                Log-Message -Message "SecondCheck: User $curUser is in Administrators group." -LogFilePath $LogFilePath -LogLevel $LogLevel -LogFormat $LogFormat
                return $true
            }
            else {
                Log-Message -Message "SecondCheck: User $curUser is not in Administrators group." -LogFilePath $LogFilePath -LogLevel $LogLevel -LogFormat $LogFormat
                return $false
            }
        }
        Catch {
            write-output "Script Check Failed"
            Log-Message -Message "Error occurred during SecondCheck: $_" -LogFilePath $LogFilePath -LogLevel "Error" -LogFormat $LogFormat
        }
    }
}

function Log-Message {
    param(
        [string]$Message,
        [string]$LogFilePath,
        [string]$LogLevel,
        [string]$LogFormat
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$LogLevel] $Message"

    if ($LogFormat -eq "JSON") {
        $logEntry = @{
            Timestamp = $timestamp
            Level = $LogLevel
            Message = $Message
        } | ConvertTo-Json
    }

    Add-Content -Path $LogFilePath -Value $logEntry
}
