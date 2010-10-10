#!/usr/bin/env python
########################################
#
# CA Downloader - Python
#
# by aegis
#
####################
#
# Imports section
#
####################

import sys, os, urllib2, md5, httplib, time, zlib
import cStringIO as StringIO
from zipfile import ZipFile, ZIP_DEFLATED
from gzip import GzipFile

####################
#
# Config section
#
####################


base_url = 'http://files.caspring.org'

if os.name == 'posix':
	home = os.environ['HOME']
	scan_dirs = ['%s/.spring/mods' % home]
	drop_dir = '%s/.spring/mods' % home
elif os.name =='nt':
	scan_dirs = ['C:\Program Files\Spring\mods']
	drop_dir = ['C:\Program Files\Spring\mods']
else:
	raise NotImplementedError('Unknown OS: %s' % os.name)

# Custom configutation goes here
#scan_dirs = ['.']
#drop_dir = '.'

compress_in_ram = False
pool_versions = 1

def check_mod(path):
	dir, filename = os.path.split(path)
	if filename.startswith('ca-r') and filename.endswith('.sdz'):
		return True
############################################################
#
# A progress bar that actually shows progress!
#
############################################################

class progressBar:
    """ Creates a text-based progress bar. Call the object with the `print'
        command to see the progress bar, which looks something like this:
            
        [=======>        22%                  ]
        
        You may specify the progress bar's width, min and max values on init.
    """

    def __init__(self, minValue = 0, maxValue = 100, totalWidth=80):
        self.progBar = "[]"   # This holds the progress bar string
        self.min = minValue
        self.max = maxValue
        self.span = maxValue - minValue
        self.width = totalWidth
        self.amount = 0       # When amount == max, we are 100% done 
        self.updateAmount(0)  # Build progress bar string

    def updateAmount(self, newAmount = 0):
        """ Update the progress bar with the new amount (with min and max
            values set at initialization; if it is over or under, it takes the
            min or max value as a default. """
        if newAmount < self.min: newAmount = self.min
        if newAmount > self.max: newAmount = self.max
        self.amount = newAmount

        # Figure out the new percent done, round to an integer
        diffFromMin = float(self.amount - self.min)
        percentDone = (diffFromMin / float(self.span)) * 100.0
        percentDone = int(round(percentDone))

        # Figure out how many hash bars the percentage should be
        allFull = self.width - 2
        numHashes = (percentDone / 100.0) * allFull
        numHashes = int(round(numHashes))

        # Build a progress bar with an arrow of equal signs; special cases for
        # empty and full
        if numHashes == 0:
            self.progBar = "[>%s]" % (' '*(allFull-1))
        elif numHashes == allFull:
            self.progBar = "[%s]" % ('='*allFull)
        else:
            self.progBar = "[%s>%s]" % ('='*(numHashes-1),
                                        ' '*(allFull-numHashes))

        # figure out where to put the percentage, roughly centered
        percentPlace = (len(self.progBar) / 2) - len(str(percentDone)) 
        percentString = str(percentDone) + "%"

        # slice the percentage into the bar
        self.progBar = ''.join([self.progBar[0:percentPlace], percentString,
                                self.progBar[percentPlace+len(percentString):]
                                ])

    def __str__(self):
        return str(self.progBar)

    def __call__(self, value):
        """ Updates the amount, and writes to stdout. Prints a carriage return
            first, so it will overwrite the current line in stdout."""
        print '\r',
        self.updateAmount(value)
        sys.stdout.write(str(self))
        sys.stdout.write("\r")
        sys.stdout.flush()


############################################################
#
# Probably don't need to change anything under this block
#
############################################################

print
print '- CA Downloader -'
print

revisions = []

helpstr = '''
Usage: python downloader.py [scan directories] [drop directory (automatically scanned)] [compress] revision|test|stable|cleanup
'''

if len(sys.argv) > 1:
	for arg in sys.argv[1:]:
		if arg in ['-h', '--help', '-?', '/h', '/?']:
			print helpstr
		elif arg.lower() == 'compress':
			compress_in_ram = True
		elif arg.lower() == 'cleanup':
			print 'not implemented'
		elif arg.lower() == 'test' or arg.lower() == 'stable' or arg.isdigit():
			arg = arg.lower()
			if not arg in revisions:
				revisions.append(arg)
		elif os.path.exists(arg):
			drop_dir = path
			if not path in scan_dirs:
				scan_dirs.append(path)

if not revisions:
	revisions = ['stable']

def readurl(url):
	return urllib2.urlopen(base_url+url).read()

latest_test = readurl('/snapshots/latest_test')
latest_stable = readurl('/snapshots/latest_stable')

print 'Latest test:', latest_test
print 'Latest stable:', latest_stable
print

