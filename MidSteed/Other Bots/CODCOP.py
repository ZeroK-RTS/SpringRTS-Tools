from springlib import SpringCallback #import Aegis's SpringLib (Thanks, Aegis!). This handles basic spring server connection stuff. 
import time, random, sys #import basic expanded programming functionality
import hashlib, binascii, base64 #import the requirements for the hash function
#TalkityBot: A battleroom-filling bot by MidKnight!

##############-----CONFIG-----##############
##Replace USERNAME with your desired bot's username:
##NOTE: LOG IN ONCE WITH YOUR SPECIFIED USERNAME AND ACCEPT THE LICENSE AGREEMENT, THIS SCRIPT WILL NOT MAKE YOU AN ACCOUNT!
userName = "DAMACY"
##Replace PASSWORD with your desired bot's password:
passWord = "lulz"
##What is the message that you want to send?
message = "Guys! Join Journier's game! NAO!!!!!1!"
##Follow the example given to fill in the list of users you want to recieve the message:
recList = "[BB]Journier", "[1uP]MidKnight"
##############END OF CONFIG##############

def Hash(ascii): #this handles the hashing of the password into the form the spring server wants (md5-b64) - This function is written by Aegis ;) 
    m = hashlib.md5()
    m.update(ascii)
    return base64.b64encode(binascii.a2b_hex(m.hexdigest()))

spring = SpringCallback().login(userName, Hash(passWord)) #a very important line. This handles login and (I think) lets us use many of springlib's functions

#vars, vars, and more vars!
userList = []
chanList = []
tyme = 0

#abstractions
Say = spring.Say
SayEx = spring.SayEx
SayPrivate = spring.SayPrivate

#conditions
def Said(chan, user, msg):
    print chan, user, msg

def SaidEx(chan, user, msg):
    print chan, user, msg

def SaidPrivate(user, msg):
    print user, msg
    adminList = ["[BB]Journier", "[1uP]MidKnight"]
    if ((user in adminList) and (message.lower() == "!send")):
        global recList
        for rec in recList:
            SayPrivate(rec, message)

def Clients(chan, clients):
    print "clientlist recieved"

def Joined(chan, user):
    print chan, user, " Joined"


def Left(chan, user):
    print chan, user, " Left"

def Adduser(user, country, ping):
    global userList
    userList.append(user)
    print user, "has been added to the online users list."
    sys.exit()

def Removeuser(user):
    global userList
    userList.remove(user)
    print user, "has been removed from the online users list."

def Channel(chan, users, topic):
    print "Recieving: " + chan + " - Users: " + users
    chanList.append(chan)

def Endofchannels():
    print "-------------EOCL RECIEVED-------------"
    print "-------------CHANNEL LIST-------------"
    global chanList
    print chanList

def Denied(msg):
	print 'Denied!', msg

#listeners
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

#------------------Stuff the bot does immediately after joining goes between here...
print "Script successfully initialized, KAT-A-MA-RI DA-MA-CY-Y-Y-Y!"
spring.Join('BB')
for rec in recList:
    SayPrivate(rec, message)
#------------------...and here.
spring.pump()
