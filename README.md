# Kryptos Terra — Protección de Secretos en Infraestructura como Código



## Descripción General

**Kryptos Terra** es una propuesta de seguridad en tres capas diseñada para evitar la exposición de secretos en proyectos de Infraestructura como Código (IaC). El sistema demuestra cómo prevenir, detectar y eliminar completamente la presencia de credenciales dentro del código fuente y su historial.

El enfoque combina validaciones locales, análisis automatizados en pipeline y gestión centralizada de secretos para garantizar que ninguna credencial llegue a producción sin ser controlada.

---

## Objetivo

Demostrar, mediante un caso práctico, cómo una mala gestión de secretos puede comprometer un repositorio y cómo aplicar una arquitectura de seguridad en capas para mitigar este riesgo de forma estructural.

---

## Arquitectura de Seguridad

El sistema se compone de tres capas complementarias:

### Capa 1 — Prevención Local (Pre-commit con Gitleaks)

- **Herramienta:** Gitleaks  
- **Función:** Detectar credenciales antes del commit  
- **Resultado:** Bloquea commits que contengan secretos

**Ventaja:**  
Previene la introducción de secretos desde el origen.

**Limitación:**  
Depende de que el desarrollador tenga el hook activo.

---

### Capa 2 — Detección en CI/CD (TruffleHog)

- **Herramienta:** TruffleHog  
- **Función:** Detectar secretos en cualquier commit, incluso antiguos  
- **Resultado:** Bloquea merges si hay hallazgos

**Ventaja:**  
No puede ser evitado por desarrolladores individuales.

---

### Capa 3 — Gestión de Secretos (HashiCorp Vault)

- **Herramienta:** HashiCorp Vault  
- **Función:** Almacenar y proveer secretos en tiempo de ejecución  
- **Resultado:** El código solo contiene referencias, no valores reales

**Ventaja:**  
Elimina el problema de raíz.

---

## Caso de Estudio

Se implementa un repositorio de ejemplo que simula la infraestructura de una aplicación:

- Instancia en la nube
- Base de datos
- Token de API

### Escenario Vulnerable

**Fase inicial:**

- Se incluyen credenciales en texto plano en archivos Terraform.
- Se realiza un commit con secretos reales (simulados).
- Se intenta corregir eliminando las credenciales en un segundo commit.

> **Resultado:**  
> El historial conserva los secretos expuestos.

---

## Implementación

### Requisitos

- Terraform >= 1.5  
- Git  
- Gitleaks  
- TruffleHog  
- HashiCorp Vault  

---

### Fase 1 — Repositorio Vulnerable

Se crea la infraestructura con credenciales hardcodeadas:

```hcl
access_key = "AKIAIOSFODNN7EXAMPLE"
password   = "123456"
```

Se realiza un commit inicial con estos valores.

Posteriormente, se eliminan en un segundo commit.

> **Resultado:**  
> El historial sigue expuesto.

---

### Fase 2 — Seguridad en Capas de Detección

#### Pre-commit con Gitleaks

Se configura Gitleaks como hook:

```bash
pre-commit install
```

> **Resultado:**  
> Bloquea nuevos commits con secretos.

#### Pipeline con TruffleHog

Se configura GitHub Actions para escaneo automático:

- Se ejecuta en `push` y `pull request`
- Analiza todo el historial

> **Resultado:**  
> Detecta secretos históricos y bloquea el merge.

---

### Fase 3 — Solución Estructural con Vault

1. **Iniciar Vault**
    ```bash
    vault server -dev
    ```
2. **Configurar entorno**
    ```bash
    export VAULT_ADDR='http://127.0.0.1:8200'
    export VAULT_TOKEN='<root_token>'
    ```
3. **Cargar secretos**
    ```bash
    vault kv put secret/samj/aws access_key="..." secret_key="..."
    vault kv put secret/samj/database username="admin" password="..."
    vault kv put secret/samj/api token="..."
    ```
4. **Integrar Vault en Terraform**

    ```hcl
    provider "vault" {
      address = "http://127.0.0.1:8200"
      token   = var.vault_token
    }

    data "vault_kv_secret_v2" "aws_creds" {
      mount = "secret"
      name  = "samj/aws"
    }

    provider "aws" {
      access_key = data.vault_kv_secret_v2.aws_creds.data["access_key"]
      secret_key = data.vault_kv_secret_v2.aws_creds.data["secret_key"]
    }
    ```

> **Resultado:**  
> El código deja de contener secretos.

---

## Validación

### Gitleaks

```bash
gitleaks detect --source . --verbose
```

> **Resultado esperado:**  
> 0 leaks found

### TruffleHog

```bash
trufflehog git file://. --only-verified
```

> **Resultado esperado:**  
> Sin hallazgos verificados.

---

## Resultados

**Antes:**

- Credenciales en archivos Terraform
- Secretos visibles en historial
- Alto riesgo de exposición

**Después:**

- Código sin secretos
- Validación automática en commits y pipeline
- Vault como única fuente de verdad

---

## Conclusión

Kryptos Terra demuestra que la seguridad en IaC no debe depender únicamente de herramientas de detección. La combinación de prevención, monitoreo y gestión centralizada permite eliminar completamente la exposición de secretos.

La implementación reduce la superficie de ataque sin afectar significativamente el flujo de trabajo del desarrollador.

---

## Recomendaciones

- Rotar credenciales expuestas en historial
- Evitar uso de valores hardcodeados
- Integrar Vault en entornos productivos con autenticación segura
- Mantener validaciones automatizadas activas

---

## Autor

Proyecto académico de demostración de seguridad en Infraestructura como Código, conformado por:

- **Mariana Malagón Tochoy**
- **Sergio Alejandro Idarraga Torres**
- **Jacobo Diaz Alvarado**
- **Allan Steef Contreras Rodriguez**
