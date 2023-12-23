const std = @import("std");

pub fn Queue(comptime T: type) type {
  
    return struct {
        const Self = @This();

        listData: []T = undefined,
        length: usize = 0,
        capacity: usize = 0,
        front: usize = 0,
        mem_arena: ?std.heap.ArenaAllocator = undefined,
        mem_allocator: std.mem.Allocator = undefined,

        pub fn init(self: *Self, allctr: std.mem.Allocator, cap:usize) !void{
            if (self.mem_arena == null) {
                self.mem_arena = std.heap.ArenaAllocator.init(allctr);
                self.mem_allocator = self.mem_arena.?.allocator();
            }
            self.capacity = cap;
            self.listData = try self.mem_allocator.alloc(T, self.capacity);
            @memset(self.listData,@as(T, 0));
        }

        pub fn deinit(self: *Self)void{
            if (self.mem_arena == null) {
                return;
            }else {
                self.mem_arena.?.deinit();
            }
        }


        pub fn enQueue(self: *Self, val: T) !void{
            if (self.length == self.capacity) {
                std.debug.print(
                    "Queue capacity met", .{});
                return;
            }

            const rear = (self.front + self.length) % self.capacity;

            self.listData[rear] = val;

            self.length += 1;

        }

        pub fn deQueue(self: *Self) !void{
            if (self.length == 0) {
                @panic(
                    "Queue is empty"
                );
            }else{
                //const num = self.listData[self.front];

                self.front = (self.front + 1) % self.capacity ;
                self.length -= 1;
            }
        }

        pub fn print(self: *Self) !void {
            std.debug.print(
                "\nPrinting Queue\n", .{});
            var i:usize = self.front;
            while (i < self.capacity) : (i += 1) {
                std.debug.print("element: {}\n", .{self.listData[i]});
            }
        }

     

      

    };

}


var integerQueue = Queue(i32) {};


pub fn main() !void {
    // instantiate allocator 
    const allocator = std.heap.page_allocator;
    const queueCap: usize = 10;
    //instantiate Queue w/ allocator
    try integerQueue.init(allocator, queueCap);
    defer integerQueue.deinit();

    var i:i32 = 0;
    while (i < queueCap) : (i += 1) {
        try integerQueue.enQueue(i);
    }


    try integerQueue.print();

    try integerQueue.deQueue();
    try integerQueue.deQueue();
    try integerQueue.deQueue();

    try integerQueue.print();


}

