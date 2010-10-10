from springlib import SpringCallback
import time, random, sys
spring = SpringCallback().login('KnightBot1', Hash(1243540))
userList = []
def Said(chan, user, msg):
    print chan, user, msg
    if (user == "smoth") or (user == "[1uP]MidKnight[0_0]") and (msg == "!end"):
        sys.stop()
def SaidEx(chan, user, msg):
    print chan, user, msg
def SaidPrivate(user, msg):
    print user, msg

def Clients(chan, clients):
    print "clientlist recieved"

def Joined(chan, user):
    print chan, user, " Joined"
    #userList.append(user)

def Left(chan, user):
    print chan, user, " Left"
    #userList.remove(user)
	
def Adduser(user):
    print user, "is added"
    global userList
    userList.append(user)

def Removeuser(user):
    print user, "is removed"
    global userList
    userList.remove(user)

def Denied(msg):
	print 'Denied!', msg

if "moi" in userList:
	SayPrivate("ChanServ", "!kick moi You blew your chance.")
listeners = {
    'SAID':Said,
    'SAIDEX':SaidEx,
    'SAIDPRIVATE':SaidPrivate,
    'DENIED':Denied,
    'JOINED':Joined,
    'LEFT':Left,
    'ADDUSER':Adduser,
    'REMOVEUSER':Removeuser,
    'CLIENTS':Clients
    }
spring.addListeners(listeners)


spring.Join('gundam')
print "Script successfully initialized."
spring.pump()
