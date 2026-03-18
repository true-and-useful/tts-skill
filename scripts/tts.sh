#!/usr/bin/env bash
set -euo pipefail

VOICE_ID="86e30c1d-714b-4074-a1f2-1cb6b552fb49"
MODEL="sonic-3"

# Resolve API key: --api-key flag > env var > credentials file
resolve_api_key() {
  if [[ -n "${CARTESIA_API_KEY:-}" ]]; then
    echo "$CARTESIA_API_KEY"
  elif [[ -f ~/.cartesia/credentials ]]; then
    cat ~/.cartesia/credentials
  else
    echo "Error: No Cartesia API key found." >&2
    echo "Set CARTESIA_API_KEY env var or save key to ~/.cartesia/credentials" >&2
    exit 1
  fi
}

usage() {
  echo "Usage: tts.sh <input.txt> [output.mp3] [--voice <id>] [--api-key <key>]"
  echo ""
  echo "Options:"
  echo "  --voice <id>     Voice ID (default: Carson)"
  echo "  --api-key <key>  API key (default: env/credentials file)"
  exit 1
}

[[ $# -lt 1 ]] && usage

INPUT="$1"
OUTPUT="${2:-${INPUT%.txt}.mp3}"

shift
[[ $# -ge 1 ]] && shift  # skip output arg if present

while [[ $# -gt 0 ]]; do
  case "$1" in
    --voice) VOICE_ID="$2"; shift 2 ;;
    --api-key) CARTESIA_API_KEY="$2"; shift 2 ;;
    *) shift ;;
  esac
done

[[ ! -f "$INPUT" ]] && echo "Error: $INPUT not found" && exit 1

API_KEY=$(resolve_api_key)

JSON=$(python3 -c "
import json, sys
with open('$INPUT') as f:
    text = f.read()
print(json.dumps({
    'model_id': '$MODEL',
    'transcript': text,
    'voice': {'mode': 'id', 'id': '$VOICE_ID'},
    'output_format': {'container': 'mp3', 'bit_rate': 128000, 'sample_rate': 44100, 'encoding': 'mp3'}
}))
")

curl -s -X POST https://api.cartesia.ai/tts/bytes \
  -H "X-API-Key: $API_KEY" \
  -H "Cartesia-Version: 2026-03-01" \
  -H "Content-Type: application/json" \
  -d "$JSON" \
  -o "$OUTPUT"

SIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
if [[ "$SIZE" -lt 1000 ]]; then
  echo "Error: TTS failed" >&2
  cat "$OUTPUT" >&2
  rm -f "$OUTPUT"
  exit 1
fi

DURATION=$(ffprobe -i "$OUTPUT" -show_entries format=duration -v quiet -of csv="p=0" 2>/dev/null || echo "unknown")
echo "$OUTPUT (${DURATION}s)"
