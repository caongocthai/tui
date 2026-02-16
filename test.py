import time
import sys

# Beatles lyrics to display
songs = [
    "1. Hey Jude, don't make it bad",
    "2. Let it be, let it be",
    "3. Lucy in the sky with diamonds",
    "4. All you need is love",
    "5. Here comes the sun",
    "6. Yellow submarine, yellow submarine",
    "7. Yesterday, all my troubles seemed so far away",
    "8. I want to hold your hand",
    "9. Come together, right now",
    "10. Strawberry fields forever"
]

def draw_tui():
    # \x1b[2J = Clear entire screen
    # \x1b[H  = Move cursor to home (0,0)
    sys.stdout.write("\x1b[2J\x1b[H")
    
    # Draw a simple border
    print("\x1b[1;34m" + "="*45) # Blue bold text
    print("      THE BEATLES - TEXT INTERFACE")
    print("="*45 + "\x1b[0m")     # Reset color
    
    # Draw the lines
    for line in songs:
        # \x1b[32m = Green text
        sys.stdout.write(f"\x1b[32m║\x1b[0m  {line}\n")
    
    print("\x1b[1;34m" + "="*45 + "\x1b[0m")
    print("\nPress Ctrl+C to exit.")
    sys.stdout.flush()

try:
    draw_tui()
    # Keep the application "alive"
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("\nExiting...")
