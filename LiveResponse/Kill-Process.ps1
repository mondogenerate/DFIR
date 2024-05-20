param(
    [Parameter(Mandatory=$true)]
    [int]$pid
)

try {
    Stop-Process -Id $pid -Force
    Write-Output "Process with ID $pid has been stopped successfully."
} catch {
    Write-Error "Failed to stop process with ID $pid. Error: $_"
}
