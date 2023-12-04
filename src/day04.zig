const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");

test part1 {
    const example =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    const input = trim(u8, example, &std.ascii.whitespace);

    try std.testing.expectEqual(@as(u32, 13), try part1(input));
}

test part2 {
    const example =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    const input = trim(u8, example, &std.ascii.whitespace);

    try std.testing.expectEqual(@as(u32, 30), try part2(input));
}

fn part1(input: []const u8) !u32 {
    var line_it = tokenizeSca(u8, input, '\n');

    var sum: u32 = 0;

    while (line_it.next()) |line| {
        var header_it = tokenizeSeq(u8, line, ": ");
        var local_sum: u32 = 0;

        _ = header_it.next(); // Card X

        var num_it = tokenizeSca(u8, header_it.next().?, '|');

        while (num_it.next()) |lhs| {
            const rhs = num_it.next().?;

            var lhs_it = tokenizeSca(u8, lhs, ' ');
            var rhs_it = tokenizeSca(u8, rhs, ' ');

            while (lhs_it.next()) |lhs_str| {
                const lhs_num = try std.fmt.parseInt(u32, lhs_str, 10);

                while (rhs_it.next()) |rhs_str| {
                    const rhs_num = try std.fmt.parseInt(u32, rhs_str, 10);

                    if (lhs_num == rhs_num) {
                        if (local_sum == 0) local_sum = 1 else local_sum *= 2;
                    }
                }

                rhs_it.reset();
            }
        }

        sum += local_sum;
    }

    return sum;
}

fn part2(input: []const u8) !u32 {
    const card_len = indexOf(u8, input, '\n') orelse return error.no_newline;

    const current_card = 0;
    _ = current_card;

    var queue = std.ArrayList(usize).init(std.heap.page_allocator);
    defer queue.deinit();

    const Context = struct {
        pub fn hash(self: @This(), key: usize) u64 {
            _ = self;
            return @intCast(key);
        }

        pub fn eql(self: @This(), left: usize, right: usize) bool {
            _ = self;
            return left == right;
        }
    };

    var counter = std.HashMap(usize, u32, Context, 80).init(std.heap.page_allocator);
    defer counter.deinit();

    try queue.insert(0, 0);
    try queue.insert(0, 1);
    try queue.insert(0, 2);

    print("hi\n", .{});
    while (true) {
        const card_num = queue.popOrNull() orelse break;
        const entry = try counter.getOrPutValue(card_num + 1, 0);
        entry.value_ptr.* += 1;

        const card_str = input[card_num * (card_len + 1) ..][0..card_len];
        const match_num = try countMatches(card_str);

        for (0..match_num) |i|
            try queue.insert(0, (card_num + 1) + i);
    }

    var sum: u32 = 0;

    print("totals:\n", .{});

    var val_it = counter.valueIterator();
    while (val_it.next()) |ptr| {
        print("{}\n", .{ptr.*});
        sum += ptr.*;
    }

    return sum;
}

fn countMatches(card_str: []const u8) !usize {
    var header_it = tokenizeSeq(u8, card_str, ": ");
    var sum: usize = 0;

    _ = header_it.next(); // Card X

    var num_it = tokenizeSca(u8, header_it.next().?, '|');

    while (num_it.next()) |lhs| {
        const rhs = num_it.next().?;

        var lhs_it = tokenizeSca(u8, lhs, ' ');
        var rhs_it = tokenizeSca(u8, rhs, ' ');

        while (lhs_it.next()) |lhs_str| {
            const lhs_num = try std.fmt.parseInt(usize, lhs_str, 10);

            while (rhs_it.next()) |rhs_str| {
                const rhs_num = try std.fmt.parseInt(usize, rhs_str, 10);

                if (lhs_num == rhs_num) sum += 1;
            }

            rhs_it.reset();
        }
    }

    return sum;
}

pub fn main() !void {
    const input = trim(u8, data, &std.ascii.whitespace);

    print("Part 1: {}", .{try part1(input)});
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
