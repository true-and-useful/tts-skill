---
name: tts
description: >
  Convert text to speech using Cartesia's Sonic 3 model. Use when asked to
  "read this aloud", "make an audio version", "generate speech", "text to speech",
  "TTS this", "create an audiobook", or "turn this into audio".
  Outputs an MP3 file.
---

Generate natural-sounding speech from text using Cartesia Sonic 3.

## Requirements

`curl`, `python3`, `ffprobe` (optional, for duration)

## Setup

Save your Cartesia API key:

```bash
mkdir -p ~/.cartesia && echo "YOUR_KEY" > ~/.cartesia/credentials && chmod 600 ~/.cartesia/credentials
```

Or set `CARTESIA_API_KEY` env var. Or pass `--api-key` flag.

Resolution order: `--api-key` flag > `$CARTESIA_API_KEY` env var > `~/.cartesia/credentials` file.

## API details

- **API**: Cartesia (https://api.cartesia.ai)
- **Model**: `sonic-3`
- **Docs version header**: `Cartesia-Version: 2026-03-01` (required on every request)
- **Auth header**: `X-API-Key: {key}` (NOT Bearer token)

## Default voice

Ronald: `5ee9feff-1265-424a-9d7f-8e4d431a12c7`

Natural, conversational male voice. Good for narration, briefings, and long-form content.

## How to use this skill — the full workflow

TTS is a two-step process: **write a script**, then **generate audio**. Never skip the first step. Raw source content (blog posts, docs, notes, case studies) sounds terrible when fed directly to TTS — you can hear the "AI blog post" cadence and it's painful to listen to.

### Step 1: Write a spoken script (.txt file)

Before generating audio, ALWAYS rewrite the source material into a conversational script. This is the most important step. Save it as a plain `.txt` file with no formatting.

**The goal**: it should sound like a knowledgeable person casually explaining this stuff to you — like a friend briefing you over coffee, not a corporate blog post being read aloud.

**Rules for the script**:

- No headings, no bullet points, no markdown, no structure — just flowing paragraphs of natural speech
- Write in first person or second person. "Let me walk you through this" not "This document outlines"
- Use contractions: "they're", "it's", "don't", "that's". Nobody speaks without contractions
- Spell out numbers: "ninety-five percent" not "95%", "two billion dollars" not "$2B", "seventy-two hours" not "72 hours"
- Spell out abbreviations on first use: "Forward Deployed Engineers, or FDEs" not just "FDEs"
- Use natural transitions between topics: "Now, the interesting part is...", "Which brings us to...", "So here's where it gets good..."
- Vary sentence length. Short punchy sentences mixed with longer flowing ones. Monotonous rhythm is death
- Add conversational filler where it feels natural: "honestly", "basically", "the crazy thing is", "and look"
- When citing quotes, introduce them naturally: "Their CTO said they evaluated over a dozen vendors" — don't use quotation marks or attribution blocks
- When citing stats, weave them into sentences: "They hit seventy-five percent resolution on the first attempt" not "Resolution rate: 75%"
- No sign-off or summary paragraph at the end. Just stop when the content is done. Don't wrap up with "So that's..." or "In conclusion..."
- Let the content dictate the length. Don't pad and don't artificially truncate. A 3-minute briefing is fine. So is 15 minutes

**What to avoid**:

- Don't preserve the original document's structure — restructure for spoken flow
- Don't include section headers read aloud ("Chapter one, the execution gap...")
- Don't read out URLs, citation marks, or formatting artifacts
- Don't use the word "delve"
- Don't be breathlessly enthusiastic. Be measured, thoughtful, and occasionally wry
- Don't start with "Hey there!" or any greeting. Just start talking about the subject

### Step 2: Generate the audio

```bash
./scripts/tts.sh <script.txt> <output.mp3>
```

Or call the API directly:

```bash
curl -s -X POST https://api.cartesia.ai/tts/bytes \
  -H "X-API-Key: $(cat ~/.cartesia/credentials)" \
  -H "Cartesia-Version: 2026-03-01" \
  -H "Content-Type: application/json" \
  -d "$(python3 -c "
import json
with open('script.txt') as f:
    text = f.read()
print(json.dumps({
    'model_id': 'sonic-3',
    'transcript': text,
    'voice': {'mode': 'id', 'id': '5ee9feff-1265-424a-9d7f-8e4d431a12c7'},
    'output_format': {'container': 'mp3', 'bit_rate': 128000, 'sample_rate': 44100, 'encoding': 'mp3'}
}))
")" \
  -o output.mp3
```

The response body IS the MP3 file. No JSON wrapper. Just pipe or save directly.

## Available voices

List voices:

```bash
curl -s -H "X-API-Key: $(cat ~/.cartesia/credentials)" \
  -H "Cartesia-Version: 2026-03-01" \
  https://api.cartesia.ai/voices
```

To use a different voice, pass `--voice <id>` to the script. You can also use a custom/cloned voice ID directly.

## Multiple parts

For longer scripts, split at paragraph breaks and generate each part separately. Concatenate with ffmpeg:

```bash
ffmpeg -i "concat:part1.mp3|part2.mp3|part3.mp3" -c copy output.mp3
```

## Uploading

After generating audio, use the `airloom` skill to upload and get a shareable URL:
```bash
~/.agents/skills/airloom/scripts/upload.sh output.mp3 --title "My Audio" --client claude-code
```
