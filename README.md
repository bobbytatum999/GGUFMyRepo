# GGUFMyRepo

GGUFMyRepo is a native iOS SwiftUI app scaffold for on-device GGUF quantization using llama.cpp.

## Current status

This repository now includes a stronger base implementation:
- iPhone hardware detection via `sysctlbyname`
- RAM availability bridge via `os_proc_available_memory()` C helper
- quant recommendation rules with thermal downgrade and storage blocker logic
- GGUF v3 header parser with little-endian safe reads and early-stop key extraction
- callback-ready quantization stream shape that uses unmanaged context (compatible with C callback bridging)

## On-device pipeline

1. Search Hugging Face for GGUF models (`filter=gguf`).
2. Download source GGUF (F16/BF16/F32).
3. Parse header metadata (`general.parameter_count`, architecture, name, file type).
4. Recommend quantization type based on iPhone hardware and thermal state.
5. Quantize on-device via `Task.detached` engine integration point.
6. Upload output GGUF to Hugging Face repository.

## Sideloading the unsigned IPA

- AltStore: install IPA via "My Apps" → plus button.
- Sideloadly: connect device, drag IPA, start sideload.
- ios-deploy: install generated `.app`/`.ipa` via CLI.

## Major next improvements

1. Integrate `llmfarm_core.swift` or local `llama.cpp` package and replace simulated quant loop with `llama_model_quantize()`.
2. Add an actual Xcode project (`GGUFMyRepo.xcodeproj`) and target settings so CI can archive for iOS.
3. Add `URLSessionDownloadTask` resume-data persistence + background session restoration.
4. Add chunked upload implementation and retries for Hugging Face repository upload.
5. Add Swift tests for recommendation rules and GGUF parser fixtures.
6. Add widget extension for active quant job progress (recommended next feature).


## Widget extension scaffold

A starter widget target source is included at `GGUFMyRepoWidget/GGUFMyRepoWidget.swift`.
It reads active job fields from the shared app group defaults (`group.com.ggufmyrepo.shared`) and displays phase + progress.


## Recent upgrades

- Resumable background download manager with persisted resume-data snapshot.
- Thermal monitor service that polls every 2 seconds for quantization screens.
- Quantization progress UI now displays ETA and throughput in locale-friendly units.


## Test scaffolding

Added `GGUFMyRepoTests` with initial parser and recommendation tests; wire this target into `GGUFMyRepo.xcodeproj` once the project file is created.


## Core package (testable today)

A standalone Swift Package is included for deterministic core logic testing:
- `Sources/GGUFCore` (recommendation + GGUF header parser core)
- `Tests/GGUFCoreTests`

Run:

```bash
swift test
```


## CI updates

CI now runs `swift test` in a dedicated `core-tests` job before the unsigned IPA packaging job.


## Sideload-only engine option (not App Store safe)

`GGUFMyRepo/Services/BinaryQuantizeEngine.swift` adds a sideload-oriented path that launches a bundled `llama-quantize` executable with `posix_spawn`, streams stdout/stderr, and parses `%` progress from log lines.


## Feature backlog

See `IOS_FEATURE_BACKLOG.md` for iOS-capable features/settings tailored to this app.
