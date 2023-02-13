import pygame

extract_range = False
range_start = 375
range_end = 413
input_filename = '../data/seq_data.csv'
output_filename = '../data/seq_color.png'
#output_filename = '../data/seq_375_413_color.png'
multicolor = True
inst_map = {}
color_map = {}
inst_map['a'] = 'nop' 
inst_map['b'] = 'nop' 
inst_map['c'] = 'nop' 
inst_map['d'] = 'nop' 
inst_map['e'] = 'nop' 
inst_map['f'] = 'nop' 
inst_map['g'] = 'math' 
inst_map['h'] = 'math' 
inst_map['i'] = 'math' 
inst_map['j'] = 'math' 
inst_map['k'] = 'math' 
inst_map['l'] = 'math' 
inst_map['m'] = 'math' 
inst_map['n'] = 'flow' 
inst_map['o'] = 'flow' 
inst_map['p'] = 'flow' 
inst_map['q'] = 'flow' 
inst_map['r'] = 'flow' 
inst_map['s'] = 'flow' 
inst_map['t'] = 'flow' 
inst_map['u'] = 'flow' 
inst_map['v'] = 'flow' 
inst_map['w'] = 'flow' 
inst_map['x'] = 'flow' 
inst_map['y'] = 'manip' 
inst_map['z'] = 'manip' 
inst_map['A'] = 'manip' 
inst_map['B'] = 'manip' 
inst_map['C'] = 'manip' 
inst_map['D'] = 'manip' 
inst_map['E'] = 'manip' 
inst_map['F'] = 'manip' 
inst_map['G'] = 'repro' 
inst_map['H'] = 'env' 
inst_map['I'] = 'env' 
inst_map['J'] = 'env' 
inst_map['K'] = 'env' 
inst_map['L'] = 'env' 
inst_map['M'] = 'flow' 
inst_map['N'] = 'flow' 
inst_map['O'] = 'flow' 
inst_map['P'] = 'flow' 
inst_map['Q'] = 'flow' 
inst_map['R'] = 'flow' 
inst_map['S'] = 'flow' 

color_map['nop'] = (150,150,150)
color_map['math'] = (150,50,0)
color_map['flow'] = (150,150,0)
color_map['manip'] = (50,150,0)
color_map['env'] = (0,150,150)
color_map['repro'] = (0,0,150)


data = []

with open(input_filename, 'r') as fp:
    header = fp.readline()
    for line in fp:
        line = line.strip()
        line = line.replace('"', '')
        if line == '':
            continue
        line_parts = line.split(',')
        data.append(line_parts[1:])

if extract_range:
    data = data[range_start:(range_end+1)]

pygame.init()
screen_width = len(data[0])
screen_height = len(data)
surf = pygame.Surface((screen_width, screen_height))

empty_color = (0,0,0)
inst_color = (50, 150, 75)
mut_color = (50, 75, 150)

for row_idx, row in enumerate(data):
    for col_idx, char in enumerate(row):
        if char == '$':
            pygame.draw.rect(surf, empty_color, (col_idx, row_idx, 1, 1))
        else:
            color = inst_color
            if not multicolor and row_idx > 0 and data[row_idx-1][col_idx] != char:
                color = mut_color
            if multicolor:
                color = color_map[inst_map[char]]
            pygame.draw.rect(surf, color, (col_idx, row_idx, 1, 1))
pygame.image.save(surf, output_filename)
