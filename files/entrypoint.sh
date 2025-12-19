#!/bin/bash
# Minecraft Bedrock Server Entrypoint Script
# Designed to run in userspace as the minecraft user

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="/app"
readonly MINECRAFT_HOME="${MINECRAFT_HOME:-/app/data}"
readonly SERVER_DIR="${MINECRAFT_HOME}"

# Logging functions
log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Validate environment
validate_environment() {
    if [[ ! -f "${SCRIPT_DIR}/get_version.js" ]]; then
        log_error "Version detection script not found: ${SCRIPT_DIR}/get_version.js"
        exit 1
    fi

    if [[ ! -f "${SCRIPT_DIR}/templates/envforge.yaml" ]]; then
        log_error "Configuration template not found: ${SCRIPT_DIR}/templates/envforge.yaml"
        exit 1
    fi
}

# Get Bedrock version
get_bedrock_version() {
    local current_version

    log_info "Detecting latest Bedrock server version..."
    if ! current_version=$(node "${SCRIPT_DIR}/get_version.js" 2>/dev/null); then
        log_error "Failed to detect Bedrock version using Node.js script"
        exit 1
    fi

    echo "$current_version"
}

# Create necessary directories
setup_directories() {
    log_info "Setting up directories..."
    mkdir -p "$SERVER_DIR"
}

# Download and extract Bedrock server
download_bedrock_server() {
    local version="$1"
    local zip_file="./bedrock-server-${version}.zip"
    local extract_dir="./bedrock-server-${version}"

    log_info "Downloading Bedrock server v${version}..."

    # Download with retry logic
    local max_retries=3
    local retry_count=0

    while [[ $retry_count -lt $max_retries ]]; do
        if curl -L --fail --silent --show-error \
               "https://minecraft.azureedge.net/bin-linux/bedrock-server-${version}.zip" \
               --output "$zip_file"; then
            break
        fi

        retry_count=$((retry_count + 1))
        log_info "Download failed, retrying... ($retry_count/$max_retries)"
        sleep 2
    done

    if [[ ! -f "$zip_file" ]]; then
        log_error "Failed to download Bedrock server after $max_retries attempts"
        exit 1
    fi

    log_info "Extracting server files..."
    if ! unzip -q "$zip_file" -d "$extract_dir"; then
        log_error "Failed to extract Bedrock server archive"
        rm -f "$zip_file"
        exit 1
    fi

    # Clean up zip file to save space
    rm -f "$zip_file"

    echo "$extract_dir"
}

# Install server files
install_server_files() {
    local extract_dir="$1"

    log_info "Installing server configuration files..."
    # Copy JSON files without overwriting existing configs
    find "$extract_dir" -name "*.json" -exec cp -nv {} "$SERVER_DIR/" \; -exec rm -f {} \;

    log_info "Installing server binaries..."
    # Copy remaining files
    cp -rf "$extract_dir"/* "$SERVER_DIR/"

    # Ensure server binary is executable
    chmod +x "$SERVER_DIR/bedrock_server"

    # Clean up extraction directory
    rm -rf "$extract_dir"
}

# Render configuration templates
render_configuration() {
    log_info "Rendering server configuration..."
    if ! envforge render -c "${SCRIPT_DIR}/templates/envforge.yaml"; then
        log_error "Failed to render configuration templates"
        exit 1
    fi
}

# Main execution
main() {
    log_info "Starting Minecraft Bedrock Server initialization..."

    validate_environment

    # Get version information
    local current_version
    current_version=$(get_bedrock_version)
    local target_version="${BEDROCK_VERSION:-$current_version}"

    log_info "Current Bedrock version: $current_version"
    log_info "Target server version: $target_version"

    # Setup and installation
    setup_directories

    local extract_dir
    extract_dir=$(download_bedrock_server "$target_version")
    install_server_files "$extract_dir"

    render_configuration

    # Start the server
    log_info "Starting Minecraft Bedrock server..."
    cd "$SERVER_DIR"

    # Execute server with proper signal handling
    exec ./bedrock_server
}

# Run main function
main "$@"
