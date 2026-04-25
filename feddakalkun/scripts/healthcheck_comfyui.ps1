param(
    [int]$Port = 8188,
    [int]$TimeoutSeconds = 30
)

$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$url = "http://127.0.0.1:$Port/system_stats"

while ((Get-Date) -lt $deadline) {
    try {
        $response = Invoke-WebRequest -UseBasicParsing $url -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Output "ComfyUI healthy on $url"
            exit 0
        }
    }
    catch {
        Start-Sleep -Seconds 2
    }
}

Write-Error "ComfyUI did not respond on $url within $TimeoutSeconds seconds"
exit 1
