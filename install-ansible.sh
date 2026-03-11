#!/bin/bash
# install-ansible.sh
# Installs Ansible on macOS via Homebrew and pip3.
# Usage: bash install-ansible.sh

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────────
DEFAULT_PLAYBOOK="enhanced-developer-arduino.yml"

# ── Colours ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colour

info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── 1. Xcode Command Line Tools ────────────────────────────────────────────────
info "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools (a dialog may appear)..."
  xcode-select --install 2>/dev/null || true
  echo ""
  warn "If a dialog appeared, complete the Xcode CLT installation, then re-run this script."
  exit 0
fi
info "Xcode Command Line Tools are installed."

# ── 2. Homebrew ────────────────────────────────────────────────────────────────
info "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for the remainder of this script
  if [[ "$(uname -m)" == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  info "Homebrew installed."
else
  info "Homebrew already installed — updating..."
  brew update
fi

# ── 3. Python 3 ────────────────────────────────────────────────────────────────
info "Checking for Python 3..."
if ! command -v python3 &>/dev/null; then
  info "Installing Python 3 via Homebrew..."
  brew install python3
fi
PYTHON3=$(command -v python3)
info "Using Python 3: $PYTHON3"

# ── 4. pip / pipx ─────────────────────────────────────────────────────────────
# Modern macOS pip installations may be managed (PEP 668).
# pipx is the recommended way to install Ansible in an isolated environment.
info "Checking for pipx..."
if ! command -v pipx &>/dev/null; then
  info "Installing pipx via Homebrew..."
  brew install pipx
  pipx ensurepath
fi

# ── 5. Ansible ─────────────────────────────────────────────────────────────────
info "Installing Ansible via pipx..."
if pipx list | grep -q "ansible"; then
  info "Ansible is already installed via pipx."
else
  pipx install --include-deps ansible
fi

# Ensure the pipx bin directory is on PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# ── 6. Verify ─────────────────────────────────────────────────────────────────
if command -v ansible &>/dev/null; then
  ANSIBLE_VERSION=$(ansible --version | head -1)
  info "Ansible installed successfully: $ANSIBLE_VERSION"
else
  error "Ansible installation could not be verified. Try opening a new terminal."
  exit 1
fi

# ── 7. Summary ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}✅ Ansible is ready!${NC}"
echo ""
echo "Next step — run the Mac developer setup playbook:"
echo "  ansible-playbook ${DEFAULT_PLAYBOOK} -K"
echo ""
echo "If 'ansible' is not found in a new terminal, add the following to your shell profile:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
