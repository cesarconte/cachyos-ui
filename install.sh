#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "  Instalador de CachyOS UI (Design System)"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"

echo "==> Configurando con CMake..."
cmake -B "${BUILD_DIR}" -S "${SCRIPT_DIR}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr

echo "==> Compilando CachyOS UI..."
cmake --build "${BUILD_DIR}" -j"$(nproc)"

echo "==> Instalando en el sistema (requiere sudo)..."
sudo cmake --install "${BUILD_DIR}"

echo "=========================================="
echo "  ✓ CachyOS UI instalado correctamente."
echo "=========================================="
