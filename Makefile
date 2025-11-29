.PHONY: deploy status test clean help

# Основные команды
deploy: ## Развернуть ClickHouse в Kubernetes
	@echo "🚀 Deploying ClickHouse..."
	./scripts/deploy.sh

status: ## Проверить статус развертывания
	@echo "📊 Checking status..."
	./scripts/test-connection.sh status

test: ## Протестировать подключение и пользователей
	@echo "🧪 Testing connection..."
	./scripts/test-connection.sh

clean: ## Удалить ClickHouse из кластера
	@echo "🧹 Cleaning up..."
	./scripts/cleanup.sh

help: ## Показать эту справку
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'