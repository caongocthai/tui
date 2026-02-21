#!/usr/bin/env python

import cv2
import math
import os
import shutil
import sys

if len(sys.argv) < 2:
    print("Usage: python /path/to/image")
    exit(1)

image_path = sys.argv[1]
if not os.path.isfile(image_path):
    print(f"File at {image_path} doesn't exist")
    exit(1)

def get_tsize():
    t_size = shutil.get_terminal_size()
    return t_size.lines, t_size.columns

def get_image(image_path):
    img = cv2.imread(image_path)
    height, width = img.shape[:2]
    return img, height, width


def main():
    t_height, t_width = get_tsize()
    img, i_height, i_width = get_image(image_path)

    ratio = max(
        math.ceil(i_height/t_height), 
        math.ceil(i_width*2/t_width)
    )
    d_height, d_width = math.ceil(i_height/ratio), math.ceil(i_width/ratio) 

    print("\x1b[2J")
    for row in range(0, d_height):
        for col in range(0, d_width):
            pixel_count = 0
            total_b, total_g, total_r = 0, 0, 0
            for i_row in range(row*ratio, min((row+1)*ratio, i_height)):
                for i_col in range(col*ratio, min((col+1)*ratio, i_width)):
                    b, g, r = img[i_row, i_col]
                    total_b += int(b)
                    total_g += int(g)
                    total_r += int(r)
                    pixel_count += 1
            b, g, r = total_b//pixel_count, total_g//pixel_count, total_r//pixel_count
            print(f"\x1b[{row};{col*2}H\x1b[30m\x1b[48;2;{r};{g};{b}m  \x1b[0m")

if __name__ == "__main__":
    main()

