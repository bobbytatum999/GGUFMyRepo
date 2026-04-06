# iOS-Capable Feature & Settings Backlog for GGUFMyRepo

## High-value features

1. **Background task checkpoints**
   - Persist quantization checkpoint metadata every N tensors.
   - Recover gracefully after app relaunch when full continuation is not possible.

2. **File-provider import/export**
   - Import GGUF from Files, iCloud Drive, external providers.
   - Export quantized output directly to Files destinations.

3. **Job presets**
   - Save named presets (threads + quant type + upload visibility).
   - One-tap replay for repeated model families.

4. **Per-device recommendation profile cache**
   - Cache benchmark throughput + preferred quant defaults per model size bracket.

5. **Offline mode**
   - Queue upload actions while offline and execute when connectivity returns.

6. **Notifications & Live Activities**
   - Local notifications for download/quant/upload completion and errors.
   - Lock-screen style progress surface while jobs run.

## Settings worth adding

### Quantization
- `pauseOnThermalCritical`
- `warnOnThermalSerious`
- `minimumFreeSpaceMultiplier`
- `defaultThreads`
- `autoShowRecommendationCard`

### Download
- `maxConcurrentDownloads`
- `autoResumeDownloadsOnLaunch`
- `preferredDownloadSubdirectory`

### Upload
- `uploadChunkSize` (4/8/16MB)
- `uploadPolicy` (Wi-Fi only / Any)
- default visibility (public/private)

### UX & logs
- `showTensorNames`
- `compactMode`
- `logVerbosity`

### Notifications
- `notifyOnDownloadCompletion`
- `notifyOnQuantCompletion`
- `notifyOnUploadCompletion`
- `notifyOnFailure`
