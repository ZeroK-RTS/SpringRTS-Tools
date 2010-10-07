#MOD AO PLATE MAKER
#by Beherith mysterme@gmail.com

#how to use:
# 1. install xnormal, python 2.6 and python imaging library (PIL)
# 2. edit xnormalpath (in this file) to contain the path to xnormal.
#	Remember that the slashes '\' must be replaced with \\, 
#	and that you shoudlnt leave out the trailing \", because it allows spaces into the path
# 3. install imagemagick, make sure to allow it to modify your path
# 4. copy the desired .fbi files and .s3o and .3do files and their preexisting gound plates next to this script into their respective 'units', 'unittextures' and 'objects3d' folders
#	Dont place unitdefs into subdirectories in 'units', place them all into the root of 'units'
#	Script will only run on units that have (maxvelocity=0 or no max velocity tag) and no waterline tag
# 5. run python aobaker.py from the command line
#	Specifying a unitname like so:
#	python aobaker.py armllt
#	results in aobaker only running on that file
# 6. copy the fbi files back into the mod, copy all the *_aoplate.dds files into unittextures
# 7. run spring!
	
#-------------------------------------------------
#Todo:
#fix bake:
#	clamp to max
#	expand to min
#	increase to 256 rays
#	fiddle with burn
#make better documentation (yeah like thats gonna happen)
#add support for fucking luadefs (dislike lua)
#-------------------------------------------------
import winsound
import sys
import os
from struct import *
import Image
xnormalpath="\"C:\\Program Files (x86)\\Santiago Orgaz\\xNormal\\3.17.3\\x64\\"
pnum=1
vnum=1
runxnormal=1
runimagemagick=1
runnvdxt=1
only=''
cwd=os.getcwd()
aoraysperpixel=256
aoplaterez=128
defdir='.\\units\\'
texdir='.\\unittextures\\'
objdir='.\\objects3d\\'
print 'Working in :',cwd
if len(sys.argv)==2:
	only=sys.argv[1]

