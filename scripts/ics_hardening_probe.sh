#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-4173}"
BASE="http://127.0.0.1:${PORT}"
LOG="/tmp/manna_dev_${PORT}.log"
OUT="/tmp/manna_ics_hardening_probe_${PORT}"
rm -rf "$OUT"; mkdir -p "$OUT"

run_dev() { npm run dev -- --host 127.0.0.1 --port "$PORT" >"$LOG" 2>&1 & echo $!; }
wait_ping() {
  for _ in $(seq 1 400); do
    curl -fsS "$BASE/api/ping" >/dev/null 2>&1 && return 0
    sleep 0.1
  done
  echo "FAIL: server never became reachable"
  tail -n 120 "$LOG" || true
  exit 1
}
fetch() {
  local tag="$1"
  curl -fsS -D "$OUT/prayer.${tag}.hdr"   -o "$OUT/prayer.${tag}.ics"   "$BASE/prayer.ics"
  curl -fsS -D "$OUT/reachout.${tag}.hdr" -o "$OUT/reachout.${tag}.ics" "$BASE/reachout.ics"
}
etag_of() { awk -F": " "tolower(\$1)==\"etag\"{gsub(/\\r/,\"\",\$2); print \$2}" "$1" | tail -n 1; }
hash_only() { shasum -a 256 "$1" | awk "{print \$1}"; }

pick_port() {
  if lsof -nP -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
    PORT=$((PORT+1))
    BASE="http://127.0.0.1:${PORT}"
    LOG="/tmp/manna_dev_${PORT}.log"
    OUT="/tmp/manna_ics_hardening_probe_${PORT}"
    rm -rf "$OUT"; mkdir -p "$OUT"
  fi
}

pick_port
echo "Using PORT=$PORT"

PID="$(run_dev)"; trap "kill \"$PID\" >/dev/null 2>&1 || true" EXIT
wait_ping
fetch a

PRAYER_ETAG="$(etag_of "$OUT/prayer.a.hdr")"
REACHOUT_ETAG="$(etag_of "$OUT/reachout.a.hdr")"

echo "ETAG prayer:   $PRAYER_ETAG"
echo "ETAG reachout: $REACHOUT_ETAG"

# 304 check (same server)
code_prayer="$(curl -s -o /dev/null -w "%{http_code}" -H "If-None-Match: $PRAYER_ETAG" "$BASE/prayer.ics")"
code_reachout="$(curl -s -o /dev/null -w "%{http_code}" -H "If-None-Match: $REACHOUT_ETAG" "$BASE/reachout.ics")"
[ "$code_prayer" = "304" ] || { echo "FAIL: prayer did not 304 (got $code_prayer)"; exit 1; }
[ "$code_reachout" = "304" ] || { echo "FAIL: reachout did not 304 (got $code_reachout)"; exit 1; }
echo "PASS: 304 works with If-None-Match"

# across restart determinism (content)
kill "$PID" >/dev/null 2>&1 || true
sleep 0.2
PID="$(run_dev)"; trap "kill \"$PID\" >/dev/null 2>&1 || true" EXIT
wait_ping
fetch b

echo "HASH prayer   a=$(hash_only "$OUT/prayer.a.ics")"
echo "HASH prayer   b=$(hash_only "$OUT/prayer.b.ics")"
echo "HASH reachout a=$(hash_only "$OUT/reachout.a.ics")"
echo "HASH reachout b=$(hash_only "$OUT/reachout.b.ics")"

cmp -s "$OUT/prayer.a.ics" "$OUT/prayer.b.ics" && echo "PASS: prayer deterministic across restarts" || { echo "FAIL: prayer changed"; diff -u "$OUT/prayer.a.ics" "$OUT/prayer.b.ics" | head -n 120 || true; exit 1; }
cmp -s "$OUT/reachout.a.ics" "$OUT/reachout.b.ics" && echo "PASS: reachout deterministic across restarts" || { echo "FAIL: reachout changed"; diff -u "$OUT/reachout.a.ics" "$OUT/reachout.b.ics" | head -n 160 || true; exit 1; }

echo "Artifacts: $OUT"
