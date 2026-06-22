// Package config loads Brume control-plane configuration from the environment.
package config

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// Config holds all runtime configuration for the control-plane.
type Config struct {
	// HTTP server.
	Addr            string
	ShutdownTimeout time.Duration

	// PostgreSQL connection string (pgx format / libpq URL).
	DatabaseURL string

	// BaseDomain is the wildcard domain used to generate per-app hostnames,
	// e.g. "apps.example.com" -> "my-app.apps.example.com".
	// When empty, Brume falls back to sslip.io against PublicIP so HTTPS works
	// without owning a domain (see docs/ARCHITECTURE.md).
	BaseDomain string
	// PublicIP is the cluster ingress IP used for the sslip.io fallback.
	PublicIP string

	// SecretsKey is the 32-byte key (base64 or raw) used to encrypt app secrets
	// at rest before they are stored in Postgres.
	SecretsKey string
}

// Load reads configuration from environment variables, applying defaults.
func Load() (*Config, error) {
	c := &Config{
		Addr:            getenv("BRUME_ADDR", ":8080"),
		ShutdownTimeout: getduration("BRUME_SHUTDOWN_TIMEOUT", 15*time.Second),
		DatabaseURL:     os.Getenv("BRUME_DATABASE_URL"),
		BaseDomain:      os.Getenv("BRUME_BASE_DOMAIN"),
		PublicIP:        os.Getenv("BRUME_PUBLIC_IP"),
		SecretsKey:      os.Getenv("BRUME_SECRETS_KEY"),
	}
	return c, nil
}

// EffectiveBaseDomain returns the configured base domain, or an sslip.io
// fallback derived from PublicIP when no domain is configured.
func (c *Config) EffectiveBaseDomain() string {
	if c.BaseDomain != "" {
		return c.BaseDomain
	}
	if c.PublicIP != "" {
		return fmt.Sprintf("%s.sslip.io", c.PublicIP)
	}
	return ""
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func getduration(key string, def time.Duration) time.Duration {
	if v := os.Getenv(key); v != "" {
		if d, err := time.ParseDuration(v); err == nil {
			return d
		}
		if secs, err := strconv.Atoi(v); err == nil {
			return time.Duration(secs) * time.Second
		}
	}
	return def
}