for filename in os.listdir(os.getcwd()+defdir):
	if (".fbi" in filename.lower() and only in filename) or (".lua" in filename.lower() and only in filename):# and filename.partition('.')[0]>'armdf':
		
		pnum=1
		fname=filename.partition('.')[0]+'.3do'
		outfname=fname.partition('.')[0]+'.obj'
		#f=open(fname,'rb')
		vnum=1
		deftype='fbi'
		if 'lua' in filename:
			deftype='lua'
			fbifilename=fname.partition('.')[0]+'.lua'
		else:
			fbifilename=fname.partition('.')[0]+'.fbi'
		print 'Definition type is',deftype
		fbi=open(defdir+fbifilename,'r')
		fbiln=fbi.readlines()
		static=0
		#-----------------Parse for FBIs for static buildings-------------------
		nomaxvel=1
		wl=0
		mv=-1
		for l in fbiln:
			if 'maxvelocity' in l.lower():
				nomaxvel=0
				mv=-1
				try:
					mv=float(l.partition('=')[2].strip().strip(';,'))
				except	ValueError:
					print 'cant parse maxvelocity!'
				if mv==0.0:
					static=1
				break
					
		for l in fbiln:
			if 'waterline' in l.lower():
				static=0	
				wl=1
				break
			# if 'useBuildingGroundDecal' in l.lower():
				# static=0
		if nomaxvel==1:
			static=1
		if static==0:
			print filename, ': not static (mv',mv, ' no mv:',nomaxvel,' waterline:',wl
			continue
			

		objectname=''

		fpx=0
		fpz=0

		#-----------------Parse fbi for footprint-------------------
		
		for l in fbiln:
			if 'footprintx' in l.lower():
				try:
					fpx=int(l.partition('=')[2].strip().strip(';,'))
				except	ValueError:
					print 'cant parse footprintx!'
				break
		for l in fbiln:					
			if 'footprintz' in l.lower():
				try:
					fpz=int(l.partition('=')[2].strip().strip(';,'))
				except	ValueError:
					print 'cant parse footprintz!'
				break
		for l in fbiln:
			if 'objectname' in l.lower():
				if deftype=='fbi':
					objectname=l.partition('=')[2].strip().strip(';').strip()
				else:
					objectname=l.partition('=')[2].strip().strip(',').strip().strip('[]\"')
				break
		print 'fbi parsed' , filename
			
	#------------------------Parse for pre existing groundplate (preferably one not made by this)--------------
		preplate=''
		for l in fbiln:
			if 'buildinggrounddecaltype' in l.lower():
				if 'aoplane.dds' in l.lower().partition('=')[2]:
					print filename, ' already contains an aoplate'
					break
				else:
					if '.dds' in l.lower() or '.png' in l.lower() or '.tga' in l.lower():
						preplate=l.lower().partition('=')[2].strip().strip(',[];\"').strip()
						try:
							pp=open(texdir+preplate,'r')
						except IOError:
							print 'Cant open premade plate',texdir+preplate,' referenced from',filename
							preplate=''
							break
						pp.close()
						if '.dds' in l.lower():
							cmd='convert '+texdir+preplate+' '+texdir+preplate.partition('.')[0]+'.tga'
							preplate=preplate.partition('.')[0]+'.tga'
							print cmd
							os.system(cmd)
						
					else:
						print 'Error, groundplate not .DDS format!'
						preplate=''
		ppx=0
		ppy=0
		pprez=aoplaterez
		if preplate!='':
			for l in fbiln:
				if 'buildinggrounddecalsizex' in l.lower():
					try:
						ppx=int(l.partition('=')[2].strip().strip(',[];').strip())
					except ValueError:
						print 'Failed to parse buildingGroundDecalSizeX in',l,'in file:',filename
				if 'buildinggrounddecalsizey' in l.lower():
					try:
						ppy=int(l.partition('=')[2].strip().strip(',[];').strip())
					except ValueError:
						print 'Failed to parse buildingGroundDecalSizeY in',l,'in file:',filename
			if ppx>0 and ppy>0:
				try:
					ppimg=Image.open(texdir+preplate,'r')
					ppsizex,ppsizey=ppimg.size
				except:
					print '------ERROR!-------------------------------Unable to open preexisting groundplate file!',preplate,filename
					continue
				if ppsizex!=ppsizey:
					print ' fucked up ground plate dimensions!', ppsizex, ppsizey
				else:
					pprez=ppsizex
					print 'plate sizes parsed successfully! ',ppx, ppy,pprez
			else:
				print 'plate sizes not parsed well!'
				preplate=''
				
		def reads3o(filename):

			try:
				s3o=open(filename,'rb')
			except IOError:
				print "FAILED TO OPEN s3o file ",filename,'!\n'
				return
			magic=s3o.read(12)
			header=s3o.read(4+5*4+4*4)
			header=unpack('ifffffiiii',header)
			print  'header:',header
			recursereads3o(s3o, header[6],0,0,0)
			
		def recursereads3o(f,p,ox,oy,oz):
			global pnum
			global vnum
			
			f.seek(p)
			piece=f.read(10*4+3*4)
			piece=unpack('iiiiiiiiiifff',piece)
			obj.write('o object'+str(pnum)+'\n')
			# print 'piece:',piece
			# print 'numchilds:',piece[1]
			# print 'numvertices:',piece[3]
			# print 'verticeoffset:',piece[4]
			# print 'primitivetype:',piece[6]
			# print 'vertextablesize:',piece[7]
			# print 'vertextableoffset:',piece[8]
			# print 'piece:',piece
			# print 'piece:',piece
			# print 'piece:',piece
			pnum+=1
			nv=piece[3]
			f.seek(piece[4])
			vertices=[]
			ox+=piece[10]
			oy+=piece[11]
			oz+=piece[12]
			# print 'numverts:',nv
			for i in range(0,nv):
				try:
					readdata=f.read(4*8)
					if len(readdata)!=32:
						print '-----======ERROR, read data is only ',len(readdata)
					
					#print 'vertex read success'
					v=unpack('ffffffff',readdata)
					#print 'vertex', v, i, ' of ',nv
				except error:
					print 'readdatalength:',len(readdata)
					print v, i, ' of ',nv
					
				#print v[0] / (65536.0),v[1] / (65536.0), v[2] / (65536.0)
				obj.write('v '+str(v[0]+ox)+' '+str(v[1]+oy)+' '+str(v[2]+oz)+'\n')
				obj.write('vn '+str(v[3])+' '+str(v[4])+' '+str(v[5])+'\n')
				obj.write('vt 0 0\n') # or should be this for proper export: obj.write('vt '+str(v[6])+' '+str(v[7])+'\n')
				vertices.append([v[0]+piece[10],v[1]+piece[11],v[2]+piece[12]])

			f.seek(piece[8])
			vtable=f.read(piece[7]*4)			
	
	
			unpackstr=''
			for i in range(0,piece[7]):
				unpackstr+='l'
			# print 'vtable length:',len(vtable)
			prims=unpack(unpackstr,vtable)
			# print 'primitives:',len(prims),' ',prims
			if piece[6]==0: #triangles:
				for i in range(0,len(prims),3):
					obj.write('f '+str(prims[i]+vnum)+'/'+str(prims[i]+vnum)+'/'+str(prims[i]+vnum)+' '+str(prims[i+1]+vnum)+'/'+str(prims[i+1]+vnum)+'/'+str(prims[i+1]+vnum)+' '+str(prims[i+2]+vnum)+'/'+str(prims[i+2]+vnum)+'/'+str(prims[i+2]+vnum)+'\n')			
			if piece[6]==2: #quads:
				for i in range(0,len(prims),4):
					obj.write('f '+str(prims[i]+vnum)+'/'+str(prims[i]+vnum)+'/'+str(prims[i]+vnum)+' '+str(prims[i+1]+vnum)+'/'+str(prims[i+1]+vnum)+'/'+str(prims[i+1]+vnum)+' '+str(prims[i+2]+vnum)+'/'+str(prims[i+2]+vnum)+'/'+str(prims[i+2]+vnum)+' '+str(prims[i+3]+vnum)+'/'+str(prims[i+3]+vnum)+'/'+str(prims[i+3]+vnum)+'\n')
			
			if piece[6]==1: #tristrips:
				fstr='f'
				for i in prims:
					if i>100000000:	#0xffffffff means end of strip:
						fstr+='\n'
						obj.write(fstr)
						fstr='f'
					else:	
						fstr+= ' '+str(i+vnum)+'/'+str(i+vnum)+'/'+str(i+vnum)
			
			vnum+=nv			
			f.seek(piece[2])
			for i in range(0,piece[1]):
				f.seek(piece[2]+4*i)
			
				child=f.read(4)
				# print child
				f.seek(unpack('l',child)[0])
				recursereads3o(f,unpack('l',child)[0],ox,oy,oz)
			
			return
	
				
			
		def recurseread3do(px, py, pz):
		#--------------------- unpack 3d0 files to OBJ files------------------------
			print 'reading 3do'
			global vnum
			global pnum
			main=f.read(13*4)
			mo=unpack('lllllllllllll', main)

			print mo
			f.seek(mo[7])
			obj.write('o object'+str(pnum)+'\n')

			pnum+=1
			nv=mo[1]
			f.seek(mo[9])
			vertices=[]
			for i in range(0,nv):
				v=unpack('lll',f.read(4*3))

				#print v[0] / (65536.0),v[1] / (65536.0), v[2] / (65536.0)
				obj.write('v '+str( (v[0]+px+mo[4]) / (65536.0))+' '+str( (v[1]+py+mo[5]) / (65536.0))+' '+str( (v[2]+pz+mo[6]) / (65536.0))+'\n')
				vertices.append([v[0] / (65536.0),v[1] / (65536.0), v[2] / (65536.0)])
			f.seek(mo[10])

			np=mo[2]

			if vnum==1:
				obj.write('vt 0 0'+'\n')
			firstplate=1
			for i in range(0,np):
				f.seek(mo[10]+32*i)
				p=unpack('llllllll',f.read(4*8))
				#print p
				nvi=p[1]
				f.seek(p[3])
				if nvi==3:
					vi=unpack('HHH',f.read(2*3))
				if nvi==4:
					vi=unpack('HHHH',f.read(2*4))
				if not (nvi==3 or nvi==4):
					continue
				if p[4]==0:
					print 'no texture on primitive ',p
					continue
				if nvi==4 and firstplate==1: #remove selection plate from 3do
					if vi[0]+vnum==1:
						vsum1= abs(vertices[vi[0]+1][0]) +abs(vertices[vi[0]+1][2]) 			
						vsum2= abs(vertices[vi[0]+2][0]) +abs(vertices[vi[0]+2][2] )			
						vsum3= abs(vertices[vi[0]+3][0]) +abs(vertices[vi[0]+3][2] )				
						vsum4= abs(vertices[vi[0]][0]) +abs(vertices[vi[0]][2]) 
						print vsum4
						if (abs(vsum1-vsum2)<0.01 and abs(vsum1-vsum3)<0.01 and abs(vsum1-vsum4)<0.01) :
							firstplate=0
							print 'Skipping first plate'
							continue
					
				obj.write('f')
				for j in vi:
					obj.write(' '+str(j+vnum)+'/1/')
				obj.write('\n')	
			vnum+=nv

			if mo[12]!=0:##child
				f.seek(mo[12])
				recurseread3do(px+mo[4],py+mo[5],pz+mo[6])	
			if mo[11]!=0: ##sibling
				f.seek(mo[11])
				recurseread3do(px,py,pz)	
		filetype=''
		if '.s3o' not in objectname:
			print 'objtype 3do', objectname
			try:
				f=open(objdir+objectname.partition('.')[0]+'.3do','rb')
			except IOError:
				print "FAILED TO OPEN 3d0 file ",objectname,'!\n'
				continue
			obj=open(outfname,'w')	
			filetype='3do'
			print 'wtf'
			recurseread3do(0,0,0)
		else:
			print 'objtype s3o'
			filetype='s3o'
			obj=open(outfname,'w')		
			reads3o(objdir+objectname)
		
		print 'working on: ',filename,'  vertices: ',vnum,' parts:',pnum
		obj.write('o groundplane\n')
		#--------------------- create AO plate ------------------------
		largeao=''
		size=8*max(fpz,fpz)
		if size>=5*8:
			largeao='large'
			size+=24
		else:
			size+=16
		if preplate=='':
			sizex=size
			sizez=size
		else:
			sizex=ppx*8
			sizez=ppy*8

		obj.write('v '+str(sizex)+' 0 '+str(sizez)+'\n')
		obj.write('v '+str(sizex)+' 0 '+str(-sizez)+'\n')
		obj.write('v '+str(-sizex)+' 0'+str(-sizez)+'\n')
		obj.write('v '+str(-sizex)+' 0 '+str(sizez)+'\n')
		obj.write('vt 1 0\n')
		obj.write('vt 1 1\n')
		obj.write('vt 0 1\n')
		obj.write('vt 0 0\n')
		if filetype=='3do':
			obj.write('f '+str(vnum)+'/2/ '+str(vnum+1)+'/3/ '+str(vnum+2)+'/4/ '+str(vnum+3)+'/5/ \n')
			
		else:
			obj.write('vn 0 1 0\n')
			obj.write('vn 0 1 0\n')
			obj.write('vn 0 1 0\n')
			obj.write('vn 0 1 0\n')
			obj.write('f '+str(vnum)+'/'+str(vnum)+'/'+str(vnum)+' '+str(vnum+1)+'/'+str(vnum+1)+'/'+str(vnum+1)+' '+str(vnum+2)+'/'+str(vnum+2)+'/'+str(vnum+2)+' '+str(vnum+3)+'/'+str(vnum+3)+'/'+str(vnum+3)+'\n')
			
		obj.close()
		#--------------------- edit xnormal settings XML file------------------------
		xml=open('aoplane.xml','r')
		xmlln=xml.readlines()
		xmlfilename='xnormalsettings.xml'
		xmlout=open(xmlfilename,'w')
		for l in xmlln:
			if 'S:\\models\\!AO\\corfus+plane2.obj' in l:
				print 'found .obj in xml'
				l=l.replace('S:\\models\\!AO\\corfus+plane2.obj',cwd+'\\'+outfname)
			if 'S:\\models\\!AO\\corfusplaneuniform.bmp' in l:
				l=l.replace('S:\\models\\!AO\\corfusplaneuniform.bmp',cwd+'\\'+outfname.partition('.')[0]+'_ao.bmp')
				print 'found .bmp in xml'
			if 'Width=\"128\" Height=\"128\"' in l:
				l=l.replace('Width=\"128\" Height=\"128\"','Width=\"'+str(pprez)+'\" Height=\"'+str(pprez)+'\"')
			if 'Width=\"128\" Height=\"128\"' in l:
				l=l.replace('Width=\"128\" Height=\"128\"','Width=\"'+str(pprez)+'\" Height=\"'+str(pprez)+'\"')
			xmlout.write(l)
		xmlout.close()
		#--------------------- run xnormal------------------------
		if runxnormal==1:
			os.system('del '+outfname.partition('.')[0]+'_ao_occlusion.bmp')
			cmd=xnormalpath+'xnormal.exe\" '+xmlfilename
			print cmd		
			os.system(cmd)
			
		#--------------------- Adjust color balance of AO bake ------------------------------------------
			img=Image.open(outfname.partition('.')[0]+'_ao_occlusion.bmp')
			impl=img.load()
			
			w,h=img.size			
			tl=img.getpixel((0,0))
			bl=img.getpixel((0,h-1))
			tr=img.getpixel((w-1,0))
			br=img.getpixel((w-1,h-1))
			modifier= min(tl[0]+tl[1]+tl[2],tr[0]+tr[1]+tr[2],bl[0]+bl[1]+bl[2],br[0]+br[1]+br[2])-10
			modifier=255 -int(modifier/3.0)
			maxdarkness =32
			darken=0.8

			for x in range(w):
				for y in range(h):
					px=img.getpixel((x,y))
					p=(px[1]+px[2]+px[0])/3
					p=min(p+modifier,255)
					p=p-(255-p)/8
					
					p=max(maxdarkness,p)
					img.putpixel((x,y),(p,p,p))
			img.save(outfname.partition('.')[0]+'_ao_normalized.bmp')
		
		
		#--------------------- make color channel black, and put AO bake into alpha channel------------------------
		
		if runimagemagick==1:
			if filetype =='s3o':
				cmd='convert -flip '+outfname.partition('.')[0]+'_ao_normalized.bmp '+outfname.partition('.')[0]+'_ao_normalized.bmp'
				print cmd
				os.system(cmd)
			cmd='composite.exe -compose Multiply -negate '+outfname.partition('.')[0]+'_ao_normalized.bmp aomask'+str(pprez)+largeao+'.bmp aotemp.bmp'
			print cmd
			os.system(cmd)

			cmd='composite -compose CopyOpacity aotemp.bmp black'+str(pprez)+'.bmp '+outfname.partition('.')[0]+'_aoplane.tga'
			print cmd		
			os.system(cmd)
			if preplate !='':
				preplateimg=Image.open(texdir+preplate)
				
				w,h=preplateimg.size

				
				aoplane=Image.open(outfname.partition('.')[0]+'_aoplane.tga')
				w2,h2=aoplane.size				
				aoplane.save(outfname.partition('.')[0]+'_aoplane_ao_only.png')
				if w!=w2 or h!=h2:
					print "i fucking knew this would happen, damned plate and ao sizes dont match!", h,w,h2,w2
					continue
				preplateimg.load()
				aoplane.load()
				alpha=Image.new('L',(w,h))
				for x in range(w):
					for y in range(h):
						platepix=preplateimg.getpixel((x,y))
						aopix=aoplane.getpixel((x,y))

						if 1==1:#len(aopix)==4 and len(platepix)==4:
							np=[0,0,0]#,0]							
							if platepix[3]==0: #transparent pixel! (or is it fully opaque? we shall see)
								#np[3]=aopix[3]
								alpha.putpixel((x,y),aopix[3])
							else:
								alpha.putpixel((x,y),platepix[3])
								np[0]=platepix[0]*(255-aopix[3])/255
								np[1]=platepix[1]*(255-aopix[3])/255
								np[2]=platepix[2]*(255-aopix[3])/255
							preplateimg.putpixel((x,y),(np[0],np[1],np[2]))
						else:
							print 'Wrong channel amount for plate or ao!', preplate, outfname
						# if x*y%1024==0:
							# print 'ao:',aopix, 'pl:',platepix, 'np',np
				alpha.save(outfname.partition('.')[0]+'_aoplane_merged_a.bmp')
				preplateimg=preplateimg.convert('RGB')
				preplateimg.save(outfname.partition('.')[0]+'_aoplane_merged.bmp')
				preplateimg.save(outfname.partition('.')[0]+'_aoplane.png')
				cmd='composite -compose CopyOpacity '+outfname.partition('.')[0]+'_aoplane_merged_a.bmp '+ outfname.partition('.')[0]+'_aoplane_merged.bmp '+ outfname.partition('.')[0]+'_aoplane.tga'
			print cmd		
			os.system(cmd)
				#preplateimg.close()
				#aoplane.close()
				
				
		#--------------------- compress to dds------------------------
		if runnvdxt==1:
			if preplate=='':
				cmd='nvdxt -dxt5 -quality_highest -file '+outfname.partition('.')[0]+'_aoplane.tga'
			else:
				cmd='nvdxt -dxt5 -quality_highest -file '+outfname.partition('.')[0]+'_aoplane.tga'
			print cmd
			os.system(cmd)

		#--------------------- edit FBI file to contain ground decal info------------------------
		fbi.close()
		fbi=open(fbifilename,'w')
		bracketcount=0
		alreadyhasgroundplate=0
		for l in fbiln:
			if 'buildinggrounddecaltype' in l.lower() and (outfname.partition('.')[0]+'_aoplane.dds') in l.lower():
				alreadyhasgroundplate=1
			if 'return lowerkeys' in l.lower():
				fbi.write(l)
				continue
			if '{' in l:
				bracketcount+=1
			if '}' in l:
				bracketcount-=1
				if bracketcount==0 and alreadyhasgroundplate==0:
					if deftype=='fbi':
					
						decalinfo=' buildingGroundDecalDecaySpeed=30;\n buildingGroundDecalSizeX='+str(sizex/8)+ ';\n buildingGroundDecalSizeY='+str(sizez/8)+';\n useBuildingGroundDecal=1;\n buildingGroundDecalType='+outfname.partition('.')[0]+'_aoplane.dds;\n}\n'
					else:
						decalinfo='	buildingGroundDecalDecaySpeed=30,\n	buildingGroundDecalSizeX='+str(sizex/8)+ ',\n	buildingGroundDecalSizeY='+str(sizez/8)+',\n	useBuildingGroundDecal = true,\n	buildingGroundDecalType=[['+outfname.partition('.')[0]+'_aoplane.dds]],\n}\n'
					
					print  decalinfo
					fbi.write(decalinfo)
					alreadyhasgroundplate=1
				else:
					fbi.write(l)
			else:
				fbi.write(l)
		fbi.close()
		 
