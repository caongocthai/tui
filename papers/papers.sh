#!/usr/bin/env bash

IFS= read -d '' -r header <<"EOF"
██████╗  █████╗ ██████╗ ███████╗██████╗ ███████╗
██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝
██████╔╝███████║██████╔╝█████╗  ██████╔╝███████╗
██╔═══╝ ██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
██║     ██║  ██║██║     ███████╗██║  ██║███████║
╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝
EOF
header_height=$(printf "%s" "$header" | wc -l)
header_width=48

IFS= read -d '' -r papers <<"EOF"
What Every Programmer Should Know About Memory,https://people.freebsd.org/~lstewart/articles/cpumemory.pdf,false
Time Clocks and the Ordering of Events in a Distributed System,https://lamport.azurewebsites.net/pubs/time-clocks.pdf,false
The Case for Shared Nothing,https://dsf.berkeley.edu/papers/hpts85-nothing.pdf,false
The Google File System,https://static.googleusercontent.com/media/research.google.com/en//archive/gfs-sosp2003.pdf,false
CAP Twelve Years Later: How the Rules Have Changed,https://sites.cs.ucsb.edu/~rich/class/cs293b-cloud/papers/brewer-cap.pdf,false
ZooKeeper: Wait-free coordination for Internet-scale systems,https://www.usenix.org/legacy/event/atc10/tech/full_papers/Hunt.pdf,false
Reflections on Trusting Trust,https://www.cs.cmu.edu/~rdriley/487/papers/Thompson_1984_ReflectionsonTrustingTrust.pdf,false
Internet Routing Instability,https://www.cs.princeton.edu/courses/archive/fall20/cos461/papers/BGPstability98.pdf,false
A Scalable Commodity Data Center Network Architecture,http://ccr.sigcomm.org/online/files/p63-alfares.pdf,false
The Design and Implementation of a Log-Structured File System,https://people.eecs.berkeley.edu/~brewer/cs262/LFS.pdf,false
The UNIX Time-Sharing System,https://courses.cs.washington.edu/courses/cse550/20au/papers/CSE550.UNIX-Timesharing.pdf,false
Why Functional Programming Matters,https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf,false
Why Threads Are A Bad Idea (for most purposes),https://sites.cc.gatech.edu/classes/AY2010/cs4210_fall/papers/ousterhout-threads.pdf,false
Modern Microprocessors A 90-Minute Guide!,https://www.lighterra.com/papers/modernmicroprocessors,false
False Sharing,https://docs.kernel.org/kernel-hacking/false-sharing.html,false
Scalability! But at what COST?,https://www.usenix.org/system/files/conference/hotos15/hotos15-paper-mcsherry.pdf,false
Dynamo: Amazon’s Highly Available Key-value Store,https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf,true
Large-scale cluster management at Google with Borg,https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/43438.pdf,false
Out of the Tar Pit,https://curtclifton.net/papers/MoseleyMarks06a.pdf,false
The BSD Packet Filter: A New Architecture for User-level Packet Capture,https://www.tcpdump.org/papers/bpf-usenix93.pdf,false
Scaling Memcache at Facebook,https://www.usenix.org/system/files/conference/nsdi13/nsdi13-final170_update.pdf,false
The Tail at Scale,https://www.barroso.org/publications/TheTailAtScale.pdf,false
TAO: Facebook’s Distributed Data Store for the Social Graph,https://www.usenix.org/system/files/conference/atc13/atc13-bronson.pdf,false
Spanner: Google’s Globally-Distributed Database,https://www.usenix.org/system/files/conference/osdi12/osdi12-final-16.pdf,false
Caching for a Global Netflix,https://netflixtechblog.com/caching-for-a-global-netflix-7bcc457012f1,false
A large scale analysis of hundreds of in-memory cache clusters at Twitter,https://www.usenix.org/system/files/osdi20-yang.pdf,false
EOF

paper_count=$(printf "%s" "$papers" | wc -l)

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

draw_header() {
  header_line=$(((lines/2 - paper_count/2)/2))
  header_col=$((cols/2 - header_width/2))
  while IFS= read -r line; do
    printf "\x1b[%s;%sH\x1b[36m%s\x1b[0m" "$header_line" "$header_col" "$line"
    header_line=$((header_line+1))
  done <<< "$header"
}

