# ClickHouse Kubernetes Deployment

Простое автоматическое разворачивание базы данных ClickHouse в Kubernetes.

## 📋 Техническое решение

### Архитектура

- **Single-инсталляция** - один pod с персистентным хранилищем
- **Helm-based** - параметризованная конфигурация через values.yaml
- **Автоматизация** - Makefile и bash-скрипты для управления

### Компоненты

- **ClickHouse Pod** - контейнер с выбранной версией ClickHouse
- **Persistent Volume** - хранение данных между перезапусками
- **ConfigMap** - конфигурация пользователей
- **Service** - сетевой доступ к ClickHouse

## 🚀 Быстрый старт

### Автоматическое развертывание (рекомендуется)

```bash
# Полное развертывание и тестирование
make deploy    # Установка ClickHouse
make test      # Проверка работы
make status    # Статус компонентов
make clean     # Удаление
```

### Ручное управление

```bash
# Через скрипты
./scripts/deploy.sh          # Развертывание
./scripts/test-connection.sh # Тестирование
./scripts/cleanup.sh         # Очистка

# Через Helm напрямую
helm install clickhouse ./helm/clickhouse -n clickhouse --create-namespace
```

## ⚙️ Конфигурация

### Изменение версии ClickHouse

В файле `helm/clickhouse/values.yaml`:

```yaml
image:
  repository: clickhouse/clickhouse-server
  tag: "24.12"  # Желаемая версия
```

### Добавление пользователей

В файле `helm/clickhouse/values.yaml`:

```yaml
users:
  - name: admin
    password: "admin123"
  - name: readonly
    password: "readonly123"
```

### Настройка ресурсов

```yaml
storage:
  size: 1Gi
  className: "standard"

service:
  type: ClusterIP
  port: 8123
```

## 🔧 Требования

- **Kubernetes кластер (Minikube рекомендован)**
- **Helm 3.0+**
- **kubectl**

## 📁 Структура проекта

```bash
.
├── helm/                 # Helm chart
│   └── clickhouse/
│       ├── Chart.yaml           # Метаданные chart
│       ├── values.yaml          # Параметры конфигурации
│       └── templates/           # Kubernetes манифесты
│           ├── deployment.yaml  # Развертывание ClickHouse
│           ├── service.yaml     # Сетевой доступ
│           ├── pvc.yaml         # Персистентное хранилище
│           └── configmap-users.yaml  # Пользователи БД
├── scripts/              # Скрипты автоматизации
│   ├── deploy.sh         # Развертывание
│   ├── test-connection.sh # Тестирование
│   └── cleanup.sh        # Очистка
├── Makefile              # Управление командами
└── README.md             # Документация
```

## 🧪 Проверка работы

### Тестирование подключения

```bash
# Port-forward для локального доступа
kubectl port-forward -n clickhouse svc/clickhouse 8123:8123

# Проверка HTTP API
curl http://localhost:8123
# Ожидаемый результат: "Ok."

# Проверка через clickhouse-client
kubectl exec -it -n clickhouse deployment/clickhouse -- \
  clickhouse-client --user=default --password=password --query "SELECT version()"
```

### Проверка пользователей

Все пользователи из конфигурации должны успешно аутентифицироваться:

1. Пользователь default:

    ```bash
    kubectl exec -it -n clickhouse deployment/clickhouse -- \
      clickhouse-client --user=default --password=password --query "SELECT version()"
    ```

2. Пользователь analyst:

    ```bash
    kubectl exec -it -n clickhouse deployment/clickhouse -- \
      clickhouse-client --user=analyst --password=analyst123 --query "SHOW DATABASES"
    ```
  
3. Пользователь readonly:

    ```bash
    kubectl exec -it -n clickhouse deployment/clickhouse -- \
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
kubectl logs -n clickhouse deployment/clickhouse
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
