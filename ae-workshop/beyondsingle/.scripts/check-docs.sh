#!/usr/bin/env bash
# Checks that the specs are filled in enough to start building.
# Exit 0 if ready, 1 if something needs attention. Advisory, not a gate.
set -uo pipefail

issues=0

echo "Checking documentation..."

if [ ! -f docs/SPECS.md ]; then
  echo "  missing docs/SPECS.md"; issues=$((issues+1))
fi
if [ ! -f docs/architecture.md ]; then
  echo "  missing docs/architecture.md"; issues=$((issues+1))
else
  for section in "API Contracts" "Data Models" "Verification"; do
    if ! grep -q "^## ${section}" docs/architecture.md; then
      echo "  docs/architecture.md is missing the '${section}' section"
      issues=$((issues+1))
    fi
  done
fi

if [ "$issues" -eq 0 ]; then
  echo "OK: documentation looks ready."
  exit 0
else
  echo "${issues} item(s) to fill in. These are reminders, not blockers."
  exit 1
fi
