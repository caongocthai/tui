#!/usr/bin/env bash

IFS= read -d '' -r logo << "EOF"
██████╗ ██╗   ██╗██████╗
██╔══██╗██║   ██║██╔══██╗
██║  ██║██║   ██║██║  ██║
██║  ██║╚██╗ ██╔╝██║  ██║
██████╔╝ ╚████╔╝ ██████╔╝
╚═════╝   ╚═══╝  ╚═════╝
    ▄▄▄██████████▄▄▄
 ▄██▀▀   VIDEO   ▀▀██▄
 ▀▀██▄▄          ▄▄▄█▀▀
    ▀▀███████████▀▀
EOF

logo_height=10
logo_width=25

get_tsize() {
  # 1. Save Cursor: \x1b7 (Save current position so we don't lose our place).
  # 2. Move to Edge: \x1b[999;999H (Try to go to row 999, col 999).
  # 3. Query Position: \x1b[6n (Ask "Where did you land?").
  # 4. Restore Cursor: \x1b8 (Jump back to where we started).
  # It returns \x1b[24;80R
  # read -sd -R: read silently untill char R then put \x1b[24;80 to POS
  # /dev/tty is used because in draw_menu we read on this function, so we have to write to /dev/tty and read from /dev/tty to POS
  printf "\x1b7\x1b[999;999H\x1b[6n\x1b8" > /dev/tty && read -sd R POS < /dev/tty
  # POS#*[ find first match for *[ then remove prefix
  SIZE=${POS#*[}
  cols=${SIZE#*;}
  # SIZE%;* find last match for ;* then remove suffix
  lines=${SIZE%;*}
  echo "$cols" "$lines"
}

# read output to 2 variables. <<< "24 80"
# <  Input Redirection: Reads from a file (e.g., read < file.txt).
# << Here Document: Reads a multi-line block of text from the script itself. EOF. Read untill seeing "24 80"
# <<< Here String: Reads a single string (variable or command result).
read -r cols lines <<< $(get_tsize)

draw_screen() {
  local color=31
  local pos_r=1
  local pos_c=1
  local vel_r=1
  local vel_c=2
  while true; do
    printf "\x1b[2J\x1b[0H"

    if (( (pos_r + logo_height - 1) > lines )); then
      pos_r=$((lines - logo_heigh + 1))
    fi
    if (( (pos_c + logo_width - 1) > cols )); then
      pos_c=$((cols - logo_width + 1))
    fi

    local is_edge=0
    if [[ $pos_r -eq 1 && vel_r -eq -1 ]]; then
      is_edge=1
      vel_r=1
    elif [[ "$((pos_r + logo_height - 1))" == "$lines" && vel_r -eq 1 ]]; then
      is_edge=1
      vel_r=-1
    fi

    if (( $pos_c <= 1 && vel_c < 0 )); then
      pos_c=1
      is_edge=1
      vel_c=2
    elif (( (pos_c + logo_width - 1) >= cols && vel_c > 0 )); then
      is_edge=1
      vel_c=-2
    fi

    if [[ $color -eq 37 ]]; then
        color=31
    fi

    local r=$pos_r
    while IFS= read -r line; do
      printf "\x1b[%s;%sH" "$r" "$pos_c"
      printf "\x1b[%sm%s\x1b[0m" "$color" "$line"
      ((r++))
    done <<< "$logo"
    printf "\x1b[H"
    pos_r=$((pos_r + vel_r))
    pos_c=$((pos_c + vel_c))
    if [[ $is_edge -eq 1 ]]; then
      ((color++))
    fi
    sleep 0.1
  done
}

play_bg_music() {
  if ! command -v mpv &>/dev/null; then
    (HOMEBREW_NO_AUTO_UPDATE=1 brew install mpv yt-dlp > /dev/null 2>&1 && mpv --no-video "https://www.youtube.com/watch?v=jfKfPfyJRdk" > /dev/null 2>&1) &
  else
    mpv --no-video "https://www.youtube.com/watch?v=jfKfPfyJRdk" > /dev/null 2>&1 &
  fi
}

window_resize() {
  read -r cols lines <<< $(get_tsize)
}

cleanup() {
  printf "\x1b[2J"
}

main() {
  trap cleanup exit
  trap window_resize SIGWINCH

  play_bg_music

  draw_screen
}

main

