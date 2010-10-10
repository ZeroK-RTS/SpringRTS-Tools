answer = input('what is 8 + 2?')
if type(answer) != "<type 'int'>":
    print type(answer)
    print "Enter a number, fool!"
elif answer == 10:
    print "Nice job! You're right!"
elif answer > 10:
    print "too high!"
else:
    print "Too low!"