winsound.Beep(500,500) #yep, this shit can run so long it needs to BEEEP when its done :D
				
			
			
	
	
	
	
#------------------------s3o format:

# struct S3OHeader{
	# char magic[12];		///< "Spring unit\0"

	# int version;		///< 0 for this version
	# float radius;		///< radius of collision sphere
	# float height;		///< height of whole object
	# float midx;		///< these give the offset from origin(which is supposed to lay in the ground plane) to the middle of the unit collision sphere
	# float midy;
	# float midz;
	# int rootPiece;		///< offset in file to root piece
	# int collisionData;	///< offset in file to collision data, must be 0 for now (no collision data)
	# int texture1;		///< offset in file to char* filename of first texture
	# int texture2;		///< offset in file to char* filename of second texture	
		
	
# struct Piece{
	#0 int name;		///< offset in file to char* name of this piece
	#1 int numChilds;		///< number of sub pieces this piece has
	#2 int childs;		///< file offset to table of dwords containing offsets to child pieces
	#3 int numVertices;	///< number of vertices in this piece
	#4 int vertices;		///< file offset to vertices in this piece
	#5 int vertexType;	///< 0 for now
	#6 int primitiveType;	///< type of primitives for this piece, 0=triangles,1 triangle strips,2=quads
	#7 int vertexTableSize;	///< number of indexes in vertice table
	#8 int vertexTable;	///< file offset to vertice table, vertice table is made up of dwords indicating vertices for this piece, to indicate end of a triangle strip use 0xffffffff
	#9 int collisionData;	///< offset in file to collision data, must be 0 for now (no collision data)
	#10 float xoffset;		///< offset from parent piece
	#11 float yoffset;
	#12 float zoffset;

	
	
	
	
	
	
	
	# Unoffical .3do by Dan Melchione 
