package parser

import xml "core:encoding/xml"
import "core:fmt"
import "core:strings"


Row :: struct {
	portfolio: string,
	id:        string,
	title:     string,
	status:    string,
}

parse_file :: proc(data: []byte) -> ([]Row, string) {
	content := string(data)
	tbody_content := get_tbody(content)
	if tbody_content == "" {
		return {}, "No tbody found in the content"
	}
	return parse_tbody(tbody_content)
}

@(private)
get_tbody :: proc(content: string) -> string {
	start_idx := strings.index(content, "<tbody>")
	if start_idx == -1 {
		return ""
	}

	end_idx := strings.index(content, "</tbody>")
	if end_idx == -1 {
		return ""
	}

	end_idx += len("</tbody>")

	return content[start_idx:end_idx]
}


@(private)
parse_tbody :: proc(content: string) -> ([]Row, string) {

	document, err := xml.parse(content)
	if err != nil {
		return {}, fmt.tprint(err)
	}
	defer xml.destroy(document)

	rows := make([dynamic]Row)
	for element in document.elements {
		if element.ident == "tr" {
			td_count := 0
			row := Row{}

			for value in element.value {
				switch v in value {
				case string:
					continue
				case xml.Element_ID:
					content := parse_row(document, v)
					if content != "" {
						switch td_count {
						case 0:
							// Portfolio (1st column)
							row.portfolio = content
						case 2:
							// ID (3rd column)
							row.id = content
						case 3:
							// Title (4th column)
							row.title = content
						case 8:
							// Status (9th column)
							row.status = content
						}
					}
					td_count += 1
				}
			}

			if row.id != "" {
				append(&rows, row)
			}
		}
	}

	return rows[:], ""
}

@(private)
parse_row :: proc(document: ^xml.Document, tr_element: xml.Element_ID) -> string {
	element := document.elements[tr_element]
	if element.ident == "td" {

		for value in element.value {
			switch v in value {
			case string:
				return v
			case xml.Element_ID:
				continue
			}
		}

	}

	return ""
}
