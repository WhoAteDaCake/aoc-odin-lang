package sslice

import "core:slice"

difference :: proc(a: []byte, b: []byte) -> []byte {
    new_value := make([dynamic]byte)
    for char in a  {
        if !slice.contains(b, char) {
            append(&new_value, char)
        }
    }
    for char in b  {
        if !slice.contains(a, char) {
            append(&new_value, char)
        }
    }
    return new_value[:]
}

without :: proc(a: []byte, b: []byte) -> []byte {
    new_value := make([dynamic]byte)
    for char in b  {
        if !slice.contains(a, char) {
            append(&new_value, char)
        }
    }
    return new_value[:]
}

overlap :: proc(a: []byte, b: []byte) -> []byte {
    new_value := make([dynamic]byte)
    for char in a  {
        if slice.contains(b, char) {
            append(&new_value, char)
        }
    }
    return new_value[:]
}

unique :: proc(a: [][]byte) -> []byte {
    new_value := make([dynamic]byte)
    for row in a {
        for char in row {
            if !slice.contains(new_value[:], char) {
                append(&new_value, char)
            }
        }
    }
    return new_value[:]
}

delete_at :: proc(slice: []byte, idx: int) -> []byte {
    new_slice := make([]byte, len(slice) - 1)
    offset := 0
    for item, s_idx in slice {
        if s_idx == idx {
            continue
        } 
        new_slice[offset] = item
        offset += 1
    }
    return new_slice
}
