#!/bin/bash
##### Customize the settings in this section to format the subtitles  #####
FONTSIZE=12
PRIMARYCOLOR="FFFFFF"
FONTNAME="Arial"
MARGINV=50
##### End subtitle formatting #####

##### Enviornment settings #####
INPUT_FILE=$1
OUTPUT_FILE="${INPUT_FILE%.*}_subtitled.${INPUT_FILE##*.}"
CONFIG_DIR=$HOME/.config/mailbag
##### End enviornment settings #####

function process_file {
    mkdir .tmp
    echo "Extracting audio..."
    ffmpeg -hide_banner -loglevel error -i "$INPUT_FILE" -vn -acodec pcm_s16le -ar 16000 -ac 1 .tmp/input_audio.wav >/dev/null 2>&1
    echo "Transcribing..."
    "$CONFIG_DIR/bin/whisper" .tmp/input_audio.wav --model medium --language English --task transcribe --output_format srt --output_dir .tmp >/dev/null 2>&1
    echo "Burning in subtitles..."
    ffmpeg -hide_banner -loglevel error -i "$INPUT_FILE"  -vf "subtitles=.tmp/input_audio.srt:force_style='Fontname=$FONTNAME,Fontsize=$FONTSIZE,PrimaryColour=&H$PRIMARYCOLOR&,BackColour=&H80000000&,BorderStyle=3,Alignment=2,MarginV=$MARGINV'" -c:a copy "$OUTPUT_FILE"
    echo "Cleaning up..."
    rm -rf .tmp/
}

function first_run_check {
    if [ -d "$CONFIG_DIR" ]; then
        :
    else
        if command -v python3 &>/dev/null && command -v ffmpeg &>/dev/null; then
            echo "First run detected. Setting up python enviornment..."
            python3 -m venv "$CONFIG_DIR" >/dev/null 2>&1
            "$CONFIG_DIR/bin/pip" install openai-whisper >/dev/null 2>&1
            echo "Setup complete"
        else
            echo "Please ensure ffmpeg, python, and python3-venv are installed"
            exit 1
        fi
    fi
}

first_run_check
process_file
