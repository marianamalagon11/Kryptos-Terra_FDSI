# Explicacion de la Fase 1 - Kryptos Terra

## Checklist de esta entrega

- [x] Documentar todo lo implementado para la fase 1.
- [x] Explicar paso a paso que hace cada parte del demo.
- [x] Conectar cada accion con el objetivo academico de la fase 1.
- [x] Incluir guion practico de que decir y que hacer en video.
- [x] Dejar comandos de PowerShell listos para copiar y ejecutar.

## 1) Que se hizo en el proyecto

En esta fase se preparo un escenario **intencionalmente inseguro** para demostrar una falla comun en IaC:
**poner secretos directo en Terraform y luego creer que borrarlos en otro commit ya resuelve el problema**.

Se crearon estos componentes:

- `kryptos-terra/infra-insegura/main.tf`
  - Proveedor AWS con `access_key` y `secret_key` hardcodeadas (falsas, formato realista).
  - Region `us-east-1`.
  - Recurso EC2 `t3.micro` con tags de S.A.M.J. Global Services en `production`.

- `kryptos-terra/infra-insegura/database.tf`
  - Recurso RDS MySQL `db.t3.micro`.
  - Usuario y password hardcodeados en el codigo.
  - Tags de la empresa y ambiente productivo.

- `kryptos-terra/infra-insegura/storage.tf`
  - Bucket S3 `samj-global-backups-prod`.
  - Token API ficticio con patron `SAMJ-...` para deteccion personalizada futura.

- `kryptos-terra/.gitleaks.toml`
  - Hereda reglas por defecto de Gitleaks con `extend`.
  - Agrega regla personalizada `samj-api-token` para detectar tokens `SAMJ-`.
  - Incluye `allowlist` para excluir el propio `.gitleaks.toml` y evitar falsos positivos.

Adicionalmente, se dejo estructura base para fases siguientes:

- `kryptos-terra/infra-segura/*`
- `kryptos-terra/vault/setup-vault.sh`
- `kryptos-terra/.github/workflows/secret-scanner.yml`
- `kryptos-terra/.pre-commit-config.yaml`
- `kryptos-terra/README.md`

## 2) Por que esto es exactamente la Fase 1

La fase 1 no busca resolver el problema; busca **mostrar evidencia del problema**.

La idea pedagogica es:

1. El desarrollador comete el error (secreto en codigo).
2. Lo corrige superficialmente en un commit posterior.
3. Se demuestra que Git conserva el historial completo.
4. Gitleaks confirma que los secretos siguen detectables en commits anteriores.

Con esto demuestras el mensaje central de la fase:
**"Borrar en la version actual no elimina la exposicion historica"**.

## 3) Guion para el video: que decir y que hacer

## Escena A - Contexto (30-45 segundos)

**Que decir:**

"Este es Kryptos Terra, un demo academico de seguridad en Infraestructura como Codigo para S.A.M.J. Global Services. En esta fase 1 vamos a mostrar una mala practica: credenciales hardcodeadas en Terraform y un falso arreglo que no limpia el historial de Git."

**Que hacer:**

- Mostrar el arbol del proyecto.
- Entrar a `infra-insegura`.

```powershell
Set-Location "C:\Users\maria\Downloads\Kryptos-Terra_FDSI"
Get-ChildItem .\kryptos-terra\
Get-ChildItem .\kryptos-terra\infra-insegura\
```

## Escena B - Evidencia del error inicial (1-2 minutos)

**Que decir:**

"Aqui vemos secretos en texto plano: claves de AWS, credenciales de base de datos y un token de API. Esto representa un error real de desarrollo rapido sin controles de seguridad."

**Que hacer:**

- Abrir cada archivo y remarcar visualmente las lineas sensibles.

```powershell
Get-Content .\kryptos-terra\infra-insegura\main.tf
Get-Content .\kryptos-terra\infra-insegura\database.tf
Get-Content .\kryptos-terra\infra-insegura\storage.tf
```

## Escena C - Primer commit inseguro (30-45 segundos)

**Que decir:**

