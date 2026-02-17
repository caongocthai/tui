#!/usr/bin/env bash

# We define the transition phases: 
# 1. Red -> Yellow (Increase Green)
# 2. Yellow -> Green (Decrease Red)
# 3. Green -> Cyan (Increase Blue)
# 4. Cyan -> Blue (Decrease Green)
# 5. Blue -> Magenta (Increase Red)
# 6. Magenta -> Red (Decrease Blue)

r=255
g=0
b=0
step=10  # Adjust this to change speed (smaller = smoother/slower)

# A function to print the line
print_line() {
    printf "\x1b[30m\x1b[48;2;%s;%s;%sm Hello RGB: %3s %3s %3s \x1b[0m\n" "$1" "$2" "$3" "$1" "$2" "$3"
}

while true; do
    # 1. Red to Yellow (Increasing Green)
    for ((g=0; g<=255; g+=step)); do print_line $r $g $b; done
    g=255
    
    # 2. Yellow to Green (Decreasing Red)
    for ((r=255; r>=0; r-=step)); do print_line $r $g $b; done
    r=0
    
    # 3. Green to Cyan (Increasing Blue)
    for ((b=0; b<=255; b+=step)); do print_line $r $g $b; done
    b=255
    
    # 4. Cyan to Blue (Decreasing Green)
    for ((g=255; g>=0; g-=step)); do print_line $r $g $b; done
    g=0
    
    # 5. Blue to Magenta (Increasing Red)
    for ((r=0; r<=255; r+=step)); do print_line $r $g $b; done
    r=255
    
    # 6. Magenta to Red (Decreasing Blue)
    for ((b=255; b>=0; b-=step)); do print_line $r $g $b; done
    b=0
    
    # Optional: break after one full cycle
    break 
done
