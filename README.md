# ClickHouse Kubernetes Deployment

Простое автоматическое разворачивание базы данных ClickHouse в Kubernetes.

## Технические характеристики

- **Single-инсталляция**: один pod с персистентным хранилищем
- **Версия ClickHouse**: настраивается через `values.yaml`
- **Пользователи**: список пользователей с паролями настраивается через `values.yaml`

## Установка

1. Создаем namespace и устанавливаем ClickHouse:

    ```bash
    helm install clickhouse ./helm/clickhouse -n clickhouse --create-namespace
    ```

2. Проверяем статус:

    ```bash
    kubectl get pods -n clickhouse
    kubectl get services -n clickhouse
    ```

## Настройка

## Изменение версии ClickHouse

В файле `values.yaml`:

```YAML
image:
  tag: "23.11"  # желаемая версия
```  

## Добавление пользователей

В файле `values.yaml`:

```YAML
users:
  - name: admin
    password: "admin123"
  - name: readonly
    password: "readonly123"
```  

## Доступ к ClickHouse

1. Port-forward для локального доступа:

    ```bash
    kubectl port-forward svc/clickhouse 8123:8123 -n clickhouse
    ```

2. Проверка подключения:

    ```bash
    curl http://localhost:8123
    ```

## Удаление

```bash
helm uninstall clickhouse -n clickhouse
```
