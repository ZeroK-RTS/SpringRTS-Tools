3DO Builder+ 2.1 (beta)
   by Immerman
   immerx@yahoo.com

An improvement of Kinboat's 3DO Builder 1.1 (see bottom of page) 


--------------------------------------------------------------------------------
3DO Builder+ 2.1 *released*
--------------------------------------------------------------------------------
OpenGL view now uses "nearest pixel"  textureing rather than linear interpolation 
	so that low-res textures which appear more like they do within TA.
	
Some reorganizing of menus and hot-keys (among oher things ctrl-C/ctrl-V are now unused - so they 
	work to copy/paste text from the various data fields)

right-dragging in a window zooms 
	ctrl-right-clicking resets
	(3D view has independent zooming)
	
shift-left-dragging pans the view
	ctrl-left-clicking resets
	(3D view has independent panning)

Alt-clicking any of the 2d views aligns the 3d view to match

Alt-clicking/dragging the 3D view shows the unit as it will appear in TA


F7/F8 rotate the selected texture

Ctrl-Alt-Doubleclicking will maximize/restore the 3D view without rotating it

Ctrl-Shift-Doubleclicking will zoom a view while maximizing/restoring it
	(Unit keeps the same size relative to the window)

Advanced|Other menu now works - has functions:

	Remove selected face - umm, not sure what this one does :)

	Create Face from polygon 
		-creates a multi-edged face out of the closed loop of 2-point "faces" (lines) that you get 
		if you export a polygon or closed poly-line from Rhino3D.
		  It comes in handy when you want to create faces with more than 4 sides since Rhino 
		can't handle them.  NOTE: you must Merge Duplicate Vertexes (Special menu) before it will work

	Create Faces from all Polygons
		- does the smae thing, except for all closed loops in the piece rather than just the one whose 
		first segment is selected.

Accurate texture deforming (under View|OpenGL View menu) - 
	applies textures to non-rectangular faces more acurately (usually) - somewhat CPU intensive
	
Voodoo3 Texture fixing (under View|OpenGL View menu)
	if the textures appear corrupted in the 3D view - memory intensize
	(Should also work for any other OpenGL implementation that has problems)
	
--------------------------------------------------------------------------------
3DO Builder+ 2.03 (beta)
--------------------------------------------------------------------------------
New features include:
  * "Use current position as Object Origin" updates child object positions 
      as well as vertices
  * "Clean Up Model..." works much better
  * Grid size can be specified in terms of the TA footprint dimensions 
      (from the .fbi files)
Bug fixes include
  * Advanced : Other toolbox is displayed
  * Remove Face is accessible and works correctly
--------------------------------------------------------------------------------
3DO Builder+ 2.02 (beta)
--------------------------------------------------------------------------------
New features include:
  * Distances are now measured using the same units as in the scripts
  * Quickkeys to change 3d viewing mode (Ctrl-F1 through F4) 
  * Optional background texture in 3D view (Ctrl-F7/F8 to enable/disable)
--------------------------------------------------------------------------------
3DO Builder+ 2.01 (beta)
--------------------------------------------------------------------------------
New features include:
  * Autocentering is also applied to 3D view 
  * Hitting ESC will cancel most dialogs

Bug fixes include:
  * 3D View color selection now works (View|Display Options...) 
--------------------------------------------------------------------------------
3DO Builder+ 2.0 (beta) *released*
--------------------------------------------------------------------------------
New features include:
  * Automated model "clean-up" available
  * Individual faces can be removed
  * Warnings are given before exiting or ceating new models
  * Currently selected face can be displayed in textured view
  * Back faces are no longer displayed
  * Textured triangles are now displayed (since TA:K supports them)

Bug fixes include:
  * A bug that caused the textured view to crash has been fixed
--------------------------------------------------------------------------------
3DO Builder+ 1.0 beta 3 
--------------------------------------------------------------------------------
New features include:
  * TA:K support
  * All new OpenGL views: wireframe, barframe, shaded, and textured
  * All changes are now immediately reflected in the OpenGL view
  * Merge duplicate vertices
  * Optional texture ratio preservation in "Faces" toolbox
  * Optional OpenGL zoom
  * Can change default texture angle (By rotating vertex order)

Bug fixes include:
  * Ground plates are now created/resized so that they face in the right direction(downward)

--------------------------------------------------------------------------------
3DO Builder+ 1.0 beta 2 *released*
--------------------------------------------------------------------------------
New feature include:
  * Copy/Paste of objects and branches by importing/exporting to 3doClipboard.3dt
  * Added unlimited zoom in/out, and zoom restore
  * Rotate/Scale can now be applied to entire object branches
  * A last chance warning is now given before creating a new 3DO

Bug fixes include:
  * using the move tool now moves a pieces origin, rather than it's "center"
  * move tool now works correctly in the Top view
  * move tool now works correctly in full screen Top and Side views
  * "Import Image..." in the unit picture window has been fixed

--------------------------------------------------------------------------------
3DO Builder+ 1.0 beta 1 *released*
--------------------------------------------------------------------------------
New features include:
  * Scale objects along each axis independently
  * Rotate objects around any axis
  * Manualy reposition individual vertices
  * Import/Export fully textured objects with new 3DE format
  * Import/Export entire object tree brances with new 3DT format
  * Optionaly display and reposition the origin of objects
  * Quick keys (F11/F12) for cycling through object faces 
  * Axis indicators in view windows
  * Faces:Apply... now keeps the 'From' and 'To' values for the current object
  * Faces:Apply... can now apply texture orientations as well

Bug fixes in include:  
  * Top and OpenGL views no longer display mirror images of the unit
  * The Faces:Apply... feature now works correctly with colored faces
  * Create Object... now makes sure that the new object name is unique
  * Scaling by zero is no longer possible

--------------------------------------------------------------------------------
3DO Builder 1.1  *released*
--------------------------------------------------------------------------------
3DO Builder 1.1
Copyright (C) 1998 by Kinboat
hotlizard@annihilated.org

Installation Notes
You must have OpenGL for Win32 installed to use 3DO Builder.  If you do not 
already have it installed on your system, extract opengl32.zip to your 
windows\system directory.

Features
  * Import/Export DXF, LWO, and OBJ 3D files
  * Quick texture auto-load
  * Instant export to TADD enhanced TA unit viewer
  * Point and click object move tool
  * Add/Remove/Rename objects
  * Inverse/Rotate faces
  * Custom texture import dialog
  * 4 views: Front, Top, Side, OpenGL Wireframe/Shaded
  * Unit Picture creation (GAF gadget file)
  * Grid display/Zoom tool

Thanks to
Blackthorn
Dan Melchione
DCS
Falcor
Inotek
Jeroen
Magar
PWD
Richie
Shinkage
Smitt
Storm3

Legaleese:
To the maximum extent permitted by law, Kinboat and Immerman  (hearafter refered to as the Programmers) disclaim all
warranties regarding this software, express or implied, including but not
limited to warranties of merchantability and fitness for a particular
purpose.  In no event shall the Programmers be liable for consequential,
special, incidental or indirect damages arising out of the use or inability
to use this software even if the Programmers are aware of the possibility of
such damages or a known defect.
