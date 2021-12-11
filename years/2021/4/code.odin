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

mark_number :: proc(number: int, boards: []Board, check: []BoardCheck) {
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

check :: proc(board: BoardCheck) -> bool {
    // Check for horizontal lines
    for y := 0; y < BOARD_SIZE; y += 1 {
        acc := 0
        for x := 0; x < BOARD_SIZE; x+= 1 {
            acc += int(board[y][x])
        }
        if acc == BOARD_SIZE {
            return true
        }
    }
    // Check for vertical lines
    for x := 0; x < BOARD_SIZE; x += 1 {
        acc := 0
        for y := 0; y < BOARD_SIZE; y+= 1 {
            acc += int(board[y][x])
        }
        if acc == BOARD_SIZE {
            return true
        }
    }
    return false
}

unmarked_score :: proc(board: Board, board_check: BoardCheck) -> int {
    acc := 0
    for y := 0; y < BOARD_SIZE; y += 1 {
        for x := 0; x < BOARD_SIZE; x+= 1 {
            if !(board_check[y][x]) {
                acc += board[y][x]
            }
        }
    }
    return acc
}

task_1 :: proc(nums: []int, boards: []Board, boards_check: []BoardCheck) -> int {
    for number in nums {
        mark_number(number, boards, boards_check)
        for board, idx in boards_check {
            if check(board) {
                total := number * unmarked_score(boards[idx], boards_check[idx])
                return total
            }
        }
    }
    return -1
}

main_ :: proc() {
    input := string(#load("input.txt"))
    defer delete(input)

    rows := strings.split(input, "\n")
    defer delete(rows)

    nums := numbers(rows[0])
    defer delete(nums)

    board_c := (len(rows) - 1)/ (BOARD_SIZE + 1)
    // fmt.println(len(rows) - 1, BOARD_SIZE)
    boards := make([]Board, board_c)
    defer delete(boards)

    idx := 0
    for i := 2; i < len(rows); i += BOARD_SIZE + 1 {
        boards[idx] = parse_board(rows, i)
        idx += 1
    }
    
    boards_check := make([]BoardCheck, board_c)
    defer delete(boards_check)

    result_1 := task_1(nums, boards, boards_check)
    fmt.println(result_1)
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
