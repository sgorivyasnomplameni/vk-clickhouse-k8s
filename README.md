# ClickHouse Kubernetes Deployment

Single-инсталляция ClickHouse с сохранением данных, безопасными пользователями и автоматизацией развертывания в Kubernetes.

## Архитектура

- Один ClickHouse instance
- 🧠 StatefulSet для гарантированного хранения состояния
- 💾 PersistentVolumeClaim для данных
- 🔐 Secret с пользователями и паролями
- 🌐 ClusterIP Service для доступа к API
- 🕳️ Headless Service для устойчивого DNS-имени пода
- 🎛 Управление через Helm + Makefile

## 🚀 Быстрый старт

Для Minikube (рекомендуется для тестирования)

```bash
minikube start
```
### Автоматическое развертывание

```bash
make deploy     # Развернуть ClickHouse
make test       # Проверить соединение и пользователей
make status     # Проверка ресурсов
make clean      # Удаление всего
```

### Ручное управление

```bash
./scripts/deploy.sh
./scripts/test-connection.sh
./scripts/cleanup.sh
```

или через Helm:

```bash
helm install clickhouse ./helm/clickhouse -n clickhouse --create-namespace
```

## ⚙️ Конфигурация

Редактируется в `helm/clickhouse/values.yaml`:

### Изменение версии ClickHouse

```yaml
image:
  repository: clickhouse/clickhouse-server
  tag: "24.12"
```

### Настройка хранилища

```yaml
storage:
  size: 1Gi
  className: "standard"
```

### Сетевой доступ

```yaml
service:
  port: 8123
```

### Управление пользователями

```yaml
passwords:
  default: "password"
  analyst: "analyst123"
  readonly: "readonlypass"
```

Пароли автоматически превращаются в Secret.

## 🔧 Требования

- **Kubernetes кластер (Minikube рекомендуется для локальной разработки)**
- **Helm 3.0+**
- **kubectl**

## 📁 Структура проекта

```bash
.
├── helm/
│   └── clickhouse/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── statefulset.yaml
│           ├── service.yaml      
│           ├── headless-service.yaml
│           └── secret-users.yaml
├── scripts/
│   ├── deploy.sh
│   ├── test-connection.sh
│   └── cleanup.sh
├── Makefile
└── README.md
```

## 🧪 Проверка работы

### Через локальный порт-форвард

```bash
kubectl port-forward -n clickhouse svc/clickhouse 8123:8123
curl http://localhost:8123
```

Ожидается:

```bash
Ok.
```

### Проверка пользователей

Все пользователи из конфигурации должны успешно аутентифицироваться:

1. Пользователь default:

    ```bash
    kubectl exec -it -n clickhouse statefulset/clickhouse -- \
      clickhouse-client --user=default --password=password --query "SELECT version()"
    ```

2. Пользователь analyst:

    ```bash
    kubectl exec -it -n clickhouse statefulset/clickhouse -- \
      clickhouse-client --user=analyst --password=analyst123 --query "SHOW DATABASES"
    ```
  
3. Пользователь readonly:

    ```bash
    kubectl exec -it -n clickhouse statefulset/clickhouse -- \
      clickhouse-client --user=readonly --password=readonlypass --query "SELECT 1"
    ```

**Ожидаемые результаты:**

- ✅ Все команды выполняются без ошибок аутентификации

- ✅ SELECT version() возвращает версию ClickHouse

- ✅ SHOW DATABASES возвращает список баз данных

- ✅ SELECT 1 возвращает значение 1

### Автоматическая проверка всех пользователей

```bash
# Одной командой через make
make test

# Или через скрипт
./scripts/test-connection.sh
```

**При успешной проверке вы увидите:**

```bash
✅ User default: authentication successful
✅ User analyst: authentication successful  
✅ User readonly: authentication successful
```

## 🗑️ Удаление

```bash
# Полное удаление
make clean

# Или через Helm
helm uninstall clickhouse -n clickhouse
kubectl delete namespace clickhouse
```

## 💡 Особенности реализации

- **Параметризация:** Все настройки вынесены в values.yaml
- **Безопасность:** Пароли настраиваются через конфигурацию
- **Надежность:** Персистентное хранилище сохраняет данные
- **Автоматизация:** Скрипты и Makefile упрощают управление

## 🆘 Устранение неполадок

### Pod не запускается

```bash
kubectl describe pod -n clickhouse -l app=clickhouse
kubectl logs -n clickhouse clickhouse-0
```

### Проблемы с хранилищем

```bash
kubectl get pvc -n clickhouse
kubectl describe pvc -n clickhouse clickhouse-storage
```

### Сетевые проблемы

```bash
kubectl get services -n clickhouse
kubectl describe service -n clickhouse clickhouse
```