draw_static() {
  # 2J: clear. ${lines}H: move cursor to first col in $lines row
  printf "\x1b[2J\x1b[0H"

  total_block=$((lines*2 + cols*2 - 4 + 1)) # Add 1 to not facing divided by 0 at the end
  total_color=1536 # 256*6
  color_step=$((total_color / total_block))
  color_used=0
  block_used=0

  colors=(0 255 0)
  current_color=0
  step_mul=1
  for ((x=1; x<cols; x++)); do
    printf "\x1b[48;2;%s;%s;%sm \x1b[0m" ${colors[@]}
    colors[current_color]=$((colors[current_color] + step_mul * color_step))
    ((block_used++))
    color_used=$((color_used + color_step))
    color_step=$(( (total_color - color_used) / (total_block-block_used) ))
    if [[ ${colors[current_color]} -gt 255 ]]; then
      colors[current_color]=255
      current_color=$(( (current_color+1) % 3 ))
      step_mul=$((step_mul * -1))
    elif [[ ${colors[current_color]} -lt 0 ]]; then
      colors[current_color]=0
      current_color=$(( (current_color+1) % 3 ))
      step_mul=$((step_mul * -1))
    fi
  done
  for ((y=1; y<lines; y++)); do
    printf "\x1b[%s;%sH\x1b[48;2;%s;%s;%sm  \x1b[0m" $y $((cols - 1)) ${colors[@]}
    colors[current_color]=$((colors[current_color] + step_mul * color_step))
    ((block_used++))
    color_used=$((color_used + color_step))
    color_step=$(( (total_color - color_used) / (total_block-block_used) ))
    if [[ ${colors[current_color]} -gt 255 ]]; then
      colors[current_color]=255
      current_color=$(( (current_color+1) % 3 ))
      step_mul=$((step_mul * -1))
    elif [[ ${colors[current_color]} -lt 0 ]]; then
      colors[current_color]=0
      current_color=$(( (current_color+1) % 3 ))
      step_mul=$((step_mul * -1))
    fi
  done
  for ((x=cols; x>1; x--)); do
    printf "\x1b[%s;%sH\x1b[48;2;%s;%s;%sm \x1b[0m" $lines $x ${colors[@]}
    colors[current_color]=$((colors[current_color] + step_mul * color_step))
    ((block_used++))
    color_used=$((color_used + color_step))
    color_step=$(( (total_color - color_used) / (total_block-block_used) ))
    if [[ ${colors[current_color]} -gt 255 ]]; then
      colors[current_color]=255
      current_color=$(( (current_color+1) % 3 ))
      step_mul=$((step_mul * -1))
    elif [[ ${colors[current_color]} -lt 0 ]]; then
      colors[current_color]=0
      current_color=$(( (current_color+1) % 3 ))
      step_mul=$((step_mul * -1))
    fi
  done
  for ((y=lines; y>1; y--)); do
    printf "\x1b[%sH\x1b[48;2;%s;%s;%sm  \x1b[0m" $y ${colors[@]}
    colors[current_color]=$((colors[current_color] + step_mul * color_step))
    ((block_used++))
    color_used=$((color_used + color_step))
    color_step=$(( (total_color - color_used) / (total_block-block_used) ))
    if [[ ${colors[current_color]} -gt 255 ]]; then
      colors[current_color]=255
      current_color=$(( (current_color+1) % 3 ))
      step_mul=$((step_mul * -1))
    elif [[ ${colors[current_color]} -lt 0 ]]; then
      colors[current_color]=0
      current_color=$(( (current_color+1) % 3 ))
      step_mul=$((step_mul * -1))
    fi
  done

  draw_header
}

draw_menu() {
  printf "\x1b[$((lines - paper_count - 3));7H"
  first_line=$((lines/2 + header_height - paper_count/2))

  i=1
  selected=$1
  while IFS= read -r line; do
    if [[ -z $line ]]; then
      continue
    fi
    while IFS="," read -r name link completed; do
      if [[ $i -eq $selected ]]; then
        printf "\x1b[$((first_line + i));3H\x1b[33m    %02d ${name}\x1b[0m\n" $i
      else
        printf "\x1b[$((first_line + i));3H\x1b[0m    %02d ${name}\n" $i
      fi
    done <<< "$line"
    ((i++))
  done <<< "$papers"

  printf "\x1b[$((lines-1));3HPress Ctrl+C to exit.\n"

  printf "\x1b[$((first_line + selected));4H->"
  printf "\x1b[999H"
}

cleanup() {
  printf '\x1b[2J\x1b[H'
}

play_bg_music() {
  if ! command -v mpv &>/dev/null; then
    (HOMEBREW_NO_AUTO_UPDATE=1 brew install mpv yt-dlp > /dev/null 2>&1 && mpv --no-video "https://www.youtube.com/watch?v=jfKfPfyJRdk" > /dev/null 2>&1) &
  else
    mpv --no-video "https://www.youtube.com/watch?v=jfKfPfyJRdk" > /dev/null 2>&1 &
  fi
}

open_paper() {
  i=1
  paper_url=''
  while IFS= read -r line; do
    if [[ $i -lt $1 ]]; then
      ((i++))
      continue
    fi
    while IFS=',' read -r name url completed; do
      paper_url=$url
    done <<< "$line"
    break
  done <<< "$papers"

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open $paper_url > /dev/null 2>&1 &
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    open $paper_url > /dev/null 2>&1 &
  elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    explorer.exe $paper_url > /dev/null 2>&1 &
  fi
}

selected=1

window_resize() {
  read -r cols lines <<< $(get_tsize)
  draw_static
  draw_menu $selected
}

main() {
  play_bg_music
  draw_static

  draw_menu $selected
  trap cleanup exit
  trap window_resize SIGWINCH
  while read -rs -n 1 input < /dev/tty; do
  # < /dev/tty here because curl "" | bash make stdin be the file, not terminal
    if [[ "$input" == "k" && $selected -gt 1 ]]; then
      ((selected--))
      draw_menu $selected
    elif [[ "$input" == "j" && $selected -lt $paper_count ]]; then
      ((selected++))
      draw_menu $selected
    elif [[ "$input" == "" ]]; then
      open_paper $selected
    fi
  done
}

main

