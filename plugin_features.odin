package clap

// This file provides a set of standard plugin features meant to be used
// within Plugin_Descriptor.features.
//
// For practical reasons we avoid spaces and use `-` instead to facilitate
// scripts that generate the feature array.
//
// Non-standard features should be formatted as: "$namespace:$feature"

/////////////////////
// Plugin category //
/////////////////////

// Add this feature if your plugin can process note events and then produce audio
PLUGIN_FEATURE_INSTRUMENT :: "instrument"

// Add this feature if your plugin is an audio effect
PLUGIN_FEATURE_AUDIO_EFFECT :: "audio-effect"

// Add this feature if your plugin is a note effect or a note generator/sequencer
PLUGIN_FEATURE_NOTE_EFFECT :: "note-effect"

// Add this feature if your plugin converts audio to notes
PLUGIN_FEATURE_NOTE_DETECTOR :: "note-detector"

// Add this feature if your plugin is an analyzer
PLUGIN_FEATURE_ANALYZER :: "analyzer"

/////////////////////////
// Plugin sub-category //
/////////////////////////

PLUGIN_FEATURE_SYNTHESIZER :: "synthesizer"
PLUGIN_FEATURE_SAMPLER :: "sampler"
PLUGIN_FEATURE_DRUM :: "drum" // For single drum
PLUGIN_FEATURE_DRUM_MACHINE :: "drum-machine"

PLUGIN_FEATURE_FILTER :: "filter"
PLUGIN_FEATURE_PHASER :: "phaser"
PLUGIN_FEATURE_EQUALIZER :: "equalizer"
PLUGIN_FEATURE_DEESSER :: "de-esser"
PLUGIN_FEATURE_PHASE_VOCODER :: "phase-vocoder"
PLUGIN_FEATURE_GRANULAR :: "granular"
PLUGIN_FEATURE_FREQUENCY_SHIFTER :: "frequency-shifter"
PLUGIN_FEATURE_PITCH_SHIFTER :: "pitch-shifter"

PLUGIN_FEATURE_DISTORTION :: "distortion"
PLUGIN_FEATURE_TRANSIENT_SHAPER :: "transient-shaper"
PLUGIN_FEATURE_COMPRESSOR :: "compressor"
PLUGIN_FEATURE_EXPANDER :: "expander"
PLUGIN_FEATURE_GATE :: "gate"
PLUGIN_FEATURE_LIMITER :: "limiter"

PLUGIN_FEATURE_FLANGER :: "flanger"
PLUGIN_FEATURE_CHORUS :: "chorus"
PLUGIN_FEATURE_DELAY :: "delay"
PLUGIN_FEATURE_REVERB :: "reverb"

PLUGIN_FEATURE_TREMOLO :: "tremolo"
PLUGIN_FEATURE_GLITCH :: "glitch"

PLUGIN_FEATURE_UTILITY :: "utility"
PLUGIN_FEATURE_PITCH_CORRECTION :: "pitch-correction"
PLUGIN_FEATURE_RESTORATION :: "restoration" // repair the sound

PLUGIN_FEATURE_MULTI_EFFECTS :: "multi-effects"

PLUGIN_FEATURE_MIXING :: "mixing"
PLUGIN_FEATURE_MASTERING :: "mastering"

////////////////////////
// Audio Capabilities //
////////////////////////

PLUGIN_FEATURE_MONO :: "mono"
PLUGIN_FEATURE_STEREO :: "stereo"
PLUGIN_FEATURE_SURROUND :: "surround"
PLUGIN_FEATURE_AMBISONIC :: "ambisonic"
