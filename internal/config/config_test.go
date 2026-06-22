package config

import "testing"

func TestEffectiveBaseDomain(t *testing.T) {
	tests := []struct {
		name       string
		baseDomain string
		publicIP   string
		want       string
	}{
		{"explicit domain wins", "apps.example.com", "1.2.3.4", "apps.example.com"},
		{"sslip fallback", "", "1.2.3.4", "1.2.3.4.sslip.io"},
		{"empty when nothing set", "", "", ""},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			c := &Config{BaseDomain: tt.baseDomain, PublicIP: tt.publicIP}
			if got := c.EffectiveBaseDomain(); got != tt.want {
				t.Fatalf("got %q, want %q", got, tt.want)
			}
		})
	}
}
