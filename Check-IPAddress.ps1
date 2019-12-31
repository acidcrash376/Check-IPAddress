#requires -version 4
<#
.SYNOPSIS
  This script checks whether the IP of the host has changed and emails an alert if it has
.DESCRIPTION
  This script is for checking the IP of the host has changed from the last known IP and if it has, updating the file containing the IP and sending an email alert to the specified address.
  It is intended to be run from a task schedule.
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.2
  Author:         acidcrash376
  Creation Date:  27/12/2019
  Updated Date:   31/12/2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"


#----------------------------------------------------------[Declarations]----------------------------------------------------------


#Specifies the variables for the last known IP and current IP

$oldip = (Get-Content -Path ".\checkip.txt")
$currentip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content

#Sending Emails
$credfile = ".\creds.txt"
$user = "user@mail.com"
$creds=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $credFile | ConvertTo-SecureString)
$emailto = "destination@mail.com"
$emailfrom = "source@mail.com"
$subject = "IP Address Change"
$body = "The Public IP for $env:computername has changed to $currentip "
$smtpserver = "mail.server.com"
$smtpmessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
$SMTPClient.EnableSSL = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($creds.UserName, $creds.Password); 

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#Checks if you are administrator
function Test-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

#If statement for Testing if run as administrator and exiting if not
function IfTest-Administrator
{
    IF(Test-Administrator -eq $true) {
    Write-Host "You are running as Administrator"
    }
    else
    {
    Write-Host "You must run this script as administrator"
    break
    }
}

#Check if checkip.txt exits
function Test-Checkip
{
    #Check the checkip.txt file is present in the same directory
    If((Test-Path ".\checkip.txt") -eq $false){
    Write-Host ""
    Write-Host "File 'checkip.txt' not found. Check you are in the correct directory and the file exists"
    Write-Host ""
    Start-Sleep -s 1
    Write-Host "Quitting..."
    exit}
    else
    {
    Write-Host ""
    Write-Host "File 'checkip.txt' found."
    Write-Host ""
    Start-Sleep -s 1
    Write-Host "Continuing..."
    Write-Host ""
    Start-Sleep -s 1
    }
}

#Checks to see if Public IP has changed
function Test-PublicIP
{
    #Checks to see if the current IP matches the last known IP
    Write-Host "Checking if the public IP has changed..."
    Write-Host ""
    Start-Sleep -s 1
    if ($oldip -eq $currentip){
    Write-Host "The public IP has not changed from the last time the script was run. "
    }
    Else
    {
    write-host "The public IP has changed"
    $SMTPClient.Send($SMTPMessage)
    Start-Sleep -s 1
    Write-Host "Old IP: $oldip" -ForegroundColor Red
    write-host "New IP: $currentip" -ForegroundColor Green
    Start-Sleep -s 1
    Write-Host "Updating IP in text checkip.txt for next time..."
    Clear-Content -Path ".\checkip.txt"
    Add-Content -Path ".\checkip.txt" "$currentip"
    Start-Sleep -s 1
    Write-Host "Done..."
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------


IfTest-Administrator

Test-Checkip

Test-PublicIP
