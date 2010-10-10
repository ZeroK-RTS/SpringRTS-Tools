from springlib import SpringCallback#import Aegis's SpringLib (Thanks, Aegis!). This handles basic spring server connection stuff. 
import time, random, sys, threading #import basic expanded programming functionality
import hashlib, base64 #import the requirements for the hash function
import cPickle #import cpickle so as to save and load state
#Messagebot Framework by MidKnight!

spring = SpringCallback().login('MidDay', SpringCallback().Hash("1243540")) #log in, unlocking most of Springlib's abstractions.


#vars, vars, and more vars!
userList = []
chanList = []


#abstractions
Join = spring.Join
Say = spring.Say
SayEx = spring.SayEx
SayPrivate = spring.SayPrivate
Send = spring.Send


#conditions
def Said(chan, user, msg):
    print chan, user, msg
    if (msg.lower().startswith("!")):
        command, other = msg.split(' ', 1)
def SaidEx(chan, user, msg):
    print chan, user, msg

def SaidPrivate(user, msg):
    Said('<PM>', user, msg)

def Clients(chan, clients):
    print "clientlist recieved"

def Joined(chan, user):
    print chan, user, " Joined"


def Left(chan, user):
    print chan, user, " Left"


def Adduser(user, country, ping):
    global userList
    userList.append(user.lower())
    print user, "is added"

def Removeuser(user):
    global userList
    userList.remove(user.lower())
    print user, "is removed"

def Channel(chan, users, topic):
    print "Recieving: " + chan + " - Users: " + users
    if int(users) > 1:
        global chanList
        chanList.append(chan)
        print "Appended:" + chan
    
def Endofchannels():
    print "-------------EOCL RECIEVED-------------"
    print "-------------CHANNEL LIST-------------"
    global chanList
    print chanList

def Denied(msg):
    print 'Denied!', msg
    time.sleep(2)
    sys.exit()

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
print "Script successfully initialized."
#------------------...and here.
spring.pump()
