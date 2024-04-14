$userProfileFolder = $env:USERPROFILE

$logFile = Join-Path -Path $env:TEMP -ChildPath "DiscordTray.log"

$isCLI = $args[0] -eq "cli"

# Specify the relative path from the user's profile folder
$relativeFolder = "\AppData\Local\Discord"

# Construct the full folder path
$folder = Join-Path -Path $userProfileFolder -ChildPath $relativeFolder

function Log($message) {
	if ($isCLI) {
		Write-Host $message
	}
 else {
		Add-Content -Path $logFile -Value "[$(Get-Date)] $message"
	}
}

function Update-Tray {
	# Loop through all programs in the System Tray
	foreach ($GUID in (Get-ChildItem -Path 'HKCU:\Control Panel\NotifyIconSettings' -Name)) {
		$ChildPath = "HKCU:\Control Panel\NotifyIconSettings\$($GUID)"

		# Get the executable path of the current program
		$Exec = (Get-ItemProperty -Path $ChildPath -Name ExecutablePath -ErrorAction SilentlyContinue).ExecutablePath

		# If the program is discord then set the IsPromoted value to 1
		if ($Exec -match "Discord") {
			Set-ItemProperty -Path $ChildPath -Name IsPromoted -Value 1
		}
	}
}

function Wait-Process($executablePath) {
	$count = 0

	# Wait for the process to be fully loaded
	while ($null -eq (Get-Process -Name "Discord" -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $executablePath })) {
		# Break if the process is not found after 20 attempts
		If ($count -ge 10) {
			return $false
		}
		$count++

		Log "Waiting new Discord to start... (Attempt: $count)"
		Start-Sleep -Seconds 2
	}

	$true
}

# Get all items inside the folder and sort by creation date
$items = Get-ChildItem -Path $folder | Sort-Object CreationTime

$lastDate = [Environment]::GetEnvironmentVariable("DiscordTrayLastDate", "User")

if ($lastDate.GetType().Name -eq 'String') {
	$lastDate = Get-Date -Date "$($lastDate)"
}

# Check if lastDate is date object
if (-not ($lastDate.GetType().Name -eq 'DateTime')) {
	Log "Invalid date '$lastDate'"
	$lastDate = Get-Date -Year 2020
}


Log "Running DiscordWatcherV2.ps1. Last Date: $($lastDate)"

foreach ($file in $items) {
	if (-Not ($file.PSIsContainer)) {
		continue;
	}

	$discordPath = Join-Path -Path $file.FullName -ChildPath "Discord.exe"
	$hasDiscord = Test-Path -Path $discordPath

	if (-Not $hasDiscord) {
		continue;
	}

	$diff = [Math]::Floor(($file.CreationTime - $lastDate).TotalSeconds)
	$isGrater = $diff -gt 0

	Log "Discord Found Created At: $($file.CreationTime)  - Is Grater: $isGrater ($diff)"

	if (-Not $isGrater) {
		continue;
	}


	if (Wait-Process $discordPath) {
		Log "New Discord Started..."
		Update-Tray
		[Environment]::SetEnvironmentVariable("DiscordTrayLastDate", $file.CreationTime.ToString(), "User")
		Log "Tray Updated."
	}
	else {
		Log "Discord process not found..."
	}

	break
}

