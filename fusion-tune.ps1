# Fullstack Crew — Fusion Performance Tuning
param([int]$Port=6060)

$DB = "$PWD\.fusion\fusion.db"
$CFG = "$PWD\.fusion\config.json"
$GSET = "$env:USERPROFILE\.fusion\settings.json"

Write-Host "=== Fullstack Crew Tuning ==="

# Global
Write-Host "--- Global ---"
$s = Get-Content $GSET -Raw -Encoding UTF8 | ConvertFrom-Json
$s.planningGlobalModelId = "pro"
$s.executionGlobalModelId = "flash"
$s | ConvertTo-Json -Depth 10 | Out-File $GSET -Encoding UTF8
Write-Host "  planning=pro execution=flash"

# Project
Write-Host "--- Project ---"
$c = @{ settings = @{} }
if ((Get-Item $CFG).Length -gt 0) {
  $c = Get-Content $CFG -Raw -Encoding UTF8 | ConvertFrom-Json
}
$c.settings.maxConcurrent = 4
$c.settings.autoMerge = $false
$c.settings.verificationFixRetries = 0
$c.settings.reflectionEnabled = $true
$c.settings.reflectionIntervalMs = 86400000
$c | ConvertTo-Json -Depth 10 | Out-File $CFG -Encoding UTF8
Write-Host "  maxConcurrent=4 autoMerge=off verifyRetries=0 reflection=weekly"

# Agents — differentiated
Write-Host "--- Agents ---"
# Team Lead: always on, autoClaim, depth limit
sqlite3 $DB "UPDATE agents SET data=json_set(data,
  '$.runtimeConfig.skipHeartbeatWhenIdle', json('false'),
  '$.runtimeConfig.autoClaimRelevantTasks', json('true'),
  '$.runtimeConfig.maxSubTaskDepth', 1,
  '$.runtimeConfig.maxSubTasksPerSplit', 3,
  '$.runtimeConfig.heartbeatIntervalMs', 600000,
  '$.runtimeConfig.heartbeatScopeDiscipline', 'strict'
) WHERE role='triage'"
# Experts: sleep, wait for delegate
sqlite3 $DB "UPDATE agents SET data=json_set(data,
  '$.runtimeConfig.skipHeartbeatWhenIdle', json('true'),
  '$.runtimeConfig.autoClaimRelevantTasks', json('false'),
  '$.runtimeConfig.heartbeatIntervalMs', 600000,
  '$.runtimeConfig.heartbeatScopeDiscipline', 'off',
  '$.runtimeConfig.heartbeatPromptTemplate', 'compact',
  '$.runtimeConfig.messageResponseMode', 'on-heartbeat'
) WHERE role!='triage' AND id NOT LIKE 'ephemeral-%'"
$n = (sqlite3 $DB "SELECT count(*) FROM agents WHERE id NOT LIKE 'ephemeral-%'").Trim()
Write-Host "  $n agents: TL=active+autoClaim | experts=sleep+wait"

# Task defaults
Write-Host "--- Tasks (set per-task in Dashboard) ---"
Write-Host "  executionMode: fast | reviewLevel: 0"

# Workflow Steps
Write-Host "--- Workflow Steps ---"
$settings = Get-Content $GSET -Raw -Encoding UTF8 | ConvertFrom-Json
$T = $settings.daemonToken
if ($T) {
  foreach ($t in @("qa-check","security-audit")) {
    try {
      $r = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/api/workflow-step-templates/$t/create" -Method Post -Headers @{Authorization="Bearer $T"}
      Write-Host "  $t : $($r.id)"
    } catch { Write-Host "  $t : skip" }
  }
}

Write-Host "=== Done: restart dashboard ==="
