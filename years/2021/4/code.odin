package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:mem"
import "core:path"
import "shared:file"
import "core:math"

BOARD_SIZE: int : 5
Board :: distinct [BOARD_SIZE][BOARD_SIZE]int
BoardCheck :: distinct [BOARD_SIZE][BOARD_SIZE]bool

numbers :: proc(row: string) -> []int {
    nums_raw := strings.split(row, ",")
    defer delete(nums_raw)
    nums := make([]int, len(nums_raw))
    for num, idx in nums_raw {
        dec,  _  := strconv.parse_int(num, 10)
        nums[idx] = dec
    }
    return nums
}

parse_board :: proc(rows: []string, idx: int) -> Board {
    board: Board
    // fmt.println(board)
    for row, r_idx in rows[idx: idx + BOARD_SIZE] {
        nums := strings.split(row, " ")
        defer delete(nums)
        idx := 0
        for num in nums {
            if len(num) == 0 {
                continue 
            }
            dec,  _  := strconv.parse_int(num, 10)
            board[r_idx][idx] = dec
            idx += 1
        }
    }
    return board
}

mark_number :: proc(number: int, boards: [dynamic]Board, check: [dynamic]BoardCheck) {
    for board, board_idx in boards {
        for row, row_i in board {
            for col, col_i in row {
                if col == number {
                    check[board_idx][row_i][col_i] = true
                }
            } 
        }
    }
}

// check :: proc(board: [dynamic]BoardCheck) -> bool {
//     for i := 0; i += 1; i < 5
// }

main_ :: proc() {
    input := string(#load("input.txt"))
    defer delete(input)

    rows := strings.split(input, "\n")
    defer delete(rows)

    nums := numbers(rows[0])
    defer delete(nums)

    boards := make([dynamic]Board)
    defer delete(boards)

    for i := 2; i < len(rows); i += BOARD_SIZE + 1 {
        append(&boards, parse_board(rows, i))
    }
    
    boards_check := make([dynamic]BoardCheck, len(boards))
    defer delete(boards_check)

    for number in nums {
        mark_number(number, boards, boards_check)
    }

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
            printf("%v Leaked %v bytes\n", v.location, v.size)
        }
    }
}
