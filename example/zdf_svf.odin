// State-variable filter (SVF) using trapezoidal (ZDF) integration.
// Minimal CLAP plugin example using the clap-odin bindings.
//
// Build: odin build example -build-mode:dll -out:zdf_svf.clap
package zdf_svf

import "base:runtime"
import "core:fmt"
import "core:math"
import "core:strconv"

import clap ".."
import ext "../ext"
import factory "../factory"

// --- Descriptor ---

PARAM_CUTOFF    : clap.Clap_Id : 0
PARAM_RESONANCE : clap.Clap_Id : 1

_features := [?]cstring{
	clap.PLUGIN_FEATURE_AUDIO_EFFECT,
	clap.PLUGIN_FEATURE_FILTER,
	clap.PLUGIN_FEATURE_STEREO,
	nil,
}

plugin_desc := clap.Plugin_Descriptor{
	clap_version = clap.CLAP_VERSION,
	id           = "com.example.zdf-svf",
	name         = "ZDF SVF",
	vendor       = "Example",
	url          = "",
	manual_url   = "",
	support_url  = "",
	version      = "1.0.0",
	description  = "State-variable filter using trapezoidal integration",
	features     = &_features[0],
}

// --- Frequency mapping: normalized 0–1 ↔ Hz via exponential curve ---
// 0.0 → 20 Hz, 0.5 → ~632 Hz, 1.0 → 20000 Hz

FREQ_MIN :: 20.0
FREQ_MAX :: 20000.0
FREQ_RATIO :: FREQ_MAX / FREQ_MIN // 1000

norm_to_hz :: proc "contextless" (norm: f64) -> f64 {
	return FREQ_MIN * math.pow(FREQ_RATIO, clamp(norm, 0, 1))
}

hz_to_norm :: proc "contextless" (hz: f64) -> f64 {
	return math.ln(clamp(hz, FREQ_MIN, FREQ_MAX) / FREQ_MIN) / math.ln(f64(FREQ_RATIO))
}

CUTOFF_DEFAULT :: 0.5 // ~632 Hz

// --- Plugin state ---

Plug :: struct {
	plugin:      clap.Plugin,
	host:        ^clap.Host,
	sample_rate: f64,
	cutoff:      f64,    // normalized 0–1 (mapped to Hz via norm_to_hz)
	resonance:   f64,    // [0, 1]
	ic1eq:       [2]f64, // integrator state, per channel
	ic2eq:       [2]f64,
}

get_plug :: proc "c" (plugin: ^clap.Plugin) -> ^Plug {
	return cast(^Plug)plugin // Plugin is the first field of Plug
}

// --- DSP: ZDF 2-pole SVF (Zavalishin topology-preserving transform) ---

SVF_Coeffs :: struct { a1, a2, a3: f64 }

svf_coeffs :: proc "contextless" (cutoff, resonance, sample_rate: f64) -> SVF_Coeffs {
	g := math.tan_f64(math.PI * clamp(cutoff, 20, sample_rate * 0.49) / sample_rate)
	k := 2.0 - 2.0 * resonance
	a1 := 1.0 / (1.0 + g * (g + k))
	return {a1, g * a1, g * g * a1}
}

svf_tick :: proc "contextless" (ic1eq, ic2eq: ^f64, x: f64, c: SVF_Coeffs) -> f64 {
	v3 := x - ic2eq^
	v1 := c.a1 * ic1eq^ + c.a2 * v3
	v2 := ic2eq^ + c.a2 * ic1eq^ + c.a3 * v3
	ic1eq^ = 2 * v1 - ic1eq^
	ic2eq^ = 2 * v2 - ic2eq^
	return v2 // lowpass output
}

// --- Event handling ---

handle_event :: proc "c" (plug: ^Plug, hdr: ^clap.Event_Header) {
	if hdr.space_id != clap.CORE_EVENT_SPACE_ID do return
	if hdr.event_type == clap.EVENT_PARAM_VALUE {
		ev := cast(^clap.Event_Param_Value)hdr
		switch ev.param_id {
		case PARAM_CUTOFF:    plug.cutoff = ev.value
		case PARAM_RESONANCE: plug.resonance = ev.value
		}
	}
}

// --- Plugin callbacks ---

plug_init :: proc "c" (plugin: ^clap.Plugin) -> bool { return true }

plug_destroy :: proc "c" (plugin: ^clap.Plugin) {
	context = runtime.default_context()
	free(get_plug(plugin))
}

