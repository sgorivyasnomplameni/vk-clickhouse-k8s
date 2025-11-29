#!/bin/bash

check_status() {
    echo "📊 Cluster Status:"
    kubectl get nodes
    echo ""

    echo "📦 ClickHouse Resources:"
    kubectl get all,pvc -n clickhouse
    echo ""
}

get_password() {
    local user=$1
    # Получаем весь XML и парсим пароль для конкретного пользователя
    kubectl get secret clickhouse-users -n clickhouse -o jsonpath="{.data.users\.xml}" | base64 --decode | \
    grep -A1 "<$user>" | grep "<password>" | sed 's/<password>//g' | sed 's/<\/password>//g' | tr -d ' '
}

test_connection() {
    echo "🧪 Testing ClickHouse HTTP..."

    kubectl port-forward -n clickhouse svc/clickhouse 8123:8123 >/dev/null 2>&1 &
    PORT_PID=$!
    sleep 2

    if curl -s http://localhost:8123 | grep -q "Ok"; then
        echo "✨ HTTP API works"
    else
        echo "❌ HTTP API test failed"
    fi

    kill $PORT_PID >/dev/null 2>&1

    echo ""
    echo "👥 Testing users..."

    for user in default analyst readonly; do
        password=$(get_password $user)
        if kubectl exec -n clickhouse clickhouse-0 -- \
            clickhouse-client --user=$user --password="$password" \
            --query="SELECT 1" >/dev/null 2>&1; then
            echo "✅ $user authentication OK"
        else
            echo "❌ $user authentication failed"
        fi
    done
}

case "${1:-test}" in
    "status")
        check_status
        ;;
    "test"|*)
        check_status
        test_connection
        ;;
esac