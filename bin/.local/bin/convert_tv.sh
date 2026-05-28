#!/usr/bin/env bash

# ==============================================================================
# TV-Compatible Video Transcoder with Remote VPS GPU Support
# ==============================================================================
# A robust, production-quality utility to transcode any video file into a highly
# compatible H.264 MKV container tailored for Smart TVs, USB playback, and DLNA.
# Supports local CPU/GPU encoding and remote GPU-accelerated VPS execution.
# ==============================================================================

set -o errexit
set -o pipefail
set -o nounset

# Add common lightning.ai conda path and system paths (critical for remote non-interactive execution)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"
if [[ -d "/system/conda/miniconda3/bin" ]]; then
    export PATH="/system/conda/miniconda3/bin:$PATH"
fi

# --- Color Definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

REMOTE_SSH="s_01kj5kc4sfvvrp426pyq25gyh4@ssh.lightning.ai"
REMOTE_TMP_DIR="tv_convert_tmp"
PRESET="slow"

# Detect local lightning CLI globally (needed for remote provisioning and teardown traps)
LIGHTNING_CLI="lightning"
if [[ -x "./.venv/bin/lightning" ]]; then
    LIGHTNING_CLI="./.venv/bin/lightning"
elif [[ -x ".venv/bin/lightning" ]]; then
    LIGHTNING_CLI=".venv/bin/lightning"
fi

# --- Helper Functions ---
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_header() {
    echo -e "\n${BLUE}======================================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${BLUE}======================================================================${NC}"
}

show_help() {
    cat << EOF
Usage: $(basename "$0") -i <input_path> [options]

A robust media transcode utility designed for maximum Smart TV compatibility.

Options:
  -i, --input <path>      Path to input video file or directory. (Required)
  -o, --output <path>     Path to output MKV file or directory. (Optional)
                          Defaults to '<input_basename>_TV_Compatible.mkv'
  -f, --fast              Fast Mode: Skip video transcode (copy video stream)
                          if it is already H.264 High@L4.0/4.1 yuv420p.
  -g, --gpu               Force local GPU-accelerated encoding (using h264_nvenc).
                          Requires an NVIDIA GPU and configured drivers.
  -r, --remote            Remote VPS Mode: Automatically uploads the video to
                          the GPU-equipped VPS, performs transcode using GPU,
                          downloads the result, and cleans up remote workspace.
  -j, --jobs <number>     Number of parallel jobs for batch directory transcoding.
                          Default: 1 (sequential)
  -d, --dry-run           Dry Run Mode: Analyze tracks and display the exact
                          FFmpeg/SSH commands without executing them.
  -h, --help              Show this help message and exit.

Examples:
  # Transcode a single file locally via CPU:
  $(basename "$0") -i "Ronaldinho Gaúcho S01E03.mkv"

  # Transcode a single file on the remote VPS (utilizing its L4 GPU):
  $(basename "$0") -i "Ronaldinho Gaúcho S01E03.mkv" -r

  # Batch transcode a directory of files remotely in Fast Mode:
  $(basename "$0") -i "/path/to/season1" -r -f

  # Parallel local transcode of a folder (3 files at once):
  $(basename "$0") -i "./videos" -j 3
EOF
}

# --- Dependency Verification ---
check_local_dependencies() {
    local deps=("ffmpeg" "ffprobe" "python3")
    if [[ "${REMOTE_MODE:-false}" == "true" ]]; then
        deps+=("ssh" "scp")
    fi
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_error "Required local dependency '$dep' is missing. Please install it."
            exit 1
        fi
    done
}

# --- Python FFprobe JSON Parser ---
# Designed to run under python3 to parse ffprobe streams, scoring and ranking
# them for optimal selection (Normal > Forced > SDH), removing commentary/signs/songs.
read -r -d '' PYTHON_PARSER << 'EOF' || true
import sys
import json
import re

try:
    data = json.loads(sys.stdin.read())
except Exception as e:
    sys.stderr.write(f"Error parsing ffprobe output: {e}\n")
    sys.exit(1)

streams = data.get("streams", [])
format_info = data.get("format", {})
duration = format_info.get("duration", "0")
print(f"DURATION={duration}")

video_streams = []
audio_streams = []
subtitle_streams = []

# Regular expressions for language identification
POR_RE = re.compile(r"\b(por|pt|pt-br|portuguese)\b", re.IGNORECASE)
ENG_RE = re.compile(r"\b(eng|en|english)\b", re.IGNORECASE)