plug_activate :: proc "c" (
	plugin: ^clap.Plugin, sample_rate: f64, min_frames, max_frames: u32,
) -> bool {
	get_plug(plugin).sample_rate = sample_rate
	return true
}

plug_deactivate :: proc "c" (plugin: ^clap.Plugin) {}
plug_start_processing :: proc "c" (plugin: ^clap.Plugin) -> bool { return true }
plug_stop_processing :: proc "c" (plugin: ^clap.Plugin) {}

plug_reset :: proc "c" (plugin: ^clap.Plugin) {
	plug := get_plug(plugin)
	plug.ic1eq = {}
	plug.ic2eq = {}
}

plug_process :: proc "c" (plugin: ^clap.Plugin, p: ^clap.Process) -> clap.Process_Status {
	plug := get_plug(plugin)
	nframes := p.frames_count
	nevents := p.in_events.size(p.in_events)
	in_buf  := &p.audio_inputs[0]
	out_buf := &p.audio_outputs[0]
	ev_idx: u32 = 0
	frame:  u32 = 0

	for frame < nframes {
		// Process events at current sample position
		for ev_idx < nevents {
			hdr := p.in_events.get(p.in_events, ev_idx)
			if hdr.time > frame do break
			handle_event(plug, hdr)
			ev_idx += 1
		}

		// Next event boundary
		next: u32 = nframes
		if ev_idx < nevents {
			next = p.in_events.get(p.in_events, ev_idx).time
		}

		// Coefficients for this block (recomputed only at event boundaries)
		c := svf_coeffs(norm_to_hz(plug.cutoff), plug.resonance, plug.sample_rate)

		for i in frame..<next {
			for ch in 0..<2 {
				x := f64(in_buf.data32[ch][i])
				out_buf.data32[ch][i] = f32(svf_tick(&plug.ic1eq[ch], &plug.ic2eq[ch], x, c))
			}
		}
		frame = next
	}

	return .CONTINUE
}

plug_get_extension :: proc "c" (plugin: ^clap.Plugin, id: cstring) -> rawptr {
	str := string(id)
	if str == ext.EXT_AUDIO_PORTS do return &plug_audio_ports
	if str == ext.EXT_PARAMS do return &plug_params
	if str == ext.EXT_STATE do return &plug_state
	return nil
}

plug_on_main_thread :: proc "c" (plugin: ^clap.Plugin) {}

// --- Params extension ---

plug_params := ext.Plugin_Params{
	count = proc "c" (plugin: ^clap.Plugin) -> u32 { return 2 },

	get_info = proc "c" (plugin: ^clap.Plugin, index: u32, info: ^ext.Param_Info) -> bool {
		switch index {
		case 0:
			info^ = {
				id = PARAM_CUTOFF, flags = ext.PARAM_IS_AUTOMATABLE,
				min_value = 0, max_value = 1, default_value = CUTOFF_DEFAULT,
			}
			copy(info.name[:], "Cutoff")
		case 1:
			info^ = {
				id = PARAM_RESONANCE, flags = ext.PARAM_IS_AUTOMATABLE,
				min_value = 0, max_value = 1, default_value = 0,
			}
			copy(info.name[:], "Resonance")
		case:
			return false
		}
		return true
	},

	get_value = proc "c" (plugin: ^clap.Plugin, id: clap.Clap_Id, value: ^f64) -> bool {
		plug := get_plug(plugin)
		switch id {
		case PARAM_CUTOFF:    value^ = plug.cutoff
		case PARAM_RESONANCE: value^ = plug.resonance
		case: return false
		}
		return true
	},

	value_to_text = proc "c" (
		plugin: ^clap.Plugin, id: clap.Clap_Id, value: f64, buf: [^]u8, size: u32,
	) -> bool {
		context = runtime.default_context()
		temp: [64]u8
		s: string
		switch id {
		case PARAM_CUTOFF:
			hz := norm_to_hz(value)
			if hz >= 1000 {
				s = fmt.bprintf(temp[:], "%.1f kHz", hz / 1000)
			} else {
				s = fmt.bprintf(temp[:], "%.0f Hz", hz)
			}
		case PARAM_RESONANCE: s = fmt.bprintf(temp[:], "%.0f %%", value * 100)
		case: return false
		}
		if len(s) >= int(size) do return false
		copy(buf[:len(s)], s)
		buf[len(s)] = 0
		return true
	},

	text_to_value = proc "c" (
		plugin: ^clap.Plugin, id: clap.Clap_Id, text: cstring, value: ^f64,
	) -> bool {
		context = runtime.default_context()
		str := string(text)
		// Strip common suffixes
		for suffix in ([]string{" kHz", " Hz", " %", "%", "kHz", "Hz"}) {
			if len(str) > len(suffix) && str[len(str)-len(suffix):] == suffix {
				is_khz := suffix == " kHz" || suffix == "kHz"
				str = str[:len(str)-len(suffix)]
				parsed, ok := strconv.parse_f64(str)
				if !ok do return false
				if is_khz do parsed *= 1000
				switch id {
				case PARAM_CUTOFF:    value^ = hz_to_norm(parsed)
				case PARAM_RESONANCE: value^ = clamp(parsed / 100, 0, 1)
				case: return false
				}
				return true
			}
		}
		parsed, ok := strconv.parse_f64(str)
		if !ok do return false
		switch id {
		case PARAM_CUTOFF:    value^ = hz_to_norm(parsed)
		case PARAM_RESONANCE: value^ = clamp(parsed / 100, 0, 1)
		case: return false
		}
		return true
	},

	flush = proc "c" (
		plugin: ^clap.Plugin, in_ev: ^clap.Input_Events, out_ev: ^clap.Output_Events,
	) {
		plug := get_plug(plugin)
		for i in 0..<in_ev.size(in_ev) {
			handle_event(plug, in_ev.get(in_ev, i))
		}
	},
}

