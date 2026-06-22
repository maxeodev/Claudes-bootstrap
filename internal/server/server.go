// Package server wires the HTTP routes, middleware and observability endpoints
// for the Brume control-plane.
package server

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"github.com/maxeodev/claudes-bootstrap/internal/config"
	"github.com/maxeodev/claudes-bootstrap/internal/version"
)

// ReadinessChecker reports whether a dependency (e.g. the database) is ready.
type ReadinessChecker interface {
	Ping(ctx context.Context) error
}

// Server holds the dependencies required to serve HTTP requests.
type Server struct {
	cfg    *config.Config
	log    *slog.Logger
	router chi.Router
	ready  ReadinessChecker
}

// New constructs a Server and registers all routes.
func New(cfg *config.Config, log *slog.Logger, ready ReadinessChecker) *Server {
	s := &Server{cfg: cfg, log: log, ready: ready}
	s.router = s.routes()
	return s
}

// Handler exposes the underlying chi router (useful for tests).
func (s *Server) Handler() http.Handler { return s.router }

func (s *Server) routes() chi.Router {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(30 * time.Second))

	// Observability & lifecycle endpoints (pillar: Observabilité).
	r.Get("/healthz", s.handleHealthz)
	r.Get("/readyz", s.handleReadyz)
	r.Get("/version", s.handleVersion)
	r.Handle("/metrics", promhttp.Handler())

	// API v1 — populated in later phases (P1+).
	r.Route("/api/v1", func(r chi.Router) {
		r.Get("/ping", s.handlePing)
	})

	return r
}

func (s *Server) handleHealthz(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func (s *Server) handleReadyz(w http.ResponseWriter, r *http.Request) {
	if s.ready != nil {
		ctx, cancel := context.WithTimeout(r.Context(), 3*time.Second)
		defer cancel()
		if err := s.ready.Ping(ctx); err != nil {
			s.log.Warn("readiness check failed", "error", err)
			writeJSON(w, http.StatusServiceUnavailable, map[string]string{
				"status": "not ready",
				"error":  err.Error(),
			})
			return
		}
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "ready"})
}

func (s *Server) handleVersion(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{
		"version":   version.Version,
		"commit":    version.Commit,
		"buildDate": version.BuildDate,
	})
}

func (s *Server) handlePing(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"pong": "true"})
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}
