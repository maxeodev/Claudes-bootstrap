.PHONY: build run test vet lint tidy db-up db-down dev clean

VERSION ?= dev
COMMIT  := $(shell git rev-parse --short HEAD 2>/dev/null || echo none)
DATE    := $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
LDFLAGS := -X github.com/maxeodev/claudes-bootstrap/internal/version.Version=$(VERSION) \
           -X github.com/maxeodev/claudes-bootstrap/internal/version.Commit=$(COMMIT) \
           -X github.com/maxeodev/claudes-bootstrap/internal/version.BuildDate=$(DATE)

build: ## Build the control-plane binary
	go build -ldflags "$(LDFLAGS)" -o bin/brume-server ./cmd/brume-server

run: ## Run the control-plane locally
	go run ./cmd/brume-server

test: ## Run unit tests
	go test ./...

vet: ## Run go vet
	go vet ./...

tidy: ## Tidy go modules
	go mod tidy

db-up: ## Start a local Postgres for development
	docker compose -f docker-compose.dev.yml up -d

db-down: ## Stop the local Postgres
	docker compose -f docker-compose.dev.yml down

dev: db-up ## Bring up dependencies and run the server
	BRUME_DATABASE_URL="postgres://brume:brume@localhost:5432/brume?sslmode=disable" \
		go run ./cmd/brume-server

clean:
	rm -rf bin
