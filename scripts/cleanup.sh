#!/bin/bash

echo "🧹 Cleaning up ClickHouse deployment..."

# Удаляем Helm release
if helm list -n clickhouse | grep -q clickhouse; then
    helm uninstall clickhouse -n clickhouse
    echo "✅ Helm release removed"
else
    echo "ℹ️  No Helm release found"
fi

# Удаляем namespace (если пустой)
if kubectl get namespace clickhouse >/dev/null 2>&1; then
    kubectl delete namespace clickhouse
    echo "✅ Namespace removed"
fi

echo "✅ Cleanup completed!"