#!/bin/bash
set -e

# 变量配置
MINIFORGE_URL="https://mirrors.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-$(uname -m).sh"
INSTALL_DIR="$HOME/miniforge3"
INSTALLER_SCRIPT="/tmp/miniforge_installer.sh"

# 1. 系统检测与下载
# - 检测架构 (x86_64/aarch64/ppc64le)
# - 优先使用 wget，备用 curl
# - 检查安装目录是否存在

# 2. 静默安装 Miniforge
bash "$INSTALLER_SCRIPT" -b -p "$INSTALL_DIR"

# 3. 配置 .condarc 镜像源
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

# 4. 初始化 conda 环境（仅用于环境管理）
"$INSTALL_DIR/bin/conda" init bash --reverse  # 反向初始化，避免自动激活
"$INSTALL_DIR/bin/conda" init zsh --reverse
"$INSTALL_DIR/bin/conda" init fish --reverse

# 5. 配置 mamba PATH 和别名
# 为每个 shell 配置：
# - 添加 mamba 到 PATH
# - 创建 alias conda=mamba

# Bash 配置 (~/.bashrc)
echo "" >> ~/.bashrc
echo "# Miniforge - Mamba configuration" >> ~/.bashrc
echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> ~/.bashrc
echo "alias conda=mamba" >> ~/.bashrc

# Zsh 配置 (~/.zshrc) - 如果存在
if [ -f ~/.zshrc ]; then
    echo "" >> ~/.zshrc
    echo "# Miniforge - Mamba configuration" >> ~/.zshrc
    echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> ~/.zshrc
    echo "alias conda=mamba" >> ~/.zshrc
fi

# Fish 配置 (~/.config/fish/config.fish) - 如果存在
if [ -f ~/.config/fish/config.fish ]; then
    echo "" >> ~/.config/fish/config.fish
    echo "# Miniforge - Mamba configuration" >> ~/.config/fish/config.fish
    echo "fish_add_path $INSTALL_DIR/bin" >> ~/.config/fish/config.fish
    echo "alias conda=mamba" >> ~/.config/fish/config.fish
fi

# 6. 清理临时文件
rm -f "$INSTALLER_SCRIPT"
