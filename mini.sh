#!/bin/bash
set -e

MINIFORGE_URL="https://mirrors.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-$(uname -m).sh"
INSTALL_DIR="$HOME/miniforge3"
CONDA_FORGE_MIRROR="https://mirror.nju.edu.cn/anaconda/cloud/conda-forge"
INSTALLER_SCRIPT="/tmp/miniforge_installer.sh"

ARCH=$(uname -m)
echo "========================================"
echo "Miniforge 安装脚本"
echo "========================================"
echo "检测到系统架构: $ARCH"
echo "安装目录: $INSTALL_DIR"
echo "----------------------------------------"

if [ -d "$INSTALL_DIR" ]; then
    echo "警告: $INSTALL_DIR 已存在，将被覆盖"
    read -p "继续安装? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "安装已取消"
        exit 1
    fi
fi

echo "下载 Miniforge..."
if command -v wget &> /dev/null; then
    wget -q --show-progress "$MINIFORGE_URL" -O "$INSTALLER_SCRIPT"
elif command -v curl &> /dev/null; then
    curl -# -L "$MINIFORGE_URL" -o "$INSTALLER_SCRIPT"
else
    echo "错误: 未安装 wget 或 curl"
    exit 1
fi

echo ""
echo "安装 Miniforge 到 $INSTALL_DIR..."
bash "$INSTALLER_SCRIPT" -b -p "$INSTALL_DIR"

echo "配置 conda 镜像源..."
cat > ~/.condarc << 'EOF'
channels:
  - conda-forge
  - defaults
custom_channels:
  conda-forge: https://mirror.nju.edu.cn/anaconda/cloud/conda-forge
channel_priority: strict
show_channel_urls: true
ssl_verify: true
EOF

echo "初始化 conda 环境..."
source "$INSTALL_DIR/bin/activate"
"$INSTALL_DIR/bin/conda" init bash

rm -f "$INSTALLER_SCRIPT"

echo ""
echo "========================================"
echo "安装完成!"
echo "========================================"
echo "请执行以下命令使更改生效:"
echo "  source ~/.bashrc"
echo "或"
echo "  重新打开终端"
echo ""
echo "验证安装:"
echo "  conda info"
echo "  conda config --show channels"
echo "========================================"
