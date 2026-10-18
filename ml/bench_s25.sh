#!/usr/bin/env bash
# Benchmarks QNN .pte files on a USB-connected Galaxy S25 with qnn_executor_runner and posts
# each result to the BindLab server (/bench), so the dashboard's Edge benchmark tab fills in.
#
#   ./bench_s25.sh                       # esm2 8M 35M 150M 650M, 10 warm-up + 50 timed runs
#   SIZES="8M 35M" ITERS=200 ./bench_s25.sh
#   SERVER=https://<tunnel>.trycloudflare.com ./bench_s25.sh
#   DEVICE=xr SIZES="8M 35M" ./bench_s25.sh   # Galaxy XR: runtime/xr + esm2_<size>_qnn_SXR2230P.pte
#
# Needs: adb, artifacts/runtime/s25/* and artifacts/esm2_<size>_qnn.pte (see README "What we built").
# The runner reports an average only, so it's posted as p50_ms; p95 is left empty.
set -euo pipefail
cd "$(dirname "$0")/artifacts"

SIZES=${SIZES:-"8M 35M 150M 650M"}
WARM=${WARM:-10}
ITERS=${ITERS:-50}
SERVER=${SERVER:-http://localhost:8000}
DEVICE=${DEVICE:-s25}
if [ "$DEVICE" = xr ]; then RUNTIME=runtime/xr; SUFFIX=_SXR2230P; else RUNTIME=runtime/s25; SUFFIX=; fi
D=/data/local/tmp/et_qnn

adb get-state >/dev/null
adb shell mkdir -p $D
adb push -q $RUNTIME/* $D/ >/dev/null
adb shell chmod 755 $D/qnn_executor_runner

post() { curl -s -X POST "$SERVER/bench" -H 'Content-Type: application/json' -d "$1" >/dev/null || echo "  (post to $SERVER failed)"; }

for size in $SIZES; do
  pte="esm2_${size}_qnn${SUFFIX}.pte"
  if [ ! -f "$pte" ]; then echo "skip $size: $pte missing"; continue; fi
  echo "== ESM2-$size ($(du -h "$pte" | cut -f1))"
  adb push -q "$pte" $D/ >/dev/null

  # Run in the background on-device and sample its peak RSS (VmHWM) until it exits.
  out=$(adb shell "cd $D && export LD_LIBRARY_PATH=. ADSP_LIBRARY_PATH=. && \
    (./qnn_executor_runner --model_path $pte --warm_up $WARM --iteration $ITERS > run.log 2>&1 & pid=\$!; \
     hwm=0; while kill -0 \$pid 2>/dev/null; do \
       v=\$(grep VmHWM /proc/\$pid/status 2>/dev/null | tr -s ' ' | cut -d' ' -f2); [ -n \"\$v\" ] && hwm=\$v; sleep 0.2; done; \
     wait \$pid; echo EXIT=\$?; echo HWM_KB=\$hwm); cat run.log; \
     dumpsys thermalservice | grep -m1 'Thermal Status'" 2>&1)

  exit_code=$(sed -n 's/^EXIT=//p' <<<"$out")
  hwm_kb=$(sed -n 's/^HWM_KB=//p' <<<"$out")
  load_s=$(grep -m1 'Method loaded' <<<"$out" | sed -E 's/^I ([0-9:.]+).*/\1/' | awk -F: '{print $1*3600+$2*60+$3}')
  avg=$(grep -m1 'inferences took' <<<"$out" | sed -E 's/.*avg ([0-9.]+) ms.*/\1/')
  thermal=$(grep -m1 'Thermal Status' <<<"$out" | sed -E 's/.*: *//')

  # The runner exits 0 and still prints an average when every execute fails, so check for that too.
  exec_err=$(grep -m1 -E 'Graph forward failed|Fail to execute graph|execute failed' <<<"$out" || true)
  if [ "$exit_code" = 0 ] && [ -n "$avg" ] && [ -z "$exec_err" ]; then
    load_ms=$(awk -v s="$load_s" 'BEGIN{printf "%.0f", s*1000}')
    rss_mb=$(awk -v k="$hwm_kb" 'BEGIN{printf "%.0f", k/1024}')
    echo "  load ${load_ms} ms · avg ${avg} ms · peak RSS ${rss_mb} MB · thermal status ${thermal:-?}"
    post "{\"device\":\"$DEVICE\",\"model\":\"$size\",\"backend\":\"qnn\",\"load_ms\":$load_ms,\"p50_ms\":$avg,\"peak_rss_mb\":$rss_mb}"
  else
    err=${exec_err:-$(grep -E 'Error|error|failed|Killed' <<<"$out" | tail -1 || true)}
    err=$(tr '"' "'" <<<"$err" | sed -E 's/^\[ERROR\] \[Qnn ExecuTorch\]: //' | cut -c1-200)
    status=load_failed; grep -qE 'Killed|Out of memory|std::bad_alloc' <<<"$out" && status=oom
    echo "  FAILED ($status): $err"
    post "{\"device\":\"$DEVICE\",\"model\":\"$size\",\"backend\":\"qnn\",\"status\":\"$status\",\"error\":\"$err\"}"
  fi
  adb shell rm -f "$D/$pte"
done
