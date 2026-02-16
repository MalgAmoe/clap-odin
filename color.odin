package clap

Color :: struct {
	alpha: u8,
	red:   u8,
	green: u8,
	blue:  u8,
}

COLOR_TRANSPARENT :: Color { alpha = 0, red = 0, green = 0, blue = 0 }
