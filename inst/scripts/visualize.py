import pymol
from pymol import cmd
from pymol.cgo import *
import string
import math
import sys
import pandas as pd
import re
# print('Enter "dots" to display Occluded Surface dots')
obj = []


def change():
    cmd.alter('name H', 'vdw=1.25 ')
    cmd.alter('name HZ1', 'vdw=1.20')
    cmd.alter('name HZ2', 'vdw=1.20')
    cmd.alter('name HZ3', 'vdw=1.20')
    cmd.alter('name HN', 'vdw=1.20')
    cmd.alter('name C', 'vdw=1.90')
    cmd.alter('name CA', 'vdw=1.90')
    cmd.alter('name CB', 'vdw=1.90')
    cmd.alter('name CG', 'vdw=1.90')
    cmd.alter('name CD', 'vdw=1.90')
    cmd.alter('name CE', 'vdw=1.90')
    cmd.alter('name CG1', 'vdw=1.90')
    cmd.alter('name CG2', 'vdw=1.90')
    cmd.alter('name CDT', 'vdw=1.90')
    cmd.alter('name CD1', 'vdw=1.90')
    cmd.alter('name CD2', 'vdw=1.90')
    cmd.alter('name CE1', 'vdw=1.90')
    cmd.alter('name CE2', 'vdw=1.90')
    cmd.alter('name O', 'vdw=1.70')
    cmd.alter('name OD1', 'vdw=1.70')
    cmd.alter('name OD2', 'vdw=1.70')
    cmd.alter('name OE1', 'vdw=1.70')
    cmd.alter('name OE2', 'vdw=1.70')
    cmd.alter('name OG', 'vdw=1.77')
    cmd.alter('name OG1', 'vdw=1.77')
    cmd.alter('name OH', 'vdw=1.77')
    cmd.alter('name OT1', 'vdw=1.70')
    cmd.alter('name OT2', 'vdw=1.70')
    cmd.alter('name OH2', 'vdw=1.77')
    cmd.alter('name N', 'vdw=1.85')
    cmd.alter('name ND1', 'vdw=1.85')
    cmd.alter('name ND2', 'vdw=1.85')
    cmd.alter('name NE1', 'vdw=1.85')
    cmd.alter('name NE', 'vdw=1.85')
    cmd.alter('name NE2', 'vdw=1.85')
    cmd.alter('name NH1', 'vdw=1.85')
    cmd.alter('name NH2', 'vdw=1.85')
    cmd.alter('name NL', 'vdw=1.85')
    cmd.alter('name NR', 'vdw=1.85')
    cmd.alter('name NT', 'vdw=1.85')
    cmd.alter('name NZ', 'vdw=1.85')
    cmd.alter('name NZT', 'vdw=1.85')
    cmd.alter('name S', 'vdw=2.00')
    cmd.alter('name SG', 'vdw=2.00')
    cmd.alter('name SD', 'vdw=2.00')
    cmd.alter('name OW', 'vdw=1.85')
    cmd.alter('name H1', 'vdw=1.00')
    cmd.alter('name H2', 'vdw=1.00')
    cmd.alter('name H1', 'vdw=1.00')
    cmd.alter('name H2', 'vdw=1.00')
    cmd.alter('name ZN', 'vdw=1.35')
    cmd.alter('name FE', 'vdw=0.64')
    cmd.rebuild('all', 'spheres')


def dots_visualize(raydist, selection='all', name=''):
    col_r = 0.00
    col_g = 0.60
    col_b = 0.20
    radius = 0.2

    for i in range(0,len(raydist.iloc[:,1])):
        x1 = raydist.iloc[i,3]
        y1 = raydist.iloc[i,4]
        z1 = raydist.iloc[i,5]
        x2 = x1 + (0.05 * raydist.iloc[i,8])
        y2 = y1 + (0.05 * raydist.iloc[i,9])
        z2 = z1 + (0.05 * raydist.iloc[i,10])
        obj.extend([CYLINDER, x1, y1, z1, x2, y2, z2, radius, col_r, col_g, col_b, col_r, col_g, col_b])
    cmd.load_cgo(obj, 'dots_visualize')
#    cmd.extend("dots",dots_visualize)
def rays_visualize(raydist,selection='all',name=''):
    col_r = 0.00
    col_g = 0.60
    col_b = 0.20
    radius = 0.1

    for i in range(0,len(raydist['B'])):
        x1 = raydist.iloc[i,3]
        y1 = raydist.iloc[i,4]
        z1 = raydist.iloc[i,5]
        x2 = x1 + (2.8 * raydist.iloc[i,6] * raydist.iloc[i,8])
        y2 = y1 + (2.8 * raydist.iloc[i,6] * raydist.iloc[i,9])
        z2 = z1 + (2.8 * raydist.iloc[i,6] * raydist.iloc[i,10])
        obj.extend([ CYLINDER,x1,y1,z1,x2,y2,z2,radius,col_r,col_g,col_b,col_r,col_g,col_b ])
    cmd.load_cgo(obj,'rays_visualize')

def open_pymol_view(pdb):
    pymol.finish_launching()
    pymol.cmd.fetch(pdb)
    pymol.cmd.show("spheres")
    # Abra a janela de visualização 3D do PyMOL
#    pymol.cmd.viewport(800, 600)  # Defina o tamanho da janela de visualização
#    pymol.cmd.save("teste.pml")
#    pymol.cmd.orient()  # Alinhe a vista 3D


def pymol_visualize(raydist, pdb, type_visualization):
        open_pymol_view(pdb)
        change()
        if (type_visualization.upper() == "DOTS"):
            dots_visualize(raydist)
        else:
            rays_visualize(raydist)

def read_Disp(raydist_file):
    lines = []
    name_columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M']
    with open(raydist_file,"r") as rfile:
        for item in rfile:
            item = re.sub(r',', ' ', item)
            lines.append(item)
    raydist = pd.DataFrame(lines, columns = ['TEMP'])
    raydist = raydist['TEMP'].str.split(' ', expand=True)
    raydist.columns = name_columns
    raydist['D'] = raydist['D'].astype(float)
    raydist['E'] = raydist['E'].astype(float)
    raydist['F'] = raydist['F'].astype(float)
    raydist['G'] = raydist['G'].astype(float)
    raydist['H'] = raydist['H'].astype(float)
    raydist['I'] = raydist['I'].astype(float)
    raydist['J'] = raydist['J'].astype(float)
    raydist['K'] = raydist['K'].astype(float)
    return raydist
if __name__ == '__main__':
    parametros = sys.argv
    raydist = read_Disp("plot.tmp")
    pymol_visualize(raydist, parametros[1], parametros[2])
