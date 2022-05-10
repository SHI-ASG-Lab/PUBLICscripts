param ([Parameter(Mandatory = $true)]
[ValidateNotNullOrEmpty()]
[string]$enrollment_token)

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}

try
{
   #Make directory for sftd token and create token file
   mkdir C:\windows\system32\config\systemprofile\AppData\Local\scaleft
   echo "${enrollment_token}" > C:\windows\system32\config\systemprofile\AppData\Local\scaleft\enrollment.token
   
   #Make directory for scripts and download startup script
   mkdir C:\Users\shi\scaleft-source
   Invoke-WebRequest -Uri https://github.com/SHI-ASG-Lab/PUBLICscripts/blob/621a5e089910616f510f5081559ca3d6b1ba6845/oktaasa/Azure/ExtIP_allin1.cmd -OutFile C:\Users\shi\scaleft-source\ExtIP_allin1.cmd
   
   #Schedule task to get external IP for Okta
   $action = New-ScheduledTaskAction -Execute 'C:\Users\shi\scaleft-source\ExtIP_allin1.cmd'
   $trigger = New-ScheduledTaskTrigger -AtStartup
   $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
   Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskPath "TASK-FOLDER" -TaskName "GetExtIP" -Description "Gets external IP for Okta ASA"
   
   #download okta scripts and install Okta ASA
   cd C:\Users\shi\scaleft-source
   git clone https://github.com/okta-server-asa/scaleft-powershell.git
   Import-Module -Name C:\Users\shi\scaleft-source\scaleft-powershell\ScaleFT.PS\Install
   Install-ScaleFTServerTools
   
   #Run GetExtIP script for first time without reboot
   C:\Users\shi\scaleft-source\ExtIP_allin1.cmd
   #Restart sftd service
   Restart-Service -Name scaleft-server-tools
}

catch
{
    Write-Error $_.Exception
    throw $_.Exception
}

finally
{
    Write-Host "Did stuff..."
    $LASTEXITCODE
}
