from random import randint

def generateVectors( dim, bit_width ):
   vectorA_tuple = generateVector(dim, bit_width)
   vectorA_str = vectorA_tuple[1]
   vectorA = vectorA_tuple[0]

   vectorB_tuple = generateVector(dim, bit_width)
   vectorB_str = vectorB_tuple[1]
   vectorB = vectorB_tuple[0]

   dot_prod = 0
   for i in range(0,dim):
      dot_prod += vectorA[i] * vectorB[i]

   print "A = " + str(dim*bit_width) + "\'b" + vectorA_str + ";"
   print "B = " + str(dim*bit_width) + "\'b" + vectorB_str + ";"
   print "// Expected result = " + str(dot_prod)
   print "@(posedge Clock)"
   print "@(posedge Clock)"

def generateVector( dim, bit_width ):
   max_num = pow(2, bit_width)-1
   formatStr = '0' + str(bit_width) + 'b'
   
   vectorStr = ""
   vector = []
   for i in range(0, dim):
      el = randint(0,max_num)
      vector.append(el)
      vectorStr = vectorStr + format(el, formatStr)


   return (vector,vectorStr)

def gen():
   for i in range(0,10):
      generateVectors( 10, 16 )

gen()
