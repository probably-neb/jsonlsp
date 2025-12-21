//! An intrusive singly-linked list. The element type must have a `next` field
//! of type `?*T` where `T` is the element type itself.

pub fn IntrusiveLinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        first: ?*T = null,

        const empty = Self{
            .first = null,
        };

        pub fn insert_after(node: *T, new_node: *T) void {
            new_node.next = node.next;
            node.next = new_node;
        }

        pub fn remove_next(node: *T) ?*T {
            const next_node = node.next orelse return null;
            node.next = next_node.next;
            return next_node;
        }

        pub fn find_last(node: *T) *T {
            var it = node;
            while (true) {
                it = it.next orelse return it;
            }
        }

        pub fn count(list: Self) usize {
            var c: usize = 0;
            var it: ?*const T = list.first;
            while (it) |n| : (it = n.next) {
                c += 1;
            }
            return c;
        }

        pub fn reverse(indirect: *?*T) void {
            if (indirect.* == null) {
                return;
            }
            var current: *T = indirect.*.?;
            while (current.next) |next| {
                current.next = next.next;
                next.next = indirect.*;
                indirect.* = next;
            }
        }

        pub fn prepend(list: *Self, new_node: *T) void {
            new_node.next = list.first;
            list.first = new_node;
        }

        pub fn remove(list: *Self, node: *T) void {
            if (list.first == node) {
                list.first = node.next;
            } else {
                var current_elm = list.first.?;
                while (current_elm.next != node) {
                    current_elm = current_elm.next.?;
                }
                current_elm.next = node.next;
            }
        }

        pub fn pop_first(list: *Self) ?*T {
            const first = list.first orelse return null;
            list.first = first.next;
            return first;
        }
    };
}
