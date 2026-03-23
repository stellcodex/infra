#!/usr/bin/env bash
set -euo pipefail

# Canonical STELLCODEX firewall policy.
# Defaults reflect the current live state. Set ALLOW_SSH=0 only when a safe
# replacement admin path exists, because it removes public SSH access.

ALLOW_SSH="${ALLOW_SSH:-1}"
ALLOW_STELL_WEBHOOK_INTERNAL="${ALLOW_STELL_WEBHOOK_INTERNAL:-1}"

cloudflare_ipv4=(
  173.245.48.0/20
  103.21.244.0/22
  103.22.200.0/22
  103.31.4.0/22
  141.101.64.0/18
  108.162.192.0/18
  190.93.240.0/20
  188.114.96.0/20
  197.234.240.0/22
  198.41.128.0/17
  162.158.0.0/15
  104.16.0.0/13
  104.24.0.0/14
  172.64.0.0/13
  131.0.72.0/22
)

cloudflare_ipv6=(
  2400:cb00::/32
  2606:4700::/32
  2803:f800::/32
  2405:b500::/32
  2405:8100::/32
  2a06:98c0::/29
  2c0f:f248::/32
)

ufw --force reset
ufw default deny incoming
ufw default allow outgoing

if [[ "$ALLOW_SSH" == "1" ]]; then
  ufw allow 22/tcp
fi

ufw deny 5432/tcp
ufw deny 6379/tcp
ufw deny 8000/tcp

for cidr in "${cloudflare_ipv4[@]}"; do
  ufw allow from "$cidr" to any port 80,443 proto tcp comment 'Cloudflare'
done

for cidr in "${cloudflare_ipv6[@]}"; do
  ufw allow from "$cidr" to any port 80,443 proto tcp comment 'Cloudflare'
done

if [[ "$ALLOW_STELL_WEBHOOK_INTERNAL" == "1" ]]; then
  ufw allow from 172.27.0.0/16 to any port 4500 proto tcp comment 'stell internal webhook'
fi

ufw --force enable
ufw status numbered
