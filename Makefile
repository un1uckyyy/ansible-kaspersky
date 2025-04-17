SERVICE_NAME := microservice
BUILD_DIR := build
BINARY := $(BUILD_DIR)/$(SERVICE_NAME)

SRC_DIR := microservice
CMD_DIR := $(SRC_DIR)/cmd/
DOCKERFILE := $(SRC_DIR)/Dockerfile

.PHONY: deps binary image clean


deps:
	@echo "Downloading Go dependencies..."
	cd $(SRC_DIR) && go mod download


binary: deps
	@echo "Building Go binary..."
	@mkdir -p $(BUILD_DIR)
	cd $(SRC_DIR) && GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ../$(BINARY) ./cmd/


image:
	@echo "Building Docker image..."
	docker build -f $(DOCKERFILE) -t $(SERVICE_NAME):latest $(SRC_DIR)

# Очистка артефактов сборки
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
