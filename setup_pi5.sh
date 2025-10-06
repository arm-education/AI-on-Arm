#!/bin/bash

set -e

#############################################################################
# STEP 1: Update and (optonally) upgrade the system
#############################################################################
echo "======================================================================="
echo "  1. Update and upgrade the system"
echo "======================================================================="
sudo apt update
# sudo apt upgrade -y

#############################################################################
# STEP 2: Install essential development packages
#############################################################################
echo "======================================================================="
echo "  2. Install essential development packages"
echo "======================================================================="
sudo apt install -y \
    wget build-essential libssl-dev libbz2-dev libreadline-dev libsqlite3-dev \
    zlib1g-dev libncurses5-dev libncursesw5-dev libffi-dev libgdbm-dev \
    liblzma-dev uuid-dev tk-dev linux-perf cmake

#############################################################################
# STEP 3: Verify perf installation
#############################################################################
echo "======================================================================="
echo "  3. Verify perf installation"
echo "======================================================================="
if command -v perf >/dev/null 2>&1; then
    echo "perf installed successfully."
else
    echo "Error: perf installation failed."
    exit 1
fi

#############################################################################
# STEP 4: Check and install Python 3.12 if necessary
#############################################################################
echo "======================================================================="
echo "  4. Check and install Python 3.12 if necessary"
echo "======================================================================="
if ! python3.12 --version >/dev/null 2>&1; then
    echo "Downloading and building Python 3.12..."
    cd /tmp
    if [ ! -f /tmp/Python-3.12.0.tgz ]; then
        wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz
    else
        echo "Python 3.12 source archive already exists. Skipping download."
    fi

    tar -xf Python-3.12.0.tgz
    cd Python-3.12.0
    ./configure --enable-optimizations
    sudo make altinstall
else
    echo "Python 3.12 is already installed. Skipping build."
fi

#############################################################################
# STEP 5: Create Python virtual environment
#############################################################################
echo "======================================================================="
echo "  5. Create Python virtual environment"
echo "======================================================================="
if [ ! -d pi5_env ]; then
    echo "Creating Python virtual environment..."
    python3.12 -m venv pi5_env
else
    echo "Virtual environment already exists. Skipping creation."
fi

#############################################################################
# STEP 6: Activate the virtual environment and install packages
#############################################################################
echo "======================================================================="
echo "  6. Activate the virtual environment and install packages"
echo "======================================================================="
# shellcheck disable=SC1091
source pi5_env/bin/activate

echo "======================================================================="
echo "  7. Upgrade pip"
echo "======================================================================="
python3.12 -m pip install --upgrade pip

echo "======================================================================="
echo "  8. Install required Python packages"
echo "======================================================================="
python3.12 -m pip install --upgrade --trusted-host archive1.piwheels.org \
    numpy \
    matplotlib \
    pandas \
    torch \
    transformers==4.53.3 \
    jupyterlab \
    ipykernel \
    ipywidgets \
    seaborn \
    sentencepiece \
    mistral-common

#############################################################################
echo "======================================================================="
echo "Setup script completed successfully!"
echo "Activate your environment using: source pi5_env/bin/activate"
echo "======================================================================="
