const std = @import("std");

const expect = @import("std").testing.expect;

// Generic Stack 
pub fn Stack(comptime T: type) type {    
    const StackNode = struct {
        const Self = @This();
        val:T,
        next: ?*Self
    };


    return struct {
        const Self = @This();

        mem_arena: ?std.heap.ArenaAllocator,
        mem_allocator: std.mem.Allocator,
        head: ?*StackNode,
        len: usize,
        // Create a new integerStack

        pub fn init(self: *Self, alctr: std.mem.Allocator ) !void {

            if (self.mem_arena == null) {
                self.mem_arena = std.heap.ArenaAllocator.init(alctr);
                self.mem_allocator = self.mem_arena.?.allocator();
            } 
            self.len = 0;
        }

        // Remove from memory
        fn deinit(self: *Self) void {
            if (self.mem_arena == null) 
            {
                return;
            }else {
                self.mem_arena.?.deinit();
            }
        }

        // Push Node onto the stack
        fn push(self: *Self, val: T) !void{
            //Allocate memory for new node 
            var newNode = try self.mem_allocator.create(StackNode);
            const head  = self.head;
            newNode.val = val;
            newNode.next = head;
            self.head = newNode;
            self.len += 1;
        }

        fn pop(self: *Self) StackError!?T{
            if (self.head) |head| {
                self.head = head.next;
                const value = head.val;
                self.mem_allocator.destroy(head);
                self.len -= 1;
                return value;
            }
            if (self.len == 0) {
                return StackError.IndexOutOfBounds;
            } else {
                return null;
            }
            
        }

        fn print(self: *Self) void{
            var currentNode = self.head;

            std.debug.print("integerStack\n", .{});

            while (currentNode) |node| {
                std.debug.print("Value ->{d}\n", .{node.val});
                currentNode = node.next;
            }

            std.debug.print("Stack length: {}", .{self.len});
        }
        
    };
}

var integerStack = Stack(i32){
    .mem_arena=undefined, 
    .mem_allocator=undefined,
    .head=undefined,
    .len = undefined,
};

const StackError = error {
    IndexOutOfBounds,
};

pub fn main() !void {
    //instantiate allocator 
    const allocator = std.heap.page_allocator;

    //instantiate stack with allocator
    try integerStack.init(allocator);
    defer integerStack.deinit();


    const stackCap = 10;
    var i: i32 = 0;

    while (i < stackCap) : (i += 1) {
        try integerStack.push(i);
    }

    integerStack.print();

    const value = try integerStack.pop();
    if (value) |v| {
        std.debug.print("POP result: {d}\n", .{v});
    }

    integerStack.print();


    
}

//Tests to create
//
// BASIC INIT STACK
// Create an empty stack. It must have a size of zero
// 
// PUSH STACK
// Push an element onto the stack, test size matches number of items added
// 
// POP STACK
// Pop an element and test it matches the last pushed element
// 
// POP ALL ELEMENTS
// Pop all elements to leave an empty stack check that it's length is zero
//
//
// Pop an element from the empty stack and check it returns an error

test "basic init stack" {
    const allocatr = std.heap.page_allocator;
    var test_stack = Stack(i32) {
        .head = undefined,
        .len = undefined,
        .mem_allocator = undefined,
        .mem_arena = null,      
    };

    try test_stack.init(allocatr);
    defer test_stack.deinit();
    try expect(test_stack.len == 0);
}

test "push stack" {
    const allocatr = std.heap.page_allocator;
    var test_stack = Stack(i32) {
        .head = undefined,
        .len = undefined,
        .mem_allocator = undefined,
        .mem_arena = null,      
    };

    try test_stack.init(allocatr);
    defer test_stack.deinit();
    const a: i32 = 1;
    const b: i32 = 2;

    try test_stack.push(a);
    try expect(test_stack.len == 1);
    try test_stack.push(b);
    try expect(test_stack.len == 2);
}


test "pop stack" {
    const allocatr = std.heap.page_allocator;
    var test_stack = Stack(i32) {
        .head = undefined,
        .len = undefined,
        .mem_allocator = undefined,
        .mem_arena = null,      
    };

    try test_stack.init(allocatr);
    defer test_stack.deinit();
    const cap: i8 = 10;
    var i: i8 = 0;

    while (i <= cap) :(i += 1) {
        try test_stack.push(i);
    }

    const pop_val = try test_stack.pop();
    try expect(pop_val == cap);
}



test "pop all elements" {
    const allocatr = std.heap.page_allocator;
    var test_stack = Stack(i32) {
        .head = undefined,
        .len = undefined,
        .mem_allocator = undefined,
        .mem_arena = null,      
    };

    try test_stack.init(allocatr);
    defer test_stack.deinit();
    const cap: i8 = 10;
    var i: i8 = 0;

    while (i <= cap) :(i += 1) {
        try test_stack.push(i);
    }

    for (0..test_stack.len) |_| {
        _ = try test_stack.pop();
    }
    try expect(test_stack.len == 0);
}

test "StackError" {
    const allocatr = std.heap.page_allocator;
    var test_stack = Stack(i32) {
        .head = undefined,
        .len = undefined,
        .mem_allocator = undefined,
        .mem_arena = null,      
    };

    try test_stack.init(allocatr);
    defer test_stack.deinit();
    const cap: i8 = 10;
    var i: i8 = 0;

    while (i <= cap) :(i += 1) {
        try test_stack.push(i);
    }

    for (0..test_stack.len) |_| {
        _ = try test_stack.pop();
    }
    
    const err = test_stack.pop();
    try expect(err == StackError.IndexOutOfBounds);
    
}
