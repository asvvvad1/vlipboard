module vlipboard

import clipboard
import os

/*
Vlipboard methods:
	0: standard
	1: wayland
	2: termux
	3: plan9
	4: clip
	5: xsel
*/
struct Vlipboard {
mut:
	method int
	clip   &clipboard.Clipboard
}

// new creates a new Vlipboard instance
pub fn new() ?&Vlipboard {
	// Clipboard.copy() wont work linux unless it's primary
	clip := if os.user_os() == 'linux' { clipboard.new_primary() } else { clipboard.new() }
	if os.getenv('WAYLAND_DISPLAY') != '' {
		if !(os.exists_in_system_path('wl-copy') && os.exists_in_system_path('wl-paste')) {
			return error('Clipboard wont work on Wayland unless you install wl-clipboard')
		}
		return &Vlipboard{
			method: 1
			clip: clip
		}
	} else if os.exists_in_system_path('termux-clipboard-set') && os.exists_in_system_path('termux-clipboard-get') {
		return &Vlipboard{
			method: 2
			clip: clip
		}
	} else if os.exists('/dev/snarf') {
		// Plan 9 from Bell Labs
		return &Vlipboard{
			method: 3
			clip: clip
		}
	} else {
		// if default clipboard library isn't available fall back to xclip or xsel
		if clip.is_available() != true {
			if os.exists_in_system_path('xclip') {
				return &Vlipboard{
					method: 4
					clip: clip
				}
			} else if os.exists_in_system_path('xsel') {
				return &Vlipboard{
					method: 5
					clip: clip
				}
			} else {
				return error('Clipboard is not supported')
			}
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
		3 {
			file := os.open('/dev/snarf') or {
				return false
			}
			file.write(text)
			return true
		}
		4 {
			return os.system('xclip -in -selection clipboard <<< "$text"') == 0
		}
		5 {
			return os.system('xsel --input --clipboard <<< "$text"') == 0
		}
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
		3 {
			result := os.read_file('/dev/snarf') or {
				return ''
			}

			return result
		}
		4 {
			result := os.exec('xclip -out -selection clipboard') or {
				return ''
			}
			return result.output
		}
		5 {
			result := os.exec('xsel --output --clipboard') or {
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
		else { vb.copy('') }
	}
}
