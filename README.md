# NovaDeploy IaC Secrets Demo

Demo para mostrar el problema de secretos en Infrastructure as Code (Terraform) y cómo mitigarlo con varias capas de protección.

## Contexto y objetivo

Startup ficticia **NovaDeploy** que gestiona su infraestructura con Terraform. El objetivo de la demo es enseñar:

- Cómo los secretos (AWS keys, passwords) se filtran al **historial de Git** aunque luego se "borren" del código.
- Cómo detectarlos de forma **reactiva** con herramientas de escaneo (Gitleaks).
- Cómo prevenir que lleguen al historial usando **pre-commit hooks**.
- Qué nos falta: pipeline en GitHub Actions con TruffleHog y Terraform seguro usando HashiCorp Vault.

## Estructura actual del repo

- `terraform/main_insecure.tf`
  - Terraform con proveedor AWS y un `aws_db_instance` **inseguro**, con:
    - `access_key` y `secret_key` hardcodeados (demo, no reales).
    - `username` y `password` de la base de datos hardcodeados.
  - Este archivo es el "escenario del problema" para el Acto 1.
- `.gitleaks.toml`
  - Configuración personalizada de Gitleaks con reglas demo:
    - `custom-aws-access-key` para detectar claves tipo `AKIA...`.
    - `custom-db-password` para detectar `SuperSecretPassword123!`.
- `.pre-commit-config.yaml`
  - Configuración de pre-commit para ejecutar Gitleaks antes de cada commit:
    - Usa el repo oficial `https://github.com/gitleaks/gitleaks`.
    - Hook `gitleaks` con `args: ["detect", "--staged", "--config", ".gitleaks.toml", "--verbose"]`.
- `.gitignore`
  - Config estándar para proyectos Terraform (ignora `.terraform`, `*.tfstate`, `*.tfvars`, etc.).

## Lo que ya hemos hecho

1. **Inicialización del repo Git local**
   - `git init`
   - Creamos la historia mínima para la demo:
     - Commit inicial con `main_insecure.tf` conteniendo secretos.
     - Commits posteriores donde se "borran" los secretos.

2. **Instalación de Gitleaks (CLI)**
   - Descargado `gitleaks.exe` para Windows (versión 8.30.1).
   - Ejecución básica sobre el repo:
     - `./gitleaks.exe detect --source .`
   - Como los secretos de demo no coincidían con las reglas por defecto, se creó `.gitleaks.toml` con reglas específicas.

3. **Escaneo del historial de Git con configuración personalizada**
   - Archivo `.gitleaks.toml` con reglas:
     - `AKIA[0-9A-Z]{16}` para claves de acceso AWS.
     - La password `SuperSecretPassword123!` de la base de datos.
   - Comando usado:
     - `./gitleaks.exe detect --source . --config .gitleaks.toml`
   - Resultado: Gitleaks encuentra **leaks en el historial** aunque el código actual esté limpio.

4. **Configuración de pre-commit + Gitleaks**
   - Instalación de pre-commit (vía Python):
     - `py -m pip install pre-commit`
   - Configuración del hook en `.pre-commit-config.yaml`:
     - Repo: `https://github.com/gitleaks/gitleaks`
     - `rev: v8.30.1`
     - Hook `gitleaks` con:
       ```yaml
       args: ["detect", "--staged", "--config", ".gitleaks.toml", "--verbose"]
       files: .*
       ```
   - Instalación del hook en el repo:
     - `py -m pre_commit install`
   - Estado actual: el hook se ejecuta en cada `git commit`. Falta afinar la configuración para que **falle siempre** cuando se intenta commitear los secretos de demo.

## Cosas pendientes / siguientes pasos

### 1. Afinar el pre-commit para que bloquee el commit inseguro

- Objetivo: que cualquier intento de commitear un secreto (por ejemplo el `access_key` o `password` de demo) haga que el commit **falle**.
- Tareas:
  - Verificar que las reglas de `.gitleaks.toml` se aplican también en el modo `--staged`.
  - Probar con archivos nuevos de prueba (por ejemplo `secrets.txt`) para confirmar que el hook detecta los patrones.
  - Ajustar `files:` o reglas si fuera necesario.

### 2. Crear el repo remoto en GitHub y hacer push

- Crear un repo vacío en GitHub, por ejemplo `novadeploy-iac-secrets-demo`.
- Conectarlo desde local:
  ```bash
  git remote add origin https://github.com/TU-USUARIO/novadeploy-iac-secrets-demo.git
  git branch -M main
  git push -u origin main
  ```
- A partir de aquí podremos usar **GitHub Actions** y **TruffleHog**.

### 3. Pipeline de GitHub Actions con TruffleHog (detección en el servidor)

- Crear `.github/workflows/secrets-scan.yml` con un workflow que:
  - Se ejecute en cada `push` y `pull_request`.
  - Use TruffleHog para escanear el repo (incluyendo historial).
  - Marque el workflow como **fallido** si se encuentran secretos y muestre el reporte en la UI de GitHub.
- Esto será la **segunda capa** de protección (detección centralizada en el pipeline).

### 4. Terraform seguro usando HashiCorp Vault

- Crear un nuevo archivo, por ejemplo `terraform/main_vault.tf`, que muestre la versión **correcta**:
  - Sin secretos hardcodeados.
  - Variables o data sources que obtienen los valores desde Vault.
  - Explicar en comentarios que aunque el código sea público, los secretos viven en Vault.
- Esto será la **tercera capa** de la demo (gestión estructural de secretos).

### 5. Documentar el guion de la demo (acto por acto)

- Acto 1: mostrar `terraform/main_insecure.tf`, hacer commit inseguro y limpiarlo "a mano".
- Acto 2: correr Gitleaks sobre el historial y demostrar que los secretos siguen vivos.
- Acto 3: enseñar el pre-commit hook y cómo evita que el secreto llegue al historial.
- Acto 4: mostrar la versión con Vault (`main_vault.tf`) y el pipeline con TruffleHog en GitHub.

## Cómo continuar (para tu compañera)

1. Leer este README para entender el contexto y el estado actual.
2. Confirmar que Gitleaks + `.gitleaks.toml` siguen funcionando con:
   ```bash
   ./gitleaks.exe detect --source . --config .gitleaks.toml
   ```
3. Trabajar en:
   - Afinar el pre-commit hook para que bloquee el commit inseguro de forma consistente.
   - Crear el repo en GitHub y añadir el workflow de TruffleHog.
   - Diseñar el ejemplo seguro con Vault (`main_vault.tf`).

Con esto debería quedar claro qué se ha hecho, qué componentes existen en el repo y qué falta por implementar para completar la demo end-to-end.
