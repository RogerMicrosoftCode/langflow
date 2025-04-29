<!-- markdownlint-disable MD030 -->

![Langflow logo](./docs/static/img/langflow-logo-color-black-solid.svg)


[![Release Notes](https://img.shields.io/github/release/langflow-ai/langflow?style=flat-square)](https://github.com/langflow-ai/langflow/releases)
[![PyPI - License](https://img.shields.io/badge/license-MIT-orange)](https://opensource.org/licenses/MIT)
[![PyPI - Downloads](https://img.shields.io/pypi/dm/langflow?style=flat-square)](https://pypistats.org/packages/langflow)
[![GitHub star chart](https://img.shields.io/github/stars/langflow-ai/langflow?style=flat-square)](https://star-history.com/#langflow-ai/langflow)
[![Open Issues](https://img.shields.io/github/issues-raw/langflow-ai/langflow?style=flat-square)](https://github.com/langflow-ai/langflow/issues)
[![Open in HuggingFace](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-Spaces-blue)](https://huggingface.co/spaces/Langflow/Langflow?duplicate=true)
[![Twitter](https://img.shields.io/twitter/url/https/twitter.com/langflow-ai.svg?style=social&label=Follow%20%40Langflow)](https://twitter.com/langflow)
[![YouTube Channel Views](https://img.shields.io/youtube/channel/views/UCn2bInQrjdDYKEEmbpwblLQ)](https://www.youtube.com/@Langflow)


[Langflow](https://langflow.org) is a powerful tool for building and deploying AI-powered agents and workflows. It provides developers with both a visual authoring experience and a built-in API server that turns every agent into an API endpoint that can be integrated into applications built on any framework or stack. Langflow comes with batteries included and supports all major LLMs, vector databases and a growing library of AI tools.

## ✨ Highlight features

1. **Visual Builder** to get started quickly and iterate. 
1. **Access to Code** so developers can tweak any component using Python.
1. **Playground** to immediately test and iterate on their flows with step-by-step control.
1. **Multi-agent** orchestration and conversation management and retrieval.
1. **Deploy as an API** or export as JSON for Python apps.
1. **Observability** with LangSmith, LangFuse and other integrations.
1. **Enterprise-ready** security and scalability.

## ⚡️ Quickstart

Langflow works with Python 3.10 to 3.13.

Install with uv **(recommended)** 

```shell
uv pip install langflow
```

Install with pip

```shell
pip install langflow
```

## 📦 Deployment

### Self-managed

Langflow is completely open source and you can deploy it to all major deployment clouds. Follow this [guide](https://docs.langflow.org/deployment-docker) to learn how to use Docker to deploy Langflow.

### Fully-managed by DataStax

DataStax Langflow is a full-managed environment with zero setup. Developers can [sign up for a free account](https://astra.datastax.com/signup?type=langflow) to get started.

## ⭐ Stay up-to-date

Star Langflow on GitHub to be instantly notified of new releases.

![Star Langflow](https://github.com/user-attachments/assets/03168b17-a11d-4b2a-b0f7-c1cce69e5a2c)

# Langflow Docker Local Deployment

# Descargar la imagen de Langflow
docker pull langflowai/langflow:latest

# Ejecutar el contenedor
docker run -p 7860:7860 langflowai/langflow:latest

# Langflow OpenShift Deployment

Este repositorio contiene los archivos necesarios para desplegar Langflow en OpenShift, utilizando una base de datos PostgreSQL en Azure.

## Descripción

Langflow es una UI para LangChain que facilita la creación de flujos de trabajo de procesamiento de lenguaje natural. Este despliegue utiliza:

- Langflow como frontend y backend
- Base de datos PostgreSQL en Azure para almacenamiento persistente
- OpenShift como plataforma de orquestación de contenedores

## Requisitos previos

- Acceso a un clúster de OpenShift
- Cliente de OpenShift (`oc`) instalado
- Base de datos PostgreSQL en Azure (ya configurada)

## Configuración de la base de datos

Ya tenemos una instancia de PostgreSQL en Azure con los siguientes parámetros:

```
Host: microsweeper-30d70f389agbbpwd.postgres.database.azure.com
Usuario: myAdmin@microsweeper-30d70f389agbbpwd
Contraseña: adminUserGBB-30d70f389agbbpwd
String de conexión: postgresql://myAdmin@microsweeper-30d70f389agbbpwd:adminUserGBB-30d70f389agbbpwd@microsweeper-30d70f389agbbpwd.postgres.database.azure.com/postgres?sslmode=require
```

## Instrucciones de despliegue

### 1. Iniciar sesión en OpenShift

```bash
oc login <URL-del-cluster>
```

### 2. Crear un nuevo proyecto

```bash
oc new-project langflow-project
```

### 3. Crear Secret para la conexión a la base de datos

```bash
oc create secret generic postgres-azure-secret \
  --from-literal=POSTGRES_USER="myAdmin@microsweeper-30d70f389agbbpwd" \
  --from-literal=POSTGRES_PASSWORD="adminUserGBB-30d70f389agbbpwd" \
  --from-literal=POSTGRES_DB="postgres" \
  --from-literal=POSTGRES_HOST="microsweeper-30d70f389agbbpwd.postgres.database.azure.com" \
  --from-literal=LANGFLOW_DATABASE_URL="postgresql://myAdmin@microsweeper-30d70f389agbbpwd:adminUserGBB-30d70f389agbbpwd@microsweeper-30d70f389agbbpwd.postgres.database.azure.com/postgres?sslmode=require"
```

> **Nota importante**: Observa que usamos `postgresql://` en lugar de `postgres://` y no codificamos el símbolo `@` como `%40` en la URL de conexión, lo que evita errores de validación en Langflow.

### 4. Crear PersistentVolumeClaim para Langflow

```bash
oc create -f langflow-pvc.yaml
```

### 5. Desplegar Langflow

```bash
oc create -f langflow-deployment.yaml
oc create -f langflow-service.yaml
oc create -f langflow-route.yaml
```

## Archivos de despliegue

### langflow-pvc.yaml

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: langflow-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### langflow-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: langflow
  labels:
    app: langflow
spec:
  replicas: 1
  selector:
    matchLabels:
      app: langflow
  template:
    metadata:
      labels:
        app: langflow
    spec:
      # OpenShift requiere que los contenedores se ejecuten con usuarios no privilegiados
      securityContext:
        # Usar un rango permitido de usuarios en OpenShift (varía según el clúster)
        fsGroup: 1000770000
      initContainers:
      - name: init-permissions
        image: registry.access.redhat.com/ubi8/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
        - |
          echo "Configurando permisos para los directorios..."
          mkdir -p /mnt/langflow/alembic
          mkdir -p /mnt/langflow/cache
          touch /mnt/langflow/alembic/alembic.log
          chmod -R 777 /mnt/langflow
          ls -la /mnt/langflow
        volumeMounts:
        - name: langflow-data
          mountPath: /mnt/langflow
      containers:
      - name: langflow
        image: langflowai/langflow:latest
        ports:
        - containerPort: 7860
        env:
        - name: LANGFLOW_DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: postgres-azure-secret
              key: LANGFLOW_DATABASE_URL
        - name: LANGFLOW_CONFIG_DIR
          value: "/app/langflow"
        - name: LANGFLOW_PORT
          value: "7860"
        - name: LANGFLOW_ALEMBIC_LOG
          value: "/mnt/langflow/alembic/alembic.log"
        # Redirigir el directorio cache al volumen con permisos
        - name: XDG_CACHE_HOME
          value: "/mnt/langflow/cache"
        volumeMounts:
        - name: langflow-data
          mountPath: "/app/langflow"
        - name: langflow-data
          mountPath: "/app/.venv/lib/python3.12/site-packages/langflow/alembic"
          subPath: "alembic"
        - name: langflow-data
          mountPath: "/.cache"
          subPath: "cache"
      volumes:
      - name: langflow-data
        persistentVolumeClaim:
          claimName: langflow-data-pvc
```

> **Nota importante para OpenShift**: Esta configuración actualizada también maneja el directorio `/.cache` a través de volúmenes y la variable de entorno `XDG_CACHE_HOME`. Si encuentras errores de permisos adicionales, puedes seguir el mismo patrón: crear directorios en el initContainer y montarlos en las ubicaciones problemáticas.

### langflow-service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: langflow
spec:
  selector:
    app: langflow
  ports:
  - name: http  # Añadir un nombre al puerto para mejor identificación
    port: 7860
    targetPort: 7860
  type: ClusterIP
```

### langflow-route.yaml

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: langflow
spec:
  to:
    kind: Service
    name: langflow
  port:
    targetPort: 7860
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

## Para desplegar imagen personalizada con flujos precargados

Si deseas desplegar una imagen personalizada que contenga tus flujos de trabajo, crea un Dockerfile como el siguiente:

```Dockerfile
FROM langflowai/langflow:latest
RUN mkdir -p /app/flows
COPY ./flows/*.json /app/flows/
ENV LANGFLOW_LOAD_FLOWS_PATH=/app/flows
```

Luego construye y sube la imagen:

```bash
docker build -t miusuario/langflow-custom:1.0.0 .
docker push miusuario/langflow-custom:1.0.0
```

Y modifica el archivo `langflow-deployment.yaml` para usar tu imagen personalizada.

## Verificación

Para verificar que el despliegue se ha realizado correctamente:

```bash
# Ver la URL de la ruta
oc get route langflow

# Verificar que los pods están funcionando
oc get pods
```

## Solución de problemas

### Errores comunes y sus soluciones

#### Error de restricciones de seguridad en OpenShift

Si encuentras un error como:
```
FailedCreate pods is forbidden: unable to validate against any security context constraint
```

Este error ocurre porque OpenShift tiene políticas de seguridad estrictas que impiden ejecutar contenedores como root. En este caso:

1. **Verifica los rangos de UID/GID permitidos en tu proyecto**:
   ```bash
   oc describe project <nombre-proyecto> | grep openshift.io/sa
   ```
   
2. **Ajusta el `fsGroup` en el archivo deployment según el rango permitido**:
   Normalmente estarán en un rango como 1000770000-1000779999.

3. **Si necesitas permisos adicionales, solicita una SCC menos restrictiva**:
   ```bash
   # Solo administradores del clúster pueden hacer esto
   oc adm policy add-scc-to-user anyuid -z default -n langflow-project
   ```

4. **Alternativa: Usa una estrategia basada en montajes de volúmenes** como se muestra en el deployment actualizado.

#### Error de permisos en archivos o directorios

Si encuentras un error como:
```
PermissionError: [Errno 13] Permission denied: '/app/.venv/lib/python3.12/site-packages/langflow/alembic/alembic.log'
```

Nuestra configuración actualizada debería resolver este problema mediante:

1. El uso de un contenedor de inicialización para preparar los directorios y configurar permisos
2. El montaje de subdirectorios específicos desde el volumen persistente
3. La configuración de la variable de entorno `LANGFLOW_ALEMBIC_LOG` para redirigir los logs

Si persiste, verifica:
- Que el PVC se haya montado correctamente
- Que el contenedor de inicialización haya completado con éxito
- Los logs del pod para ver detalles adicionales

#### Error de validación con la URL de la base de datos

Si ves un error como:
```
ValidationError: database_url - Value error, Invalid database_url provided
```

Asegúrate de:
1. Usar `postgresql://` en lugar de `postgres://`
2. No codificar los caracteres especiales como `@` a `%40` en la URL
3. Verificar que el formato de la URL sea correcto

#### Error de validación con el puerto

Si encuentras un error como:
```
port - Input should be a valid integer, unable to parse string
```

Asegúrate de:
1. Definir el puerto como un string en la variable de entorno: `LANGFLOW_PORT: "7860"`
2. Nombrar los puertos en el servicio como se muestra en `langflow-service.yaml`

### Verificaciones generales

Si tienes problemas con la conexión a la base de datos o el despliegue, verifica:

1. Los logs del pod y el contenedor de inicialización:
   ```bash
   oc logs $(oc get pods -l app=langflow -o name)
   oc logs $(oc get pods -l app=langflow -o name) -c init-permissions
   ```

2. Que los secretos estén correctamente configurados:
   ```bash
   oc describe secret postgres-azure-secret
   ```

3. Los eventos del pod para ver problemas con el montaje de volúmenes o permisos:
   ```bash
   oc describe pod $(oc get pods -l app=langflow -o name)
   ```