"Voy a registrar esta configuracion base tal como la subiria un desarrollador distraido."

**Que hacer:**

```powershell
git add .\kryptos-terra\infra-insegura\main.tf
git add .\kryptos-terra\infra-insegura\database.tf
git add .\kryptos-terra\infra-insegura\storage.tf
git commit -m "feat: add base infrastructure config for SAMJ Global Services"
```

## Escena D - Falso arreglo y segundo commit (1 minuto)

**Que decir:**

"Ahora simulamos que el desarrollador descubre el error y borra las credenciales del estado actual. A simple vista parece resuelto."

**Que hacer:**

```powershell
(Get-Content .\kryptos-terra\infra-insegura\main.tf) -replace 'AKIA7QW9X2V4B8N6M3K1', 'REMOVED' -replace 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLE1', 'REMOVED' | Set-Content .\kryptos-terra\infra-insegura\main.tf
(Get-Content .\kryptos-terra\infra-insegura\database.tf) -replace 'samj_admin', 'REMOVED' -replace 'Samj2024\$Secure!DB', 'REMOVED' | Set-Content .\kryptos-terra\infra-insegura\database.tf
(Get-Content .\kryptos-terra\infra-insegura\storage.tf) -replace 'SAMJ-aB3xK9mP2nQ7rT1vW4yZ6cE8hJ0dL5fG', 'REMOVED' | Set-Content .\kryptos-terra\infra-insegura\storage.tf

git add .\kryptos-terra\infra-insegura\main.tf
git add .\kryptos-terra\infra-insegura\database.tf
git add .\kryptos-terra\infra-insegura\storage.tf
git commit -m "fix: remove hardcoded credentials from config files"
```

## Escena E - Historial y falsa sensacion de seguridad (30-45 segundos)

**Que decir:**

"El codigo actual parece limpio, pero revisemos el historial: hay dos commits, y el primero contiene la exposicion."

**Que hacer:**

```powershell
git --no-pager log --oneline --decorate --graph -n 10
Get-Content .\kryptos-terra\infra-insegura\main.tf
Get-Content .\kryptos-terra\infra-insegura\database.tf
Get-Content .\kryptos-terra\infra-insegura\storage.tf
```

## Escena F - Momento de impacto con Gitleaks (1 minuto)

**Que decir:**

"Ahora ejecutamos Gitleaks sobre todo el historial de Git. Aunque hoy el archivo este limpio, el scanner va a encontrar secretos en commits previos."

**Que hacer:**

```powershell
.\gitleaks.exe detect --source . --config .\kryptos-terra\.gitleaks.toml --log-opts="--all" --report-format json --report-path .\kryptos-terra\gitleaks-historial.json --verbose --redact
Get-Content .\kryptos-terra\gitleaks-historial.json
```

## Escena G - Cierre de fase (20-30 segundos)

**Que decir:**

"Conclusion de la fase 1: no basta con borrar secretos en un commit nuevo. Si llegaron a Git, quedan en el historial y siguen siendo detectables. En la siguiente fase veremos la remediacion: limpieza de historial, gestion segura de secretos y automatizacion preventiva en CI/CD."

## 4) Mensaje academico clave que debes reforzar

- El problema es de **ciclo de vida del secreto**, no solo de codigo actual.
- Git es inmutable por diseño: cada commit preserva evidencia historica.
- El escaneo debe incluir historial (`--log-opts="--all"`), no solo snapshot actual.
- La seguridad en IaC requiere prevencion + deteccion + remediacion.

## 5) Tip para que el video se vea profesional

- Haz zoom en las lineas con secretos antes y despues del falso arreglo.
- Deja visible el hash de commits cuando muestres `git log`.
- Abre el reporte JSON de Gitleaks y resalta campos `RuleID`, `File`, `Commit`.
- Cierra con una frase corta: "El secreto borrado del archivo no fue borrado de la historia".

## 6) Nota tecnica rapida

Si `gitleaks.exe` falla por incompatibilidad en Windows, reemplaza el binario por la version correcta para Windows x64 y ejecuta el mismo comando.

