param(
    [int]$Port = 8000,
    [int]$TimeoutSeconds = 30
)

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$url = "http://127.0.0.1:$Port/health"

while ((Get-Date) -lt $deadline) {
    try {
        $response = Invoke-WebRequest -UseBasicParsing $url -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Output "Backend healthy on $url"
            exit 0
        }
    }
    catch {
        Start-Sleep -Seconds 2
    }
}

Write-Error "Backend did not respond on $url within $TimeoutSeconds seconds"
exit 1
