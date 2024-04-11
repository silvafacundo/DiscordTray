# Get the current user's profile folder
$userProfileFolder = $env:USERPROFILE

# Specify the relative path from the user's profile folder
$relativeFolder = "\AppData\Local\Discord"

# Construct the full folder path
$folder = Join-Path -Path $userProfileFolder -ChildPath $relativeFolder

# Listen only to Discord.exe file
$filter ="Discord.exe"

# Create Watcher
$Watcher = New-Object IO.FileSystemWatcher $folder, $filter -Property @{ 
	IncludeSubdirectories = $true
	EnableRaisingEvents = $true
}

# Register the event
$onCreatead = Register-ObjectEvent $Watcher -EventName "Created" -SourceIdentifier "DiscordDetection" -Action {
	$path = $Event.SourceEventArgs.FullPath

	Write-Host "New Discord.exe detected at $($path)"


	$count = 0

	# Wait for the process to be fully loaded
	while ((Get-Process -Name "Discord" -ErrorAction SilentlyContinue | Where-Object {$_.Path -eq $path }) -eq $null) {
		# Break if the process is not found after 20 attempts
		If ($count -ge 20) {
			break
		}
		$count++

		Write-Host "Waiting new Discord to start... (Attempt: $count)"
		Start-Sleep -Seconds 2
	}

	If ($count -ge 20) {
		Write-Host "Discord process not found..."
	} Else {
		Write-Host "New Discord Started..."

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

}
