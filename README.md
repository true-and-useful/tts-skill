# TTS Skill

Text-to-speech for AI agents using [Cartesia](https://cartesia.ai) Sonic 3.

Writes a conversational script from your source material, then generates natural-sounding audio. Works with Claude Code, Cursor, Codex, and any agent that supports the [Agent Skills](https://agentskills.io) spec.

## Install

```bash
npx skills add true-and-useful/tts-skill --skill tts -g
```

### Manual install

```bash
git clone https://github.com/true-and-useful/tts-skill.git ~/.agents/skills/tts
chmod +x ~/.agents/skills/tts/scripts/tts.sh
```

## Setup

Get an API key from [cartesia.ai](https://cartesia.ai) and save it:

```bash
mkdir -p ~/.cartesia && echo "YOUR_KEY" > ~/.cartesia/credentials && chmod 600 ~/.cartesia/credentials
```

## Usage

```bash
~/.agents/skills/tts/scripts/tts.sh script.txt output.mp3
```

Or just ask your agent to "turn this into audio" — it'll handle the rest.