# Regex for commentary/descriptions and signs/songs
COMMENTARY_RE = re.compile(r"\b(commentary|comment|coment[aá]rio|diretor|description|hearing|visual|impaired)\b", re.IGNORECASE)
SIGNS_SONGS_RE = re.compile(r"\b(signs|songs|sinais|m[uú]sicas|lyrics)\b", re.IGNORECASE)

for s in streams:
    codec_type = s.get("codec_type")
    idx = s.get("index")
    codec = s.get("codec_name", "")
    tags = s.get("tags", {})
    lang = tags.get("language", "")
    title = tags.get("title", "")
    disp = s.get("disposition", {})
    
    # Check if forced
    is_forced = disp.get("forced") == 1 or "forced" in title.lower() or "forced" in lang.lower()
    
    # Check if SDH/hearing impaired
    is_sdh = disp.get("hearing_impaired") == 1 or any(x in title.lower() or x in lang.lower() for x in ["sdh", "cc"])

    # Language flags
    is_por = bool(POR_RE.search(lang) or POR_RE.search(title))
    is_eng = bool(ENG_RE.search(lang) or ENG_RE.search(title))
    
    if codec_type == "video":
        video_streams.append({
            "index": idx,
            "codec": codec,
            "pix_fmt": s.get("pix_fmt", ""),
            "profile": s.get("profile", ""),
            "level": s.get("level", -1)
        })
    elif codec_type == "audio":
        is_commentary = bool(COMMENTARY_RE.search(title) or disp.get("comment") == 1 or disp.get("hearing_impaired") == 1)
        audio_streams.append({
            "index": idx,
            "codec": codec,
            "is_por": is_por,
            "is_eng": is_eng,
            "channels": s.get("channels", 2),
            "is_commentary": is_commentary,
            "title": title
        })
    elif codec_type == "subtitle":
        is_commentary = bool(COMMENTARY_RE.search(title) or disp.get("comment") == 1)
        is_signs = bool(SIGNS_SONGS_RE.search(title))
        subtitle_streams.append({
            "index": idx,
            "codec": codec,
            "is_por": is_por,
            "is_eng": is_eng,
            "is_forced": is_forced,
            "is_sdh": is_sdh,
            "is_commentary": is_commentary,
            "is_signs": is_signs,
            "title": title
        })

# 1. Select Video: First available video stream
selected_video = video_streams[0] if video_streams else None

if selected_video:
    print(f"VIDEO_INDEX={selected_video['index']}")
    print(f"VIDEO_CODEC=\"{selected_video['codec']}\"")
    print(f"VIDEO_PROFILE=\"{selected_video['profile']}\"")
    print(f"VIDEO_LEVEL={selected_video['level']}")
    print(f"VIDEO_PIX_FMT=\"{selected_video['pix_fmt']}\"")
else:
    print("VIDEO_INDEX=-1")

# 2. Select Audio: Max 2 tracks. Priority: Portuguese > English. Exclude Commentary.
def score_audio(a):
    if not (a["is_por"] or a["is_eng"]): return -1
    if a["is_commentary"]: return -1
    score = 100
    if a["is_por"]: score += 10
    return score

valid_audios = [a for a in audio_streams if score_audio(a) > 0]
valid_audios.sort(key=score_audio, reverse=True)

por_audios = [a for a in valid_audios if a["is_por"]]
eng_audios = [a for a in valid_audios if a["is_eng"]]

selected_audios = []
if por_audios and eng_audios:
    selected_audios.append(por_audios[0])
    selected_audios.append(eng_audios[0])
elif por_audios:
    selected_audios = por_audios[:2]
elif eng_audios:
    selected_audios = eng_audios[:2]

print(f"AUDIO_COUNT={len(selected_audios)}")
for i, a in enumerate(selected_audios):
    print(f"AUDIO_{i}_INDEX={a['index']}")
    print(f"AUDIO_{i}_LANG=\"{'por' if a['is_por'] else 'eng'}\"")
    print(f"AUDIO_{i}_CHANNELS={a['channels']}")
    print(f"AUDIO_{i}_TITLE=\"{a['title']}\"")

