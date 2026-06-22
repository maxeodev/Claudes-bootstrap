// Package version exposes build metadata for the Brume control-plane.
package version

// These values are overridden at build time via -ldflags.
var (
	// Version is the semantic version of the build.
	Version = "dev"
	// Commit is the git commit SHA the binary was built from.
	Commit = "none"
	// BuildDate is the RFC3339 build timestamp.
	BuildDate = "unknown"
)
