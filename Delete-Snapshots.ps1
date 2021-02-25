Write-Output "$HR Delete Snapshots in VCENTER

##########################################################################################
#
#                  *Delete Snapshots in VCENTER* 
#                                                                                
# Created by Cesar Duran (Jedi Master)                                                                                        
# Version:1.0                                                                                                                                        
#                                                                                                                                                                                                                                                                                                                                                                                                                            
#                                                                                                                                                                                                          
###########################################################################################

$HR"

# CDI Snapshot Cleaner Script

# Line delimiter
$HR = "`n{0}`n" -f ('='*20)


########################################
Write-Output "$HR HELLO VMs $HR"
# Ping Servers, Ping Results

$Computers = Get-Content "C:\temp\snapshots.txt"
foreach ($computer in $computers)
{
    $Destination = "C:\temp\Export\Start\Pingup.log"
    $Destination2 = "C:\temp\Export\Start\PingDown.log"
    if (Test-Connection $computer -Count 1 -ea 0 -Quiet)
    { 
        Write-Host "$computer Is Up" -ForegroundColor Green
        $computer | out-file -Append $Destination -ErrorAction SilentlyContinue 
    } 
    else 
    { 
        Write-Host "$computer Is Down" -ForegroundColor Red
        $computer | out-file -Append $Destination2 -ErrorAction SilentlyContinue  
    }
  
} # end foreach Ping



###########################################
Write-Output "$HR HOLA VMWARE VCENTERS $HR"
# Connect-VIServer

Install-Module -Name VMware.PowerCLI -verbose -force
Import-Module -Name VMware.PowerCLI -verbose -force
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer MN-HOST-VCA-1


######################################
Write-Output "$HR 5 SECOND PAUSE $HR"
# 90sec Pause

$Timeout = 5
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 5 seconds



###############################################
Write-Output "$HR VMWARE VMs - BYE SNAPSHOTS $HR"
# This deletes snapshots in VMware

foreach($vmName in (Get-Content -Path "C:\temp\snapshots.txt"))
{

    $vm = Get-VM -Name $vmName

    Write-Host "Removing snapshot for $vmName"
    Get-Snapshot -VM $vm | Remove-Snapshot -Confirm:$false
    

    

} # End of VM Snapshot Deletion



###################################################
Write-Output "$HR HELLO DARKNESS MY OLD FRIEND $HR"
# Ping Servers, Ping Results

$Computers = Get-Content "C:\temp\snapshotss.txt"
foreach ($computer in $computers)
{
    $Destination = "C:\temp\Export\End\Pingup.log"
    $Destination2 = "C:\temp\Export\End\PingDown.log"
    if (Test-Connection $computer -Count 1 -ea 0 -Quiet)
    { 
        Write-Host "$computer Is Up" -ForegroundColor Green
        $computer | out-file -Append $Destination -ErrorAction SilentlyContinue 
    } 
    else 
    { 
        Write-Host "$computer Is Down" -ForegroundColor Red
        $computer | out-file -Append $Destination2 -ErrorAction SilentlyContinue  
    }
  
} # end foreach Ping



###################################################
Write-Output "$HR THE END, HAVE A NICE DAY!!!

##########################################################################################
#
#              *POWERFUL YOU HAVE BECOME, THE DARK SIDE I SENSE IN YOU - YODA*
#
#                                                                                                                                                                                                                                                                                                                                                                                                                              
#                                                                                                                                                                                                          
###########################################################################################

$HR"