# 3. Select Subtitles: Max 2 tracks. Priority: Normal > Forced > SDH. Exclude commentary/signs/songs. Deduplicate forced.
def score_subtitle(s):
    if not (s["is_por"] or s["is_eng"]): return -1
    if s["is_commentary"] or s["is_signs"]: return -1
    
    # Base score
    score = 100
    if s["is_por"]: score += 10
    
    # Priority offsets: Normal = 3, Forced = 2, SDH = 1
    if not (s["is_forced"] or s["is_sdh"]):
        score += 3
    elif s["is_forced"]:
        score += 2
    elif s["is_sdh"]:
        score += 1
    return score

valid_subs = [s for s in subtitle_streams if score_subtitle(s) > 0]
valid_subs.sort(key=score_subtitle, reverse=True)

por_subs = [s for s in valid_subs if s["is_por"]]
eng_subs = [s for s in valid_subs if s["is_eng"]]

def deduplicate_subs(subs):
    seen_forced = False
    deduped = []
    for s in subs:
        if s["is_forced"]:
            if not seen_forced:
                deduped.append(s)
                seen_forced = True
        else:
            deduped.append(s)
    return deduped

por_subs = deduplicate_subs(por_subs)
eng_subs = deduplicate_subs(eng_subs)

selected_subs = []
if por_subs and eng_subs:
    selected_subs.append(por_subs[0])
    selected_subs.append(eng_subs[0])
elif por_subs:
    selected_subs = por_subs[:2]
elif eng_subs:
    selected_subs = eng_subs[:2]

print(f"SUB_COUNT={len(selected_subs)}")
for i, s in enumerate(selected_subs):
    print(f"SUB_{i}_INDEX={s['index']}")
    print(f"SUB_{i}_LANG=\"{'por' if s['is_por'] else 'eng'}\"")
    print(f"SUB_{i}_FORCED={'1' if s['is_forced'] else '0'}")
    print(f"SUB_{i}_CODEC=\"{s['codec']}\"")
    print(f"SUB_{i}_TITLE=\"{s['title']}\"")
EOF

# --- Interactive Visual Progress Bar ---
run_ffmpeg_with_progress() {
    local duration="$1"
    shift
    local cmd_args=("$@")
    
    if [[ -z "$duration" || "$duration" == "0" || "$duration" == "N/A" ]]; then
        ffmpeg "${cmd_args[@]}" -y
        return $?
    fi
    
    local total_secs
    total_secs=$(printf "%.0f" "$duration" 2>/dev/null || echo "0")
    
    if (( total_secs == 0 )); then
        ffmpeg "${cmd_args[@]}" -y
        return $?
    fi
    
    local log_file
    log_file=$(mktemp)
    
    log_info "Transcoding in progress..."
    
    local current_frame=0
    local current_fps=0
    local current_speed="0.00x"
    local current_percent=0
    
    set +e
    set -o pipefail
    
    local start_time
    start_time=$(date +%s)
    
    # Run ffmpeg with stdout progress logs and stderr redirect to temp file
    ffmpeg "${cmd_args[@]}" -progress - -nostats -y 2>"$log_file" | while read -r line; do
        if [[ "$line" =~ ^frame=(.*)$ ]]; then
            current_frame="${BASH_REMATCH[1]}"
            current_frame=$(echo "$current_frame" | tr -d ' ')
        elif [[ "$line" =~ ^fps=(.*)$ ]]; then
            current_fps="${BASH_REMATCH[1]}"
            current_fps=$(echo "$current_fps" | tr -d ' ')
        elif [[ "$line" =~ ^speed=(.*)$ ]]; then
            current_speed="${BASH_REMATCH[1]}"
            current_speed=$(echo "$current_speed" | tr -d ' ')
        elif [[ "$line" =~ ^out_time_us=(.*)$ ]]; then
            local time_us="${BASH_REMATCH[1]}"
            time_us=$(echo "$time_us" | tr -d ' ')
            if [[ "$time_us" =~ ^[0-9]+$ ]]; then
                local current_secs=$(( time_us / 1000000 ))
                
                if (( current_secs > total_secs )); then
                    current_percent=100
                else
                    current_percent=$(( current_secs * 100 / total_secs ))
                fi
                
                # Calculate ETA
                local elapsed=$(( $(date +%s) - start_time ))
                local eta_str="--"
                if (( current_percent > 0 && current_percent < 100 )); then
                    local total_est=$(( elapsed * 100 / current_percent ))
                    local remaining=$(( total_est - elapsed ))
                    if (( remaining > 0 )); then
                        local rem_min=$(( remaining / 60 ))
                        local rem_sec=$(( remaining % 60 ))
                        eta_str=$(printf "%02d:%02d" "$rem_min" "$rem_sec")
                    fi
                elif (( current_percent >= 100 )); then
                    eta_str="00:00"
                fi
                
                # Render visual progress bar
                local bar_width=30
                local filled=$(( current_percent * bar_width / 100 ))
                local empty=$(( bar_width - filled ))
                local bar=""
                for ((j=0; j<filled; j++)); do bar="${bar}="; done
                if (( empty > 0 )); then
                    bar="${bar}>"
                    for ((j=1; j<empty; j++)); do bar="${bar}."; done
                fi
                
                printf "\r${BLUE}[%-${bar_width}s] %3d%%${NC} | FPS: ${YELLOW}%-4s${NC} | Speed: ${GREEN}%-5s${NC} | ETA: ${CYAN}%-5s${NC}" "$bar" "$current_percent" "$current_fps" "$current_speed" "$eta_str"
            fi
        fi
    done
    local status=$?
    set -e
    set +o pipefail
    
    echo "" # New line after carriage return
    
    if (( status == 0 )); then
        log_info "Transcoding completed successfully."
        rm -f "$log_file"
    else
        log_error "Transcoding failed. Review FFmpeg output below:"
        echo -e "${RED}"
        cat "$log_file"
        echo -e "${NC}"
        rm -f "$log_file"
    fi
    
    return $status
}

