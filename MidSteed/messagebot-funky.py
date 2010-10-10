from springlib import SpringCallback #import Aegis's SpringLib (Thanks, Aegis!). This handles basic spring server connection stuff. 
import time, random, sys, threading #import basic expanded programming functionality
import hashlib, binascii, base64 #import the requirements for the hash function
import cPickle #import cpickle so as to save and load state
#Messagebot: A messenger bot by MidKnight!

def Hash(ascii): #this handles the hashing of the password into the form the spring server wants (md5-b64) - This function is written by Aegis ;) 
    m = hashlib.md5()
    m.update(ascii)
    return base64.b64encode(binascii.a2b_hex(m.hexdigest()))

spring = SpringCallback().login('MessageBot', Hash("1243540")) #a very important line. This handles login and (I think) lets us use many of springlib's functions

#vars, vars, and more vars!
userList = []
chanList = []
msgDict = {}
recDict = {}

#load state
cmf = file("cmf.txt", "r")
curMsg = int(cmf.read())
cmf.close()

mDB = file("msgDB.txt", "r")
msgDict = cPickle.load(mDB)
mDB.close()

rDB = file("recDB.txt", "r")
recDict = cPickle.load(rDB)
rDB.close()

#funcs for  easy state dumping
def dumpMDB():
    global mDB
    mDB = file("msgDB.txt", "w")
    cPickle.dump(msgDict, mDB)
    mDB.close()
    print "mDB dump successful"

def dumpRDB():
    global rDB
    rDB = file("recDB.txt", "w")
    cPickle.dump(recDict, rDB)
    rDB.close()
    print "rDB dump successful"

#global recDict


#abstractions
Say = spring.Say
SayEx = spring.SayEx
SayPrivate = spring.SayPrivate

#The 'send message' function
def sendMsg(user, command, rec, text):
    print command, rec, text
    if rec not in userList:
        global curMsg
        msgDict[curMsg + 1] = {'send':user.lower(), 'rec':rec.lower(), 'text':text}
        if rec.lower() not in recDict:
            recDict[rec.lower()] = []
        recDict[rec.lower()].append(curMsg + 1)
        cmf = open("cmf.txt", "w")
        cmf.write(str(curMsg+1))
        cmf.close
        curMsg = curMsg+1
        log = open("log.txt", "a")
        log.writelines( "%s   %s   %s   %s" %(curMsg, user, rec, text))
        log.writelines('\n')
        log.close()
        dumpMDB()
        dumpRDB()
        print msgDict[curMsg], "recieved, logged, and saved in DB."
        if (command == '!message'):
            SayPrivate(user, "Thank you! Your message has been recieved! -- This is an experimental version of messagebot! Try the new !notify and the updated !help commands, and report any bugs to [1uP][ai]MidKnight! Thanks! :)")
        if (command == '!notify'):
            SayPrivate(user, "Thank you! You will be notified when both you and " + rec + " are online! -- This is an experimental version of messagebot! Try the new !notify and the updated !help commands, and report any bugs to [1uP][ai]MidKnight! Thanks! :)")
    else:
        SayPrivate(user, "ERROR! " + rec + " is already online! Why don't you just send him/her a PM? -- This is an experimental version of messagebot! Try the new !notify and the updated !help commands, and report any bugs to [1uP][ai]MidKnight! Thanks! :)")

#conditions
def Said(chan, user, msg):
    print chan, user, msg
    global curMsg
    global recDict
    global msgDict
    if msg.lower() == "!help":
        SayPrivate(user, "This is Messagebot, the friendly notification bot written in Python by MidKnight(with lots of help from aegis, AlcariTheMad and lurker)!")
        SayPrivate(user, "You can send a message to an offline user and have them (hopefully) recieve it when they log back in using this syntax:")
        SayPrivate(user, '"!message THE-INTENDED-RECIEVER YOUR MESSAGE" -- an example would be "!message [1uP][ai]MidKnight this bot is great!!!"')
        SayPrivate(user, 'Try out the all-new !notify command! "!notify [1uP][ai]MidKnight" will make MessageBot PM you when NidKnight logs on!')
    if (msg.lower().startswith("!message")) and (msg.count(' ') >= 2):
        command, rec, text = msg.split(' ', 2)
        sendMsg(user, command, rec, text)
    if (msg.lower().startswith("!notify")) and (msg.count(' ') >= 1):
        msg = msg + " ¤ ¤ ¤"
        command, rec, junk = msg.split(' ', 2)
        print command, rec
        sendMsg(user, command, rec, 'IamAlazyCODERpleaseDONTexploitTHISaclariLURKERorANYONEelseWHOseesTHEsource')

def SaidEx(chan, user, msg):
    print chan, user, msg
    if (user == "[1uP]MidKnight[0_0]") and (msg == "doom"):
        sys.stop()

def SaidPrivate(user, msg):
    print user, msg
    Said('<PM>', user, msg)

def Clients(chan, clients):
    print "clientlist recieved"

def Joined(chan, user):
    print chan, user, " Joined"
    if (chan == "1uP"):
        Say(chan, "The channel for the clan [1uP] is #1up - just so you know. :-P")
        print user, "was directed out of #1up! ^_^"


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
        global msgDict
        for msgID in recDict[user.lower()]:
            if ((str(msgDict[msgID['text']]) == 'IamAlazyCODERpleaseDONTexploitTHISaclariLURKERorANYONEelseWHOseesTHEsource') and (str(msgDict[msgID['send']]) in userList)):
                SayPrivate(msgDict[msgID['send']], user + " has come online.")
                del msgDict[msgID]
                dumpMDB()
                if (recDict[user.lower()] == []):
                    del recDict[user.lower()]
                    dumpRDB()
        threading.Thread(target=DelaySend1, args=(user,)).start()
        print "saidprivate"
        for msgID in recDict[user.lower()]:
            print "msgID:", msgID
            MIDDict = msgDict[msgID]
            threading.Thread(target=DelaySend2, args=(user, MIDDict['send'], MIDDict['text'],)).start()
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
spring.Join('1up')
spring.Join('1uP')
spring.Join('BB')
spring.Join('peet')
spring.Join('neddie')
spring.Join('s44')
spring.Join('evolution')
spring.Join('bots')
#------------------...and here.
spring.pump()
