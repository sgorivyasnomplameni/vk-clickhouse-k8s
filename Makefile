.PHONY: deploy status test clean help

deploy: ## Deploy ClickHouse
	./scripts/deploy.sh

status: ## Show app status
	./scripts/test-connection.sh status

test: ## Test connectivity + login
	./scripts/test-connection.sh test

clean: ## Remove everything (with PVC)
	./scripts/cleanup.sh

help: ## Help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'