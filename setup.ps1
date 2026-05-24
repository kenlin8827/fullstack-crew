# Fusion Expert Team Setup v1.0
param([int]$Port=5055)

$HERE = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "=== Fusion Expert Team Setup ==="

# 1. Import agents + skills
Write-Host "--- Agents & Skills ---"
fn agent import $HERE --skip-existing 2>&1 | Select-String "✓|Created|Agents|Skills"

# 2. Workflow Steps (dashboard must be running)
Write-Host ""
Write-Host "--- Workflow Steps ---"
$TOKEN = (Get-Content "$env:USERPROFILE\.fusion\settings.json" -Raw | ConvertFrom-Json).daemonToken
if ($TOKEN) {
  try {
    $r1 = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/api/workflow-step-templates/qa-check/create" -Method Post -Headers @{Authorization="Bearer $TOKEN"} -ErrorAction Stop
    Write-Host "  QA Check:   $($r1.id)"
  } catch { Write-Host "  QA Check:   dashboard not running" }
  try {
    $r2 = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/api/workflow-step-templates/security-audit/create" -Method Post -Headers @{Authorization="Bearer $TOKEN"} -ErrorAction Stop
    Write-Host "  Security:   $($r2.id)"
  } catch { Write-Host "  Security:   dashboard not running" }
}

Write-Host "=== Done ==="