# Unoffical Revision by Dark Rain
# Verion 0.9.1
# November 7th 2002

# Copyright (c)1995 Dan Melchione - All Rights Reserved

# You have permission to distrbute this file without charge,
# but may not alter it in any way.  This includes copying
# the included information for you own description of the
# 3do file format.  Please if send me any change requests.
# Thanks for your cooperation.

# About the revision : Well the website is dead and it's been
# FOUR years so I assume its a moot point to try to contact him.

# The latest version of this document can be found at: 
  # "http://www.tauniverse.com/~visual-ta/" , in the file format section.


# The old link for the latest version was :
  # http://www.melchione.com/totala/formats/3dofrmt.txt
# But it's dead so....

# Question, Comments, Complaints To: dmelchione@melchione.com

# Question, Comments, Complaints about this revision To: RochDenis@hotmail.com

# .3do files are used by Total Annihilation (designed by Chris Taylor)
# for drawing the 3 dimensional objects (hence the extension of .3do).
# This document what I have found about the file format so far.

# The numbers used in this file are hexadecimal.

# The beginning of the file starts with following structure:

# typedef struct tagObject
# {
    # long VersionSignature;
    # long NumberOfVertexes;
    # long NumberOfPrimitives;
    # long OffsetToselectionPrimitive;
    # long XFromParent;
    # long YFromParent;
    # long ZFromParent;
    # long OffsetToObjectName;
    # long Always_0;
    # long OffsetToVertexArray;
    # long OffsetToPrimitiveArray;
    # long OffsetToSiblingObject;
    # long OffsetToChildObject;
