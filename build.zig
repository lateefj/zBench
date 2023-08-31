const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Create a static library
    //_ = b.addModule("zbench", .{ .source_file = .{ .path = "zbench.zig" } });
    //const zbench = b.addStaticLibrary("zbench", "src/main.zig");
    // zbench.setBuildMode(optimize);

    // Add any dependencies needed by your library here

    // Install the library
    //zbench.install();

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "zbench.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    const zbench_mod = b.addModule("zbench", .{ .source_file = .{ .path = "zbench.zig" } });

    const example_step = b.step("examples", "Build examples");
    // Add new examples here
    for ([_][]const u8{"basic"}) |example_name| {
        const example = b.addExecutable(.{
            .name = example_name,
            .root_source_file = .{ .path = b.fmt("examples/{s}.zig", .{example_name}) },
            .target = target,
            .optimize = optimize,
        });
        const install_example = b.addInstallArtifact(example, .{});
        example.addModule("zbench", zbench_mod);
        example_step.dependOn(&example.step);
        example_step.dependOn(&install_example.step);
    }
}
