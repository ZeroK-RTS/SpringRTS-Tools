from springlib import SpringCallback
import time, random, sys
import hashlib, binascii, base64

def Hash(ascii):
    m = hashlib.md5()
    m.update(ascii)
    return base64.b64encode(binascii.a2b_hex(m.hexdigest()))
spring = SpringCallback().login('cetigonal', Hash("1243540"))

userList = []
chanList = []
gulist = []
def Said(chan, user, msg):
    print chan, user, msg
    if (user == "smoth") and (msg == "!muteall"):
        for u in gulist:
            spring.SayPrivate(ChanServ, "!mute #gundam " + u)
    if (user == "smoth") and (msg == "!unmuteall"):
        for u in gulist:
            spring.SayPrivate(ChanServ, "!unmute #gundam " + u)

def SaidEx(chan, user, msg):
    print chan, user, msg
    if (user == "[1uP]MidKnight[0_0]") and (msg == "doom"):
        sys.stop()

def SaidPrivate(user, msg):
    print user, msg
    if (user == "smoth") and (msg == "!muteall"):
        for u in gulist:
            spring.SayPrivate(ChanServ, "!mute #gundam " + u)
    if (user == "smoth") and (msg == "!unmuteall"):
        for u in gulist:
            spring.SayPrivate(ChanServ, "!unmute #gundam " + u)

def Clients(chan, clients):
    print "clientlist recieved"

def Joined(chan, user):
    print chan, user, " Joined"


def Left(chan, user):
    print chan, user, " Left"

	
def Adduser(user, country, ping):
    global userList
    userList.append(user)
    print user, "is added"

def Removeuser(user):
    global userList
    userList.remove(user)
    print user, "is removed"

def Channel(chan, users, topic):
    print "Recieving: " + chan + " - Users: " + users
    if chan == "gundam":
        gulist = users
        spring.Join(chan)
    
def Endofchannels():
    print "-------------EOCL RECIEVED-------------"
    print "-------------CHANNEL LIST-------------"
    global chanList
    print chanList
#    print "-----------EOCL, JOINING...-----------"
#    for chan in chanList:
#        spring.Join(chan)
#    print "------JOINED, READY FOR ANNOUNCE------"

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
    'CHANNEL':Channel,
    'ENDOFCHANNELS':Endofchannels
    }
spring.addListeners(listeners)


print "Script successfully initialized, sending for channels..."
spring.Send('CHANNELS')
#spring.Join('peet')
spring.pump()
