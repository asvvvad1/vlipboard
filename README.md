# vlipboard
An extended clipboard library for V with Wayland, Termux, Plan 9 and xclip & xclip fallback support.
It's meant to be easier to use and simple. Contributions welcome!

## Requirements:
- Wayland support needs [wl-clipboard](https://github.com/bugaevc/wl-clipboard) to be in $PATH
- Termux support only needs the Addons:API package to be installed
- There is no direct way to build V programs for Plan 9 but you can compile to C code then build it on your Plan 9 machine. see https://github.com/vlang/v/issues/4979

>Written a V port of wl-clipboard or want to do so? have an idea on other platforms support? You're welcome to open an issue or a pull request! This is my first V module and I just started out learning so any help is welcome ^^ 

# Usage:
```v
import asvvvad/vlipboard

clip := new() or {
  panic(err)
}

text := 'Hello, world!'
clip.copy(text) // copy() returns true on success
print(clip.paste()) // 'Hello, world!'
clip.clear() // clear() returns true on success
print(clip.paste().len <= 0) // true
}
```
That's it! :3
