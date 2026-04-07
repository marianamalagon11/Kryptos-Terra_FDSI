# Kryptos Terra

Demo academico de seguridad en Infraestructura como Codigo (IaC) para S.A.M.J. Global Services.

## Objetivo de la fase 1

Mostrar el problema de secretos hardcodeados en Terraform y demostrar que borrar las credenciales en un commit posterior **no elimina** la exposicion del historial Git.

## Estructura

```text
kryptos-terra/
├── infra-insegura/
│   ├── main.tf
│   ├── database.tf
│   └── storage.tf
├── infra-segura/
│   ├── main.tf
│   ├── database.tf
│   └── storage.tf
├── vault/
│   └── setup-vault.sh
├── .github/
│   └── workflows/
│       └── secret-scanner.yml
├── .gitleaks.toml
├── .pre-commit-config.yaml
└── README.md
```

## Demo fase 1 (PowerShell)

1. Revisar archivos inseguros:

```powershell
Get-Content .\kryptos-terra\infra-insegura\main.tf
Get-Content .\kryptos-terra\infra-insegura\database.tf
Get-Content .\kryptos-terra\infra-insegura\storage.tf
```

2. Primer commit (con secretos):

```powershell
git add .\kryptos-terra\infra-insegura\main.tf .\kryptos-terra\infra-insegura\database.tf .\kryptos-terra\infra-insegura\storage.tf
git commit -m "feat: add base infrastructure config for SAMJ Global Services"
```

3. Simular arreglo falso (remover visibles):

```powershell
(Get-Content .\kryptos-terra\infra-insegura\main.tf) -replace 'AKIA7QW9X2V4B8N6M3K1', 'REMOVED' -replace 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLE1', 'REMOVED' | Set-Content .\kryptos-terra\infra-insegura\main.tf
(Get-Content .\kryptos-terra\infra-insegura\database.tf) -replace 'samj_admin', 'REMOVED' -replace 'Samj2024\$Secure!DB', 'REMOVED' | Set-Content .\kryptos-terra\infra-insegura\database.tf
(Get-Content .\kryptos-terra\infra-insegura\storage.tf) -replace 'SAMJ-aB3xK9mP2nQ7rT1vW4yZ6cE8hJ0dL5fG', 'REMOVED' | Set-Content .\kryptos-terra\infra-insegura\storage.tf
git add .\kryptos-terra\infra-insegura\main.tf .\kryptos-terra\infra-insegura\database.tf .\kryptos-terra\infra-insegura\storage.tf
git commit -m "fix: remove hardcoded credentials from config files"
```

4. Mostrar historial y estado aparente limpio:

```powershell
git --no-pager log --oneline --decorate --graph -n 5
Get-Content .\kryptos-terra\infra-insegura\main.tf
Get-Content .\kryptos-terra\infra-insegura\database.tf
Get-Content .\kryptos-terra\infra-insegura\storage.tf
```

5. Escanear todo el historial con Gitleaks:

```powershell
.\gitleaks.exe detect --source . --config .\kryptos-terra\.gitleaks.toml --log-opts="--all" --report-format json --report-path .\kryptos-terra\gitleaks-historial.json --verbose --redact
Get-Content .\kryptos-terra\gitleaks-historial.json
```

El resultado esperado es que Gitleaks encuentre secretos en commits previos aunque los archivos actuales parezcan limpios.

