package markdownpp

import "core:fmt"
import "core:os"
import "core:flags"
import "core:strings"
import "core:path/filepath"
import "core:slice"
import "core:text/match"
import "core:mem"
import "functions"
import "tokens"
import "utils"

print :: fmt.println

Options :: struct {
    file: os.Handle `args:"pos=0,required,file=r" usage:"Input file containing markdown++"`,
    output: os.Handle `args:"file=cw" usage:"Output file for converted markdown"`,
}


call_csv_function :: proc(comment: string) -> string {
    rows, columns, file := functions.handle_csv(comment)
    ok: bool
    file, ok = strings.remove_all(file, "\"")
    fd, err := os.open(file); defer os.close(fd)
    if err != nil {
        fmt.eprintfln("failed to read %s: ", file, err)
        return ""
    }
    print("rows: ", rows, " columns: ", columns)
    table := functions.csv_to_md(fd, rows, columns)
    return table
}

call_import_function :: proc(comment: string) -> string {
    file := functions.handle_import(comment)
    ok: bool
    file, ok = strings.remove_all(file, "\"")
    if !ok {
        fmt.eprintfln("failed to remove \" in %s: ", file, ok)
        return ""
    }
    contents, good := os.read_entire_file(file)
    if !good {
        fmt.eprintfln("failed to read %s: ", file, good)
        return ""
    }
    return string(contents)
}

call_markdown_function :: proc(comment: string) -> string {
    file := functions.handle_import(comment)
    ok: bool
    file, ok = strings.remove_all(file, "\"")
    if !ok {
        fmt.eprintfln("failed to remove \" in %s: ", file, ok)
        return ""
    }
    contents, good := os.read_entire_file(file)
    if !good {
        fmt.eprintfln("failed to read %s: ", file, good)
        return ""
    }
    pattern := "<!--(.-)-->"
    parsed_markdown := generate_markdown(string(contents), pattern)
    return parsed_markdown
}

handle_comments :: proc(word: string) -> string {
    comment := strings.trim_left(word, "<!--")
    comment = strings.trim(comment, "-->")
    comment = strings.trim_space(comment)
    for i in tokens.Token_Kind.Keyword_Begin ..= tokens.Token_Kind.Keyword_End {
        kind: tokens.Token_Kind
        if strings.starts_with(comment, tokens.tokens[i]) {
            kind = tokens.Token_Kind(i)
            #partial switch kind {
                case .Import: {
                    file_import := call_import_function(comment) 
                    return file_import
                }
                case .Markdown: {
                    markdown_import := call_markdown_function(comment)
                    return markdown_import
                }
                case .Csv: {
                    table := call_csv_function(comment)
                    return table
                }
            }
        }
    }
    return word
}

generate_markdown :: proc(src: string, pattern: string) -> string {
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
    md := strings.to_string(plain_md)
    return md
}

main :: proc() {
    
    opt: Options
    style: flags.Parsing_Style = .Unix
    flags.parse_or_exit(&opt, os.args, style)

    src, ok := os.read_entire_file(opt.file)
    if !ok {
        fmt.eprintln("Error reading file, ", opt.file, ok)
    }

    filestat, err := os.fstat(opt.file)
    if err != nil {
        fmt.eprintln("Failed to get filename from input file handle: ", opt.file)
        return
    }
    pwd := filepath.dir(filestat.fullpath)
    set_path_err := os.set_current_directory(pwd)
    if set_path_err != nil {
        fmt.eprintln("Failed to set current working directory to: ", pwd, " ", set_path_err)
    }

    data: rawptr
    pattern := "<!--(.-)-->"
    markdown := generate_markdown(string(src), pattern)

    if opt.output != 0 {
        os.write_string(opt.output, markdown)
    } else {
        print(markdown)
    }
}
