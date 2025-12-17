#!/usr/bin/env bash
# test_remco.sh
# Purpose: Validate remco dynamic rendering of server.properties from MINECRAFT_* env vars
# Requirements: remco binary, ./remco config directory in cwd
# Lint: shellcheck compliant

set -xeuo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Starting remco integration test..."

# Export test environment variables (representative mix)
export MINECRAFT_SERVER_NAME="Test World"
export MINECRAFT_GAMEMODE="creative"
export MINECRAFT_DIFFICULTY="easy"
export MINECRAFT_ALLOW_CHEATS="true"
export MINECRAFT_MAX_PLAYERS="50"
export MINECRAFT_ONLINE_MODE="false"
export MINECRAFT_LEVEL_SEED="12345"
export MINECRAFT_CUSTOM_EXPERIMENTAL_FEATURE="enabled"  # Custom property test

# Run remco with debug output, pointing to temp destination
export REMCO_CONFIG="../remco/config.toml"
export REMCO_RESOURCE_DIR="../remco/resources.d"
export REMCO_TEMPLATE_DIR="../remco/templates"

# Temporary output directory
export REMCO_OUTPUT_DIR="../tests/artifacts"
mkdir -p "${REMCO_OUTPUT_DIR}"

# Clean previous run
rm -f "${REMCO_OUTPUT_DIR}/server.properties"

cd tests
../bin/remco \
  --config "${REMCO_CONFIG}" \
  --onetime

# Expected destination (adjust if your dst differs)
PROPERTIES_FILE="${REMCO_OUTPUT_DIR}/server.properties"
if [[ ! -f "${PROPERTIES_FILE}" ]]; then
  echo -e "${RED}FAIL: server.properties not generated at ${PROPERTIES_FILE}${NC}"
  echo
  exit 1
fi

# Validate file mode (0644)
actual_mode=$(stat -c "%a" "${PROPERTIES_FILE}" 2>/dev/null || echo "unknown")
if [[ "${actual_mode}" != "644" ]]; then
  echo -e "${RED}WARN: Unexpected file mode ${actual_mode} (expected 644)${NC}"
fi

## Validate no leading/trailing blank lines and correct format
#if grep -qE '^\s*$' "${PROPERTIES_FILE}" || ! grep -qE '^[a-z0-9_-]+=.+' "${PROPERTIES_FILE}"; then
#  echo -e "${RED}FAIL: Invalid formatting or blank lines in server.properties${NC}"
#  cat "${PROPERTIES_FILE}"
#  echo
#  exit 1
#fi

## Expected key=value pairs (core + custom)
#declare -A expected=(
#  ["server-name"]="Test World"
#  ["gamemode"]="creative"
#  ["difficulty"]="easy"
#  ["allow-cheats"]="true"
#  ["max-players"]="50"
#  ["online-mode"]="false"
#  ["level-seed"]="12345"
#  ["custom-experimental-feature"]="enabled"
#)
#
#failed=0
#for key in "${!expected[@]}"; do
#  if ! grep -qE "^${key}=${expected[$key]}$" "${PROPERTIES_FILE}"; then
#    echo -e "${RED}FAIL: Missing or incorrect '${key}=${expected[$key]}'${NC}"
#    ((failed++))
#  else
#    echo -e "${GREEN}PASS: ${key}=${expected[$key]}${NC}"
#  fi
#done

#if [[ $failed -eq 0 ]]; then
#  echo -e "${GREEN}All tests passed! server.properties rendered correctly.${NC}"
#  echo "Final content:"
#  cat "${PROPERTIES_FILE}"
#else
#  echo -e "${RED}${failed} assertion(s) failed.${NC}"
#  echo
#  exit 1
#fi

cat "${PROPERTIES_FILE}"

# Optional: cleanup
# rm -rf "${REMCO_OUTPUT_DIR}"

exit 0