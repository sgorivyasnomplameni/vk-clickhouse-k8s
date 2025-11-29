#!/bin/bash

check_status() {
    echo "📊 Cluster Status:"
    kubectl get nodes
    echo ""
    
    echo "📦 ClickHouse Resources:"
    kubectl get all,pvc -n clickhouse
    echo ""
}

test_connection() {
    echo "🧪 Testing ClickHouse connection..."
    
    # Тестируем HTTP API
    if kubectl port-forward -n clickhouse svc/clickhouse 8123:8123 >/dev/null 2>&1 & then
        PORT_FORWARD_PID=$!
        sleep 2
        
        if curl -s http://localhost:8123 | grep -q "Ok"; then
            echo "✅ HTTP API is working"
        else
            echo "❌ HTTP API test failed"
        fi
        
        kill $PORT_FORWARD_PID 2>/dev/null
    fi

    # Тестируем пользователей
    echo "👥 Testing users..."
    
    for user in default analyst readonly; do
        if kubectl exec -n clickhouse deployment/clickhouse -- clickhouse-client \
            --user=$user --password=$(get_password $user) --query="SELECT 1" >/dev/null 2>&1; then
            echo "✅ User $user: authentication successful"
        else
            echo "❌ User $user: authentication failed"
        fi
    done
}

get_password() {
    case $1 in
        "default") echo "password" ;;
        "analyst") echo "analyst123" ;;
        "readonly") echo "readonlypass" ;;
    esac
}

# Основная логика
case "${1:-test}" in
    "status")
        check_status
        ;;
    "test"|*)
        check_status
        test_connection
        ;;
esac