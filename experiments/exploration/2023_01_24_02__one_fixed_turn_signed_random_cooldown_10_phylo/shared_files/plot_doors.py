# Make sure pygame works
import pygame
pygame.init()

# Input
non_exit_doors = 3

# Constants
num_doors = non_exit_doors + 1
tile_size = 4
spacing = tile_size // 2
spacing_half = spacing // 2

# Load in data
max_len = 0
rep_list = []
with open('doors.txt', 'r') as fp:
    tmp_list = []
    for line in fp:
        if 'break' in line:
            if len(tmp_list) > max_len:
                max_len = len(tmp_list)
            rep_list.append(tmp_list)
            tmp_list = []
        else:
            line_parts = line.split()
            if len(line_parts) < 2:
                continue
            taken, expected = map(int, line_parts[1].split(','))
            tmp_list.append((taken, expected))
            
# Create surface
#   Width = just big enough to fit the largest replicate
#   Height = just big enough to fit each replicate + one line of padding
surf_width = tile_size * max_len
surf_height = tile_size * len(rep_list) * (num_doors + 1)
print('Creating image of size:', str(surf_width) + 'x' + str(surf_height))
surf = pygame.Surface((surf_width, surf_height))

for rep_idx in range(len(rep_list)):
    rep_y = rep_idx * tile_size * (num_doors + 1)
    for idx in range(len(rep_list[rep_idx])):
        # Draw blank tiles to show spacing
        for door_idx in range(num_doors):
            pygame.draw.rect(surf, (150,150,150), 
                    (idx * tile_size + spacing_half, 
                        rep_y + door_idx * tile_size + spacing_half, 
                        tile_size - spacing, 
                        tile_size - spacing))
        # Set color according to if answer was correct
        taken, expected = rep_list[rep_idx][idx]
        color = (150, 50, 25) 
        if taken == expected:
            color = (50, 150, 25)
        # Draw door taken as large, color-coordinated rectangle
        pygame.draw.rect(surf, color, 
                (idx * tile_size, rep_y + taken * tile_size, tile_size, tile_size))
        # Draw expected door as small yellow rectangle (perfectly overlaps spacing rect)
        pygame.draw.rect(surf, (200,200,25), 
                (idx * tile_size + spacing_half, 
                    rep_y + expected * tile_size + spacing_half, 
                    tile_size - spacing, 
                    tile_size - spacing))
pygame.image.save(surf, 'out.png')

