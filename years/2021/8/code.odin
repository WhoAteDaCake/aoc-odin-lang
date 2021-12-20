package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "core:math"
import "core:slice"

import "shared:utils"
import "shared:sslice"

input :: string(#load("input.txt"))

Row :: struct {
    inputs: []string,
    outputs: []string,
}
INDICE_LEN :: 7
UNIQUE_LEN_LOOKUP := map[int]int{
    2 = 1,
    4 = 4,
    3 = 7,
    7 = 8,
}
// Which slots need to be filled for a number
INDICES := [][dynamic]int {
    {0, 1, 2, 4, 5, 6}, //0
    {2, 5},//1
    {0, 2, 3, 4, 6},//2
    {0, 2, 3, 5, 6},//3
    {1, 2, 3, 5},//4
    {0, 1, 3, 5, 6},//5
    {0, 1, 3, 4, 5, 6},//6
    {0, 2, 5},//7
    {0, 1, 2, 3, 4, 5, 6},//8
    {0, 1, 2, 3, 5, 6},//9
}

parse_row :: proc(row: string) -> Row {
    entries := strings.split(row, " ")
    defer delete(entries)

    signals := make([]string, 10)

    for idx in 0..9 {
        signals[idx] = entries[idx]
    }

    output := make([]string, 4)
    for idx in 0..3 {
        output[idx] = entries[idx + 11]
    }

    return Row{signals, output}
}

task_1 :: proc(rows: []Row) -> int {
    acc := 0
    for row in rows {
        for entry in row.outputs {
            if len(entry) in UNIQUE_LEN_LOOKUP {
                acc += 1 
            }
        }
    }
    return acc
}

string_to_bytes :: proc(a: string) -> []byte {
    acc := make([]u8, len(a))
    for _, idx in a {
        acc[idx] = a[idx]
    }
    return acc
}


reduce_choices :: proc(lookup: ^[][]byte, checked: []bool) -> (int, int) {
    for choices, idx in lookup {
        if checked[idx] {
            continue
        }
        for s_choices, s_idx in lookup {
            if checked[idx] {
                continue
            }

            if idx != s_idx && len(choices) == 2 && slice.equal(choices, s_choices) {
                return idx, s_idx
            }
        }
    }
    return -1, -1
}

reduce_duplicates :: proc(lookup: ^[][]byte) {
    checked := make([]bool, len(lookup))
    defer delete(checked)

    for { 
        idx1, idx2 := reduce_choices(lookup, checked)
        if idx1 == -1 {
            break
        }
        checked[idx1] = true
        checked[idx2] = true
        for entry, idx in lookup {
            if idx == idx1 || idx == idx2 {
                continue
            }

            diff := sslice.without(lookup[idx1], entry)
            delete(lookup[idx])
            lookup[idx] = diff
        }
    }

    slice.fill(checked, false)

    // Check if any are of len 1
    for {
        selected := -1
        for entries, idx in lookup {
            if len(entries) == 1 && !checked[idx] {
                selected = idx
                break
            }
        }
        if selected == -1 {
            break
        }
        checked[selected] = true
        for entry, idx in lookup {
            if idx == selected {
                continue
            }
            diff := sslice.without(lookup[selected], entry)
            delete(lookup[idx])
            lookup[idx] = diff
            // delete(entry)
        }
    }
}

print_lookup :: proc(lookup: [][]byte) {
    for row, idx in lookup {
        fmt.println(idx, string(row))
    }
    fmt.println("----------")
}

generate_variants :: proc(lookup: ^[][]byte, idx: int, selected: []byte) -> [][]byte {
    if idx == len(lookup) {
        result := make([][]byte, 1)
        result[0] = selected
        return result
    }
    // // Needed?
    // defer delete(selected)
    if len(lookup[idx]) == 1 {
        v1 := make([]byte, len(selected) + 1)
        copy(v1, selected)
        v1[len(selected)] = lookup[idx][0]
        return generate_variants(lookup, idx + 1, v1)
    }

    v1 := make([]byte, len(selected) + 1)
    v2 := make([]byte, len(selected) + 1)
    copy(v1, selected)
    copy(v2, selected)

    v1[len(selected)] = lookup[idx][0]
    v2[len(selected)] = lookup[idx][1]

    result_1 := generate_variants(lookup, idx + 1, v1)
    result_2 := generate_variants(lookup, idx + 1, v2)

    result := make([][]byte, len(result_1) + len(result_2))
    copy(result, result_1)

    for r, r_idx in result_2 {
        result[r_idx + len(result_1)] = r
    }
    return result
}

match_word :: proc(word: []byte, layout: []byte) -> int {
    indices := make([]int, len(word))
    defer delete(indices)
    
    for char, c_idx in word {
        idx, _ := slice.linear_search(layout, char)
        if idx == -1 {
            return -1
        }
        // Assume it's always found
        indices[c_idx] = idx
    }
    slice.sort(indices)
    for order, idx in INDICES {
        if slice.equal(order[:], indices) {
            return idx
        }
    }
    return -1
}

check_variant :: proc(layout: []byte, words: [][]byte) -> bool {
    found := make([]bool, len(words))

    for word in words {
        idx := match_word(word, layout)
        if idx == -1 {
            return false
        }
        found[idx] = true
    }    

    for f in found {
        if !f {
            return false
        }
    }
    return true
}


decode :: proc(row: Row) -> int {
    lookup := make([][]u8, INDICE_LEN)
    inputs_bytes := make([][]u8, len(INDICES))
    allowed := transmute ([]u8)strings.clone("abcdefg")
    for _, idx in lookup {
        lookup[idx] = make([]u8, len(allowed))
        for c, aix in allowed {
            lookup[idx][aix] = c
        }
    }

    // Find the unique layouts first 
    for entry, idx in row.inputs {
        bytes := string_to_bytes(entry)
        inputs_bytes[idx] = bytes
        if !(len(entry) in UNIQUE_LEN_LOOKUP) {
            continue 
        }
        // Now we know the layout of the number
        num := UNIQUE_LEN_LOOKUP[len(entry)]
        fmt.println(num, entry)
        for indice in INDICES[num] {
            // fmt.println(indice, string(lookup[indice]))
            // Value not set, all values can be here
            if len(lookup[indice]) == 0 {
                lookup[indice] = bytes
                continue
            }
            if len(lookup[indice]) == 1 {
                continue
            }
            lookup[indice] = sslice.overlap(bytes, lookup[indice])
        }
    }

    fmt.println("-------------")

    // print_lookup(lookup)
    reduce_duplicates(&lookup)
    print_lookup(lookup)
    
    // Confirm algorithm works up to here
    for row, idx in lookup {
        assert(len(row) <= 2)
    }
    
    // Now we need to go ahead and try creating numbers
    selected := make([dynamic]byte)
    variants := generate_variants(&lookup, 0, selected[:])
    for variant in variants {
        if check_variant(variant, inputs_bytes) {
            acc := 0
            // Now need to check the words
            for word in row.outputs {
                bytes := string_to_bytes(word)
                number := match_word(bytes, variant)
                acc = acc * 10 + number 
            }
            return acc
        }
        // fmt.println(string(variant))
    }
    return 0
} 

task_2 :: proc(rows: []Row) -> int {
    acc := 0
    for row in rows {
        acc += decode(row)
    }
    return acc
}

main_ :: proc() {
    rows := strings.split(input, "\n")
    defer delete(rows)
    parsed := make([]Row, len(rows))
    defer {
        for row in parsed {
            delete(row.inputs)
            delete(row.outputs)
        }
        delete(parsed)
    }

    for row, idx in rows {
        parsed[idx] = parse_row(row)
    }
    // result_1 := task_1(parsed)
    result_2 := task_2(parsed)
    fmt.println(result_2)
}

main :: proc() {
    using fmt

    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    main_()

    if len(track.allocation_map) > 0 {
        println()
        for _, v in track.allocation_map {
            // printf("%v Leaked %v bytes\n", v.location, v.size)
        }
    }
}
