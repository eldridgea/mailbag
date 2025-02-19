#!/bin/bash
##### Customize the settings in this section to format the subtitles  #####
FONTSIZE=10
PRIMARYCOLOR="FFFFFF"
FONTNAME="Arial"
MARGINV=50
##### End subtitle formatting #####

##### Enviornment settings #####
INPUT_FILE=$1
OUTPUT_FILE="${INPUT_FILE%.*}_subtitled.${INPUT_FILE##*.}"
CONFIG_DIR=$HOME/.config/mailbag
##### End enviornment settings #####

function english_to_mandarin {
    input=$1
    translation=`curl -s http://localhost:11434/api/chat -d '{
        "model": "7shi/llama-translate:8b-q4_K_M",
         "messages": [
             {
                 "role": "user",
                 "content": "### Instruction: Translate English to Mandarin. ### Input: $input ### Response:"
             }
         ],
         "stream": false
    }'`
    echo "$translation" | jq '.message.content' | tr -d '"'
}



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


if [ "$#" -eq 1 ]; then
    first_run_check
    process_file
else
    echo "You need to pass in a input video file. e.g."
    echo "$ ./mailbag.sh VIDEO.mp4"
fi
