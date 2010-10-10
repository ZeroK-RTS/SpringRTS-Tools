def roombadecode(msg, rseed, rows, cols, matracoef):
	print "Initializing RoombaFunction Cryptosystem Decoder"
	print "ciphertext: " + str(msg)
	print "key: " + str((rseed, rows, cols, matracoef))
	import random


	print "\n\nGenerating Code Matrix #2 From Key..."
	random.seed(rseed)
	invmatrix = []
	multmatrix = []
	msg2 = []
	for number in xrange(0,9):
		invmatrix.append(random.randint((-1*matracoef), (matracoef)))
		print "invmatrix position " + str(number + 1) + " set to " + str(invmatrix[number]) +"."
		
	print "\n\nNow Inverting and Multiplying..."
	det = float((invmatrix[0]*invmatrix[4]*invmatrix[8]+invmatrix[1]*invmatrix[5]*invmatrix[6]+invmatrix[2]*invmatrix[3]*invmatrix[7])- (invmatrix[2]*invmatrix[4]*invmatrix[6]+invmatrix[0]*invmatrix[5]*invmatrix[7]+invmatrix[1]*invmatrix[3]*invmatrix[8]))
	print det
	if (det == 0):
		return "Matrix determinant = 0. Aborting."
	multmatrix.append((invmatrix[4]*invmatrix[8] - invmatrix[7]*invmatrix[5])/det)
	multmatrix.append((invmatrix[7]*invmatrix[2] - invmatrix[1]*invmatrix[8])/det)
	multmatrix.append((invmatrix[1]*invmatrix[5] - invmatrix[4]*invmatrix[2])/det)
	multmatrix.append((invmatrix[6]*invmatrix[5] - invmatrix[3]*invmatrix[8])/det)
	multmatrix.append((invmatrix[0]*invmatrix[8] - invmatrix[6]*invmatrix[2])/det)
	multmatrix.append((invmatrix[3]*invmatrix[2] - invmatrix[0]*invmatrix[5])/det)
	multmatrix.append((invmatrix[3]*invmatrix[7] - invmatrix[6]*invmatrix[4])/det)
	multmatrix.append((invmatrix[6]*invmatrix[1] - invmatrix[0]*invmatrix[7])/det)
	multmatrix.append((invmatrix[0]*invmatrix[4] - invmatrix[3]*invmatrix[1])/det)

	for inc in xrange(0,len(msg)/3):
		i = inc*3	
		msg2.append(msg[i]*multmatrix[0]+msg[i+1]*multmatrix[3]+msg[i+2]*multmatrix[6])
		msg2.append(msg[i]*multmatrix[1]+msg[i+1]*multmatrix[4]+msg[i+2]*multmatrix[7])
		msg2.append(msg[i]*multmatrix[2]+msg[i+1]*multmatrix[5]+msg[i+2]*multmatrix[8])
	
	
	print 
	for number in xrange(0,len(msg2)):
		msg2[number] = int(round(msg2[number]))
	while 0 in msg2:
		msg2.remove(0) #remove padding
	
	print "\n\nShuffling Alphabet From Key..."
	random.seed(rseed)
	alphalist = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",0,1,2,3,4,5,6,7,8,9," ","-",",",".","!","?"]
	random.shuffle(alphalist)
	print "Shuffled alphabet list:"
	print alphalist

	print "\nLoading Alphabet Into Coding Matrix #1..."
	if (rows*cols == 42):
		alphatable = {}
		x = 1
		y = 1
		for letter in alphalist:
			if (x == (cols+1)):
				x =  1
				y += 1
			alphatable[x,y] = letter
			print "filling in " + str(x) + "," + str(y)
			x += 1
		print "Step 2: Loading Alphabet Into Coding Matrix #1 completed successfully."
		print "42 space matrix loaded with shuffled character list:"
		print alphatable
	else:
		return "Product of row and column arguments must equal 42. Aborting."


	print "\n\nBeginning step 3: First Cipher Pass (Coordinate Conversion)..."
	msg3 = []
	for number in xrange(0,len(msg2),2):
		msg3.append(alphatable[msg2[number],msg2[number+1]])
		print alphatable[msg2[number],msg2[number+1]]

	print "Step 3: First Cipher Pass (Coordinate Conversion) completed successfully."
	print "Intermediate ciphertext (plaintext converted to coordinates): \n"
	print msg3