versions = []
for revision in revisions:
	if revision == 'test':
		revision = latest_test
	elif revision == 'stable':
		revision = latest_stable

	try:
		revision = int(revision)
	except:
		print revision+': error in revision number/name, skipping.'
		continue

        sdzname = os.path.join(drop_dir, 'ca-r%i.sdz'%revision)
        if os.path.exists(sdzname):
		print sdzname, 'already exists... skipping.'
        else:
		versions.append(revision)

if len(versions) == 0:
        sys.exit(0)

print 'Loading pool:'

pool = {}

mods = []
for dir in scan_dirs:
	if not os.path.isdir(dir):
		continue
	for posfile in os.listdir(dir):
		posfile = os.path.join(dir, posfile)
		if not os.path.isdir(posfile):
			mods.append(posfile)

ca_mods = []
for mod in mods:
	if check_mod(mod):
		ca_mods.append(mod)

ca_mods.sort()
if pool_versions > len(ca_mods):
        pool_versions = len(ca_mods)

ca_mods = ca_mods[-pool_versions:]

print 'Pooling from (%s) files:'%len(ca_mods)
for mod in ca_mods:
	print mod
	zf = ZipFile(mod, 'r')
	files = zf.namelist()
	for file in files:
		m = md5.new()
		m.update(zf.read(file))
		hash = m.hexdigest()
		if not hash in pool:
			pool[hash] = {'sdz':mod, 'file':file}

print 'Pool Loaded.'

opened_sdz_files = {}

def decompress(gz):
	f = StringIO.StringIO(gz)
	data = GzipFile(fileobj=f).read()
	return data

def get_from_zip(hash):
	sdz = pool[hash]['sdz']
	filename = pool[hash]['file']
	if not sdz in opened_sdz_files:
		opened_sdz_files[sdz] = ZipFile(sdz, 'r')
	data = opened_sdz_files[sdz].read(filename)
	return data

def get_rev(revision):
	return decompress(urllib2.urlopen(base_url+'/store/revs/%s.gz'%revision).read())

modlist = decompress(readurl('/store/modlist.gz'))

for version in versions:
	sdzname = os.path.join(drop_dir, 'ca-r%i.sdz'%version)
      
	print
	print 'Fetching revision %s:'%version
	files = get_rev(version).strip().split('\n')
   
	print
	print 'Initializing...'
   
	paths = {}
	for line in files:
		location, file, null = line.split(',',2)
		paths[location] = file
   
	download = []
	from_pool = []
	for path in paths:
		hash = paths[path]
		if hash in from_pool or hash in download:
			continue
		if hash in pool:
			from_pool.append(hash)
		else:
			download.append(hash)
   
	file_data = {}
   
	if len(from_pool) > 0:
		print 'Fetching', len(from_pool), 'files from local pool (this normally doesn\'t take very long:'
		sys.stdout.write('\n.')
		bar = progressBar(0, len(from_pool))
		count = 0
		for hash in from_pool:
			if compress_in_ram:
				file_data[hash] = zlib.compress(get_from_zip(hash))
			else:
				file_data[hash] = get_from_zip(hash)
			count += 1
			bar(count)
   
	print
	
	if len(download) > 0:
		print
		printstr = 'Fetching %s files from web (this may take a while depending on the speed of your connection):'%len(download)
		print
		
		# Hardcoded - to fit the window width nicely.
		print '-'*80
		print printstr
		sys.stdout.write('\n.')
		bar = progressBar(0, len(download))
		count = 0
		conn = httplib.HTTPConnection(base_url.split('http://',1)[1])
		for hash in download:
			for iter in xrange(10):
	#			try:
					conn.request('GET', '/store/pool/%s.gz'%hash)
					data = conn.getresponse().read()
					if compress_in_ram:
						file_data[hash] = zlib.compress(decompress(data))
					else:
						file_data[hash] = decompress(data)
					sys.stdout.write('.')
					count += 1
					bar (count)
					break
	#			except:
	#				print
	#				print 'problems, retrying'
	#				time.sleep(iter)
   
	print
	print '----------'
	print 'Zipping...'
   
	zf = ZipFile(sdzname, 'w', ZIP_DEFLATED)
	for path in paths:
		if compress_in_ram:
			zf.writestr(path, zlib.decompress(file_data[paths[path]]))
		else:
			zf.writestr(path, file_data[paths[path]])
	zf.close()
   
	print
	print 'Done.'
	print
	print '----------'
	print
	print 'Changelog (revision %s):'%version
	print modlist.split('<Revision>%s</Revision>'%version)[1].split('<Changelog>')[1].split('</Changelog>')[0]

print
raw_input('Done. Press enter to close.')
