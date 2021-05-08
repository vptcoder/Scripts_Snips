

function UpdateLine([string]$text)
{ 
    Write-Output $text
    Write-Host $text
}

function UpdateStatusProgress([string]$activity, [string]$status, [int]$percentage)
{ 
    Write-Progress -Activity $activity -Status $status -PercentComplete $percentage
    $output = -join("Progess: [", $percentage, "%] " , $activity, " - " , $status)
    Write-Output $output
    Write-Host $output
}

function UpdateStatusBox([string]$status, [string]$from, [string]$to){
    $linecomplete = -join("| ", $status, ": Complete")
    $linefrom = -join("| ", $status, ": from - ", $from)
    $lineto = -join("| ", $status, ": to   - ", $to)

    Write-Output "--Status------------------------------------------"
    Write-Output $linecomplete
    Write-Output $linefrom
    Write-Output $lineto
    Write-Output "--------------------------------------------------"

    Write-Host -Fore Green "--Status------------------------------------------"
    Write-Host -Fore Green $linecomplete
    Write-Host -Fore Green $linefrom
    Write-Host -Fore Green $lineto
    Write-Host -Fore Green "--------------------------------------------------"

}

function SearchTargetPackageComponentSub1 (
    [parameter(Mandatory=$true)]
    [alias("z")]
    [string]$zipFullPath, 
    
    [parameter(Mandatory=$true)]
    [alias("c")]
    [string]$componentName,

    [parameter(Mandatory=$true)]
    [alias("s")]
    [string]$SubName

) {
    $zip = [IO.Compression.ZipFile]::OpenRead($zipFullPath)
    $entries = $zip.Entries | where {$_.FullName -like -join($componentName, "/*")} 

    #check package Component
    if(!$entries) {
        Write-Output "There is no valid $componentName package!"
        $zip.Dispose()
        return false
    }

    #check package component sub folder lv 1
    $criteria = -join($componentName,"/", $SubName, "/*")
    $check = $entries | where {$_.FullName -like $criteria}
    $zip.Dispose()
    return [bool]$check
}

function SearchTargetPackageComponent(
    [parameter(Mandatory=$true)]
    [alias("z")]
    [string]$zipFullPath, 
    
    [parameter(Mandatory=$true)]
    [alias("c")]
    [string]$componentName
) {
    Add-Type -Assembly System.IO.Compression.FileSystem

    $zip = [IO.Compression.ZipFile]::OpenRead($zipFullPath)
    $entries = $zip.Entries | where {$_.FullName -like -join($componentName, '/*') -and $_.FullName -ne -join($componentName, '/')} 
    $zip.Dispose()
    return [bool]$entries
}

function ExtractTargetPackageComponent(
    [parameter(Mandatory=$true)]
    [alias("z")]
    [string]$zipFullPath, 
    
    [parameter(Mandatory=$true)]
    [alias("c")]
    [string]$componentName, 

    [parameter(Mandatory=$true)]
    [alias("d")]
    [string]$destPath, 

    [parameter(Mandatory=$true)]
    [alias("o")]
    [bool]$overwrite
)
{ 
    Add-Type -Assembly System.IO.Compression.FileSystem

    $zip = [IO.Compression.ZipFile]::OpenRead($zipFullPath)
    $entries = $zip.Entries | where {$_.FullName -like -join($componentName, '/*') -and $_.FullName -ne -join($componentName, '/')} 

    New-Item -ItemType Directory -Path $destPath -Force | Out-Null
    foreach ($e in $entries) {
        if( $e.Name -notlike "") {
            $extract_to = Join-Path -Path $destPath -ChildPath $e.FullName
            New-Item -ItemType Directory -Path (Split-Path -Path $extract_to -Parent) -Force | Out-Null
            [IO.Compression.ZipFileExtensions]::ExtractToFile( $e, (Join-Path -Path $destPath -ChildPath $e.FullName), $true) 
        }
    }
    $zip.Dispose()

}
