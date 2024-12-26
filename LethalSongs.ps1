$r2ModMan = "r2modmanPlus-local"
$thunderstore = "Thunderstore Mod Manager\DataFolder"

function Test-PathOrThrow {
    param (
        [string]$path,
        [string]$errorString
    )

    if (!(Test-Path $path)) {
        throw $errorString
    }

}

function Get-BinId {
    param (
        [string]$binId
    )

    if (!$binId) {
        Write-Host "Insert the binId to download songs" -ForegroundColor Blue
        $binId = Read-Host
    }

    return $binId
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

    Write-Host "Downloading files from bin: $binRequestPath" -ForegroundColor Blue

    curl.exe -X 'GET' $binRequestPath -H 'accept: */*' --output $zipFile

    Write-Host "Extracting files to folder: $destinationFolder" -ForegroundColor Blue

    Remove-Item -Path "$destinationFolder\*"

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
