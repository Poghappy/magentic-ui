# 多阶段构建 Dockerfile for Railway 部署
# 阶段1: 前端构建
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# 复制前端文件
COPY frontend/package*.json ./
COPY frontend/yarn.lock ./

# 安装依赖
RUN yarn install --frozen-lockfile

# 复制前端源码
COPY frontend/ ./

# 构建前端
RUN yarn build

# 阶段2: Python 后端
FROM python:3.12-slim

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=8080

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    ffmpeg \
    exiftool \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /app

# 复制 Python 项目文件
COPY pyproject.toml ./
COPY uv.lock ./

# 安装 uv
RUN pip install uv

# 安装 Python 依赖
RUN uv venv .venv && \
    . .venv/bin/activate && \
    uv sync --frozen

# 激活虚拟环境
ENV PATH="/app/.venv/bin:$PATH"

# 复制源码
COPY src/ ./src/

# 从前端构建阶段复制构建产物
COPY --from=frontend-builder /app/frontend/public ./src/magentic_ui/backend/web/ui/

# 复制启动脚本
COPY railway-start.sh ./
RUN chmod +x railway-start.sh

# 暴露端口
EXPOSE $PORT

# 启动命令
CMD ["./railway-start.sh"] 