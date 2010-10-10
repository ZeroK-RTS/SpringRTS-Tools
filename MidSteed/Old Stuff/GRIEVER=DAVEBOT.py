from springlib import SpringCallback
import time, random, sys
import hashlib, binascii, base64

def Hash(ascii):
    m = hashlib.md5()
    m.update(ascii)
    return base64.b64encode(binascii.a2b_hex(m.hexdigest()))
spring = SpringCallback().login('COXBOT', Hash("lulz"))
userList = []
chanList = []
timer = 1

def Said(chan, user, msg):
    print chan, user, msg
    if ((user == "[BB]Griever") or (user == "DIX"))and ((start == 0) or ((time.clock() - start) >= 60)):
        spring.Say('ca', "Remember, Griever == DAVETHEBRAVE!!")
        start = time.clock()
def SaidEx(chan, user, msg):
    print chan, user, msg
    if (user == "[1uP]MidKnight") and (msg == "doom"):
        sys.stop()
def SaidPrivate(user, msg):
    print user, msg


def Clients(chan, clients):
    print "clientlist recieved"

def Joined(chan, user):
    print chan, user, " Joined"
    spring.Say('ca', "Hey," + user + ", did you know that [BB]Griever is actually DAVETHEBRAVE!?!?!?!?!!?!?!??!!?")


def Left(user):
    print user, " Left"

	
def Adduser(user, c, p):
    print user, "is added"
    global userList
    userList.append(user)

def Removeuser(user):
    print user, "is removed"
    global userList
    userList.remove(user)

def Channel(chan, users):
    global chanList
    chanList.append(chan)
    
def Denied(msg):
	print 'Denied!', msg

listeners = {
    'SAID':Said,
    'SAIDEX':SaidEx,
    'SAIDPRIVATE':SaidPrivate,
    'DENIED':Denied,
    'JOINED':Joined,
    'LEFT':Left,
    'ADDUSER':Adduser,
    'REMOVEUSER':Removeuser,
    'CLIENTS':Clients,
    'CHANNEL':Channel
    }
spring.addListeners(listeners)


spring.Join('ca')
print "Script successfully initialized."
spring.pump()
