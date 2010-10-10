from springlib import SpringCallback
import time, random
spring = SpringCallback().login('MidSteed', 'vQXhbDHl73TBZVEK0LcAQw==')
spring.Join('gundam')
print "wewe"
meh = 0
users = {1: "mkbot", 2: "MidSteed"}
timer = 0

random.seed()
messages = {1: "Why hello there,", 2: "Yo! ", 3: "Lovin' the new hairdo, ", 4: "hello, ", 5: "Well well, look what the cat dragged in. Welcome, "}
def Said(chan, user, msg):
    print chan, user, msg
#if 'mkbot' in msg:
    if ((("gundam" or "this mod") and "illegal") in msg) and (timer < 5):
		b = random.randint(1, 5)
		spring.Say('gundam', "Gundam is perfectly legal, you deluded jerk!")
		users[user] = 2
		timer + 1 = timer
		if timer == 4:
			spring.Say('gundam', "This is below me...")
			time.Sleep(30)
			timer = 0


def SaidEx(chan, user, msg):
    print chan, user, msg
 
def SaidPrivate(user, msg):
    print user, msg
    if "MidKnight" in user:
        if not meh:
            meh = 0
        if meh == 1:
            spring.Say('ca', msg)
            meh = 0
        if "sayzor" in msg:
            meh = 1
 
def Denied(msg):
	print 'Denied!', msg

listeners = {
    'SAID':Said,
    'SAIDEX':SaidEx,
    'SAIDPRIVATE':SaidPrivate,
    'DENIED':Denied
    }
spring.addListeners(listeners)
spring.pump()
