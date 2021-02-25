


function Get-RCVMinventory{
    <#
    .Synopsis
    Queries a vcenter server and obtains its virtual machines info
    .DESCRIPTION
    This will obtain info of every virtual machine on the vcenter selected using PowerCLI
    .PARAMETER ComputerName
    The name of the vCenter to query. Accepts multiple values
    and accepts pipeline input
    .PARAMETER ShowProgress
    Displays a progress bar showing curret operations and percent complete.
    Percentage will be accurate when piping computer names into the command. 
    .EXAMPLE
    Get-RCVMinventory -vCenter vcenter1 
    This will display the info of all virtual machines on the vcenter called “vcenter1"
    .EXAMPLE
    Get-RCVMinventory -vCenter vcenter1 -ShowProgress
    This will display the info of all virtual machines on the vcenter called  "vcenter1" with a progress bar
    .EXAMPLE 
    'vcenter1','vcenter2' | Get-RCVMinventory -ShowProgress -Verbose
    Queries multiple vcenters receiving info from pipeline.
    .EXAMPLE 
    Get-RCVMinventory -vCenter vcenter1 -ComputerName vm1,vm2
    Queries  the information just for the computer or computers specified 
    .EXAMPLE 
    'vcenter1' | Get-RCVMinventory | Export-Csv -Path C:\vcenter_report.csv -NoTypeInformation
    Queries a vcenter resiving pipeline input and saving the output to a CSV file
    #>   
    [CmdletBinding()]
    Param(          
        [Parameter(Position =0,
                   Mandatory=$true,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   HelpMessage = 'VCenter server to query',
                   ParameterSetName = 'vCenterName')]
        [Alias('vCenter')]
        [String[]]$vCenterName,
        
        
        [Parameter(HelpMessage = 'Computername to query',ParameterSetName="vCenterName")]
        [String[]]$ComputerName,
        
        [Parameter()]
        [String]$ErrorLogFile = $RCErrorLogPath,

        [Switch]$ShowProgress 
    )

    BEGIN {          
        if(-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {
           Add-PSSnapin VMware.VimAutomation.Core 
        }     
    }
    PROCESS {
        
        foreach($vc in $vCenterName) {  
            try {
                $ok = $true
                Write-Verbose "conecting to vCenter $vc"
                Connect-VIServer -Server $vc  -WarningAction 0 -ErrorAction Stop | Out-Null                
            }catch{
                Write-Warning "vCenter with the name $vc is not responding"
                $ok=$false
            }

            if ($ok) {
                $vMachins = Get-VM
                if($PSBoundParameters.ContainsKey('ComputerName')) {
                     Write-Verbose "Queryng the following servers $ComputerName"
                     $vMachins = Get-VM -name $ComputerName
                }         
                $counter = 0
                foreach ($vm in $vMachins){ 
                    Write-Verbose "querying vm info.. $vm"
                    $vhost = Get-VMHost -VM $vm.name   
                    $vware = Get-VMGuest  -VM $vm 
                    $FreeSpace = $vware.Disks  | select -ExpandProperty freespace  | Measure-Object -sum 
                    $Size = $vware.Disks  | select -ExpandProperty capacity  | Measure-Object -sum      
                    $UsedSpace = (($Size.Sum - $FreeSpace.Sum)/1gb -as [int])
                    [PSCustomObject]@{  'Cluster' = $vhost.parent;
                                        'Host' = $vhost.name;
                                        'vCenter' = $vc;                             
                                        'ServerName' = $vm.name;
                                        'FQDN' = $vware.hostname;
                                        'State' = $vware.State;
                                        'Operating System' = $vware.OSFullName;
                                        'CPUs' = $vm.NumCpu;
                                        'MemoryRAM' = $vm.MemoryGB;
                                        'UsedSpace'= $UsedSpace
                                        'ProvisionedSpaceGB' = $vm.ProvisionedSpaceGB -as [int];
                                        'IPaddress' = $vware.IPAddress;
                                        'NetworLabel'= $vware.nics.networkname;
                                        'macaddress' = $vware.nics.macaddress;
                                    }

                    if($ShowProgress) {
                        $counter++
                        $Parameters = @{ Activity = "Processing -->";
                                         Status = "vCEnter $($vc) -- $($counter) of $($vMachins.count) VM's";
                                         CurrentOperation = $vm;
                                         PercentComplete = (($counter /  $vMachins.count) * 100) 
                                       }     
                        Write-Progress @Parameters
                    }
                }               
            }
        }
    }
    END {
        if($ShowProgress) { Write-Progress -Activity "Completed" -Completed }
        Disconnect-VIServer -Server $vc -confirm:$False | Out-Null
    }
} 

