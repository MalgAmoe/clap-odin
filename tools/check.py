#!/usr/bin/env python3
"""Compile all packages; optionally compare selected ABI layouts with CLAP 1.2.10."""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
# Explicit coverage: core processing plus every new/changed interface in 1.2.10.
LAYOUTS = {
    'clap.Version': ('clap_version_t', 'major minor revision'),
    'clap.Audio_Buffer': ('clap_audio_buffer_t', 'data32 data64 channel_count latency constant_mask'),
    'clap.Process': ('clap_process_t', 'steady_time frames_count transport audio_inputs audio_outputs audio_inputs_count audio_outputs_count in_events out_events'),
    'ext.Window': ('clap_window_t', 'api'),
    'draft.Plugin_Background_Activation': ('clap_plugin_background_activation_t', 'activate_from_background_thread deactivate_from_background_thread'),
    'draft.Host_Background_Progress': ('clap_host_background_progress_t', 'is_canceled progress'),
    'draft.Plugin_Background_State_Context': ('clap_plugin_background_state_context_t', 'save_from_background_thread load_from_background_thread'),
    'draft.Plugin_Flush_Events': ('clap_plugin_flush_events_t', 'flush'),
    'draft.Host_Flush_Events': ('clap_host_flush_events_t', 'request_flush'),
    'draft.Plugin_Octave_Number': ('clap_plugin_octave_number_t', 'set_note60_octave'),
    'draft.Host_Param_Hovered': ('clap_host_param_hovered_t', 'update'),
    'draft.Plugin_Params_Origin': ('clap_plugin_params_origin_t', 'get'),
    'draft.Host_Params_Origin': ('clap_host_params_origin_t', 'changed'),
    'draft.Host_Transport_Control': ('clap_host_transport_control_t', 'request_start request_stop request_continue request_pause request_toggle_play request_jump request_loop_region request_toggle_loop request_enable_loop request_record request_toggle_record request_tempo request_time_signature'),
}
IDS = ['BACKGROUND_ACTIVATION', 'BACKGROUND_PROGRESS', 'BACKGROUND_STATE_CONTEXT',
       'FLUSH_EVENTS', 'OCTAVE_NUMBER', 'PARAM_HOVERED', 'PARAMS_ORIGIN', 'TRANSPORT_CONTROL']


def run(args, **kwargs):
    return subprocess.run(args, cwd=ROOT, check=True, **kwargs)


def abi(include, temp):
    # Resolve imports to this checkout even when its directory has been renamed.
    collection = temp / 'bindings'
    collection.mkdir()
    (collection / 'clap-odin').symlink_to(ROOT, target_is_directory=True)
    c = ['#include <stdio.h>', '#include <stddef.h>', '#include <clap/all.h>', 'int main(void) {']
    odin = ['package main', 'import "core:fmt"', 'import clap "bindings:clap-odin"',
            'import ext "bindings:clap-odin/ext"', 'import draft "bindings:clap-odin/ext/draft"', 'main :: proc() {']
    for ot, (ct, fields) in LAYOUTS.items():
        c.append(f'printf("%zu %zu\\n", sizeof({ct}), _Alignof({ct}));')
        odin.append(f'fmt.println(size_of({ot}), align_of({ot}))')
        for field in fields.split():
            c.append(f'printf("%zu\\n", offsetof({ct}, {field}));')
            odin.append(f'fmt.println(offset_of({ot}, {field}))')
    c.append('printf("%zu\\n", offsetof(clap_window_t, uikit));')
    odin.append('fmt.println(offset_of(ext.Window, handle) + offset_of(ext.Window_Handle, uikit))')
    for name in IDS:
        c.append(f'puts(CLAP_EXT_{name});')
        odin.append(f'fmt.println(draft.EXT_{name})')
    c.append('puts(CLAP_WINDOW_API_UIKIT);')
    odin.append('fmt.println(ext.WINDOW_API_UIKIT)')
    for component in ['MAJOR', 'MINOR', 'REVISION']:
        c.append(f'printf("%d\\n", CLAP_VERSION_{component});')
        odin.append(f'fmt.println(clap.CLAP_VERSION_{component})')
    c.append('return 0; }'); odin.append('}')
    (temp/'layout.c').write_text('\n'.join(c))
    (temp/'layout.odin').write_text('\n'.join(odin))
    run([os.environ.get('CC', 'cc'), '-std=c11', '-I'+str(include), str(temp/'layout.c'), '-o', str(temp/'c-layout')])
    run(['odin', 'build', str(temp/'layout.odin'), '-file', '-thread-count:1',
         '-collection:bindings='+str(collection), '-out:'+str(temp/'odin-layout')])
    expected = run([str(temp/'c-layout')], capture_output=True).stdout
    actual = run([str(temp/'odin-layout')], capture_output=True).stdout
    if expected != actual:
        raise RuntimeError(f'ABI/constant mismatch\nC: {expected!r}\nOdin: {actual!r}')
    print(f'ABI checks passed: {len(LAYOUTS)} layouts, member offsets and selected constants.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--clap-include', type=Path, help='CLAP 1.2.10 include directory (no automatic download)')
    args = parser.parse_args()
    for package in ['.', 'ext', 'ext/draft', 'factory', 'factory/draft']:
        run(['odin', 'check', package, '-no-entry-point', '-thread-count:1'])
    with tempfile.TemporaryDirectory(prefix='clap-check-') as directory:
        temp = Path(directory)
        run(['odin', 'build', 'example', '-build-mode:dll', '-thread-count:1', '-out:'+str(temp/'example.clap')])
        if args.clap_include:
            abi(args.clap_include.resolve(), temp)
    print('All package checks and example build passed.')


if __name__ == '__main__':
    main()