// --- Audio ports extension ---

plug_audio_ports := ext.Plugin_Audio_Ports{
	count = proc "c" (plugin: ^clap.Plugin, is_input: bool) -> u32 { return 1 },

	get = proc "c" (
		plugin: ^clap.Plugin, index: u32, is_input: bool, info: ^ext.Audio_Port_Info,
	) -> bool {
		if index != 0 do return false
		info^ = {
			id = 0, flags = ext.AUDIO_PORT_IS_MAIN,
			channel_count = 2, port_type = ext.AUDIO_PORT_STEREO,
			in_place_pair = clap.INVALID_ID,
		}
		if is_input {
			copy(info.name[:], "Input")
		} else {
			copy(info.name[:], "Output")
		}
		return true
	},
}

// --- State extension ---

plug_state := ext.Plugin_State{
	save = proc "c" (plugin: ^clap.Plugin, stream: ^clap.Output_Stream) -> bool {
		plug := get_plug(plugin)
		params := [2]f64{plug.cutoff, plug.resonance}
		return stream.write(stream, &params, size_of(params)) == i64(size_of(params))
	},

	load = proc "c" (plugin: ^clap.Plugin, stream: ^clap.Input_Stream) -> bool {
		plug := get_plug(plugin)
		params: [2]f64
		if stream.read(stream, &params, size_of(params)) != i64(size_of(params)) do return false
		plug.cutoff = params[0]
		plug.resonance = params[1]
		return true
	},
}

// --- Factory ---

plug_factory := factory.Plugin_Factory{
	get_plugin_count = proc "c" (f: ^factory.Plugin_Factory) -> u32 { return 1 },

	get_plugin_descriptor = proc "c" (
		f: ^factory.Plugin_Factory, index: u32,
	) -> ^clap.Plugin_Descriptor {
		if index == 0 do return &plugin_desc
		return nil
	},

	create_plugin = proc "c" (
		f: ^factory.Plugin_Factory, host: ^clap.Host, id: cstring,
	) -> ^clap.Plugin {
		if string(id) != string(plugin_desc.id) do return nil
		context = runtime.default_context()
		plug := new(Plug)
		plug^ = {
			host    = host,
			cutoff  = CUTOFF_DEFAULT,
			plugin  = {
				desc             = &plugin_desc,
				init             = plug_init,
				destroy          = plug_destroy,
				activate         = plug_activate,
				deactivate       = plug_deactivate,
				start_processing = plug_start_processing,
				stop_processing  = plug_stop_processing,
				reset            = plug_reset,
				process          = plug_process,
				get_extension    = plug_get_extension,
				on_main_thread   = plug_on_main_thread,
			},
		}
		return &plug.plugin
	},
}

// --- Entry point ---

@(export)
clap_entry := clap.Plugin_Entry{
	clap_version = clap.CLAP_VERSION,
	init         = proc "c" (path: cstring) -> bool { return true },
	deinit       = proc "c" () {},
	get_factory  = proc "c" (id: cstring) -> rawptr {
		if string(id) == factory.PLUGIN_FACTORY_ID do return &plug_factory
		return nil
	},
}
