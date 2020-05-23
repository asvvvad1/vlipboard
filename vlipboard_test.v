module vlipboard

fn test_vlipboard() {
	clip := new() or {
		panic(err)
	}

	text := 'Hello, world!'
	assert clip.copy(text) == true
	assert clip.paste() == 'Hello, world!'
	assert clip.clear() == true
	assert clip.paste().len <= 0
}