# } Object;

# /*
# The fields of this structure are:

# VersionSignature:
# This is field is always one.  I assume that it represents the signature
# (which is a somewhat standard thing to do at the beginning of a
# structure)

# NumberOfVertexes:
# This field represents the number of vertexes used by this object.  A
# vertex is simply a 3D point.

# NumberOfPrimitives:
# This field represents the number of primitives used by this object.
# A primitive is a simple 3D object like a point, line, triangle, or
# quad.

# OffsetToselectionPrimitive:
# This fiel is an offset to a primitive in the parent object that
# will serve as the "selection" rectangle in TA.  All Child
# and Sibling objects should have this value set to -1.

# XFromParent:
# YFromParent:
# ZFromParent:
# This appears to be the location of the object relative to the parent
# object.  This first object in a file doesn't have any parents.
# It appears to be a fixed-point integer. The scale is the same as the
# one used to describe the primitives of an object.

# OffsetToObjectName:
# This field is an offset to the name of the object.  The name of the
# object is stored as a null terminated string.

# Always_0:
# This field appears to always be zero.  If anyone finds a case where this
# is not so, or has any more onfo, please let me know.

# OffsetToVertexArray:
# This is an offset to an array of vertexes used by this object.  The
# number of vertexes in the array is stored above in NumberOfVertexes.

