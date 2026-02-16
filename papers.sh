#!/usr/bin/env bash

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

draw_menu() {
  # read output to 2 variables. <<< "24 80"
  # <  Input Redirection: Reads from a file (e.g., read < file.txt).
  # << Here Document: Reads a multi-line block of text from the script itself. EOF. Read untill seeing "24 80"
  # <<< Here String: Reads a single string (variable or command result).
  read -r cols lines <<< $(get_tsize)

  # 2J: clear. ${lines}H: move cursor to first col in $lines row
  printf "\x1b[2J\x1b[${lines}H"
  printf '\x1b[34m=======================================\n'
  printf '                  PAPERS\n'
  printf '=======================================\n\x1b[0m'

  printf '\x1b[32m ║ \x1b[0m 1. Hello how are you?\n'
  printf '\x1b[32m ║ \x1b[0m 2. Im fine\n'

  i=$1
  j=1
  line='='
  while [ $j -lt $i ]; do
    line="${line}=" 
    ((j++))
  done
  printf "\x1b[34m${line}\x1b[0m\n\n"
  printf 'Press Ctrl+C to exit.\n'
}

i=1
while True; do
  draw_menu $i
  ((i++))
  if [ $i -eq 40 ]; then
    sleep 2
    i=1
  fi
  sleep 0.2
done

