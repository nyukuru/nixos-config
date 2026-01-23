vim.g["clang_format#detect_style_file"] = 1
vim.g["clang_format#auto_format"] = 1
vim.g["clang_format#auto_filetypes"] = { "c", "cpp", "objc" }
vim.g["clang_format#code_style"] = "google"

vim.g["clang_format#style_options"] = {
	IndentPPDirectives = "AfterHash",
	IndentWidth = "2",
}
