package cli


parse_args :: proc(args: []string) -> (string, string) {
	if len(args) == 0 {
		return "", "Usage: xls-to-text <input-file.xls>"
	}

	if args[0] == "--help" || args[0] == "-h" {
		return "", "Usage: xls-to-text <input-file.xls>"
	}

	return args[0], ""
}
