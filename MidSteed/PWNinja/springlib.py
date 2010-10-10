import time, thread, socket, traceback
import hashlib, base64
import inspect

class null:
	def __getattr__(self, attr):
		def null(self, *args, **kwargs): pass
		return null

class Msg:
	def __init__(self, msg, id=None):
		self.msg = msg
		self.id = id

class SpringBase:
	def __init__(self, host='taspringmaster.clan-sy.com', port=8200):
		self.host = str(host)
		self.port = int(port)
		self.pending = ''
		self.connected = False
		self.conn = null()
		self.username = ''
		self.password = ''
		self.callbacks = {}
		self.gcallbacks = set()
	
	def connect(self):
		conn = socket.socket()
		conn.connect((self.host, self.port))
		self.conn = conn
		self.connected = True
		thread.start_new_thread(self.ping, ())
	
	def disconnect(self):
		self.connected = False
		self.conn.close()
		self.pending = ''
		self.conn = null()
	
	def reconnect(self, sleep=15):
		self.disconnect()
		time.sleep(sleep)
		self.connect()
		self.login()
	
	def login(self, username=None, password=None):
		if not username and self.username: username = self.username
		if not password and self.password: password = self.password
		if not username or not password: return
		self.username = username
		self.password = password
		if self.connected: self.disconnect()
		else: self.connect()
		if not self.connected: raise socket.error
		self.send('LOGIN %s %s 0 0 aegis\' python springlib'%(username, password))
		return self
	
	def ping(self):
		while self.connected:
			self.send('PING')
			time.sleep(10)
			
	def send(self, msg): self.conn.send(msg+'\n')
	
	def recv(self):
		while not '\n' in self.pending:
			self.pending += self.conn.recv(1024)
			while self.pending[0] == '\n':
				self.pending = self.pending[1:]
		cmd, self.pending = self.pending.split('\n',1)
		return cmd
class SpringProtocol(SpringBase):
	def Hash(self, ascii):
		m = hashlib.md5()
		m.update(ascii)
		return base64.b64encode(m.digest())

	def Join(self, chan, key=None):
		if type(chan) in (list, tuple, set):
			for chan in chan: self.Join(chan)
		elif type(chan) == dict:
			for name in chan: self.Join(name, chan[name])
		elif type(chan) == str:
			if key: self.send('JOIN %s %s'%(chan, key))
			else: self.send('JOIN %s'%chan)
			
	def Leave(self, *chan):
		for chan in chan:
			if type(chan) in (list, tuple, set, dict):
				for chan in chan: self.Leave(chan)
			elif type(chan) == str: self.send('LEAVE %s'%chan)
	
	def Say(self, chan, *args):
		for msg in args:
			if type(msg) in (list, tuple, set):
				for msg in msg: self.Say(chan, msg)
			elif type(msg) == dict:
				for name in msg: self.Say(chan, '%s: %s'%(name, msg[name]))
			else: self.send('SAY %s %s'%(chan, msg))
	
	def SayEx(self, chan, *args):
		for msg in args:
			if type(msg) in (list, tuple, set):
				for msg in msg: self.SayEx(chan, msg)
			elif type(msg) == dict:
				for name in msg: self.SayEx(chan, '%s: %s'%(name, msg))
			else: self.send('SAYEX %s %s'%(chan, msg))
	
	def SayPrivate(self, user, *args):
		for msg in args:
			if type(msg) in (list, tuple, set, dict):
				for msg in msg: self.SayEx(user, msg)
			else: self.send('SAYPRIVATE %s %s'%(user, msg))

	def Send(self, msg):
		self.send(msg)
		print "Sent: " + msg

class SpringCallback(SpringProtocol):
	def addListeners(self, pairs):
		if not type(pairs) == dict: return
		for cmd in pairs:
			self.addListener(cmd, pairs[cmd])
			
	def addListener(self, cmd, func):
		if cmd in self.callbacks: self.callbacks[cmd].add(func)
		else: self.callbacks[cmd] = set([func])
	
	def removeListener(self, cmd, func):
		if cmd in self.callbacks and func in self.callbacks[cmd]: self.callbacks[cmd].remove(func)
	
	def addGlobalListener(self, func): self.gcallbacks.add(func)
	
	def removeGlobalListener(self, func):
		if func in self.gcallbacks: self.gcallbacks.remove(func)
	
	def pump(self):
		while True:
			data = self.recv()
			if not data: continue
			if self.gcallbacks:
				for func in self.gcallbacks: func(data)
			if ' ' in data:
				cmd, args = data.split(' ',1)
				if cmd in self.callbacks:
					for func in self.callbacks[cmd]:
						self.callCallback(func, args.split(' '))
			else:
				if data in self.callbacks:
					for func in self.callbacks[cmd]:
						self.callCallback(func)
	
	def callCallback(self, func, args=[]):
		msg_id = 0
		if len(args) > 0 and args[0].startswith('#'):
			test = args[0].split(' ')[0][1:]
			if test.isdigit():
				msg_id = '#%s '%test
				args = args[1:]
		info = inspect.getargspec(func)
		total = len(info[0])
		if not total: func()
		else:
			optional = 0
			if info[3]: optional = len(info[3])
			required = total - optional
			if len(args) < required: return
			elif required == 0 and len(args) == 0: func()
			else:
				if len(args) > total-1: args = ' '.join(args).split(' ',total-1)
				func(*args)