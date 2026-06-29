param(
    [string]$Description = "",
    [string]$DescriptionFile = ".\description_daiai.txt",
    [string]$Labels = "SECFiling_Phase2"
)

if (-not $env:JIRA_API_TOKEN) {
    Write-Error "Environment variable JIRA_API_TOKEN is not set. Please set it and retry."
    exit 1
}

if (-not $env:JIRA_EMAIL) {
    Write-Error "Environment variable JIRA_EMAIL is not set. Please set it and retry."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Description)) {
    if (-not (Test-Path $DescriptionFile)) {
        Write-Error "Description file not found: $DescriptionFile"
        exit 1
    }
    $Description = Get-Content $DescriptionFile -Raw
}

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    Write-Error "Python not found or not available. Please install Python and ensure 'python' is in PATH."
    exit 1
}

$pythonExe = $pythonCmd.Source
$script = ".\create_daiai_ticket.py"
$args = @(
    "--summary", "Evaluation Page UI & Function Enhancement",
    "--description", $Description,
    "--type", "Story",
    "--project", "DAIAI",
    "--parent", "DAIAI-423",
    "--priority", "Medium (migrated)",
    "--assignee", "712020:00e3b76d-5d06-40ca-8356-5f8082c5458a",
    "--labels", $Labels
)

try {
    & $pythonExe $script @args
    if ($LASTEXITCODE -ne 0) {
        Write-Error "create_daiai_ticket.py returned non-zero exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
    Write-Host "Ticket creation script executed successfully."
} catch {
    Write-Error "Error executing Python script: $_"
    exit 1
}
