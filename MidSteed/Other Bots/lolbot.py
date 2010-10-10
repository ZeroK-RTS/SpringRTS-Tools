from springlib import SpringCallback #import Aegis's SpringLib (Thanks, Aegis!). This handles basic spring server connection stuff. 
import time, random, sys, threading #import basic expanded programming functionality
import hashlib, base64 #import the requirements for the hash function
import cPickle #import cpickle so as to save and load state
#Messagebot: A messenger bot by MidKnight!

def Hash(ascii): #this handles the hashing of the password into the form the spring server wants (md5-b64) - This function is written by Aegis ;) 
    m = hashlib.md5()
    m.update(ascii)
    return base64.b64encode(m.digest())

spring = SpringCallback().login('MidDay', Hash("1243540")) #a very important line. This handles login and (I think) lets us use many of springlib's functions

#vars, vars, and more vars!
userList = []
chanList = []

#abstractions
Say = spring.Say
SayEx = spring.SayEx
SayPrivate = spring.SayPrivate

#crypt function
def crypt(x, k):
    o = ''
    for c,i in zip(x, k*30):
        o+= chr(ord(c)^(ord(i)))
    return o

#conditions
def Said(chan, user, msg):
    print chan, user, msg
    if 'MidDay' not in user:
        Say('pw', 'Wow! not as inactive as I thought!')
        Say('pw', 'Total length of inactivity (since bot start): ' + str(int(time.clock()-starttime)) + " seconds.")
        time.sleep(.2)
        sys.exit()
def SaidEx(chan, user, msg):
    print chan, user, msg
    if (user == "[1uP]MidKnight[0_0]") and (msg == "doom"):
        sys.stop()

def SaidPrivate(user, msg):
    Said('<PM>', user, msg)

def Clients(chan, clients):
    print "clientlist recieved"

def Joined(chan, user):
    print chan, user, " Joined"

def Left(chan, user):
    print chan, user, " Left"

def DelaySend1(user, a, b):
    while 1:
        Say('pw', 'LOL THIS CHANNEL IS INACTIVE LOLOLOLOLOLOLOLOLOLOL')
        time.sleep(1)

def DelaySend2(user, send, text):
    time.sleep(3.5)
    SayPrivate(user, '%s says:' % (send))
    SayPrivate(user, '"%s"' % (text))

def Adduser(user, country, ping):
    print user, "is removed"

def Removeuser(user):
    print user, "is removed"

def Channel(chan, users, topic):
    print "Recieving: " + chan + " - Users: " + users
    if int(users) > 1:
        global chanList
        chanList.append(chan)
        spring.Join(chan)
        print "Appended and Joined: " + chan
    
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

print "Script successfully initialized, joining specified channels..."
#spring.Send('CHANNELS')
spring.Join('pw')
starttime = time.clock()
threading.Thread(target=DelaySend1, args=('bob')).start()
#------------------...and here.
spring.pump()
