#!/usr/bin/env bash
set -euo pipefail

# Script de ejemplo para preparar un KV en Vault para el demo.
# Requiere VAULT_ADDR y VAULT_TOKEN exportados en el entorno.

vault secrets enable -path=samj kv-v2 || true

vault kv put samj/iac/aws \
  access_key="REEMPLAZAR_EN_VAULT" \
  secret_key="REEMPLAZAR_EN_VAULT"

vault kv put samj/iac/database \
  username="REEMPLAZAR_EN_VAULT" \
  password="REEMPLAZAR_EN_VAULT"

vault kv put samj/iac/backups \
  token="REEMPLAZAR_EN_VAULT"

echo "Vault inicializado para demo de Kryptos Terra."