# OffsetToPrimitiveArray:
# This is an offset to an array of primitives used by this object.  The
# number of primitives is stored above in NumberOfPrimitives.

# OffsetToSiblingObject:
# This is an offset to a sibling object.  A sibling object is an object
# which shares the same parent as this object.  The sibling object
# structure appears to be identical.  The objects act like a linked
# list, terminated by a NULL (offset 00000000)

# OffsetToChildObject:
# This is an offset to a child object.  A child object is an object
# which has the current object as a parent.  The child object
# structure appears to be identical. The objects act like a linked
# list, terminated by a NULL (offset 00000000)

# */

# If we examine the armsy.3do file (the arm shipyard) and overlay the
# above structure we end up with the following:

# 00000000 Object
 # 01 00 00 00  00000001  VersionSignature
 # C4 00 00 00  000000C4  VertexCount
 # 6D 00 00 00  0000006D  PrimitiveCount
 # 00 00 00 00  00000000  OffsetToselectionPrimitive
# 00000010 
 # 00 00 00 00  00000000  XFromParent
 # 00 00 00 00  00000000  YFromParent
 # 00 00 00 00  00000000  ZFromParent
 # E5 1A 00 00  00001AE5  OffsetToObjectName (base)
# 00000020 
 # 00 00 00 00  00000000  Always_0
 # 15 04 00 00  00000415  OffsetToVertexArray
 # 45 0D 00 00  00000D45  OffsetToPrimitiveArray
 # 00 00 00 00  00000000  OffsetToSiblingObject
