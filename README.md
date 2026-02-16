# CLAP-Odin

Odin bindings for [CLAP](https://github.com/free-audio/clap) (CLever Audio Plugin) v1.2.7.

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

Every Odin file maps 1:1 to a C header:

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

## Example

`example/` contains a complete ZDF SVF (state-variable filter) plugin -- stereo processing, sample-accurate parameter automation, state save/load. ~230 lines.

```bash
odin build example -build-mode:dll -out:zdf_svf.clap
```

## Building

Build your plugin as a shared library with the `.clap` extension:

```bash
odin build <folder> -build-mode:dll -out:<plugin-name>.clap
```

Test with the [CLAP validator](https://github.com/free-audio/clap-validator):

```bash
clap-validator validate /path/to/your/plugin.clap
```

## License

Same license as the [CLAP specification](https://github.com/free-audio/clap).
