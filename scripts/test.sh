#!/bin/bash
# Test script for environment setup

set -euo pipefail

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Test configuration
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="${CONFIG_FILE:-$PROJECT_ROOT/config.yaml}"
TEST_LOG="$PROJECT_ROOT/logs/test-$(date +%Y%m%d-%H%M%S).log"

# Create test log directory
mkdir -p "$(dirname "$TEST_LOG")"

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test runner
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    log "INFO" "Running test: $test_name"
    
    if $test_function; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        log "SUCCESS" "✅ $test_name PASSED"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        log "ERROR" "❌ $test_name FAILED"
    fi
}

# Test functions
test_config_validation() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log "ERROR" "Config file not found: $CONFIG_FILE"
        return 1
    fi
    
    if ! command_exists yq; then
        log "WARN" "yq not installed, skipping YAML validation"
        return 0
    fi
    
    # Validate YAML syntax
    if ! yq eval '.' "$CONFIG_FILE" >/dev/null 2>&1; then
        log "ERROR" "Invalid YAML syntax in $CONFIG_FILE"
        return 1
    fi
    
    # Check required fields
    local required_fields=("metadata.name" "metadata.version" "config.log_level" "packages.core.brew")
    for field in "${required_fields[@]}"; do
        if ! yq eval ".$field" "$CONFIG_FILE" >/dev/null 2>&1; then
            log "ERROR" "Missing required field: $field"
            return 1
        fi
    done
    
    return 0
}

test_script_syntax() {
    local scripts=("setup.sh" "cleanup.sh" "generate-csv-readme.sh")
    local lib_scripts=("lib/common.sh" "lib/brew.sh" "lib/extensions.sh" "lib/ai.sh")
    
    # Test main scripts
    for script in "${scripts[@]}"; do
        if [ ! -f "$SCRIPT_DIR/$script" ]; then
            log "ERROR" "Script not found: $script"
            return 1
        fi
        
        if ! bash -n "$SCRIPT_DIR/$script" 2>/dev/null; then
            log "ERROR" "Syntax error in $script"
            return 1
        fi
    done
    
    # Test lib scripts
    for script in "${lib_scripts[@]}"; do
        if [ ! -f "$SCRIPT_DIR/$script" ]; then
            log "ERROR" "Lib script not found: $script"
            return 1
        fi
        
        if ! bash -n "$SCRIPT_DIR/$script" 2>/dev/null; then
            log "ERROR" "Syntax error in $script"
            return 1
        fi
    done
    
    return 0
}

test_dry_run() {
    # Test dry run mode
    if ! ./scripts/setup.sh --dry-run --only core >/dev/null 2>&1; then
        log "ERROR" "Dry run failed"
        return 1
    fi
    
    return 0
}

test_cleanup_dry_run() {
    # Test cleanup dry run
    if ! ./scripts/cleanup.sh --dry-run >/dev/null 2>&1; then
        log "ERROR" "Cleanup dry run failed"
        return 1
    fi
    
    return 0
}

test_help_commands() {
    # Test help commands
    if ! ./scripts/setup.sh --help >/dev/null 2>&1; then
        log "ERROR" "Setup help command failed"
        return 1
    fi
    
    if ! ./scripts/cleanup.sh --help >/dev/null 2>&1; then
        log "ERROR" "Cleanup help command failed"
        return 1
    fi
    
    return 0
}

test_makefile() {
    # Test Makefile targets
    local makefile_targets=("help" "config-validate" "lint")
    
    for target in "${makefile_targets[@]}"; do
        if ! make -C "$PROJECT_ROOT" "$target" >/dev/null 2>&1; then
            log "ERROR" "Makefile target failed: $target"
            return 1
        fi
    done
    
    return 0
}

test_documentation_generation() {
    # Test documentation generation
    if ! ./scripts/generate-csv-readme.sh >/dev/null 2>&1; then
        log "ERROR" "Documentation generation failed"
        return 1
    fi
    
    if [ ! -f "$PROJECT_ROOT/docs/README_GENERATED.md" ]; then
        log "ERROR" "Generated documentation not found"
        return 1
    fi
    
    return 0
}

