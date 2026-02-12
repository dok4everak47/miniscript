#!/bin/bash
set -euo pipefail

# ============================================================================
# Miniforge 快速部署脚本
# 功能：自动下载安装 Miniforge，配置 NJU 镜像，设置 mamba 为默认包管理器
# ============================================================================

# 配置变量
MINIFORGE_URL="https://mirrors.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-$(uname -m).sh"
INSTALL_DIR="${INSTALL_DIR:-$HOME/miniforge3}"
INSTALLER_SCRIPT="/tmp/miniforge_installer.sh"
CONDA_FORGE_MIRROR="https://mirror.nju.edu.cn/anaconda/cloud/conda-forge"

# 系统架构检测
ARCH=$(uname -m)
echo "========================================"
echo "Miniforge 快速部署脚本"
echo "========================================"
echo "检测到系统架构: $ARCH"
echo "安装目录: $INSTALL_DIR"
echo "----------------------------------------"

# 检查安装目录是否存在
if [ -d "$INSTALL_DIR" ]; then
    echo "警告: $INSTALL_DIR 已存在，将被覆盖"
    read -p "继续安装? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "安装已取消"
        exit 1
    fi
fi

# 下载 Miniforge 安装包
echo "下载 Miniforge..."
DOWNLOAD_SUCCESS=false

if command -v wget &> /dev/null; then
    if wget -q --show-progress "$MINIFORGE_URL" -O "$INSTALLER_SCRIPT"; then
        DOWNLOAD_SUCCESS=true
    fi
elif command -v curl &> /dev/null; then
    if curl -# -L "$MINIFORGE_URL" -o "$INSTALLER_SCRIPT"; then
        DOWNLOAD_SUCCESS=true
    fi
else
    echo "错误: 未安装 wget 或 curl"
    exit 1
fi

if [ "$DOWNLOAD_SUCCESS" = false ]; then
    echo "错误: 下载失败"
    exit 1
fi

# 验证下载文件
if [ ! -f "$INSTALLER_SCRIPT" ]; then
    echo "错误: 下载文件不存在: $INSTALLER_SCRIPT"
    exit 1
fi

# 验证文件大小（至少 50MB）
FILE_SIZE=$(stat -c%s "$INSTALLER_SCRIPT" 2>/dev/null || stat -f%z "$INSTALLER_SCRIPT" 2>/dev/null)
if [ -z "$FILE_SIZE" ]; then
    echo "错误: 无法获取文件大小"
    exit 1
fi

if [ "$FILE_SIZE" -lt 50000000 ]; then
    echo "错误: 下载的文件大小异常 ($FILE_SIZE bytes)"
    exit 1
fi

echo "下载完成，文件大小: $((FILE_SIZE / 1024 / 1024)) MB"

# 静默安装 Miniforge
echo ""
echo "安装 Miniforge 到 $INSTALL_DIR..."
if ! bash "$INSTALLER_SCRIPT" -b -p "$INSTALL_DIR"; then
    echo "错误: 安装失败"
    exit 1
fi

# 配置 .condarc 镜像源
echo ""
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

# 配置 mamba 为默认包管理器
echo ""
echo "配置 mamba 为默认包管理器..."

# Bash 配置
if [ -f ~/.bashrc ]; then
    # 检查是否已存在 Miniforge 配置
    if ! grep -q "# Miniforge - Mamba configuration" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Miniforge - Mamba configuration" >> ~/.bashrc
        echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> ~/.bashrc
        echo "alias conda=mamba" >> ~/.bashrc
        echo "已配置 ~/.bashrc"
    else
        echo "~/.bashrc 已包含 Miniforge 配置，跳过"
    fi
fi

# Zsh 配置
if [ -f ~/.zshrc ]; then
    if ! grep -q "# Miniforge - Mamba configuration" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# Miniforge - Mamba configuration" >> ~/.zshrc
        echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> ~/.zshrc
        echo "alias conda=mamba" >> ~/.zshrc
        echo "已配置 ~/.zshrc"
    else
        echo "~/.zshrc 已包含 Miniforge 配置，跳过"
    fi
fi

# Fish 配置
if [ -f ~/.config/fish/config.fish ]; then
    if ! grep -q "# Miniforge - Mamba configuration" ~/.config/fish/config.fish; then
        echo "" >> ~/.config/fish/config.fish
        echo "# Miniforge - Mamba configuration" >> ~/.config/fish/config.fish
        echo "fish_add_path $INSTALL_DIR/bin" >> ~/.config/fish/config.fish
        echo "alias conda=mamba" >> ~/.config/fish/config.fish
        echo "已配置 ~/.config/fish/config.fish"
    else
        echo "~/.config/fish/config.fish 已包含 Miniforge 配置，跳过"
    fi
fi

# 清理临时文件
rm -f "$INSTALLER_SCRIPT"

# 完成提示
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
echo "  mamba --version"
echo "  mamba info"
echo "  mamba config --show channels"
echo ""
echo "使用 mamba 作为默认包管理器:"
echo "  mamba install <package>"
echo "  mamba create -n <env>"
echo "或使用 conda 别名（实际执行 mamba）:"
echo "  conda install <package>"
echo "  conda create -n <env>"
echo "========================================"
