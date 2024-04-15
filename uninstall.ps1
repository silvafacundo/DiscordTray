$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Host "Please run this script as an administrator."
	exit 1
}

try {
	Unregister-ScheduledJob -Name DiscordTray -ErrorAction SilentlyContinue
	Write-Host "DiscordTray has been successfully uninstalled!"
}
catch {
	Write-Host $_.Exception.Message
	Write-Host " "
	Write-Host " "
	Write-Host "An error occurred while uninstalling DiscordTray. Are you sure you are running this script in an elevated Windows PowerShell?"
}