package file

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

Error :: enum {
    None,
    Open,
    File_Size,
    Read,
}

read :: proc(file: string) -> ([]u8, Error) {
    f, err_no := os.open(file)
    if err_no != 0 {
        return nil, .Open
    }
    defer os.close(f)
    //
    size: i64
    size, err_no = os.file_size(f)
    if err_no != 0 {
        return nil, .File_Size
    }
    // EOF
    size += 1

    data := make([]u8, size)
    // defer delete(data)

    bytes_read: int
    bytes_read, err_no = os.read(f, data)
    if err_no != 0 {
        return nil, .Read
    }
    // text := string(data)
    return data, .None
}   

lines :: proc(file: string) -> (string, []string, Error) {
    raw, err := read(file)
    text: string
    if err != nil {
        return text, nil, err
    }
    text = string(raw)
    return text, strings.split(text, "\n"), .None
}