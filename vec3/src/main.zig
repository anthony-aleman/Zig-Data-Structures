const std = @import("std");

pub fn Vec3(comptime T: type) type {
    return struct {
        const Self = @This();
        e: []T = undefined,
        capacity: usize = 3,
        mem_arena: ?std.heap.ArenaAllocator = undefined,
        mem_allocator: std.mem.Allocator = undefined,

        pub fn init(self: *Self, allocatr: std.mem.Allocator) !void{
            if (self.mem_arena == null) {
                self.mem_arena = std.heap.ArenaAllocator.init(allocatr);
                self.mem_allocator = self.mem_arena.?.allocator();
            }
            
            self.e = try self.mem_allocator.alloc(T, self.capacity);
            @memset(self.e, @as(T, 0));

            self.e[0] = 0.0;
            self.e[1] = 0.0;
            self.e[2] = 0.0;
        }

        pub fn deinit(self: *Self) void {
            if (self.mem_arena == null) {
                return; 
            }
            else {
                self.mem_arena.?.deinit();
            }
        }

        pub fn new(self: *Self, x: T, y: T, z: T) void{
            self.e[0] = x;
            self.e[1] = y;
            self.e[2] = z;
        }

        pub fn dot(self: *Self, other: Vec3(T)) T {
            return (
                // x * x
                (self.e[0] * other.e[0]) +
                (self.e[1] * other.e[1]) + 
                (self.e[2] * other.e[2])
            );
        }

        pub fn plus(self: *Self, other:Vec3(T)) Vec3(T){
            const tmp = Vec3(T){};
            tmp.init();
            return tmp.new(
                //x
                (self.e[0] + other.e[0]), 
                //y
                (self.e[1] + other.e[1]), 
                //z
                (self.e[2] + other.e[2]),
            );
        }

        pub fn minus(self: *Self, other: Vec3(T)) Vec3(T){
            const tmp = Vec3(T){};
            return tmp.new(
                //x
                (self.e[0] - other.e[0]), 
                //y
                (self.e[1] - other.e[1]), 
                //z
                (self.e[2] - other.e[2]),
            );
        }

        pub fn scale(self: *Self, scalar: T) Vec3(T) {
            const tmp = Vec3(T){};
            tmp.init();
            return tmp.new(
                (self.e[0] * scalar), 
                (self.e[1] * scalar), 
                (self.e[2] * scalar)
            );
        }

        pub fn length(self:*Self) T {
            return @sqrt(self.dot(self));
        }
    };
}

var vector = Vec3(f64){};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    try vector.init(allocator);
    defer vector.deinit();
}

test "initialize vector" {
    const allocatr = std.heap.page_allocator;
    var testVec3 = Vec3(f64){};
    try testVec3.init(allocatr);
    defer testVec3.deinit();

    try std.testing.expect(testVec3.e[0] == 0);
    try std.testing.expect(testVec3.e[1] == 0);
    try std.testing.expect(testVec3.e[2] == 0);
}

test "new vector" {
    var testVec = Vec3(f64){};
    try testVec.init(std.heap.page_allocator);
    defer testVec.deinit();

    testVec.new(
        1.0, 
        1.0, 
        2.0
    );

    try std.testing.expect(testVec.e[0] == 1.0);
    try std.testing.expect(testVec.e[1] == 1.0);
    try std.testing.expect(testVec.e[2] == 2.0);
}


