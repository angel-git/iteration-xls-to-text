package main

import cli "cli"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import parser "parser"


main :: proc() {
	args := os.args[1:] // skip program name

	input_path, err := cli.parse_args(args)
	if err != "" {
		print_error_and_exit(err)
		return
	}

	xls_file, ok_xls_file := os.read_entire_file(input_path)
	if !ok_xls_file {
		print_error_and_exit("sd")
	}

	stories, err_on_parsing := parser.parse_file(xls_file)
	if err_on_parsing != "" {
		print_error_and_exit(err_on_parsing)
	}

	if len(stories) == 0 {
		print_error_and_exit(
			"No stories were found in the XLS file or something went wrong while parsing the XLS file",
		)
	}

	print_grouped_stories(stories)
}

print_grouped_stories :: proc(stories: []parser.Row) {
	portfolio_map := make(map[string][dynamic]parser.Row)
	defer delete(portfolio_map)

	for story in stories {
		portfolio := story.portfolio
		if portfolio == "" {
			continue
		}

		if portfolio not_in portfolio_map {
			portfolio_map[portfolio] = make([dynamic]parser.Row)
		}
		append(&portfolio_map[portfolio], story)
	}

	for portfolio, portfolio_stories in portfolio_map {
		fmt.printf("\n%s\n", strings.to_upper(portfolio))
		fmt.println(strings.repeat("=", len(portfolio)))

		for story in portfolio_stories {
			fmt.printf("%s\t%s [%s]\n", story.id, story.title, story.status)
		}
	}

	// Clean up dynamic arrays
	for _, portfolio_stories in portfolio_map {
		delete(portfolio_stories)
	}
}

print_error_and_exit :: proc(e: string) {
	fmt.printfln("🔥 ERROR: %s", e)
	os.exit(1)
}
