#!/usr/bin/env bash
set -euo pipefail

files=(
  ".github/workflows/build.yml"
  "GGUFMyRepo/Models/QuantJob.swift"
  "GGUFMyRepo/Services/DeviceInfo.swift"
  "GGUFMyRepo/Services/DownloadManager.swift"
  "GGUFMyRepo/Services/GGUFParser.swift"
  "GGUFMyRepo/Services/HFClient.swift"
  "GGUFMyRepo/Services/JobHistoryStore.swift"
  "GGUFMyRepo/Services/KeychainService.swift"
  "GGUFMyRepo/Services/QuantRecommendationEngine.swift"
  "GGUFMyRepo/Services/QuantizeEngine.swift"
  "GGUFMyRepo/Views/Job/HardwareRecommendationCard.swift"
  "GGUFMyRepo/Views/Job/QuantizeProgressView.swift"
  "GGUFMyRepo/Views/Search/ModelSearchView.swift"
  "GGUFMyRepo/Views/Settings/SettingsView.swift"
  "README.md"
)

pattern='^(<<<<<<<|=======|>>>>>>>)'

for file in "${files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing expected file: $file" >&2
    exit 1
  fi
  if rg -n "$pattern" "$file" >/dev/null 2>&1; then
    echo "Conflict marker found in $file" >&2
    rg -n "$pattern" "$file" >&2
    exit 1
  fi
done

echo "No conflict markers found in tracked merge-sensitive files."
