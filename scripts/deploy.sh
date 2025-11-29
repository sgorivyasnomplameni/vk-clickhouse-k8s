#!/bin/bash
set -e

echo "🚀 Starting ClickHouse deployment..."

# Проверяем что Minikube запущен
if ! minikube status >/dev/null 2>&1; then
    echo "❌ Minikube is not running. Starting Minikube..."
    minikube start
fi

# Устанавливаем ClickHouse
echo "📦 Installing ClickHouse via Helm..."
helm install clickhouse ./helm/clickhouse -n clickhouse --create-namespace

echo "⏳ Waiting for ClickHouse to be ready..."
kubectl wait --for=condition=ready pod -l app=clickhouse -n clickhouse --timeout=120s

echo "✅ ClickHouse deployed successfully!"