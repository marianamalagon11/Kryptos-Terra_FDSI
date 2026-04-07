# Explicacion de la Fase 2 - Kryptos Terra

## Checklist de esta entrega

- [x] Objetivo de remediacion de la fase 2.
- [x] Guion de video: que decir y que mostrar en cada escena.
- [x] Comandos PowerShell listos para ejecutar en orden.
- [x] Evidencias tecnicas que debes ensenar en camara.
- [x] Cierre academico de mitigacion y siguientes pasos.

## 1) Objetivo de la fase 2

En esta fase se implementa la **remediacion** del riesgo de secretos en IaC para S.A.M.J. Global Services.

Resultado que debes demostrar:

1. La infraestructura segura (`infra-segura`) ya no contiene secretos hardcodeados.
2. Los valores sensibles se inyectan por variables locales/no versionadas o gestor de secretos.
3. Se agregan controles preventivos en local (pre-commit) y en CI (GitHub Actions con Gitleaks).
4. Se valida con escaneo de Gitleaks que el estado actual queda sin fugas.

## 2) Que implementa esta fase

Archivos que debes mencionar en el video:

- `kryptos-terra/infra-segura/main.tf`
  - Proveedor AWS sin `access_key` ni `secret_key` hardcodeadas.
  - Uso de variable `aws_region`.
- `kryptos-terra/infra-segura/database.tf`
  - RDS con `username` y `password` por variables.
  - `db_admin_password` marcada como `sensitive = true`.
- `kryptos-terra/infra-segura/storage.tf`
  - Token de backups como variable sensible (`backup_api_token`).
- `kryptos-terra/.pre-commit-config.yaml`
  - Hook local de Gitleaks antes de commit.
- `kryptos-terra/.github/workflows/secret-scanner.yml`
  - Escaneo automatico en push/PR con Gitleaks.

## 3) Guion para video (paso a paso)

## Escena A - Apertura de fase 2 (20-30 segundos)

**Que decir:**

"En esta fase 2 pasamos de evidencia a remediacion. El objetivo es eliminar hardcoding de secretos en Terraform y dejar controles automáticos para evitar reincidencias."

**Que mostrar:**

```powershell
Set-Location "C:\Users\maria\Downloads\Kryptos-Terra_FDSI"
Get-ChildItem .\kryptos-terra\
Get-ChildItem .\kryptos-terra\infra-segura\
```

## Escena B - Revisar IaC segura (1-2 minutos)

**Que decir:**

"Aqui se ve la diferencia: en `infra-segura` no hay credenciales en texto plano. Los datos sensibles se referencian mediante variables y marcamos sensibilidad en Terraform."

**Que mostrar:**

```powershell
Get-Content .\kryptos-terra\infra-segura\main.tf
Get-Content .\kryptos-terra\infra-segura\database.tf
Get-Content .\kryptos-terra\infra-segura\storage.tf
```

## Escena C - Crear archivo local de variables (no versionado) (45-60 segundos)

**Que decir:**

"Para la demo cargamos secretos falsos en un archivo local `terraform.auto.tfvars` que no debe subirse al repositorio."

**Que mostrar:**

```powershell
@"
aws_region = "us-east-1"
app_ami = "ami-0c02fb55956c7d316"
db_admin_username = "<USUARIO_FAKE>"
db_admin_password = "<PASSWORD_FAKE>"
backup_api_token = "<TOKEN_FAKE>"
"@ | Set-Content .\kryptos-terra\infra-segura\terraform.auto.tfvars

Get-Content .\kryptos-terra\infra-segura\terraform.auto.tfvars
```

> Nota para decir en camara: "Este archivo es local de demo y no se versiona".

> Importante: si intentas hacer `git add .\kryptos-terra\infra-segura\terraform.auto.tfvars`, Git no lo va a tomar porque `*.tfvars` esta cubierto por `.gitignore`. Esto es intencional: ese archivo suele contener valores sensibles locales y no debe entrar al historial del repositorio.

> Si quieres mostrar algo versionable, usa una plantilla como `terraform.auto.tfvars.example` o un archivo de ejemplo sin secretos.

## Escena D - Validar seguridad con Gitleaks (impacto tecnico) (1 minuto)

**Que decir:**

"Ahora validamos el estado actual del repositorio. Si la remediacion esta bien, Gitleaks no deberia encontrar secretos hardcodeados en la configuracion segura."

**Que mostrar:**

