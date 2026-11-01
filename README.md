# CLAP-Odin

Odin bindings for [CLAP](https://github.com/free-audio/clap) (CLever Audio Plugin) v1.2.10.

## Setup

Tested with Odin `dev-2026-03:1a5126c6b` on macOS arm64. Python 3.9+
is needed only for the verification helper; a C11 compiler is needed for ABI checks.

Clone this repository into a dependencies directory and register its parent:

```sh
git clone https://github.com/MalgAmoe/clap-odin /path/to/deps/clap-odin
odin build your-plugin -build-mode:dll -collection:deps=/path/to/deps
```

Import `clap "deps:clap-odin"`, `ext "deps:clap-odin/ext"`, and so on.
Alternatively, use relative imports when the bindings are inside your project.
The examples below show package paths; choose the prefix for your layout.
All consumers must use the same package location to preserve Odin type identity.

## Packages

There are 5 Odin packages, matching the C header directory layout:

```odin
import clap "clap-odin"                      // Core types: Plugin, Host, events, streams, process
import clap_ext "clap-odin/ext"              // Stable extensions: params, gui, state, audio ports, ...
import clap_ext_draft "clap-odin/ext/draft"  // Draft extensions: webview, triggers, undo, ...
import clap_factory "clap-odin/factory"      // Factories: plugin factory, preset discovery
import clap_factory_draft "clap-odin/factory/draft" // Draft factories: state converter, invalidation
```

## Naming conventions

C names map to Odin names with these rules:

| C | Odin | Example |
|---|------|---------|
| `clap_` prefix on types | dropped (package is the namespace) | `clap_plugin_t` -> `clap.Plugin` |
| `clap_` prefix on extension types | dropped | `clap_plugin_gui_t` -> `ext.Plugin_Gui` |
| `CLAP_` prefix on constants | dropped | `CLAP_EXT_GUI` -> `ext.EXT_GUI` |
| snake_case types | Pascal_Case | `clap_event_header_t` -> `Event_Header` |
| SCREAMING_SNAKE constants | kept as-is | `CLAP_INVALID_ID` -> `INVALID_ID` |
| Bitmask flags | plain constants (OR-able) | `CLAP_PARAM_IS_AUTOMATABLE` -> `PARAM_IS_AUTOMATABLE` |
| Single-value selectors | Odin `enum` | `clap_process_status` -> `Process_Status` |
| File names | `kebab-case.h` -> `snake_case.odin` | `audio-ports.h` -> `audio_ports.odin` |

## File mapping

Each binding file maps to a C header (the example and tooling are separate):

```
clap-odin/                        C header
├── audio_buffer.odin             audio-buffer.h
├── color.odin                    color.h
├── entry.odin                    entry.h
├── events.odin                   events.h
├── fixedpoint.odin               fixedpoint.h
├── host.odin                     host.h
├── id.odin                       id.h
├── plugin.odin                   plugin.h
├── plugin_features.odin          plugin-features.h
├── process.odin                  process.h
├── stream.odin                   stream.h
├── string_sizes.odin             string-sizes.h
├── timestamp.odin                timestamp.h
├── universal_plugin_id.odin      universal-plugin-id.h
├── version.odin                  version.h
├── ext/                          ext/
│   ├── ambisonic.odin            ambisonic.h
│   ├── audio_ports.odin          audio-ports.h
│   ├── audio_ports_activation.odin audio-ports-activation.h
│   ├── audio_ports_config.odin   audio-ports-config.h
│   ├── configurable_audio_ports.odin configurable-audio-ports.h
│   ├── context_menu.odin         context-menu.h
│   ├── event_registry.odin       event-registry.h
│   ├── gui.odin                  gui.h
│   ├── latency.odin              latency.h
│   ├── log.odin                  log.h
│   ├── note_name.odin            note-name.h
│   ├── note_ports.odin           note-ports.h
│   ├── param_indication.odin     param-indication.h
│   ├── params.odin               params.h
│   ├── posix_fd_support.odin     posix-fd-support.h
│   ├── preset_load.odin          preset-load.h
│   ├── remote_controls.odin      remote-controls.h
│   ├── render.odin               render.h
│   ├── state.odin                state.h
│   ├── state_context.odin        state-context.h
│   ├── surround.odin             surround.h
│   ├── tail.odin                 tail.h
│   ├── thread_check.odin         thread-check.h
│   ├── thread_pool.odin          thread-pool.h
│   ├── timer_support.odin        timer-support.h
│   ├── track_info.odin           track-info.h
│   ├── voice_info.odin           voice-info.h
│   └── draft/                    draft/
│       ├── background_activation.odin     background-activation.h
│       ├── background_progress.odin       background-progress.h
│       ├── background_state_context.odin  background-state-context.h
│       ├── flush_events.odin              flush-events.h
│       ├── octave_number.odin             octave-number.h
│       ├── param_hovered.odin             param-hovered.h
│       ├── params_origin.odin             params-origin.h
│       ├── extensible_audio_ports.odin extensible-audio-ports.h
│       ├── gain_adjustment_metering.odin gain-adjustment-metering.h
│       ├── mini_curve_display.odin mini-curve-display.h
│       ├── project_location.odin project-location.h
│       ├── resource_directory.odin resource-directory.h
│       ├── scratch_memory.odin   scratch-memory.h
│       ├── transport_control.odin transport-control.h
│       ├── triggers.odin         triggers.h
│       ├── tuning.odin           tuning.h
│       ├── undo.odin             undo.h
│       └── webview.odin          webview.h
└── factory/                      factory/
    ├── plugin_factory.odin       plugin-factory.h
    ├── preset_discovery.odin     preset-discovery.h
    └── draft/                    draft/
        ├── plugin_invalidation.odin plugin-invalidation.h
        └── plugin_state_converter.odin plugin-state-converter.h
```

## Updating from 1.2.7

The draft transport-control extension now uses `clap.transport-control/2` and
adds `request_tempo` and `request_time_signature`. Hosts implementing this
interface must provide both callbacks; do not expose the old struct under the new ID.
Draft extensions are optional and may change incompatibly upstream.

## Example

`example/` contains a complete ZDF SVF (state-variable filter) plugin -- stereo processing, sample-accurate parameter automation, state save/load.

On Linux, build the shared library directly:

```bash
odin build example -build-mode:dll -thread-count:1 -out:zdf_svf.clap
```

On macOS, a `.clap` plugin is a bundle, not just a renamed dylib. For the example:

```bash
mkdir -p build/zdf_svf.clap/Contents/MacOS
odin build example -build-mode:dll -thread-count:1 -out:build/zdf_svf.clap/Contents/MacOS/zdf_svf.dylib
mv build/zdf_svf.clap/Contents/MacOS/zdf_svf.dylib build/zdf_svf.clap/Contents/MacOS/zdf_svf
python3 - <<'PLIST'
import plistlib
from pathlib import Path
Path("build/zdf_svf.clap/Contents/Info.plist").write_bytes(plistlib.dumps({
    "CFBundleExecutable": "zdf_svf",
    "CFBundleIdentifier": "com.example.zdf-svf",
    "CFBundleName": "ZDF SVF",
    "CFBundleVersion": "1.0.0",
    "CFBundleShortVersionString": "1.0.0",
    "CFBundlePackageType": "BNDL",
}))
PLIST
codesign --force --sign - build/zdf_svf.clap
codesign --verify --strict build/zdf_svf.clap
clap-validator validate --no-parallel build/zdf_svf.clap
```

This does not install the plugin. The example metadata above must stay in sync
with `example/zdf_svf.odin`. Production packaging belongs in the consumer's build
tooling; macOS distribution signing/notarization is outside this example.

## Building

Compile your plugin as a shared library (on macOS, then package it as above):

```bash
odin build <folder> -build-mode:dll -out:<plugin-name>.clap
```

Test with the [CLAP validator](https://github.com/free-audio/clap-validator):

```bash
clap-validator validate /path/to/your/plugin.clap
```

## Verification

```sh
python3 tools/check.py
# Optional native C/Odin ABI comparison against an explicit CLAP 1.2.10 checkout:
python3 tools/check.py --clap-include /path/to/clap/include
```

The helper checks all five packages and builds the example in a temporary directory.
The optional comparison covers 14 selected layouts, member offsets, version constants,
and new/changed extension IDs. It does not prove callback signature correctness or
exhaustive ABI parity. It does not download headers or modify dependency locks.
Runtime validation and platform-specific builds remain separate checks.
GitHub Actions runs these checks on Linux with the pinned Odin dev-2026-03
release (SHA-256 verified) and CLAP 1.2.10 reference commit. The workflow has
not yet been exercised remotely.

## License

Same license as the [CLAP specification](https://github.com/free-audio/clap).