test_pre_commit_config() {
    # Test pre-commit configuration
    if [ ! -f "$PROJECT_ROOT/.pre-commit-config.yaml" ]; then
        log "ERROR" "Pre-commit config not found"
        return 1
    fi
    
    if ! command_exists pre-commit; then
        log "WARN" "Pre-commit not installed, skipping validation"
        return 0
    fi
    
    if ! pre-commit validate-config >/dev/null 2>&1; then
        log "ERROR" "Pre-commit config validation failed"
        return 1
    fi
    
    return 0
}

test_github_workflows() {
    # Test GitHub Actions workflows
    local workflows=(".github/workflows/ci.yml" ".github/workflows/release.yml")
    
    for workflow in "${workflows[@]}"; do
        if [ ! -f "$PROJECT_ROOT/$workflow" ]; then
            log "ERROR" "Workflow not found: $workflow"
            return 1
        fi
        
        if ! command_exists yq; then
            log "WARN" "yq not installed, skipping workflow validation"
            continue
        fi
        
        if ! yq eval '.' "$PROJECT_ROOT/$workflow" >/dev/null 2>&1; then
            log "ERROR" "Invalid YAML in $workflow"
            return 1
        fi
    done
    
    return 0
}

test_port_conflicts() {
    # Test port conflict detection
    if ! command_exists lsof; then
        log "WARN" "lsof not available, skipping port conflict test"
        return 0
    fi
    
    # Test with non-conflicting ports
    local test_ports=(9999 9998)
    local conflicts=0
    
    for port in "${test_ports[@]}"; do
        if lsof -i ":$port" >/dev/null 2>&1; then
            conflicts=$((conflicts + 1))
        fi
    done
    
    if [ "$conflicts" -gt 0 ]; then
        log "WARN" "Port conflicts detected in test ports"
    fi
    
    return 0
}

test_file_permissions() {
    # Test file permissions
    local executable_files=(
        "scripts/setup-v4.sh"
        "scripts/cleanup.sh"
        "scripts/generate-csv-readme.sh"
        "scripts/lib/common.sh"
        "scripts/lib/brew.sh"
        "scripts/lib/extensions.sh"
        "scripts/lib/ai.sh"
    )
    
    for file in "${executable_files[@]}"; do
        if [ ! -f "$PROJECT_ROOT/$file" ]; then
            log "ERROR" "File not found: $file"
            return 1
        fi
        
        if [ ! -x "$PROJECT_ROOT/$file" ]; then
            log "ERROR" "File not executable: $file"
            return 1
        fi
    done
    
    return 0
}

# Main test function
main() {
    log "INFO" "Starting test suite"
    log "INFO" "Test log: $TEST_LOG"
    
    # Redirect output to log file
    exec > >(tee -a "$TEST_LOG")
    exec 2>&1
    
    # Run tests
    run_test "Config Validation" test_config_validation
    run_test "Script Syntax" test_script_syntax
    run_test "Dry Run" test_dry_run
    run_test "Cleanup Dry Run" test_cleanup_dry_run
    run_test "Help Commands" test_help_commands
    run_test "Makefile" test_makefile
    run_test "Documentation Generation" test_documentation_generation
    run_test "Pre-commit Config" test_pre_commit_config
    run_test "GitHub Workflows" test_github_workflows
    run_test "Port Conflicts" test_port_conflicts
    run_test "File Permissions" test_file_permissions
    
    # Summary
    echo ""
    log "INFO" "=== Test Summary ==="
    log "INFO" "Total tests: $TESTS_TOTAL"
    log "INFO" "Passed: $TESTS_PASSED"
    log "INFO" "Failed: $TESTS_FAILED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log "SUCCESS" "All tests passed! 🎉"
        exit 0
    else
        log "ERROR" "Some tests failed. Check the log: $TEST_LOG"
        exit 1
    fi
}

# Run main function
main "$@"









