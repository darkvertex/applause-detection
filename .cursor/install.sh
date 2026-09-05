#!/usr/bin/env bash
#
# Idempotent dependency setup for the applause-detection Cloud Agent environment.
#
# Creates an isolated Python 3.8 virtualenv and installs the pinned requirements
# with the compatibility constraints in .cursor/constraints.txt. Safe to run
# repeatedly: existing state is reused and only refreshed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENV_DIR="${APPLAUSE_VENV:-${HOME}/.venvs/applause}"

# Prefer sudo when available and not already root (Dockerfile image ships deps, so
# this apt path is a fallback for the default base image).
SUDO=""
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

ensure_system_deps() {
  local need_apt=0
  command -v python3.8 >/dev/null 2>&1 || need_apt=1
  command -v ffmpeg   >/dev/null 2>&1 || need_apt=1
  if [ "${need_apt}" -eq 0 ]; then
    return 0
  fi

  echo "[install] Installing system dependencies via apt..."
  ${SUDO} apt-get update -qq
  ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y -qq software-properties-common
  if ! command -v python3.8 >/dev/null 2>&1; then
    ${SUDO} add-apt-repository -y ppa:deadsnakes/ppa
    ${SUDO} apt-get update -qq
    ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
      python3.8 python3.8-venv python3.8-dev python3.8-distutils
  fi
  ${SUDO} DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    ffmpeg build-essential libsndfile1 libatlas-base-dev
}

ensure_system_deps

if [ ! -x "${VENV_DIR}/bin/python" ]; then
  echo "[install] Creating virtualenv at ${VENV_DIR}"
  python3.8 -m venv "${VENV_DIR}"
fi

echo "[install] Upgrading pip toolchain"
"${VENV_DIR}/bin/python" -m pip install --upgrade "pip<24" "setuptools<66" wheel

echo "[install] Installing pinned requirements with compatibility constraints"
"${VENV_DIR}/bin/python" -m pip install \
  -r "${REPO_DIR}/requirements.txt" \
  -c "${SCRIPT_DIR}/constraints.txt"

echo "[install] Done. Activate with: source ${VENV_DIR}/bin/activate"
