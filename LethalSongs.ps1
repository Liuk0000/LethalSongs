$r2ModMan = "r2modmanPlus-local"
$thunderstore = "Thunderstore Mod Manager\DataFolder"
$binIdLink = "https://raw.githubusercontent.com/Liuk0000/LethalSongs/refs/heads/master/binId.txt"

function Test-PathOrThrow {
    param (
        [string]$path,
        [string]$errorString
    )

    if (!(Test-Path $path)) {
        throw $errorString
    }

}

function Get-RemoteBinId {
    $binIdPath = ".\binId.txt"

    Write-Host "Retrieving binId from GitHub: " -ForegroundColor Blue -NoNewline
    Write-Host $binIdLink -ForegroundColor Yellow
    Invoke-WebRequest -Uri $binIdLink -OutFile $binIdPath
    
    $binId = Get-Content -Path $binIdPath -First 1

    Write-Host "Retrieved binId: " -ForegroundColor Blue -NoNewline
    Write-Host $binId -ForegroundColor Yellow

    return $binId
}

function Get-BinId {
    param (
        [string]$binId
    )

    if($binId){
        return $binId
    }

    return Get-RemoteBinId
}

function Get-ModManager {
    param (
        [string]$modManagerType
    )

    if (!$modManagerType) {
        Write-Host "Which mod manager do you use ? r2Modman (R) or thunderstore (T)" -ForegroundColor Blue
        $modManagerType = Read-Host
    }
    
    if ($modManagerType -eq "R") {
        return $r2ModMan
    }
    elseif ($modManagerType -eq "T") {
        return $thunderstore
    }
    else {
        throw "Invalid mod manager type!"
    }
}

function Get-ProfileName {
    param (
        [string]$profileName
    )

    if (!$profileName) {
        Write-Host Read-Host "Insert your mod manager profile name" -ForegroundColor Blue
        $profileName = Read-Host 
    }

    return $profileName
}

function Test-RemoveExistingItem {
param (
        [string]$path
    )

    if ((Test-Path $path)) {
        Remove-Item -Path $path -Recurse
        Write-Host "Successfully deleted existing folder: " -ForegroundColor Blue -NoNewline
        Write-Host $path -ForegroundColor Yellow
    }else {
        Write-Host "Removing folder not required as it doesn't exist." -ForegroundColor Blue
    }
}

try {
    $userPath = $env:USERPROFILE
    $binId = Get-BinId $args[0]
    $modManager = Get-ModManager $args[1]
    $profileName = Get-ProfileName $args[2]

    $modManagerPath = "$userPath\AppData\Roaming\$modManager"
    Test-PathOrThrow $modManagerPath "Mod manager path doesn't exist!"

    $profilePath = "$modManagerPath\LethalCompany\profiles\$profileName"
    Test-PathOrThrow $profilePath "Profile path doesn't exist!"

    $binRequestPath = "https://filebin.net/archive/$binId/zip"
    $zipFile = "$userPath\Downloads\lethalSongs.zip"
    $destinationFolder = "$profilePath\BepInEx\Custom Songs\Boombox Music"

    Write-Host "Downloading files from bin: " -ForegroundColor Blue -NoNewline
    Write-Host $binRequestPath -ForegroundColor Yellow

    curl.exe -X 'GET' $binRequestPath -H 'accept: */*' --output $zipFile

    Write-Host "Cleaning target folder: " -ForegroundColor Blue -NoNewline
    Write-Host $destinationFolder -ForegroundColor Yellow

    Test-RemoveExistingItem  $destinationFolder

    Write-Host "Extracting files to folder: " -ForegroundColor Blue -NoNewline
    Write-Host $destinationFolder -ForegroundColor Yellow

    Expand-Archive -Path $zipFile -DestinationPath $destinationFolder

    Remove-Item -Path $zipFile

    Write-Host "Lethal songs imported correctly!" -ForegroundColor Green

}
catch {
    Write-Host "Caught an exception: $_" -ForegroundColor Red
}
finally {
    Pause
}
