package markdownpp_parser

import "core:strings"
import "core:os"
import "core:fmt"
import "core:text/match"

import "../functions"

print :: fmt.println

Token_Kind :: enum u32 {
    Keyword_Begin,
        Import,
        Table,
        Csv,
    Keyword_End,

    COUNT,
}

tokens := [Token_Kind.COUNT]string {
    "",
        "#import",
        "#table",
        "#csv",
    "",
}

capture_call_args :: proc(call: string) -> string {
    res: string
    res_builder := strings.builder_make()
    match_call := match.matcher_init(call, "%((.-)%)")
    matching_value, ok := match.matcher_match(&match_call)
    matching_value = strings.trim_left(matching_value, "(")
    matching_value = strings.trim_right(matching_value, ")")
    if strings.contains(matching_value, "\"") {
        matching_value_cleaned, was_allocation := strings.remove_all(matching_value, "\"")
        defer delete(matching_value_cleaned)
        strings.write_string(&res_builder, matching_value_cleaned)
    } else {
        strings.write_string(&res_builder, matching_value)
    }
    res = strings.to_string(res_builder)
    return res
}


handle_csv :: proc(comment: string) {
    match_file := match.matcher_init(comment, "%\"(.-)\"")
    file: string

    file_capture, is_file := match.matcher_match(&match_file)
    if is_file { file = file_capture }

    match_columns_call := match.matcher_init(comment, "%.columns%b()")
    columns_call, is_columns := match.matcher_match(&match_columns_call)
    columns: string
    if is_columns {
        columns = capture_call_args(columns_call)
    }

    match_rows_call := match.matcher_init(comment, "%.rows%b()")
    rows_call, is_rows := match.matcher_match(&match_rows_call)
    rows: string
    if is_rows {
        rows = capture_call_args(rows_call)
    }
    functions.csv(rows, columns, file)
}

handle_comments :: proc(word: string) -> string {
    comment := strings.trim_left(word, "<!--")
    comment = strings.trim(comment, "-->")
    comment = strings.trim_space(comment)
    for i in Token_Kind.Keyword_Begin ..= Token_Kind.Keyword_End {
        kind: Token_Kind
        if strings.starts_with(comment, tokens[i]) {
            kind = Token_Kind(i)
            #partial switch kind {
                case .Import: {
                    return "this was an import"
                }
                case .Table: {
                    print("found table")
                    return "we replaced the table"
                }
                case .Csv: {
                    handle_csv(comment)
                    return "this was a csv"
                }
            }
        }
    }
    return word
}

generate_markdown :: proc(src: string, pattern: string) {
    captures: [32]match.Match
    src := src
    plain_md := strings.builder_make()
    for {
        length := match.find_aux(src, pattern, 0, false, &captures) or_break
        if length == 0 { break }
        cap := captures[0]
        word := src[cap.byte_start:cap.byte_end]
        replacement := handle_comments(word)
        strings.write_string(&plain_md, src[:cap.byte_start])
        strings.write_string(&plain_md, replacement)
        src = src[cap.byte_end:]
    }
    print(strings.to_string(plain_md))
}

parse :: proc(src: string) {
    data: rawptr
    pattern := "<!--(.-)-->"
    generate_markdown(src, pattern)








}
