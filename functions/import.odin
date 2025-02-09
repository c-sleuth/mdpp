package markdownpp_functions

import "core:fmt"
import "core:io"
import "core:slice"
import "core:os"
import "core:strings"
import "core:mem"
import "core:strconv"
import "core:text/match"
import "../utils"


handle_import :: proc(comment: string) -> string {
    file, ok := utils.get_file_name(comment)
    if !ok {
        fmt.eprintln("Failed to get filename in: ", comment)
        return ""
    }
    return file
}
