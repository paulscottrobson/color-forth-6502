# ******************************************************************************
# ******************************************************************************
#
#		Name : 		genconst.py
#		Purpose : 	Generate constants file.
#		Author : 	Paul Robson (paul@robsons.org.uk)
#		Created : 	1st October 2019
#
# ******************************************************************************
# ******************************************************************************

cList = [ 	0,1,2,4,6,8,10,12,14,16,
			24,32,64,100,127,128,255,
			256,512,1024,2048,4096,
			32767,32768,-1
		]

print("; *** this file is created by genconst.py ***")
for c in cList:
	print("Constant_{0}: ;; [{1}]".format(str(c).replace("-","minus"),str(abs(c))+("-" if c<0 else "")))
	print("\t.pushconst {0}".format(c & 0xFFFF))	