```powershell
.\gitleaks.exe detect --source . --config .\kryptos-terra\.gitleaks.toml --report-format json --report-path .\kryptos-terra\gitleaks-fase2-actual.json --verbose --redact
Get-Content .\kryptos-terra\gitleaks-fase2-actual.json
```

## Escena E - Activar control preventivo local (pre-commit) (45-60 segundos)

**Que decir:**

"Ademas del escaneo manual, dejamos una barrera preventiva: cada commit pasa por Gitleaks automaticamente."

**Que mostrar:**

```powershell
python -m pip install pre-commit
pre-commit install
pre-commit run --all-files
Get-Content .\kryptos-terra\.pre-commit-config.yaml
```

## Escena F - Mostrar control en CI (GitHub Actions) (30-45 segundos)

**Que decir:**

"En CI tambien queda habilitado el escaneo para push y pull request, de modo que la proteccion no dependa solo de la maquina local."

**Que mostrar:**

```powershell
Get-Content .\kryptos-terra\.github\workflows\secret-scanner.yml
```

## Escena G - Commit de remediacion (30-45 segundos)

**Que decir:**

"Registro estos cambios como baseline de remediacion para la fase 2."

**Que mostrar:**

```powershell
git add .\kryptos-terra\infra-segura\main.tf
git add .\kryptos-terra\infra-segura\database.tf
git add .\kryptos-terra\infra-segura\storage.tf
git add .\kryptos-terra\.pre-commit-config.yaml
git add .\kryptos-terra\.github\workflows\secret-scanner.yml
git add .\kryptos-terra\explicacion.md
git commit -m "feat: phase 2 remediation with secure iac and secret scanning controls"
```

## Escena H - (Opcional) Limpieza fuerte del historial de la rama demo (60-90 segundos)

**Que decir:**

"Si el historial antiguo de la rama conserva exposiciones, la mitigacion completa incluye reescritura controlada de la rama de demo."

**Que mostrar:**

```powershell
git checkout Demo
git checkout --orphan Demo-clean
git add .
git commit -m "chore: bootstrap secure baseline without leaked history"
git branch -M Demo
git push --force origin Demo
```

Despues valida:

```powershell
git --no-pager log --oneline --decorate --graph -n 10
.\gitleaks.exe detect --source . --config .\kryptos-terra\.gitleaks.toml --log-opts="--all" --report-format json --report-path .\kryptos-terra\gitleaks-fase2-historial.json --verbose --redact
Get-Content .\kryptos-terra\gitleaks-fase2-historial.json
```

## 4) Bloque de comandos completos (corrida continua)

```powershell
Set-Location "C:\Users\maria\Downloads\Kryptos-Terra_FDSI"

Get-Content .\kryptos-terra\infra-segura\main.tf
Get-Content .\kryptos-terra\infra-segura\database.tf
Get-Content .\kryptos-terra\infra-segura\storage.tf

@"
aws_region = "us-east-1"
app_ami = "ami-0c02fb55956c7d316"
db_admin_username = "<USUARIO_FAKE>"
db_admin_password = "<PASSWORD_FAKE>"
backup_api_token = "<TOKEN_FAKE>"
"@ | Set-Content .\kryptos-terra\infra-segura\terraform.auto.tfvars

.\gitleaks.exe detect --source . --config .\kryptos-terra\.gitleaks.toml --report-format json --report-path .\kryptos-terra\gitleaks-fase2-actual.json --verbose --redact
Get-Content .\kryptos-terra\gitleaks-fase2-actual.json

python -m pip install pre-commit
pre-commit install
pre-commit run --all-files

Get-Content .\kryptos-terra\.pre-commit-config.yaml
Get-Content .\kryptos-terra\.github\workflows\secret-scanner.yml

git add .\kryptos-terra\infra-segura\main.tf
git add .\kryptos-terra\infra-segura\database.tf
git add .\kryptos-terra\infra-segura\storage.tf
git add .\kryptos-terra\.pre-commit-config.yaml
git add .\kryptos-terra\.github\workflows\secret-scanner.yml
git add .\kryptos-terra\explicacion.md
git commit -m "feat: phase 2 remediation with secure iac and secret scanning controls"
```

## 5) Mensaje de cierre para el video

"La fase 2 deja una postura de seguridad mas madura: IaC sin secretos hardcodeados, controles preventivos locales, validacion automatizada en CI y evidencia verificable de mitigacion. Con esto pasamos de detectar el problema a gobernarlo de forma repetible."