transcode_single_file() {
    local input="$1"
    local output="$2"
    
    # Wait until the input file is fully synchronized and readable (critical for remote FUSE mounts)
    log_info "Verifying input file sync state..."
    local read_attempts=0
    while ! dd if="$input" of=/dev/null bs=1024 count=1 &>/dev/null; do
        read_attempts=$((read_attempts + 1))
        if (( read_attempts > 12 )); then
            log_error "Input file failed to synchronize after 60 seconds."
            return 1
        fi
        log_info "Waiting for file to sync (attempt $read_attempts)..."
        sleep 5
    done
    log_info "Input file is synchronized and ready."
    
    log_header "Analyzing Input File: $(basename "$input")"
    
    # 1. Probe the input file structure
    local probe_cmd
    probe_cmd=$(ffprobe -v error -show_entries format=duration:stream=index,codec_type,codec_name,channels,profile,level,pix_fmt,disposition:stream_tags=language,title -of json "$input")
    
    # 2. Run Python analyzer and source results into environment variables
    local analysis_result
    analysis_result=$(echo "$probe_cmd" | python3 -c "$PYTHON_PARSER")
    eval "$analysis_result"
    
    if [[ "$VIDEO_INDEX" == "-1" ]]; then
        log_error "No valid video stream detected in '$input'."
        return 1
    fi
    
    # Display stream selection details
    log_info "Video stream found: Index $VIDEO_INDEX ($VIDEO_CODEC, Profile: $VIDEO_PROFILE, Level: $VIDEO_LEVEL, PixFmt: $VIDEO_PIX_FMT)"
    log_info "Selected $AUDIO_COUNT audio tracks:"
    for ((i=0; i<AUDIO_COUNT; i++)); do
        local idx_var="AUDIO_${i}_INDEX"
        local lang_var="AUDIO_${i}_LANG"
        local chan_var="AUDIO_${i}_CHANNELS"
        local title_var="AUDIO_${i}_TITLE"
        log_info "  - Track $((i+1)): Index ${!idx_var} (Lang: ${!lang_var}, Channels: ${!chan_var}, Title: ${!title_var})"
    done
    
    log_info "Selected $SUB_COUNT subtitle tracks:"
    for ((i=0; i<SUB_COUNT; i++)); do
        local idx_var="SUB_${i}_INDEX"
        local lang_var="SUB_${i}_LANG"
        local forced_var="SUB_${i}_FORCED"
        local codec_var="SUB_${i}_CODEC"
        local title_var="SUB_${i}_TITLE"
        log_info "  - Track $((i+1)): Index ${!idx_var} (Lang: ${!lang_var}, Forced: ${!forced_var}, Codec: ${!codec_var}, Title: ${!title_var})"
    done
    
    # 3. Assemble FFmpeg mapping and encoding commands
    local ffmpeg_args=()
    if [[ "$USE_GPU" == "true" ]]; then
        ffmpeg_args+=("-hwaccel" "cuda" "-hwaccel_output_format" "cuda")
    fi
    ffmpeg_args+=("-i" "$input")
    
    # Video mapping & settings
    ffmpeg_args+=("-map" "0:$VIDEO_INDEX")
    
    local copy_video="false"
    if [[ "$FAST_MODE" == "true" ]]; then
        # Check H.264 profile, level and pixel format compliance
        if [[ "$VIDEO_CODEC" == "h264" ]] && \
           [[ "$VIDEO_PROFILE" =~ [Hh]igh ]] && \
           [[ "$VIDEO_LEVEL" == "40" || "$VIDEO_LEVEL" == "4.0" || "$VIDEO_LEVEL" == "41" || "$VIDEO_LEVEL" == "4.1" ]] && \
           [[ "$VIDEO_PIX_FMT" == "yuv420p" ]]; then
            copy_video="true"
        fi
    fi
    
    if [[ "$copy_video" == "true" ]]; then
        log_info "Fast Mode active: Video complies with H.264 High@L4.x yuv420p. Skipping video re-encoding."
        ffmpeg_args+=("-c:v" "copy")
    else
        if [[ "$USE_GPU" == "true" ]]; then
            log_info "Encoding video via GPU (h264_nvenc)..."
            ffmpeg_args+=("-c:v" "h264_nvenc" "-preset" "p5" "-profile:v" "high" "-level" "4.1" "-rc" "vbr" "-cq" "23" "-b:v" "0" "-coder" "cabac" "-bf" "2" "-g" "60" "-vf" "scale_cuda='min(1920,iw)':-2:force_original_aspect_ratio=1" "-r" "30" "-movflags" "+faststart")
        else
            log_info "Encoding video via CPU (libx264)..."
            ffmpeg_args+=("-c:v" "libx264" "-crf" "20" "-preset" "$PRESET" "-profile:v" "high" "-level" "4.1" "-pix_fmt" "yuv420p" "-coder" "cabac" "-bf" "2" "-g" "60" "-vf" "scale='min(1920,iw)':-2:force_original_aspect_ratio=decrease" "-r" "30" "-movflags" "+faststart")
        fi
    fi
    
    # Audio mapping & settings
    local default_audio_idx=-1
    for ((i=0; i<AUDIO_COUNT; i++)); do
        local lang_var="AUDIO_${i}_LANG"
        if [[ "${!lang_var}" == "por" ]]; then
            default_audio_idx=$i
            break
        fi
    done
    if [[ "$default_audio_idx" == "-1" && "$AUDIO_COUNT" -gt 0 ]]; then
        default_audio_idx=0
    fi
    
    for ((i=0; i<AUDIO_COUNT; i++)); do
        local idx_var="AUDIO_${i}_INDEX"
        local lang_var="AUDIO_${i}_LANG"
        local chan_var="AUDIO_${i}_CHANNELS"
        
        ffmpeg_args+=("-map" "0:${!idx_var}")
        ffmpeg_args+=("-c:a:$i" "ac3" "-b:a:$i" "384k")
        
        # AC3 strictly supports max 6 channels (5.1). Downmix if input exceeds it.
        if (( chan_var > 5 )); then
            ffmpeg_args+=("-ac:a:$i" "6")
        fi
        
        ffmpeg_args+=("-metadata:s:a:$i" "language=${!lang_var}")
        
        if (( i == default_audio_idx )); then
            ffmpeg_args+=("-disposition:a:$i" "default")
        else
            ffmpeg_args+=("-disposition:a:$i" "0")
        fi
    done
    
    # Subtitle mapping & settings
    local default_sub_idx=-1
    local found_por_sub="false"
    for ((i=0; i<SUB_COUNT; i++)); do
        local lang_var="SUB_${i}_LANG"
        if [[ "${!lang_var}" == "por" ]]; then
            default_sub_idx=$i
            found_por_sub="true"
            break
        fi
    done
    if [[ "$default_sub_idx" == "-1" && "$SUB_COUNT" -gt 0 ]]; then
        default_sub_idx=0
    fi
    
    for ((i=0; i<SUB_COUNT; i++)); do
        local idx_var="SUB_${i}_INDEX"
        local lang_var="SUB_${i}_LANG"
        local forced_var="SUB_${i}_FORCED"
        local codec_var="SUB_${i}_CODEC"
        
        ffmpeg_args+=("-map" "0:${!idx_var}")
        
        # Image subtitles (PGS / VOBSUB) cannot be transcoded to SRT without OCR. Copy as-is.
        if [[ "${!codec_var}" == "hdmv_pgs_subtitle" || "${!codec_var}" == "dvd_subtitle" ]]; then
            ffmpeg_args+=("-c:s:$i" "copy")
        else
            ffmpeg_args+=("-c:s:$i" "srt")
        fi
        
        ffmpeg_args+=("-metadata:s:s:$i" "language=${!lang_var}")
        
        # Setup dispositions
        local disp_str=""
        if (( i == default_sub_idx )) && [[ "$found_por_sub" == "true" ]]; then
            disp_str="default"
        fi
        
        if [[ "${!forced_var}" == "1" ]]; then
            if [[ -n "$disp_str" ]]; then
                disp_str="$disp_str+forced"
            else
                disp_str="forced"
            fi
        fi
        
        if [[ -n "$disp_str" ]]; then
            ffmpeg_args+=("-disposition:s:$i" "$disp_str")
        else
            ffmpeg_args+=("-disposition:s:$i" "0")
        fi
    done
    
    # Metadata & attachment removal rules
    ffmpeg_args+=("-map" "-0:t")
    ffmpeg_args+=("-map_metadata" "-1")
    ffmpeg_args+=("-map_chapters" "-1")
    ffmpeg_args+=("-metadata" "title=")
    
    # Output file
    ffmpeg_args+=("$output")
    
    # 4. Execution or Dry Run
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "Dry Run Mode: Command that would run locally:"
        echo -e "${CYAN}ffmpeg ${ffmpeg_args[*]}${NC}"
        return 0
    fi
    
    run_ffmpeg_with_progress "$DURATION" "${ffmpeg_args[@]}"
}

