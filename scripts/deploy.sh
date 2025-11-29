#!/bin/bash
set -e

echo "🚀 Starting ClickHouse deployment..."

# Проверка запуска Minikube
if ! minikube status >/dev/null 2>&1; then
    echo "🤦 Minikube is not running. Starting it..."
    minikube start
fi

echo "📦 Deploying ClickHouse via Helm..."
helm upgrade --install clickhouse ./helm/clickhouse -n clickhouse --create-namespace

echo "⏳ Waiting for StatefulSet to be ready..."
kubectl rollout status statefulset/clickhouse -n clickhouse --timeout=180s

echo "✨ Deployment complete! ClickHouse is alive and confused!"