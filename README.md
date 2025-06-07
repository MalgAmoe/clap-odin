# CLAP-Odin

Odin language bindings for the CLAP (CLever Audio Plugin) API.

## Overview

This package provides complete Odin bindings for CLAP v1.2.6, enabling developers to create audio plugins using the Odin programming language. The bindings follow the same structure as the official C headers while providing type-safe, idiomatic Odin interfaces.

## Features

- **Complete CLAP API coverage**: All core CLAP interfaces and extensions
- **Type safety**: Leverages Odin's type system for safer plugin development
- **Zero-cost abstractions**: Direct mapping to C structures with no overhead
- **Extension support**: Audio ports, parameters, GUI, state management, and more
- **Memory safe**: Proper handling of C interop with Odin's memory management

## Structure

The bindings are organized to mirror the official CLAP structure:

```
clap-odin/
├── README.md              # This file
├── entry.odin             # Plugin entry points and factory interface
├── plugin.odin            # Core plugin interface and lifecycle
├── host.odin              # Host interface for plugin communication
├── process.odin           # Audio processing structures and enums
├── audio_buffer.odin      # Audio buffer management
├── events.odin            # Event handling system
├── stream.odin            # I/O stream interfaces for state save/load
├── version.odin           # CLAP version constants
├── consts_n_types.odin    # Core constants and type definitions
└── ext/                   # CLAP extensions
    ├── audio_ports.odin   # Audio port configuration
    ├── params.odin        # Parameter automation
    ├── state.odin         # Plugin state management
    ├── gui.odin           # Graphical user interface
    ├── latency.odin       # Latency reporting
    ├── log.odin           # Logging interface
    ├── note.odin          # Note handling
    ├── render.odin        # Offline rendering
    ├── tail.odin          # Audio tail handling
    ├── thread.odin        # Thread checking
    ├── timer.odin         # Timer support
    ├── voice_info.odin    # Voice information
    └── draft/             # Draft extensions
        └── scratch_memory.odin
```

## Core Concepts

### Plugin Entry Point

Every CLAP plugin must export a `clap_entry` symbol:

```odin
@(export)
clap_entry := clap.Plugin_Entry {
    clap_version = clap.CLAP_VERSION,
    init = proc "c" (plugin_path: cstring) -> bool {
        return true
    },
    deinit = proc "c" () {
        // Cleanup if needed
    },
    get_factory = proc "c" (factory_id: cstring) -> rawptr {
        if factory_id == clap.PLUGIN_FACTORY_ID {
            return &plugin_factory
        }
        return nil
    },
}
```

### Plugin Factory

The factory creates plugin instances:

```odin
plugin_factory := clap.Plugin_Factory {
    get_plugin_count = proc "c" (factory: ^clap.Plugin_Factory) -> u32 {
        return 1
    },
    get_plugin_descriptor = proc "c" (
        factory: ^clap.Plugin_Factory,
        index: u32,
    ) -> ^clap.Plugin_Descriptor {
        // Return plugin descriptor
    },
    create_plugin = proc "c" (
        factory: ^clap.Plugin_Factory,
        host: ^clap.Host,
        plugin_id: cstring,
    ) -> ^clap.Plugin {
        // Create and return plugin instance
    },
}
```

### Plugin Implementation

Core plugin interface with lifecycle methods:

```odin
plugin := clap.Plugin {
    desc = &plugin_descriptor,
    plugin_data = your_plugin_data,
    init = plugin_init,
    destroy = plugin_destroy,
    activate = plugin_activate,
    deactivate = plugin_deactivate,
    start_processing = plugin_start_processing,
    stop_processing = plugin_stop_processing,
    reset = plugin_reset,
    process = plugin_process,
    get_extension = plugin_get_extension,
    on_main_thread = plugin_on_main_thread,
}
```

### Audio Processing

The process callback handles real-time audio:

```odin
plugin_process :: proc "c" (plugin: ^clap.Plugin, process: ^clap.Process) -> clap.Process_Status {
    // Process parameter events
    // Process audio samples
    // Generate output events if needed
    return .CONTINUE
}
```

## Extensions

Extensions provide additional functionality beyond the core plugin interface:

### Audio Ports

Define input/output audio ports:

```odin
plugin_audio_ports := ext.Plugin_Audio_Ports {
    count = proc "c" (plugin: ^clap.Plugin, is_input: bool) -> u32 {
        return 1 // One stereo input/output
    },
    get = proc "c" (
        plugin: ^clap.Plugin,
        index: u32,
        is_input: bool,
        info: ^ext.Audio_Port_Info,
    ) -> bool {
        // Fill port information
        return true
    },
}
```

### Parameters

Expose automatable parameters:

```odin
plugin_params := ext.Plugin_Params {
    count = proc "c" (plugin: ^clap.Plugin) -> u32 {
        return 2 // Number of parameters
    },
    get_info = proc "c" (
        plugin: ^clap.Plugin,
        param_index: u32,
        param_info: ^ext.Param_Info,
    ) -> bool {
        // Fill parameter information
        return true
    },
    get_value = proc "c" (plugin: ^clap.Plugin, param_id: clap.Clap_Id, out_value: ^f64) -> bool {
        // Return current parameter value
        return true
    },
    // Additional parameter methods...
}
```

### State Management

Save and load plugin state:

```odin
plugin_state := ext.Plugin_State {
    save = proc "c" (plugin: ^clap.Plugin, stream: ^clap.OStream) -> bool {
        // Write plugin state to stream
        return true
    },
    load = proc "c" (plugin: ^clap.Plugin, stream: ^clap.IStream) -> bool {
        // Read plugin state from stream  
        return true
    },
}
```

## Memory Management

### C Interop Guidelines

- Use `proc "c"` calling convention for all CLAP callbacks
- Manage memory carefully when interfacing with the host
- Avoid dynamic allocation in real-time audio callbacks
- Use pre-allocated buffers for parameter text display

### String Handling

CLAP uses C-style null-terminated strings. Use Odin's string conversion utilities:

```odin
// Converting Odin string to C string buffer
runtime.copy_from_string(info.name[:], "Parameter Name")

// Converting C string to Odin string
id_str := string(plugin_id)
```

## Building

To build a CLAP plugin with these bindings:

1. Import the clap-odin package in your plugin source
2. Implement the required interfaces
3. Export the `clap_entry` symbol
4. Compile as a shared library (.clap file)

Example build command:
```bash
odin build <folder> -o:aggressive -build-mode:dll -out:<plugin-name>.clap
```

## Validation

Use the official [CLAP validator](https://github.com/free-audio/clap-validator) to test your plugin:

```bash
./clap-validator validate /path/to/your/plugin.clap
```

## CLAP Version

These bindings are compatible with CLAP v1.2.6.

## License

This project follows the same license as the CLAP specification.