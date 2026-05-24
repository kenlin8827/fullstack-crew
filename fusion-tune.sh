#!/bin/bash
# Fullstack Crew — Fusion 性能调优
# 用法: bash fusion-tune.sh

DB="$(pwd)/.fusion/fusion.db"
CFG="$(pwd)/.fusion/config.json"
GSET="$HOME/.fusion/settings.json"

echo "=== Fullstack Crew Tuning ==="

# === 全局 — settings.json ===
echo "--- Global ---"
sed -i 's/"planningGlobalModelId": "[^"]*"/"planningGlobalModelId": "pro"/' "$GSET"
sed -i 's/"executionGlobalModelId": "[^"]*"/"executionGlobalModelId": "flash"/' "$GSET"
grep -E "planningGlobalModelId|executionGlobalModelId" "$GSET" | head -2

# === 项目 — config.json ===
echo "--- Project ---"
node -e "
var f=require('fs'),c=JSON.parse(f.readFileSync('$CFG','utf8'));
c.settings.maxConcurrent=4;
c.settings.autoMerge=false;
c.settings.verificationFixRetries=0;
c.settings.reflectionEnabled=true;
c.settings.reflectionIntervalMs=86400000;
f.writeFileSync('$CFG',JSON.stringify(c,null,2));
console.log('  maxConcurrent=4 autoMerge=off verifyRetries=0 reflection=weekly')
"

# === Agent 差异化配置 ===
echo "--- Agents ---"
# Team Lead: 常驻，主动认领，完整 scope，限制拆分深度
sqlite3 "$DB" "UPDATE agents SET data=json_set(data,
  '$.runtimeConfig.skipHeartbeatWhenIdle', json('false'),
  '$.runtimeConfig.autoClaimRelevantTasks', json('true'),
  '$.runtimeConfig.maxSubTaskDepth', 1,
  '$.runtimeConfig.maxSubTasksPerSplit', 3,
  '$.runtimeConfig.heartbeatIntervalMs', 600000,
  '$.runtimeConfig.heartbeatScopeDiscipline', 'strict'
) WHERE role='triage'"
# 其他专家: 休眠，不抢任务，最小 prompt
sqlite3 "$DB" "UPDATE agents SET data=json_set(data,
  '$.runtimeConfig.skipHeartbeatWhenIdle', json('true'),
  '$.runtimeConfig.autoClaimRelevantTasks', json('false'),
  '$.runtimeConfig.heartbeatIntervalMs', 600000,
  '$.runtimeConfig.heartbeatScopeDiscipline', 'off',
  '$.runtimeConfig.heartbeatPromptTemplate', 'compact',
  '$.runtimeConfig.messageResponseMode', 'on-heartbeat'
) WHERE role!='triage' AND id NOT LIKE 'ephemeral-%'"
N=$(sqlite3 "$DB" "SELECT count(*) FROM agents WHERE id NOT LIKE 'ephemeral-%'")
echo "  $N agents: TL=active+autoClaim | experts=sleep+wait"

# === 任务默认（创建时在 Dashboard 设） ===
echo "--- Tasks (set in Dashboard) ---"
echo "  executionMode:  fast      (Dashboard task detail → Settings)"
echo "  reviewLevel:    0         (Dashboard task detail → Settings)"
echo "  Agent:          手动指派   (拖拽任务到 Agent 头像)"

# === Workflow Steps ===
echo "--- Workflow Steps ---"
T=$(grep -o '"daemonToken":"[^"]*"' "$GSET" 2>/dev/null | cut -d'"' -f4)
P=${1:-6060}
if [ -n "$T" ]; then
  for t in qa-check security-audit; do
    R=$(curl -s -X POST -H "Authorization: Bearer $T" \
      "http://127.0.0.1:$P/api/workflow-step-templates/$t/create" 2>/dev/null)
    ID=$(echo "$R" | grep -o 'WS-[0-9]*')
    [ -n "$ID" ] && echo "  $t: $ID" || echo "  $t: skip"
  done
fi

echo ""
echo "=== Done: restart dashboard, then set task defaults in Dashboard ==="
