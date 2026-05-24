#!/bin/bash
# Fusion Expert Team Setup v1.0
# 用法: bash setup.sh [--port PORT]

HERE="$(cd "$(dirname "$0")" && pwd)"
PORT="${1:-5055}"

echo "=== Fusion Expert Team Setup ==="

# 1. 导入 Agent + Skills
echo "--- Agents & Skills ---"
fn agent import "$HERE" --skip-existing 2>&1 | grep "✓\|Created\|Agents\|Skills"

# 2. Workflow Steps（需 Dashboard 运行中）
echo ""
echo "--- Workflow Steps ---"
TOKEN=$(grep -o '"daemonToken":"[^"]*"' ~/.fusion/settings.json 2>/dev/null | cut -d'"' -f4)
if [ -n "$TOKEN" ]; then
  R1=$(curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    "http://127.0.0.1:$PORT/api/workflow-step-templates/qa-check/create" 2>/dev/null)
  R2=$(curl -s -X POST -H "Authorization: Bearer $TOKEN" \
    "http://127.0.0.1:$PORT/api/workflow-step-templates/security-audit/create" 2>/dev/null)
  echo "  QA Check:   $(echo $R1 | grep -o 'WS-[0-9]*' || echo 'dashboard not running')"
  echo "  Security:   $(echo $R2 | grep -o 'WS-[0-9]*' || echo 'dashboard not running')"
else
  echo "  Start dashboard first, then re-run for workflow steps"
fi

echo ""
echo "=== Done ==="
