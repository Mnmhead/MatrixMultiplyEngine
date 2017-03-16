# This script generates test vectors for functional simulation

DEBUG = False
#DEBUG = True

import argparse
import os
import random

IN_FN = "input_matrix.mif"
W_FN = "weight_matrix.mif"
OUT_FN = "out_matrix.mif"

#################################################
# Input generation
#################################################

# This function generates add/mult input/output vectors
def generate_op_inputs(args):
   in_list = []
   in_list_strs = []
   w_list = []
   w_list_strs = []
   out_list_strs = []

   if not args.nondet:
      random.seed(0xDEADBEEF)

   # generate input matrix (A)
   debugPrint( "MATRIX A: " + str(args.m) + " by " + str(args.length) )
   for i in range(args.m):
      row_a = []
      row_a_str = ""
      for j in range(args.length):
         el = random.randrange(0, (1<<(args.widthA)))
         elStr = ("{:0" + str(args.widthA / 4) + "X}").format(el)
         row_a.append(el)
         row_a_str = row_a_str + elStr

      debugPrint(row_a)
      debugPrint(row_a_str)

      row_a_str = row_a_str + "\n"
      in_list.append(row_a)
      in_list_strs.append(row_a_str)

   with open(os.path.join(args.dest_dir, IN_FN), 'w') as f:
      for elem in in_list_strs:
         f.write(elem)

   # generate weights matrix (B)
   debugPrint( "MATRIX B: " + str(args.o) + " by " + str(args.length) )
   for i in range(args.o):
      col_b = []
      col_b_str = ""
      for j in range(args.length):
         el = random.randrange(0, (1<<(args.widthB)))
         elStr = ("{:0" + str(args.widthB / 4) + "X}").format(el)
         col_b.append(el)
         col_b_str = col_b_str + elStr

      debugPrint(col_b)
      debugPrint(col_b_str)

      col_b_str = col_b_str + "\n"
      w_list.append(col_b)
      w_list_strs.append(col_b_str)

   with open(os.path.join(args.dest_dir, W_FN), 'w') as f:
      for elem in w_list_strs:
         f.write(elem)

   # compute and generate output matrix (C)
   debugPrint( "MATRIX C: " + str(args.m) + " by " + str(args.o) )
   for a in range(args.m):
      a_row = in_list[a]
      c_row = []
      c_row_str = ""
      widthC = 16  # for now, change this later

      for b in range(args.o):
         b_col = w_list[b]
         dp = dotProduct(a_row, b_col, args.length)
         c_row.append(dp)
         c_el_str = ("{:0" + str(widthC / 4) + "X}").format(dp)
         c_row_str = c_row_str + c_el_str

      debugPrint(c_row)
      debugPrint(c_row_str)

      c_row_str = c_row_str + "\n"
      out_list_strs.append(c_row_str)

   with open(os.path.join(args.dest_dir, OUT_FN), 'w') as f:
      for elem in out_list_strs:
         f.write(elem)

#################################################
# Helper Functions
#################################################

def dotProduct(row, col, length):
   dp = 0
   for i in range(length):
      dp = dp + (row[i] * col[i])			

   return dp

def debugPrint(s):
   global DEBUG
   if DEBUG:
      print(s)

#################################################
# Argument validation
#################################################

def cli():
    parser = argparse.ArgumentParser(
        description='Generates test bit vectors'
    )
    parser.add_argument(
        '-dst', dest='dest_dir', action='store', type=str, required=False,
        default=".", help='Destination directory'
    )
    parser.add_argument(
        '-r', dest='nondet', action='store_true', required=False,
        default=False, help='Random seeding'
    )
    parser.add_argument(
        '-wa', dest='widthA', action='store', type=int, required=False,
        default=4, help='Data width of elements in matrix A'
    )
    parser.add_argument(
        '-wb', dest='widthB', action='store', type=int, required=False,
        default=8, help='Data width of elements in matrix B'
    )
    parser.add_argument(
        '-n', dest='length', action='store', type=int, required=False,
        default=4, help='Dimension N if A*B is [MxN]*[N*O]'
    )
    parser.add_argument(
        '-m', dest='m', action='store', type=int, required=False,
        default=8, help='Dimension M if A*B is [MxN]*[N*O]'
    )
    parser.add_argument(
        '-o', dest='o', action='store', type=int, required=False,
        default=8, help='Dimension O if A*B is [MxN]*[N*O]'
    )
 
    args = parser.parse_args()

    # Argument validation
    if (not os.path.isdir(args.dest_dir)):
        print "ERROR: dst={} is not a valid path".format(args.dest_dir)
        exit()
    if (args.widthA > 64 or args.widthB > 64):
        print "ERROR: w={} is greater than 64!".format(args.width)
        exit()

    generate_op_inputs(args)
    
if __name__ == '__main__':
    cli()
