from springlib import SpringCallback#import Aegis's SpringLib (Thanks, Aegis!). This handles basic spring server connection stuff. 
import time, random, sys, threading #import basic expanded programming functionality
import hashlib, base64 #import the requirements for the hash function
import cPickle #import cpickle so as to save and load state
#Messagebot Framework by MidKnight!


def Hash(ascii): #this handles the hashing of the password into the form the spring server wants (md5-b64) - This function is written by Aegis ;) 
    m = hashlib.md5()
    m.update(ascii)
    return base64.b64encode(m.digest())

spring = SpringCallback().login('MidDay', SpringCallback().Hash("1243540")) #a very important line. This handles login and (I think) lets us use many of springlib's functions


#vars, vars, and more vars!
userList = []
chanList = []


#abstractions
Say = spring.Say
SayEx = spring.SayEx
SayPrivate = spring.SayPrivate
Send = spring.Send


#conditions
def Said(chan, user, msg):
    print chan, user, msg
    if msg.lower() == "!help":
        SayPrivate(user, "This is Messagebot, the friendly notification bot written in Python by MidKnight, on Aegis's springlib, with help and code from Lurker and AlcariTheMad!")
        SayPrivate(user, "You can send a message to an offline user and have them (hopefully) recieve it when they log back in using this syntax:")
        SayPrivate(user, '"!message THE-INTENDED_RECIEVER YOUR MESSAGE" -- an example would be "!message [1uP]MidKnight this bot is great!!!"')
    if (msg.lower().startswith("!")) and (msg.count(' ') >= 2):
        command, rec, text = msg.split(' ', 2)
        if command.lower() == "!message":
                print command, rec, text
                if rec.lower() not in userList:
                    global curMsg
                    global recDict
                    msgDict[curMsg + 1] = {'send':user.lower(), 'rec':rec.lower(), 'text':text}
                    if rec.lower() not in recDict:
                        #global recDict
                        recDict[rec.lower()] = []
                    recDict[rec.lower()].append(curMsg + 1)
                    cmf = file("cmf.txt", "w")
                    cmf.write(str(curMsg+1))
                    cmf.close
                    curMsg = curMsg+1
                    log = file("log.txt", "a")
                    log.writelines( "%s   %s   %s   %s" %(curMsg, user, rec, text))
                    log.writelines('\n')
                    log.close()
                    dumpMDB()
                    dumpRDB()
                    print msgDict[curMsg], "recieved, logged, and saved in DB."
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
    #global recDict
    userList.append(user.lower())
    print user, "is added"
    if (user.lower() in recDict):
        #global recDict
        threading.Thread(target=DelaySend1, args=(user,)).start()
        print "saidprivate"
        for msgID in recDict[user.lower()]:
            global msgDict
            print "msgID:", msgID
            MIDDict = msgDict[msgID]
            threading.Thread(target=DelaySend2, args=(user, MIDDict['send'], MIDDict['text'],)).start()
            #SayPrivate(user, '%s says:' % (MIDDict['send']))
            #SayPrivate(user, '"%s"' % (MIDDict['text']))
            del msgDict[msgID]
            dumpMDB()
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
spring.Join('main')
spring.Join('newbies')
spring.Join('springlobby')
spring.Join('qtlobby')
spring.Join('sy')
spring.Join('ai')
spring.Join('1up')
spring.Join('BB')
spring.Join('peet')
spring.Join('neddie')
spring.Join('ca')
spring.Join('s44')
spring.Join('evolution')
spring.Join('meridian')
spring.Join('bots')
#------------------...and here.
spring.pump()
