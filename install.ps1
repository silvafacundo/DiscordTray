$userProfileFolder = $env:USERPROFILE

$folderPath = Join-Path -Path $userProfileFolder -ChildPath "\AppData\Local\DiscordTray"

New-Item -ItemType Directory -Path $folderPath -Force

$filePath = Join-Path -Path $folderPath -ChildPath "DiscordTray.ps1"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/silvafacundo/DiscordTray/main/DiscordTray.ps1" -OutFile $filePath

$trigger = New-JobTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([timespan]::MaxValue)

$options = New-ScheduledJobOption -RunElevated -StartIfOnBattery -ContinueIfGoingOnBattery

Unregister-ScheduledJob -Name DiscordTray -ErrorAction SilentlyContinue

Register-ScheduledJob -Name DiscordTray -FilePath $filePath -Trigger $trigger -ScheduledJobOption $options
