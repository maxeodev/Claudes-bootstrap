// Command brume-server is the Brume PaaS control-plane: an HTTP API + web UI
// that builds client apps from a Dockerfile and deploys them onto a k3s cluster.
package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/maxeodev/claudes-bootstrap/internal/config"
	"github.com/maxeodev/claudes-bootstrap/internal/server"
	"github.com/maxeodev/claudes-bootstrap/internal/store"
	"github.com/maxeodev/claudes-bootstrap/internal/version"
)

func main() {
	log := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))

	if err := run(log); err != nil {
		log.Error("fatal", "error", err)
		os.Exit(1)
	}
}

func run(log *slog.Logger) error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}

	log.Info("starting brume control-plane",
		"version", version.Version,
		"commit", version.Commit,
		"addr", cfg.Addr,
		"baseDomain", cfg.EffectiveBaseDomain(),
	)

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	// The database is optional at P0 so the binary can boot for smoke tests
	// before Postgres is provisioned. Readiness reflects DB availability.
	var ready server.ReadinessChecker
	if cfg.DatabaseURL != "" {
		st, err := store.Open(ctx, cfg.DatabaseURL)
		if err != nil {
			log.Warn("database unavailable at startup; /readyz will report not-ready", "error", err)
		} else {
			defer st.Close()
			ready = st
			log.Info("connected to database")
		}
	} else {
		log.Warn("BRUME_DATABASE_URL not set; running without a database (P0 smoke mode)")
	}

	srv := server.New(cfg, log, ready)
	httpServer := &http.Server{
		Addr:              cfg.Addr,
		Handler:           srv.Handler(),
		ReadHeaderTimeout: 10 * time.Second,
	}

	errCh := make(chan error, 1)
	go func() {
		log.Info("http server listening", "addr", cfg.Addr)
		if err := httpServer.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			errCh <- err
		}
	}()

	select {
	case err := <-errCh:
		return err
	case <-ctx.Done():
		log.Info("shutdown signal received")
	}

	shutdownCtx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
	defer cancel()
	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		return err
	}
	log.Info("shutdown complete")
	return nil
}