# --- Remote VPS Coordination Engine ---
transcode_remote_vps() {
    local input="$1"
    local output="$2"
    
    local abs_input
    abs_input=$(realpath "$input")
    local abs_output
    abs_output=$(realpath "$output")
    
    local safe_basename
    safe_basename=$(basename "$input")
    local remote_input="/home/zeus/content/${REMOTE_TMP_DIR}/${safe_basename}"
    local remote_output="/home/zeus/content/${REMOTE_TMP_DIR}/$(basename "$output")"
    
    # Verify we can execute the lightning CLI
    if [[ "$LIGHTNING_CLI" == "lightning" ]] && ! command -v lightning &>/dev/null; then
        log_error "Lightning CLI not found. Please activate your virtual environment (.venv) or install it: pip install lightning-sdk"
        return 1
    fi
    
    log_header "Remote Coordination Engine: $(basename "$input")"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        local -a cmd_args=("bash" "/home/zeus/tv_convert_tmp/convert_tv.sh" "--gpu" "--input" "$remote_input" "--output" "$remote_output" "--preset" "$PRESET")
        if [[ "$FAST_MODE" == "true" ]]; then
            cmd_args+=("--fast")
        fi
        cmd_args+=("--dry-run")
        
        local remote_cmd
        remote_cmd=$(printf '%q ' "${cmd_args[@]}")
        
        log_warn "Dry Run Mode (Remote): Commands that would run:"
        echo -e "${CYAN}${LIGHTNING_CLI} studio switch --name \"prickly-copper-64tb\" --machine \"L4\" --teamspace \"contatoashanti/interactive-data-science-project\" || ${LIGHTNING_CLI} studio start --name \"prickly-copper-64tb\" --machine \"L4\" --teamspace \"contatoashanti/interactive-data-science-project\"${NC}"
        echo -e "${CYAN}ssh -o StrictHostKeyChecking=no ${REMOTE_SSH} \"mkdir -p tv_convert_tmp content/${REMOTE_TMP_DIR}\"${NC}"
        echo -e "${CYAN}ssh -o StrictHostKeyChecking=no ${REMOTE_SSH} \"cat > tv_convert_tmp/convert_tv.sh\" < \"$0\"${NC}"
        echo -e "${CYAN}${LIGHTNING_CLI} studio cp \"$abs_input\" \"lit://contatoashanti/interactive-data-science-project/studios/prickly-copper-64tb/tv_convert_tmp/\"${NC}"
        echo -e "${CYAN}ssh -t -o StrictHostKeyChecking=no ${REMOTE_SSH} '${remote_cmd}'${NC}"
        echo -e "${CYAN}${LIGHTNING_CLI} studio cp \"lit://contatoashanti/interactive-data-science-project/studios/prickly-copper-64tb/tv_convert_tmp/\$(basename \"$output\")\" \"$abs_output\"${NC}"
        echo -e "${CYAN}ssh -o StrictHostKeyChecking=no ${REMOTE_SSH} \"rm -rf tv_convert_tmp content/${REMOTE_TMP_DIR}\"${NC}"
        echo -e "${CYAN}${LIGHTNING_CLI} studio stop --name \"prickly-copper-64tb\" --teamspace \"contatoashanti/interactive-data-science-project\"${NC}"
        return 0
    fi
    
    # 0. Deterministic remote Studio state-machine check to bypass redundant transitions (prevents API client hangs)
    log_info "Checking remote Studio status..."
    local status_info
    while true; do
        status_info=$("$LIGHTNING_CLI" studio list --teamspace "contatoashanti/interactive-data-science-project" 2>/dev/null | grep "prickly-copper-64tb" || true)
        if [[ "$status_info" =~ "Stopping" ]]; then
            log_info "Studio is currently Stopping. Waiting for it to fully stop..."
            sleep 10
        else
            break
        fi
    done
    
    if [[ "$status_info" =~ "Running" ]] && [[ "$status_info" =~ "L4" ]]; then
        log_info "Studio is already running on GPU (L4). Bypassing boot/switch phase."
    elif [[ "$status_info" =~ "Running" ]]; then
        log_info "Studio is running on CPU. Switching to GPU (L4)..."
        "$LIGHTNING_CLI" studio switch --name "prickly-copper-64tb" --machine "L4" --teamspace "contatoashanti/interactive-data-science-project"
    else
        log_info "Studio is stopped. Waking up remote Lightning Studio on GPU (L4) machine in the background..."
        "$LIGHTNING_CLI" studio start --name "prickly-copper-64tb" --machine "L4" --teamspace "contatoashanti/interactive-data-science-project" &
        local start_pid=$!
        
        log_info "Waiting for Studio to transition to Running..."
        local attempts=0
        while true; do
            attempts=$((attempts + 1))
            local list_out
            list_out=$("$LIGHTNING_CLI" studio list --teamspace "contatoashanti/interactive-data-science-project" 2>/dev/null | grep "prickly-copper-64tb" || true)
            if [[ "$list_out" =~ "Running" ]]; then
                log_info "Studio has booted and is now Running."
                break
            fi
            if (( attempts > 24 )); then
                log_error "Studio failed to start after 2 minutes."
                kill "$start_pid" 2>/dev/null || true
                return 1
            fi
            log_info "Still waiting for Studio start (attempt $attempts)..."
            sleep 5
        done
    fi
    
    # Setup automatic cleanup trap to stop the Studio completely on exit (success, failure, or manual interrupt)
    cleanup_vps_hardware() {
        log_header "Deactivating Remote Hardware"
        log_info "Stopping Studio safely..."
        "$LIGHTNING_CLI" studio stop --name "prickly-copper-64tb" --teamspace "contatoashanti/interactive-data-science-project" || true
    }
    # trap cleanup_vps_hardware EXIT
    
    log_info "Waiting for remote Studio volume to fully mount..."
    local attempts=0
    # Attempt to run a basic check to ensure the persistent home volume is mounted and ready
    while ! ssh -o StrictHostKeyChecking=no "$REMOTE_SSH" "[ -f /home/zeus/content/.bashrc ]" &>/dev/null; do
        attempts=$((attempts + 1))
        if (( attempts > 24 )); then
            log_error "Studio volume failed to mount after 2 minutes."
            return 1
        fi
        log_info "Still waiting for filesystem mount (attempt $attempts)..."
        sleep 5
    done
    log_info "Studio volume is fully mounted and ready."
    
    # 1. Connect and initialize remote directories
    log_info "Connecting to VPS (${REMOTE_SSH}) and preparing workspace..."
    ssh -o StrictHostKeyChecking=no "$REMOTE_SSH" "mkdir -p tv_convert_tmp content/${REMOTE_TMP_DIR}"
    
    # 2. Upload transcoder script via SSH redirection directly to local ext4 partition
    log_info "Uploading transcoder script to VPS..."
    ssh -o StrictHostKeyChecking=no "$REMOTE_SSH" "cat > tv_convert_tmp/convert_tv.sh" < "$0"
    
    # 3. Upload target video via lightning studio cp directly to Cloud Storage
    log_info "Uploading input file to VPS..."
    "$LIGHTNING_CLI" studio cp "$abs_input" "lit://contatoashanti/interactive-data-science-project/studios/prickly-copper-64tb/tv_convert_tmp/"
    
    # 4. Trigger remote transcode (automatic GPU mode)
    log_info "Executing GPU-accelerated transcoding on VPS..."
    
    local -a cmd_args=("bash" "/home/zeus/tv_convert_tmp/convert_tv.sh" "--gpu" "--input" "$remote_input" "--output" "$remote_output" "--preset" "$PRESET")
    if [[ "$FAST_MODE" == "true" ]]; then
        cmd_args+=("--fast")
    fi
    
    local remote_cmd
    remote_cmd=$(printf '%q ' "${cmd_args[@]}")
    
    ssh -t -o StrictHostKeyChecking=no "$REMOTE_SSH" "${remote_cmd}"
    
    # 5. Download resulting MKV via lightning studio cp directly from Cloud Storage
    log_info "Downloading transcoded file from VPS..."
    "$LIGHTNING_CLI" studio cp "lit://contatoashanti/interactive-data-science-project/studios/prickly-copper-64tb/tv_convert_tmp/$(basename "$output")" "$abs_output"
    
    # 6. Cleanup remote workspace
    log_info "Cleaning up remote VPS scratchpad..."
    ssh -o StrictHostKeyChecking=no "$REMOTE_SSH" "rm -rf tv_convert_tmp content/${REMOTE_TMP_DIR}"
    
    log_info "Remote job completed successfully."
}

