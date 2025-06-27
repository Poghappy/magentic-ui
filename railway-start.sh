#!/bin/bash

echo "🚀 Starting Magentic-UI on Railway..."

# 设置默认端口
export PORT=${PORT:-8080}

# 设置工作目录
export WORK_DIR=${WORK_DIR:-/tmp/magentic-ui-data}
mkdir -p $WORK_DIR

# 检查必要的环境变量
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  警告: OPENAI_API_KEY 环境变量未设置"
    echo "   请在 Railway 项目设置中添加 OPENAI_API_KEY"
fi

# 启动 Magentic-UI (无 Docker 模式)
echo "🌐 启动 Magentic-UI 服务在端口 $PORT..."
exec magentic-ui \
    --port $PORT \
    --host 0.0.0.0 \
    --work-dir $WORK_DIR \
    --run-without-docker 