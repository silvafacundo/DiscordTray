$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Host "Please run this script as an administrator."
	exit 1
}

try {
	$userProfileFolder = $env:USERPROFILE

	$folderPath = Join-Path -Path $userProfileFolder -ChildPath "\AppData\Local\DiscordTray"

	New-Item -ItemType Directory -Path $folderPath -Force

	$filePath = Join-Path -Path $folderPath -ChildPath "DiscordTray.ps1"

	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/silvafacundo/DiscordTray/main/DiscordTray.ps1" -OutFile $filePath

	$trigger = New-JobTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([timespan]::MaxValue)

	$options = New-ScheduledJobOption -RunElevated -StartIfOnBattery -ContinueIfGoingOnBattery

	Unregister-ScheduledJob -Name DiscordTray -ErrorAction SilentlyContinue

	Register-ScheduledJob -Name DiscordTray -FilePath $filePath -Trigger $trigger -ScheduledJobOption $options
	Clear-Host
	Write-Host "DiscordTray has been successfully installed!"
}
catch {
	Clear-Host
	Write-Host $_.Exception.Message
	Write-Host " "
	Write-Host " "
	Write-Host "An error occurred while installing DiscordTray. Are you sure you are running this script in an elevated Windows PowerShell?"
}

