# GGUFMyRepo

GGUFMyRepo is a native iOS SwiftUI app scaffold for on-device GGUF quantization using llama.cpp.

## Current status

This repository includes the app architecture, view hierarchy, recommendation engine rules, GGUF header parser, and CI workflow for unsigned IPA builds.

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

## Notes

- Python `convert_hf_to_gguf.py` is intentionally excluded (not iOS compatible).
- This scaffold expects GGUF input files directly.
- Add `llmfarm_core.swift` or local `llama.cpp` package in Xcode package settings.
