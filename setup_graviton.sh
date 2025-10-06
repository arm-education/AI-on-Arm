#!/bin/bash

set -e

echo "======================================================================="
echo "  0. Update package lists"
echo "======================================================================="
sudo apt update


echo "======================================================================="
echo "  1. Add essential development packages"
echo "======================================================================="
sudo apt install -y \
    wget build-essential libssl-dev libbz2-dev libreadline-dev libsqlite3-dev \
    zlib1g-dev libncurses-dev libffi-dev libgdbm-dev liblzma-dev uuid-dev \
    tk-dev python3-pip libblas-dev \
    linux-tools-common linux-tools-$(uname -r) \
    libelf-dev cmake clang llvm llvm-dev

echo "======================================================================="
echo "  2. Verify perf installation"
echo "======================================================================="
if command -v perf >/dev/null 2>&1; then
    echo "perf installed successfully."
else
    echo "Error: perf installation failed."
    exit 1
fi

echo "======================================================================="
echo "  3. Add deadsnakes PPA for Python 3.12"
echo "======================================================================="
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update

echo "======================================================================="
echo "  4. Install Python 3.12 and related tools"
echo "======================================================================="
sudo apt install -y gcc g++ build-essential google-perftools \
    python3.12 python3.12-venv python3.12-dev

echo "======================================================================="
echo "  5. Create (or recreate) Python 3.12 virtual environment 'graviton_env'"
echo "======================================================================="
if [ -d graviton_env ]; then
    echo "Removing existing virtual environment 'graviton_env'..."
    rm -rf graviton_env
fi

python3.12 -m venv graviton_env

echo "======================================================================="
echo "  6. Activate the virtual environment"
echo "======================================================================="
# shellcheck disable=SC1091
source graviton_env/bin/activate

echo "======================================================================="
echo "  7. Upgrade pip"
echo "======================================================================="
python3.12 -m pip install --upgrade pip

echo "======================================================================="
echo "  8. Install Python packages from graviton_requirements.txt"
echo "======================================================================="
if [ -f "graviton_requirements.txt" ]; then
    python3.12 -m pip install -r graviton_requirements.txt
else
    echo "Error: graviton_requirements.txt not found!"
    exit 1
fi



####################
# STEP 15: Clone and build processwatch (if not already cloned)
#############################################################################
echo "======================================================================="
echo "  15. Clone and build 'processwatch'"
echo "======================================================================="

# Just in case, re-install the dev packages, though they should already be present:
sudo apt-get update
sudo apt-get install -y libelf-dev cmake clang llvm llvm-dev
sudo apt-get update && sudo apt-get upgrade

if [ ! -d "processwatch" ]; then
    #git clone --recursive https://github.com/intel/processwatch.git
    git clone --recursive https://github.com/grahamwoodward/processwatch.git
else
    echo "processwatch folder already exists. Skipping clone."
fi
sudo apt-get install -y linux-tools-generic
cd processwatch
./build.sh
cd ..
echo "ubuntu ALL=(ALL) NOPASSWD: /home/ubuntu/processwatch/processwatch" | sudo tee /etc/sudoers.d/99-processwatch
sudo chmod 0440 /etc/sudoers.d/99-processwatch
#############################################################################

echo "======================================================================="
echo "Setup script completed successfully!"
echo "Activate your environment using: source graviton_env/bin/activate"
echo "======================================================================="
