$trigger = New-JobTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([timespan]::MaxValue)

$options = New-ScheduledJobOption -RunElevated -StartIfOnBattery -ContinueIfGoingOnBattery

Register-ScheduledJob -Name DiscordWatcher -FilePath C:\Proyectos\DiscordWatcher\DiscordWatcher.ps1 -Trigger $trigger -ScheduledJobOption $options
