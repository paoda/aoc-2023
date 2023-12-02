const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

test part1 {
    const example =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    const input = trim(u8, example, &std.ascii.whitespace);

    try std.testing.expectEqual(@as(u32, 8), try part1(input));
}

test part2 {
    const example =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    const input = trim(u8, example, &std.ascii.whitespace);

    try std.testing.expectEqual(@as(u32, 2286), try part2(input));
}

fn part2(input: []const u8) !u32 {
    var line_it = tokenizeSca(u8, input, '\n');

    var sum: u32 = 0;

    while (line_it.next()) |line| {
        var set_it = tokenizeAny(u8, line, ";:");

        const game_num = blk: { // TODO: Simplify
            var game_it = tokenizeSca(u8, set_it.next().?, ' ');
            std.debug.assert(std.mem.eql(u8, game_it.next().?, "Game"));

            break :blk try std.fmt.parseInt(u32, game_it.next().?, 10);
        };
        _ = game_num;

        var totals: [3]u32 = .{ 0, 0, 0 };

        while (set_it.next()) |set| {
            var it = tokenizeAny(u8, set, " ,");

            while (it.next()) |num_str| {
                const count = try std.fmt.parseInt(u8, num_str, 10);
                const colour_idx = colourToIndex(it.next().?);

                totals[colour_idx] = @max(totals[colour_idx], count);
            }
        }

        sum += totals[0] * totals[1] * totals[2];
    }

    return sum;
}

fn part1(input: []const u8) !u32 {
    var line_it = tokenizeSca(u8, input, '\n');

    var sum: u32 = 0;

    while (line_it.next()) |line| {
        var set_it = tokenizeAny(u8, line, ";:");

        const game_num = blk: { // TODO: Simplify
            var game_it = tokenizeSca(u8, set_it.next().?, ' ');
            std.debug.assert(std.mem.eql(u8, game_it.next().?, "Game"));

            break :blk try std.fmt.parseInt(u32, game_it.next().?, 10);
        };

        var valid: bool = true;

        while (set_it.next()) |set| {
            var totals: [3]u8 = .{ 0, 0, 0 };
            var it = tokenizeAny(u8, set, " ,");

            while (it.next()) |num_str| {
                const count = try std.fmt.parseInt(u8, num_str, 10);
                const colour_idx = colourToIndex(it.next().?);

                totals[colour_idx] += count;
            }

            // Perform the check the question asks

            valid = valid and (totals[0] <= 12) and (totals[1] <= 13) and (totals[2] <= 14);
        }

        if (valid) sum += game_num;

        print("\n", .{});
    }

    return sum;
}

fn colourToIndex(colour: []const u8) usize {
    return switch (colour[0]) {
        'r' => 0,
        'g' => 1,
        'b' => 2,
        else => std.debug.panic("{s} was an unexpected input", .{colour}),
    };
}

pub fn main() !void {
    const input = trim(u8, data, &std.ascii.whitespace);
    print("Part 1: {}", .{try part1(input)});

    print("Part 2: {}", .{try part2(input)});
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
