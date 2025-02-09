package markdownpp_utils

import "core:strings"
import "core:fmt"
import "core:text/match"

get_file_name :: proc(call: string) -> (string, bool) {
    match_file := match.matcher_init(call, "%\"(.-)\"")
    file: string
    file_capture, is_file := match.matcher_match(&match_file)
    if is_file { 
        return file_capture, true
    }
    return "", false
    
}

get_inner_function_call_values :: proc(comment: string, func: string) -> string {
    a := [?]string {`%.`, func, "%b()"}
    call := strings.concatenate(a[:]) 
    match_function_call := match.matcher_init(comment, call)
    function_call, is_function := match.matcher_match(&match_function_call)
    if is_function {
        return capture_call_args(function_call)
    }
    return ""
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
