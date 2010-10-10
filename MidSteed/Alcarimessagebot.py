from springlib import SpringCallback #import Aegis's SpringLib (Thanks, Aegis!). This handles basic spring server connection stuff. 
import time, random, sys, threading #import basic expanded programming functionality
import hashlib, base64 #import the requirements for the hash function
import cPickle #import cpickle so as to save and load state
#Messagebot: A messenger bot by MidKnight!

def Hash(ascii): #this handles the hashing of the password into the form the spring server wants (md5-b64) - This function is written by Aegis ;) 
    m = hashlib.md5()
    m.update(ascii)
    return base64.b64encode(m.digest())

spring = SpringCallback().login('b_', Hash("asdbc")) #a very important line. This handles login and (I think) lets us use many of springlib's functions

#vars, vars, and more vars!
userList = []
chanList = []
recDict = {}

#load state
rDB = file("recDB.txt", "r")
recDict = cPickle.load(rDB)
rDB.close()

#save state func
def dumpRDB():
    global rDB
    rDB = file("recDB.txt", "w")
    cPickle.dump(recDict, rDB)
    rDB.close()
    print "rDB dump successful"

#abstractions
Say = spring.Say
SayEx = spring.SayEx
SayPrivate = spring.SayPrivate

#conditions
def Said(chan, user, msg):
    print chan, user, msg
    if msg.lower() == "!help":
        SayPrivate(user, "This is Messagebot, the friendly notification bot written in Python by MidKnight(with lots of help from aegis, AlcariTheMad and lurker)!")
        SayPrivate(user, "You can send a message to an offline user and have them (hopefully) recieve it when they log back in using this syntax:")
        SayPrivate(user, '"!message THE-INTENDED_RECIEVER YOUR MESSAGE" -- an example would be "!message [1uP]MidKnight this bot is great!!!"')
    if (msg.lower().startswith("!")) and (msg.count(' ') >= 2):
        command, rec, text = msg.split(' ', 2)
        if command.lower() == "!message":
                print command, rec, text
                if rec.lower() not in userList:
                    global recDict
                    if rec.lower() not in recDict:
                        #global recDict
                        recDict[rec.lower()] = []
                    recDict[rec.lower()].append((user, text))
                    log = file("log.txt", "a")
                    log.write( "%s   %s   %s\n" %(user, rec, text))
                    log.close()
                    dumpRDB()
                    print recDict[rec.lower()][-1], "recieved, logged, and saved in DB."
                    SayPrivate(user, "Thank you! Your message has been recieved!")
                else:
                    SayPrivate(user, "ERROR! " + rec + " is already online! Why don't you just send him/her a PM?")
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

def DelaySend1(user):
    time.sleep(3)
    SayPrivate(user, "You recieved some mail while you were offline:")

def DelaySend2(user, send, text):
    time.sleep(3.5)
    SayPrivate(user, '%s says:' % (send))
    SayPrivate(user, '"%s"' % (text))

def Adduser(user, country, ping):
    global userList
    userList.append(user.lower())
    print user, "is added"
    if (user.lower() in recDict):
        threading.Thread(target=DelaySend1, args=(user,)).start()
        print "saidprivate"
        for msg in recDict[user.lower()]:
            threading.Thread(target=DelaySend2, args=(user, msg[0], msg[1])).start()
            recDict[user.lower()].pop()
        if not len(recDict[user.lower()]):
            del recDict[user.lower()]
        dumpRDB()

def Removeuser(user):
    global userList
    userList.remove(user.lower())
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
spring.Join('bots')
#------------------...and here.
try:
    spring.pump()
finally:
    dumpRDB()