# --- Main Entry Point ---
main() {
    local input=""
    local output=""
    FAST_MODE="false"
    USE_GPU="false"
    REMOTE_MODE="false"
    DRY_RUN="false"
    local max_jobs=1
    
    # Parse Command Line Options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--input)
                input="$2"
                shift 2
                ;;
            -o|--output)
                output="$2"
                shift 2
                ;;
            -f|--fast)
                FAST_MODE="true"
                shift
                ;;
            -g|--gpu)
                USE_GPU="true"
                shift
                ;;
            -r|--remote)
                REMOTE_MODE="true"
                shift
                ;;
            -p|--preset)
                PRESET="$2"
                shift 2
                ;;
            -j|--jobs)
                max_jobs="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown argument: $1"
                show_help
                exit 1
        esac
    done
    
    # Verify local dependencies depending on remote/local execution modes
    check_local_dependencies
    
    # Validation
    if [[ -z "$input" ]]; then
        log_error "Input option (-i / --input) is required."
        show_help
        exit 1
    fi
    
    # Verification of input existence with support for remote FUSE/Overlay filesystem synchronization delays
    if [[ ! -e "$input" ]]; then
        log_info "Input file '$input' not immediately found. Waiting for FUSE synchronization..."
        local sync_attempts=0
        while [[ ! -e "$input" ]]; do
            sync_attempts=$((sync_attempts + 1))
            if (( sync_attempts > 12 )); then
                log_error "Input path '$input' does not exist."
                exit 1
            fi
            sleep 5
        done
        log_info "Input file '$input' detected after FUSE synchronization."
    fi
    
    # Handle Directory Processing
    if [[ -d "$input" ]]; then
        log_info "Processing directory: $input"
        
        # Collect video files
        local files=()
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find "$input" -maxdepth 1 -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" -o -name "*.m4v" -o -name "*.webm" \) -print0)
        
        if (( ${#files[@]} == 0 )); then
            log_warn "No video files found in '$input'."
            exit 0
        fi
        
        log_info "Found ${#files[@]} videos in directory."
        
        local active_jobs=0
        for f in "${files[@]}"; do
            # Compute output path
            local out_file
            if [[ -n "$output" ]]; then
                mkdir -p "$output"
                out_file="${output}/$(basename "${f%.*}")_TV_Compatible.mkv"
            else
                out_file="${f%.*}_TV_Compatible.mkv"
            fi
            
            # Execute job
            if [[ "$REMOTE_MODE" == "true" ]]; then
                # Remote execution does its own transfer, sequential is safer for network, but works in parallel too
                transcode_remote_vps "$f" "$out_file" &
            else
                transcode_single_file "$f" "$out_file" &
            fi
            
            ((active_jobs++))
            if (( active_jobs >= max_jobs )); then
                wait -n
                ((active_jobs--))
            fi
        done
        wait
        log_info "Batch processing directory completed."
        
    else
        # Handle Single File Processing
        if [[ -z "$output" ]]; then
            output="${input%.*}_TV_Compatible.mkv"
        fi
        
        if [[ "$REMOTE_MODE" == "true" ]]; then
            transcode_remote_vps "$input" "$output"
        else
            transcode_single_file "$input" "$output"
        fi
    fi
}

main "$@"
