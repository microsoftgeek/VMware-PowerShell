#CSV file of the VM's to have their snapshots removed
$csvfile = "c:\temp\Snapshots.csv"

#Script's log file location
$logfile = "c:\temp\log.txt"

#This is the CDI Vcenter server
$vcenter = "MN-HOST-VCA-1"



#Read the CSV File into a variable
$vms = Import-Csv $csvfile

#Get the user's credentials for vCenter (assumes the user has the same user/pass for all vCenters)
$creds = Get-Credential

 
#Get the current date/time and place entry into log that a new session has started
$timestamp = Get-Date

Add-Content $logfile "#####################################################"

Add-Content $logfile "$timestamp New Session Started"

 
#Read the vCenters contained in the CSV and dedupe them
$vcenters = $vms | select -ExpandProperty vCenter -Unique

 

#Log into each vCenter included in the CSV file (assumes the user has the same user/pass for all vCenters)
foreach ($vcenter in $vcenters)


#Get the current date/time and place entry into log that the script is connecting to each vCenter
{

$timestamp = Get-Date

$message = "$timestamp Connecting to $vcenter"

Write-Host $message

Add-Content $logfile  $message

 
#Connect to the vCenter using the credentials provided at first run
Connect-VIServer $vcenter -Credential $creds
 

Write-Host `n

}


#Remove snapshots for each VM in the CSV
foreach ($vm in $vms)

{

#Load the virtual machine object
$vm = get-VM $vm.VM

#Get the number of snapshots for the VM
$snapshotcount = $vm | Get-Snapshot | measure

#This line makes it easier to insert the number of snapshots into the log file
$snapshotcount = $snapshotcount.Count

 
#Get the current date/time and place entry into log that the script is going to remove x number of shapshots for the VM
$timestamp = Get-Date

$message = "$timestamp Removing $snapshotcount Snapshot(s) for VM $vm"

Write-Host $message

Add-Content $logfile  $message

 
#Removes the VM's snapshot(s) and writes any output to the log file
$vm | Get-Snapshot | Remove-Snapshot -confirm:$false | Out-File $logfile -Append

 
#Get the current date/time and place entry into log that the script has finished removing the VM's snapshot(s)
$timestamp = Get-Date

Add-Content $logfile "$timestamp Snapshots removed for $vm"

}
