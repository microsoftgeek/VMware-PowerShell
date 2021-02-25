#CSV file of the VM's to have their snapshots removed
$csvfile = "c:\temp\Snapshots.csv"

#Script's log file locatio
$logfile = "c:\temp\log.txt"

 

$vms = Import-Csv $csvfile #Read the CSV File into a variable

$creds = Get-Credential #Get the user's credentials for vCenter (assumes the user has the same user/pass for all vCenters)

 

$timestamp = Get-Date #Get the current date/time and place entry into log that a new session has started

Add-Content $logfile "#####################################################"

Add-Content $logfile "$timestamp New Session Started"

 

$vcenters = $vms | select -ExpandProperty vCenter -Unique #Read the vCenters contained in the CSV and dedupe them

 

foreach ($vcenter in $vcenters) #Log into each vCenter included in the CSV file (assumes the user has the same user/pass for all vCenters)

{

$timestamp = Get-Date #Get the current date/time and place entry into log that the script is connecting to each vCenter

$message = "$timestamp Connecting to $vcenter"

Write-Host $message

Add-Content $logfile  $message

 

Connect-VIServer $vcenter -Credential $creds #Connect to the vCenter using the credentials provided at first run

 

Write-Host `n

}

 

foreach ($vm in $vms) #Remove snapshots for each VM in the CSV

{

$vm = get-VM $vm.VM #Load the virtual machine object

$snapshotcount = $vm | Get-Snapshot | measure #Get the number of snapshots for the VM

$snapshotcount = $snapshotcount.Count #This line makes it easier to insert the number of snapshots into the log file

 

$timestamp = Get-Date #Get the current date/time and place entry into log that the script is going to remove x number of shapshots for the VM

$message = "$timestamp Removing $snapshotcount Snapshot(s) for VM $vm"

Write-Host $message

Add-Content $logfile  $message

 

$vm | Get-Snapshot | Remove-Snapshot -confirm:$false | Out-File $logfile -Append #Removes the VM's snapshot(s) and writes any output to the log file

 

$timestamp = Get-Date #Get the current date/time and place entry into log that the script has finished removing the VM's snapshot(s)

Add-Content $logfile "$timestamp Snapshots removed for $vm"

}
