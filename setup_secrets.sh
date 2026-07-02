#!/bin/bash
set -e

REPO="redovarin09/uangkos"
KEYSTORE_FILE="uangkos.jks"

echo "🔐 Setup GitHub Secrets untuk CI/CD signing — Uang Kos"
echo "======================================================"

# ── Cek keystore ada ───────────────────────────────────
if [ ! -f "$KEYSTORE_FILE" ]; then
  echo "❌ $KEYSTORE_FILE tidak ditemukan. Jalankan dari ~/uang_kos"
  exit 1
fi

# ── Cek gh auth ─────────────────────────────────────────
if ! gh auth status &>/dev/null; then
  echo "❌ Belum login gh CLI. Jalankan: gh auth login"
  exit 1
fi

# ── Input credentials (sekali, tidak disimpan di script) ─
read -sp "Masukkan storePassword keystore: " STORE_PASS
echo
read -sp "Masukkan keyPassword: " KEY_PASS
echo
read -p  "Masukkan keyAlias [uangkos]: " KEY_ALIAS
KEY_ALIAS=${KEY_ALIAS:-uangkos}

# ── Upload keystore (pipe langsung, tanpa clipboard) ─────
echo "📤 Uploading KEYSTORE_BASE64..."
base64 -w0 "$KEYSTORE_FILE" | gh secret set KEYSTORE_BASE64 --repo "$REPO"

echo "📤 Uploading KEYSTORE_PASSWORD..."
echo -n "$STORE_PASS" | gh secret set KEYSTORE_PASSWORD --repo "$REPO"

echo "📤 Uploading KEY_PASSWORD..."
echo -n "$KEY_PASS" | gh secret set KEY_PASSWORD --repo "$REPO"

echo "📤 Uploading KEY_ALIAS..."
echo -n "$KEY_ALIAS" | gh secret set KEY_ALIAS --repo "$REPO"

echo "======================================================"
echo "✅ Semua secrets berhasil diupload ke $REPO"
gh secret list --repo "$REPO"