# 00000030               
 # EA 1A 00 00  00001AEA  OffsetToChildObject

# The object has C4 vertexes (at offset 415), 6D primitives (at offset D45),
# the name of the object is base, and it has a child object at offset 00001AEA. 

# The child object at 1AEA has the same structure:

# 00001AEA Object
 # 01 00 00 00  00000001  VersionSignature
 # 29 00 00 00  00000029  VertexCount
 # 25 00 00 00  00000025  PrimitiveCount
 # FF FF FF FF  FFFFFFFF  OffsetToselectionPrimitive
# 00001AFA 
 # 01 00 CD FF  FFCD0001  XFromParent
 # 00 40 F7 FF  FFF74000  YFromParent
 # 00 40 CC FF  FFCC4000  ZFromParent
 # DA 22 00 00  000022DD  OffsetToObjectName (turret)
# 00001B0A 
 # 00 00 00 00  00000000  Always_0
 # 4E 1C 00 00  00001C4E  OffsetToVertexArray
 # 3A 1E 00 00  00001E3A  OffsetToPrimitiveArray
 # E2 22 00 00  000022E2  OffsetToSiblingObject
# 00001B1A               
 # 00 37 00 00  00003700  OffsetToChildObject

# In this case the object has 29 vertexes (at offset 1C4E), 25 primitives
# (at offset 1E3A), a sibling object at offset 22E2, and a child object
# at offset 3700.

# If you repeat following the sibling and child object nodes you end
# up with the following tree of objects:
    # base
      # turret1
        # nano1
          # beam1
      # turret2
        # nano2
          # beam2
      # slip
      # light
      # explode
      # explode1
      # explode2

# We find that a number of the objects (for example slip) have only one 
# vertex and no primitives. This is used in scripting, you can set smoke
# points, targets, explosions etc etc.

# 00002ADA 
 # 01 00 00 00  00000001  VersionSignature
 # 01 00 00 00  00000001  VertexCount
 # 00 00 00 00  00000000  PrimitiveCount
 # FF FF FF FF  FFFFFFFF  OffsetToselectionPrimitive
# 00002AEA 
 # 00 00 00 00  00000000  XFromParent
 # 00 40 F7 FF  FFF74000  YFromParent
 # 00 00 00 00  00000000  ZFromParent
 # 1A 2B 00 00  00002B1A  OffsetToObjectName (slip)
# 00002AFA 
 # 00 00 00 00  00000000  Always_0
 # 0E 2B 00 00  00002B0E  OffsetToVertexArray
 # 1A 2B 00 00  00002B1A  OffsetToPrimitiveArray
 # 1F 2B 00 00  00002B1F  OffsetToSiblingObject
# 00002B0A               
 # 00 00 00 00  00000000  OffsetToChildObject

# In cavedog created .3do files a list of texture names always appear
# to be stored at offset 00000034 (more on this later):

# From armysy.3d0:

# char TextureNameArray[][];

# 00000034 TextureNameArray 
         # * Pointed to by OffsetToTextureName in PrimitiveArray
         # * Always at offset 34 for cavedog units
 # 6E 6F 69 73 65 36 62 00 41 72 6D 34 62 00 41 72 noise6b.Arm4b.Ar
 # 6D 42 75 69 32 62 00 41 72 6D 56 33 62 00 67 72 mBui2b.ArmV3b.gr
 # 61 79 6E 6F 69 73 65 33 00 6E 6F 69 73 65 32 62 aynoise3.noise2b
 # 00 41 72 6D 70 61 6E 65 6C 31 00 33 32 58 47 6F .Armpanel1.32XGo
 # 75 72 61 75 64 00 6E 6F 69 73 65 36 61 00 66 6C uraud.noise6a.fl
 # 61 73 68 69 6E 67 30 32 00 6D 65 74 61 6C 33 63 ashing02.metal3c
 # 00 6D 65 74 61 6C 33 61 00 6D 65 74 61 6C 33 62 .metal3a.metal3b
 # 00                                              .

# In cavedog created .3do files after the texture names appears to be a 
# list of vertex indexes (more on this later)

# short VertexIndexArray[];

