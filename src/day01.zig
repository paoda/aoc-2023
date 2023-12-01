const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

const Part = enum { one, two };
const words = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn solve(comptime part: Part, input: []const u8) u32 {
    var it = splitSca(u8, input, '\n');
    var sum: u32 = 0;

    while (it.next()) |line| {
        const first, const last = blk: {
            var first: ?u32 = null;
            var last: ?u32 = null;

            for (0..line.len) |i| {
                const digit = search(part, line[i..]) orelse continue;

                if (first == null) first = digit;
                last = digit;
            }

            break :blk .{ first.?, last.? };
        };

        sum += (first * 10) + last;
    }

    return sum;
}

fn search(comptime part: Part, input: []const u8) ?u8 {
    return std.fmt.charToDigit(input[0], 10) catch blk: {
        if (part != .two) break :blk null;
        if (input.len < words[0].len) break :blk null;

        for (words, 1..) |term, i| {
            if (input.len < term.len) continue;

            if (std.mem.eql(u8, input[0..term.len], term))
                break :blk @intCast(i);
        }

        break :blk null;
    };
}

test "part 1" {
    const example =
        \\1abc2
        \\pqr3stu8vwx
        \\a1b2c3d4e5f
        \\treb7uchet
    ;

    const input = trim(u8, example, &std.ascii.whitespace);
    try std.testing.expectEqual(@as(u32, 142), solve(.one, input));
}

test "part 2" {
    const example =
        \\two1nine
        \\eightwothree
        \\abcone2threexyz
        \\xtwone3four
        \\4nineeightseven2
        \\zoneight234
        \\7pqrstsixteen
    ;

    const input = trim(u8, example, &std.ascii.whitespace);
    try std.testing.expectEqual(@as(u32, 281), solve(.two, input));
}

pub fn main() !void {
    const input = trim(u8, data, &std.ascii.whitespace);

    print("part 1: {}\n", .{solve(.one, input)});
    print("part 2: {}", .{solve(.two, input)});
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
