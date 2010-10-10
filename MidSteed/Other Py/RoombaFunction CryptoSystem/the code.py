def roombafunc(msg, rseed, rows, cols, matracoef):
	print "Initializing RoombaFunction Cipher System"
	print "plaintext: " + msg
	print "key: " + str((rseed, rows, cols, matracoef))

	print "\n\nBeginning step 1: Alphabet Shuffle..."
	import random
	random.seed(rseed)
	alphalist = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",0,1,2,3,4,5,6,7,8,9," ","-",",",".","!","?"]
	random.shuffle(alphalist)
	print "Step 1: Alphabet Shuffle completed successfully."
	print "Shuffled alphabet list:"
	print alphalist

	print "\nBeginning step 2: Loading Alphabet Into Coding Matrix #1..."
	if (rows*cols == 42):
		alphatable = {}
		x = 1
		y = 1
		for letter in alphalist:
			if (x == (cols+1)):
				x =  1
				y += 1
			alphatable[letter] = (x,y)
			print "filling in " + str(x) + "," + str(y)
			x += 1
		print "Step 2: Loading Alphabet Into Coding Matrix #1 completed successfully."
		print "42 space matrix loaded with shuffled character list:"
		print alphatable
	else:
		return "Product of row and column arguments must equal 42. Aborting."

	print "\n\nBeginning step 3: First Cipher Pass (Coordinate Conversion)..."
	msg2 = []
	for letter in msg:
		if letter in alphatable:
			msg2.append(alphatable[letter][0])
			msg2.append(alphatable[letter][1])
			print "Encoded " + letter + " as " + str(alphatable[letter]) + "."
		else:
			if letter.islower():
				if letter.upper() in alphatable:
					msg2.append(alphatable[letter.upper()][0])
					msg2.append(alphatable[letter.upper()][1])
					print "Lowercase letter " + letter + " detected. converted to uppercase letter " + letter.upper() + " and encoded as " + str(alphatable[letter.upper()]) + "."
				else:
					print "Unsupported letter " + letter + " detected. letter omitted from ciphertext."
			else:
				print "Unsupported letter " + letter + " detected. letter omitted from ciphertext."
	print "Step 3: First Cipher Pass (Coordinate Conversion) completed successfully."
	print "Intermediate ciphertext (plaintext converted to coordinates): \n"
	print msg2

	print "\n\nBeginning step 4: Preparation For Second Cipher Pass..."
	if (len(msg2)%3) != 0:
		if (len(msg2)%3) == 1:
			msg2.append(0)
			msg2.append(0)
			print "Added 2 zeros for padding."
		if (len(msg2)%3) == 2:
			msg2.append(0)
			print "Added 1 zero for padding."
	print "Step 4: Preparation For Second Cipher Pass completed successfully."

	print "\n\nBeginning step 5: Generating Code Matrix #2..."
	random.seed(rseed)
	multmatrix = []
	msg3 = []
	for number in xrange(0,9):
		multmatrix.append(random.randint((-1*matracoef), (matracoef)))
		print "Multmatrix position " + str(number + 1) + " set to " + str(multmatrix[number]) +"."
	det = (multmatrix[0]*multmatrix[4]*multmatrix[8]+multmatrix[1]*multmatrix[5]*multmatrix[6]+multmatrix[2]*multmatrix[3]*multmatrix[7])- (multmatrix[2]*multmatrix[4]*multmatrix[6]+multmatrix[0]*multmatrix[5]*multmatrix[7]+multmatrix[1]*multmatrix[3]*multmatrix[8])
	print det
	if (det == 0):
		return "Matrix determinant = 0. Aborting."
	print "Step 5: Generating Code Matrix #2 completed successfully."

	print "\n\nBeginning step 6: Final Cipher Pass (Matrix Multiplication)..."
	for inc in xrange(0,len(msg2)/3):
		i = inc*3
		msg3.append(msg2[i]*multmatrix[0]+msg2[i+1]*multmatrix[3]+msg2[i+2]*multmatrix[6])
		msg3.append(msg2[i]*multmatrix[1]+msg2[i+1]*multmatrix[4]+msg2[i+2]*multmatrix[7])
		msg3.append(msg2[i]*multmatrix[2]+msg2[i+1]*multmatrix[5]+msg2[i+2]*multmatrix[8])
	print "Step 6: Final Cipher Pass (Matrix Multiplication) completed successfully."
	print "\n\nFinal ciphertext (intermediate ciphertext plus matrix multiplication pass):"
	return msg3
	
roombafunc("Alcari is an alcari",50,6,7,9000)