# 000000A5 VertexIndexArray
         # * Pointed to by OffsetToVertexIndexArray in PrimitiveArray
 # C0 00 
 # C3 00 
 # C1 00 
 # C2 00 
 # B9 00 
 # B8 00 
 # BB 00 
 # BA 00
# 000000B5 
 # ...
# 00000405 
 # 06 00 
 # 0E 00 
 # 0F 00 
 # 07 00 
 # 08 00 
 # 00 00 
 # 07 00 
 # 0F 00

# In cavedog created .3do files after the vertex indexes appears to be
# the vertexes themselves.  These vertexes are pointed to in the Object
# structure (above) by the OffsetToVertexArray field.  The format
# appears to be the following:

# typedef struct tagVertex
# {
    # long x;
    # long y;
    # long z;
# } Vertex;

# Vertex VertexArray[];

# 00000415 
 # 6D 9A D0 FF VertexArray[0].x
 # 00 40 F7 FF VertexArray[0].y
 # 7B 59 32 00 VertexArray[0].z
 # AD 98 CF FF VertexArray[1].x
# 00000425 
 # ...         ...
# 00000535 
 # 6C DA C3 FF VertexArray[C2].z
 # 00 C0 0D 00 VertexArray[C3].y
 # 7B 19 2A 00 VertexArray[C3].x
 # 6C 5A D7 FF VertexArray[C3].z

# In cavedog created .3do files after the vertexes appears to be
# the array of primitives.  These primitives are pointed to in the Object
# structure (above) by the OffsetToPrimitiveArray field.  The format
# appears to be the following:

# typedef struct tagPrimitive
# {
    # long ColorIndex;
    # long NumberOfVertexIndexes;
    # long Always_0;
    # long OffsetToVertexIndexArray;
    # long OffsetToTextureName;
    # long Unknown_1;
    # long Unknown_2;
    # long Unknown_3;    
# } Primitive;

# /* 
# ColorIndex:
# This is the index of a color in the TA color palette. For the color
# palette, check out at the very end of this file for more detail, it
# would take too much space to display here.

# NumberOfVertexIndexes:
  # This indicates the number of vertexes used by the primitive as well 
  # as the primitive type (example: 1 = point, 2 = line, 3 = triangle,
  # 4 = quad)

# Always_0:
  # This field always appears to be 0.

# OffsetToVertexIndexArray:
  # This points to a an array of shorts which are indexes into the objects
  # vertex array.  This allows multiple primitives to share the same
  # vertexes.

# OffsetToTextureName:
  # This points to a null terminated string which indicates which texture
  # to use for this primtive.  A value of 0 probably means no texture.

  # You may notice that there is no u,v mapping coordinates for
  # the textures. That's because you have to generate them. They're
  # generated via the order of the polygon indexes. It really depends
  # on you API which index is the "TO RIGHT" of the texture, the "BOTTOM LEFT" etc.
  # You have to find it yourself. A good trick to do that, is to just have a ground
  # plate in 3do builder and apply a texture to it. Fiddle with the textures coordinates
  # order till you get the same result. You might have noticed that 3DO builder allows
  # you to set the orientation of a texture? It simply does that by changing the index
  # order.


# Unknown_1:
# Unknown_2:
# Unknown_3:
# These are Cavedog-specific used for their editor, and are 
# not needed.  Always set to 0 or ignore them.

# */

# From armsy.3d0:
# 00000D45 PrimitiveArray
         # * Pointed to by OffsetToPrimitiveArray in Header
# 00000D45 
 # 00 00 00 00 Unknown_0
 # 04 00 00 00 NumberOfVertexIndexes
 # 00 00 00 00 Always_0
 # A5 00 00 00 OffsetToVertexIndexArray
 # 00 00 00 00 OffsetToTextureName
 # 00 00 00 00 Unknown_0
 # 00 00 00 00 Unknown_1
 # 01 00 00 00 Unknown_2
# 00000D65 
# ...          ...
# 00001AC5 
 # 00 00 00 00 Unknown_0
 # 04 00 00 00 NumberOfVertexIndexes
 # 00 00 00 00 Always_0
 # 0D 04 00 00 OffsetToVertexIndexArray
 # 52 00 00 00 OffsetToTextureName
 # 00 00 00 00 Unknown_0
 # 00 00 00 00 Unknown_1
 # 00 00 00 00 Unknown_2

# In cavedog created .3do files after the pritives appears more objects,
# texture names, etc.  By following the linked lists in the Object 
# structures you can map out the entire file.

# You may notice that there is no animation data stored in these files.
# This is because the animation data is stored in .bos (basic object script?)
# files which are compiled into .cob (cobble) files.  I haven't started
# looking at these yet, so if anyone has any useful infomation please
# let me know.

# Well thats it for now, check back for updates.  Let me know what
# you find so we can share the wealth.


# Dan Melchione
# dmelchione@melchione.com

# Dark Rain
# RochDenis@hotmail.com

# -----------
