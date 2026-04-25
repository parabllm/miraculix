"""
transcribe.py - Audio-Transkription via ElevenLabs Scribe v2.

Konvertiert Audio (beliebiges Format) zu MP3, archiviert in _anhaenge/audio-files/,
laed MP3 zu ElevenLabs Scribe v2 hoch, schreibt Transkript-Markdown nach
00-eingang/transkripte/{slug}.md.

CLI:
    python _claude/scripts/transcribe.py <audio-path> --slug <slug> [--language <lang>]
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

import requests
from dotenv import load_dotenv


# Vault-Root: transcribe.py liegt in _claude/scripts/, also 3 Ebenen hoch
VAULT_ROOT = Path(__file__).parent.parent.parent
MAX_FILE_SIZE_BYTES = 3 * 1024 * 1024 * 1024  # 3 GB


def load_env() -> str:
    """Laed API-Key aus _api/.env. Gibt Key zurueck oder beendet mit Fehler."""
    env_path = VAULT_ROOT / "_api" / ".env"
    load_dotenv(dotenv_path=env_path)
    api_key = os.getenv("ELEVENLABS_API_KEY")
    if not api_key or not api_key.strip():
        print("[ERROR] ELEVENLABS_API_KEY nicht gesetzt in _api/.env")
        print("        Trage den Key in _api/.env ein: ELEVENLABS_API_KEY=sk_...")
        sys.exit(1)
    return api_key.strip()


def validate_ffmpeg() -> None:
    """Prueft ob ffmpeg im PATH verfuegbar ist."""
    if shutil.which("ffmpeg") is None:
        print("[ERROR] ffmpeg nicht im PATH gefunden.")
        print("        Installation: winget install Gyan.FFmpeg")
        print("        Danach PowerShell neu starten.")
        sys.exit(1)


def validate_slug(slug: str) -> None:
    """Prueft Slug-Format: nur lowercase, Bindestriche, Ziffern."""
    pattern = r'^[a-z0-9][a-z0-9\-]*[a-z0-9]$|^[a-z0-9]$'
    if not re.match(pattern, slug):
        print(f"[ERROR] Ungültiger Slug: '{slug}'")
        print("        Erlaubt: lowercase Buchstaben, Ziffern, Bindestriche.")
        print("        Beispiel: kalani-call-2026-04-25")
        sys.exit(1)
    if '--' in slug:
        print(f"[ERROR] Doppelter Bindestrich im Slug: '{slug}'")
        print("        Beispiel: kalani-call-2026-04-25")
        sys.exit(1)


def resolve_audio_path(audio_path_str: str) -> Path:
    """Loest Audio-Pfad auf (relativ zum Vault-Root oder absolut)."""
    p = Path(audio_path_str)
    if p.is_absolute():
        resolved = p
    else:
        resolved = VAULT_ROOT / p
    if not resolved.exists():
        print(f"[ERROR] Audio-File nicht gefunden: {resolved}")
        sys.exit(1)
    size = resolved.stat().st_size
    if size > MAX_FILE_SIZE_BYTES:
        size_gb = size / (1024 ** 3)
        print(f"[ERROR] Audio-File zu gross: {size_gb:.1f} GB (Limit: 3 GB)")
        sys.exit(1)
    return resolved


def convert_to_mp3(audio_path: Path, slug: str) -> Path:
    """Konvertiert Audio zu MP3. Verschiebt oder konvertiert je nach Quellformat.

    Returns:
        Pfad zur MP3-Datei in _anhaenge/audio-files/
    """
    output_dir = VAULT_ROOT / "_anhaenge" / "audio-files"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"{slug}.mp3"

    if output_path.exists():
        print(f"[ERROR] Output-File existiert bereits: {output_path}")
        print("        Anderen Slug waehlen oder existierendes File pruefen.")
        sys.exit(1)

    if audio_path.suffix.lower() == ".mp3":
        # Bereits MP3: nur verschieben
        shutil.move(str(audio_path), str(output_path))
        print(f"[OK] Audio verschoben: {output_path.relative_to(VAULT_ROOT)}")
    else:
        # Konvertierung via ffmpeg (VBR ~190kbps, gut fuer Sprache)
        cmd = [
            "ffmpeg",
            "-i", str(audio_path),
            "-codec:a", "libmp3lame",
            "-qscale:a", "2",
            str(output_path),
            "-y"
        ]
        print(f"[INFO] Konvertiere {audio_path.name} zu MP3...")
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"[ERROR] ffmpeg-Fehler:")
            print(result.stderr[-2000:] if len(result.stderr) > 2000 else result.stderr)
            sys.exit(1)
        # Original loeschen nach erfolgreicher Konvertierung
        audio_path.unlink()
        print(f"[OK] Audio konvertiert und archiviert: {output_path.relative_to(VAULT_ROOT)}")

    return output_path


def upload_to_elevenlabs(mp3_path: Path, api_key: str, language: str | None) -> dict:
    """Laed MP3 zu ElevenLabs Scribe v2 hoch und gibt JSON-Response zurueck.

    Args:
        mp3_path: Pfad zur MP3-Datei
        api_key: ElevenLabs API-Key
        language: ISO-639-1 Code (z.B. 'de', 'en') oder None fuer Auto-Detect

    Returns:
        Parsed JSON-Response von ElevenLabs
    """
    url = "https://api.elevenlabs.io/v1/speech-to-text"
    headers = {"xi-api-key": api_key}

    # Multipart-Form-Felder
    data = {
        "model_id": "scribe_v2",
        "diarize": "true",
        "tag_audio_events": "true",
        "timestamps_granularity": "word",
    }
    if language:
        data["language_code"] = language

    print(f"[INFO] Uploade zu ElevenLabs Scribe v2 ({mp3_path.stat().st_size / (1024*1024):.1f} MB)...")

    with open(mp3_path, "rb") as f:
        files = {"file": (mp3_path.name, f, "audio/mpeg")}
        response = requests.post(
            url,
            headers=headers,
            data=data,
            files=files,
            timeout=600
        )

    if response.status_code != 200:
        print(f"[ERROR] ElevenLabs API-Fehler: HTTP {response.status_code}")
        print(response.text[:2000])
        sys.exit(1)

    return response.json()


def format_timestamp(seconds: float, total_duration: float) -> str:
    """Formatiert Sekunden als [MM:SS] oder [HH:MM:SS] je nach Gesamtlaenge."""
    total_int = int(total_duration)
    s = int(seconds)
    if total_int >= 3600:
        h = s // 3600
        m = (s % 3600) // 60
        sec = s % 60
        return f"{h:02d}:{m:02d}:{sec:02d}"
    else:
        m = s // 60
        sec = s % 60
        return f"{m:02d}:{sec:02d}"


def format_duration(seconds: float) -> str:
    """Formatiert Sekunden als MM:SS oder HH:MM:SS."""
    s = int(seconds)
    if s >= 3600:
        h = s // 3600
        m = (s % 3600) // 60
        sec = s % 60
        return f"{h:02d}:{m:02d}:{sec:02d}"
    else:
        m = s // 60
        sec = s % 60
        return f"{m:02d}:{sec:02d}"


def build_speaker_blocks(words: list[dict]) -> list[dict]:
    """Aggregiert Words-Liste zu Speaker-Blocks.

    Aufeinanderfolgende Words mit gleichem speaker_id werden zu einem Block.
    Audio-Events werden inline eingefuegt.

    Returns:
        Liste von Dicts mit keys: speaker_id, start_time, text
    """
    blocks: list[dict] = []
    current_block: dict | None = None

    for word in words:
        word_type = word.get("type", "word")
        text = word.get("text", "")
        speaker_id = word.get("speaker_id")
        start = word.get("start", 0.0)

        if word_type == "spacing":
            # Leerzeichen zwischen Words: an aktuellen Block anhaengen
            if current_block is not None:
                current_block["text"] += text
            continue

        if word_type == "audio_event":
            # Audio-Events (z.B. "(laughter)") inline in aktuellen Block
            if current_block is not None:
                if not current_block["text"].endswith(" "):
                    current_block["text"] += " "
                current_block["text"] += text
            continue

        # Normales Word
        if current_block is None or current_block["speaker_id"] != speaker_id:
            # Neuer Block
            if current_block is not None:
                current_block["text"] = current_block["text"].strip()
                blocks.append(current_block)
            current_block = {
                "speaker_id": speaker_id,
                "start_time": start,
                "text": text
            }
        else:
            # Gleicher Speaker: Text anhaengen
            if not current_block["text"].endswith(" "):
                current_block["text"] += " "
            current_block["text"] += text

    if current_block is not None:
        current_block["text"] = current_block["text"].strip()
        blocks.append(current_block)

    return blocks


def write_transcript_markdown(
    slug: str,
    mp3_path: Path,
    api_response: dict,
    blocks: list[dict],
    total_duration: float
) -> Path:
    """Schreibt Transkript-Markdown nach 00-eingang/transkripte/{slug}.md.

    Returns:
        Pfad zum erstellten Markdown-File
    """
    output_dir = VAULT_ROOT / "00-eingang" / "transkripte"
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"{slug}.md"

    if output_path.exists():
        print(f"[ERROR] Transkript existiert bereits: {output_path.relative_to(VAULT_ROOT)}")
        print("        Anderen Slug waehlen oder existierendes File loeschen.")
        sys.exit(1)

    lang_code = api_response.get("language_code", "unknown")
    lang_prob = api_response.get("language_probability", 0.0)
    lang_prob_pct = int(lang_prob * 100)

    # Sprecher-Liste
    speaker_ids = list(dict.fromkeys(
        b["speaker_id"] for b in blocks if b.get("speaker_id")
    ))
    speaker_count = len(speaker_ids)
    speaker_list_str = ", ".join(speaker_ids) if speaker_ids else "unbekannt"

    duration_str = format_duration(total_duration)
    duration_minutes = round(total_duration / 60, 1)

    now_str = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S")
    date_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    mp3_relative = str(mp3_path.relative_to(VAULT_ROOT)).replace("\\", "/")

    # Frontmatter
    lines = [
        "---",
        "typ: transkript",
        "quelle: elevenlabs-scribe-v2",
        f"datum: {date_str}",
        f'audio_datei: "{mp3_relative}"',
        f"slug: {slug}",
        f"dauer_minuten: {duration_minutes}",
        f"sprecher_anzahl: {speaker_count}",
        f"sprache: {lang_code}",
        f"sprache_wahrscheinlichkeit: {lang_prob:.2f}",
        "status: unverarbeitet",
        f"erstellt: {now_str}",
        "---",
        "",
        f"# Transkript: {slug}",
        "",
        "## Metadata",
        "",
        f"- Audio: `{mp3_relative}`",
        f"- Dauer: {duration_str}",
        f"- Sprecher: {speaker_list_str}",
        f"- Sprache: {lang_code} (Wahrscheinlichkeit {lang_prob_pct}%)",
        "",
        "## Transkript",
        "",
    ]

    # Speaker-Blocks
    for block in blocks:
        speaker = block.get("speaker_id", "unbekannt")
        start = block.get("start_time", 0.0)
        text = block.get("text", "")
        ts = format_timestamp(start, total_duration)
        lines.append(f"**[{ts}] {speaker}:**")
        lines.append(text)
        lines.append("")

    content = "\n".join(lines)
    output_path.write_text(content, encoding="utf-8")
    return output_path


def get_total_duration(words: list[dict]) -> float:
    """Berechnet Gesamtdauer aus letztem Word-Endzeit."""
    if not words:
        return 0.0
    end_times = [w.get("end", 0.0) for w in words if "end" in w]
    return max(end_times) if end_times else 0.0


def main() -> None:
    """Entry-Point: parst Argumente, fuehrt Pipeline aus."""
    parser = argparse.ArgumentParser(
        description="Audio transkribieren via ElevenLabs Scribe v2.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Beispiele:\n"
            "  python _claude/scripts/transcribe.py 00-eingang/audio/meeting.m4a --slug kalani-call-2026-04-25\n"
            "  python _claude/scripts/transcribe.py aufnahme.mp3 --slug standup-2026-04-25 --language de"
        )
    )
    parser.add_argument(
        "audio_path",
        help="Pfad zur Audio-Datei (relativ zu Vault-Root oder absolut)"
    )
    parser.add_argument(
        "--slug",
        required=True,
        help="Dateiname-Slug fuer MP3 und Transkript (z.B. kalani-call-2026-04-25)"
    )
    parser.add_argument(
        "--language",
        default=None,
        help="ISO-639-1 Sprachcode (z.B. de, en). Standard: Auto-Detect."
    )

    args = parser.parse_args()

    # Validierungen
    validate_slug(args.slug)
    validate_ffmpeg()
    api_key = load_env()

    audio_path = resolve_audio_path(args.audio_path)

    # Konvertierung
    mp3_path = convert_to_mp3(audio_path, args.slug)

    # Upload
    api_response = upload_to_elevenlabs(mp3_path, api_key, args.language)

    # Verarbeitung
    words = api_response.get("words", [])
    total_duration = get_total_duration(words)
    blocks = build_speaker_blocks(words)

    # Markdown schreiben
    transcript_path = write_transcript_markdown(
        slug=args.slug,
        mp3_path=mp3_path,
        api_response=api_response,
        blocks=blocks,
        total_duration=total_duration
    )

    # Abschluss-Report
    lang_code = api_response.get("language_code", "?")
    lang_prob = int(api_response.get("language_probability", 0.0) * 100)
    speaker_ids = list(dict.fromkeys(
        b["speaker_id"] for b in blocks if b.get("speaker_id")
    ))
    duration_str = format_duration(total_duration)

    print(f"[OK] Audio archiviert: {mp3_path.relative_to(VAULT_ROOT)}")
    print(f"[OK] Transkript erstellt: {transcript_path.relative_to(VAULT_ROOT)}")
    print(f"[INFO] Sprache: {lang_code} ({lang_prob}%), Sprecher: {len(speaker_ids)}, Dauer: {duration_str}")


if __name__ == "__main__":
    main()
