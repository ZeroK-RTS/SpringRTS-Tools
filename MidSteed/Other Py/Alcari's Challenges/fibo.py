import sys
def seele(square=1, circle=1):
     ans = square + circle
     yield ans
     circle = square
     square = ans
linecount = 1
for angelcount in seele():
    if linecount < 300:
        print angelcount
        linecount += 1
    else:
        sys.exit()
