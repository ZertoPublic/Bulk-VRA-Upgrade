#requires -Version 5
#requires -RunAsAdministrator
<#
.SYNOPSIS
   This script will connect to a Zerto environment, specified in the variables below, and upgrade the outdated VRAs in the environment. 
.DESCRIPTION
   
.EXAMPLE
   Examples of script execution
.VERSION 
   Applicable versions of Zerto Products script has been tested on.  Unless specified, all scripts in repository will be 5.0u3 and later.  If you have tested the script on multiple
   versions of the Zerto product, specify them here.  If this script is for a specific version or previous version of a Zerto product, note that here and specify that version 
   in the script filename.  If possible, note the changes required for that specific version.  
.LEGAL
   Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without 
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability 
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages.  The entire risk arising out of the use or 
performance of the sample scripts and documentation remains with you.
----------------------
#>
#------------------------------------------------------------------------------#
# Declare variables
#------------------------------------------------------------------------------#
#Examples of variables:

##########################################################################################################################
#Any section containing a "GOES HERE" should be replaced and populated with your site information for the script to work.#  
##########################################################################################################################
# Configure the variables below
################################################

#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
$LogDataDir = "Transcript Logging Directory"
$strZVMIP = "ZVM IP"
$strZVMPort = "9669"
$strVCUser = "vCenter user account"
$strVCPw = "vCenter user password"
$taskList = @()

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

#------------------------------------------------------------------------------#
# Configure logging
#------------------------------------------------------------------------------#
$Transcript = "$LogDataDir\ZVMInstallerLog.log" 
start-transcript -path $Transcript

#------------------------------------------------------------------------------#
# Nothing to configure below this line
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
#Authenticating with Zerto APIs
#------------------------------------------------------------------------------#
$xZertoSessionURI = "https://" + $strZVMIP + ":"+$strZVMPort+"/v1/session/add"
$authInfo = ("{0}:{1}" -f $strVCUser,$strVCPw)
$authInfo = [System.Text.Encoding]::UTF8.GetBytes($authInfo)
$authInfo = [System.Convert]::ToBase64String($authInfo)
$headers = @{Authorization=("Basic {0}" -f $authInfo)}
$body = '{"AuthenticationMethod": "1"}'
$contentType = "application/json"
$xZertoSessionResponse = Invoke-WebRequest -Uri $xZertoSessionURI -Headers $headers -Method POST -Body $body -ContentType $contentType  

#------------------------------------------------------------------------------#
#Extracting x-zerto-session from the response, and adding it to the actual API
#------------------------------------------------------------------------------#
$xZertoSession = $xZertoSessionResponse.headers.get_item("x-zerto-session")
$zertoSessionHeader_json = @{"Accept"="application/json"
"x-zerto-session"=$xZertoSession}

#------------------------------------------------------------------------------#
#Get and display VRAs using API
#------------------------------------------------------------------------------#
$vpgListVRA = "https://" + $strZVMIP + ":"+$strZVMPort+"/v1/vras"
$vrasOutput = Invoke-RestMethod -Uri $vpgListVRA -TimeoutSec 100 -Headers $zertoSessionHeader_json -ContentType $contentType  
 
Write-Host Listing VRAs to upgrade:
foreach ($VRA in $vrasOutput)
{
    Write-Host $VRA.VraName
}

Write-Host

    #Upgrade VRA's
    foreach ($VRA in $vrasOutput)
    {
    
        $upgradeVraUrl = "https://" + $strZVMIP + ":"+$strZVMPort+"/v1/vras/"+$VRA.VraIdentifier+"/upgrade"
        $upgradeVra = Invoke-RestMethod -Uri $upgradeVraUrl -TimeoutSec 100 -Headers $zertoSessionHeader_json -Method POST -ContentType $contentType  
        Write-Host Upgrade started for VRA $VRA.VraName using task: $upgradeVra
        $taskList += New-Object psobject -Property @{TaskID=$upgradeVra; VRAName=$VRA.VraName}
    }

    $i=0
    While ($i -ne $vrasOutput.Count)
    {
        foreach ($Task in $taskList)
        {
            #Replacing : with . to make Task ID format correct for us in API
            $cleanTaskId = $Task.TaskID.replace(':','.')
            $currentVRA = $Task.VRAName          
            $taskListUrl = "https://" + $strZVMIP + ":"+$strZVMPort+"/v1/tasks/"+$cleanTaskId
            $taskDetails = Invoke-RestMethod -Uri $taskListUrl -TimeoutSec 100 -Headers $zertoSessionHeader_json -ContentType $contentType       
            if ($taskDetails.Status.Progress = 100)
                {
                    $i++
                    Write-Progress -Activity "Upgrading VRAs" -Status "Upgraded $i of $($vrasOutput.Count)" -percentComplete (($i / $vrasOutput.Count) * 100) 
                }                            
        }
    }
#------------------------------------------------------------------------------#
##End of script
#------------------------------------------------------------------------------#