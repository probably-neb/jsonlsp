//! JSON Language Server entry point.
//! This is a thin wrapper that sets up the transport and calls server.run().

const std = @import("std");
const base = @import("base");
const lsp = @import("lsp");
const server = @import("server");

const Arena = base.Arena;

pub const std_options: std.Options = .{
    .log_level = std.log.default_level,
};

pub fn main() void {
    var arena: Arena = Arena.init(.{}) catch {
        std.process.exit(1);
    };
    // Language servers can support multiple communication channels (e.g. stdio, pipes, sockets).
    // See https://microsoft.github.io/language-server-protocol/specifications/specification-current/#implementationConsiderations
    //
    // The `lsp.Transport.Stdio` implements the necessary logic to read and write messages over stdio.
    var read_buffer: [256]u8 = undefined;
    var stdio_transport: lsp.Transport.Stdio = .init(&read_buffer, .stdin(), .stdout());
    const transport: *lsp.Transport = &stdio_transport.transport;

    server.run(&arena, transport) catch |err| {
        switch (err) {
            error.ServerShutdown => {
                // Clean exit after proper shutdown sequence
                std.process.exit(0);
            },
            error.ExitWithoutShutdown => {
                // Exit received without prior shutdown request
                std.process.exit(1);
            },
            else => {
                std.log.err("Server error: {}", .{err});
                std.process.exit(1);
            },
        }
    };
}

test {
    std.testing.refAllDecls(@This());
}
