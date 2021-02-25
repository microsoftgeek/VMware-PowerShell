#Script by Jose Rodriguez    
#Yeah this doesn't comply with any standards but it gets the job done.    
#This is by no means perfect. This is the first working version of the script   
#Creates VM's based on data from a CSV file  
#~I'm just an IT enthusiast with no certs, no degrees, no training, in any of this crap, but I know my around google so that's all that matters. -Jose Rodriguez~    
#2/10/2018    
  
$newVMs = import-csv "C:\pathtoCSVFile.csv"  
  
  
$server = 'MN-HOST-VCA-1'  
 
#Get Credentials if not exist  
if($cred -eq $null){  
  
$cred = Get-Credential  
  
}  
  
Connect-VIServer -Server $server -Credential $cred  
  
$a = @()  
  
foreach($vm in $newVMs){  
  
    Write-host "Deploying VM " -ForegroundColor Green -NoNewline; Write-Host $vm.name -ForegroundColor Yellow  
    get-OScustomizationspec $vm.csm -server $server | get-OScustomizationNicMapping | set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $vm.IP -SubnetMask $vm.subnet -DefaultGateway $vm.gateway -Dns $vm.Dns1, $vm.Dns2  
    get-OScustomizationspec $vm.csm -server $server | Set-OSCustomizationSpec -NamingScheme fixed -NamingPrefix $vm.Name  
  
  
    $vms = New-VM -Name $vm.Name -VMhost $vm.vmhost -Template $vm.template -OSCustomizationSpec $vm.csm -confirm:$false -Datastore $vm.datastore -Location $vm.location -verbose -RunAsync  
  
  
    $vms | Add-Member -type NoteProperty -name VMName -value $vm.name  
  
  
    $a += $vms  
  
}  
  
    foreach($task in $a){  
  
  
        $result = get-task -id $task.id  
  
        do{  
  
  
        $result = get-task -id $task.id  
          
        start-sleep -Seconds 10  
  
        }  
        until ($result.State -eq 'Success'){  
          
          
        }  
  
        if($result.State -eq 'Success' -and ((Get-VM -Id $result.Result).PowerState) -eq 'PoweredOff'  ){  
  
  
        Get-VM -Id $result.Result | start-vm   
  
  
    }  
  
  
}  