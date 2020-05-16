module vlipboard

import clipboard
import os

/*
Vlipboard methods:
	0: standard
	1: wayland
	2: termux
*/
struct Vlipboard {
mut:
	method int
	clip   &clipboard.Clipboard
}

// new creates a new Vlipboard instance
pub fn new() ?&Vlipboard {
	// Clipboard.copy() wont work linux unless it's primary
	clip := if os.user_os() == 'linux' {
		clipboard.new_primary()
	} else {
		clipboard.new()
	}

	if os.getenv('WAYLAND_DISPLAY') != '' {
		if !(exists_in_path('wl-copy') && exists_in_path('wl-paste')) {
			return error('Clipboard wont work on Wayland unless you install wl-clipboard')
		}
		return &Vlipboard{
			method: 1
			clip: clip
		}
	} else if exists_in_path('termux-clipboard-set') && exists_in_path('termux-clipboard-get') {
		return &Vlipboard{
			method: 2
			clip: clip
		}
	} else {
		if clip.is_available() != true {
			return error('Clipboard is not supported')
		}
		return &Vlipboard{
			clip: clip
			method: 0
		}
	}
}

// copy text into the clipboard
pub fn (mut vb Vlipboard) copy(text string) bool {
	match vb.method {
		0 { return vb.clip.copy(text) }
		1 { return os.system('wl-copy $text') == 0 }
		2 { return os.system('termux-clipboard-set $text') == 0 }
		else {}
	}
}

// paste returns the content of the clipboard
pub fn (mut vb Vlipboard) paste() string {
	match vb.method {
		0 {
			return vb.clip.paste()
		}
		1 {
			result := os.exec('wl-paste --no-newline') or {
				return ''
			}
			return result.output
		}
		2 {
			result := os.exec('termux-clipboard-get') or {
				return ''
			}
			return result.output
		}
		else {}
	}
}

// clear the content of the clipboard
pub fn (mut vb Vlipboard) clear() bool {
	match vb.method {
		0 {
			vb.clip.clear_all()
			return true
		}
		1 {
			os.system('wl-copy ""')
			return true
		}
		2 {
			os.system('termux-clipboard-set ""')
			return true
		}
		else {}
	}
}

// exists_in_path returns true if the function exists in the system's 
fn exists_in_path(prog string) bool {
	os.find_abs_path_of_executable(prog) or {
		return false
	}
	return true
}
