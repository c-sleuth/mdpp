package markdownpp_functions

import "core:fmt"
import "core:io"
import "core:slice"
import "core:encoding/csv"
import "core:os"
import "core:text/table"
import "core:strings"
import "core:mem"
import "core:strconv"
import "core:text/match"
import "../utils"

print :: fmt.println

handle_csv :: proc(comment: string) -> (string, string, string) {
    file, ok := utils.get_file_name(comment)
    if !ok { 
        fmt.println("failed to get filename in: ", comment)
        return "", "", ""
    }
    columns := utils.get_inner_function_call_values(comment, "columns")
    rows := utils.get_inner_function_call_values(comment, "rows")
    return rows, columns, file
}

csv_to_md :: proc(fd: os.Handle, rows: string, columns: string) -> string {
    r: csv.Reader
    r.reuse_record = true
    r.reuse_record_buffer = true
    defer csv.reader_destroy(&r)
    csv.reader_init(&r, os.stream_from_handle(fd))
    rows := strconv.atoi(rows)
    if rows == 0 {
            // i have no clue as to why this doesnt work
            // data, err := csv.read_all(&r)
            // defer delete(data)
            // rows = len(data) - 1
        rows = 1
    }

    string_buffer := strings.builder_make()
    defer strings.builder_destroy(&string_buffer)
    cols_list: []string
    {
        tbl: table.Table
        table.init(&tbl)
        defer table.destroy(&tbl)
        cols_i: [dynamic]int; defer delete(cols_i)
    
        row_count: for r, i in csv.iterator_next(&r) {
            if i == 0 {
                if len(columns) == 0 {
                    cols_list = r
                    for v, i in r {
                        append(&cols_i, i)
                        table.header_of_values(&tbl, v)
                    }
                } else {
                    cols_list = strings.split(columns, ",")
                    for col in cols_list {
                        col_name := strings.trim_left_space(col)
                        col_index, found_col := slice.linear_search(r, col_name)
                        if found_col {
                           table.header_of_values(&tbl, col_name)
                           append(&cols_i, col_index)
                        }
                    }
                }
                for _ in 1 ..= rows {
                    table.row(&tbl)
                }
            } else {
                values_builder := strings.builder_make()
                
                for column_index in cols_i {
                    strings.write_string(&values_builder, r[column_index])
                    strings.write_string(&values_builder, "<NEW_CSV_VALUE>")
                }
                s := strings.to_string(values_builder)
                s = strings.trim_right(s, "<NEW_CSV_VALUE>")
                l := strings.split(s, "<NEW_CSV_VALUE>")

                for value, j in l {
                    table.set_cell_value_and_alignment(&tbl, i, j, value, table.Cell_Alignment(.Center))
                }
                if i == rows do break row_count
            }
        }

        builder_writer := strings.to_writer(&string_buffer)
        table.write_markdown_table(builder_writer, &tbl)
    }
     t := strings.to_string(string_buffer)
     md_table := fmt.aprint(t)
     return md_table
}
