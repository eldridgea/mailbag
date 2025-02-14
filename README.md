# Mailbag #

A small script to leverage `whisper` to auto subtitle a video and burn the subtitles in.
Aimed at videos targeting verital video platforms like TikTok.

## Instructions
1. Ensure you have `python3`, `python3-venv`, and `ffmpeg` installed
1. Clone this repository or download the [bash script directly](https://raw.githubusercontent.com/eldridgea/mailbag/refs/heads/main/mailbag.sh)
1. Run `./mailbag.sh YOUR_VIDEO_FILE.MP4`


## Notes
* The first run will take longer than subsequent ones
* The subtitled file will be placed in the same directory as the original file and named `YOUR_VIDEO_FILE_subtitled.MP4` 
* It's called mailbag because it's for _post_ processing
