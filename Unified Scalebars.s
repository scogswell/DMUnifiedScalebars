// A script to set all the open images to the same displayed scalebar length. 
// Doesn't change calibration of images, so if images have different magnifications the bars will be different (but correct) lengths
// Scalebar position doesn't change, but will change length.  
//
// Note DM quantizes scalebar display to specific values (0.5 nm, 1 nm, 2 nm, 5 nm, 10 nm, 20 nm, etc), regardless of what you enter.
// Also, choice of a larger fontsize may make the scalebar snap to the next highest display value.  Decrease your fontsize in that case.  
// 
// Steven Cogswell, P.Eng.
// October 2012
//
// Thanks to Pavel Potapov and D.R.G. Mitchell (Scale_bar_control.s) for information how to handle scalebars and annotations in DM script

Image curr
ImageDocument imgdoc
number NumAnn, AnnID,AnnType,Fontsize
number TextID, left,right,bottom,top, retval, numwindows, i
number scalex,scaley, nmscale, barwidth
string imagename

// User chance to abort entire operation
retval = ContinueCancelDialog("This script tries to give all open images the same displayed scalebar value")
if (retval == 0) {            // 0 if user cancelled, 1 if okay
	result("Cancelled.\n") 
	exit(0)
}

// Get desired scalebar length
nmscale=20
retval = GetNumber("Desired Scalebar Length", 20, nmscale)
if (retval == 0) {            // 0 if user cancelled, 1 if okay
	result("Cancelled.\n") 
	exit(0)
}
result("User entered scale "+nmscale+"\n")
nmscale=nmscale+0.01  // Rounding makes the scale a little short, this just bumps it up. 

// Get desired font size
Fontsize=20
retval = GetNumber("Desired Font Size", 20, Fontsize)
if (retval == 0) {   // 0 if user cancelled, 1 if okay
	result("Cancelled.\n")
	exit(0)
}
result("User entered font size "+Fontsize+"\n");  

// Processing
numwindows = CountDocumentWindowsOfType(5)
  // Get number of images open
result("Processing "+numwindows+" images\n")

// Loop over all open windows 
for (i=0; i<numwindows; i++) {

	imgdoc=GetImageDocument(i)
	curr:=imgdoc.ImageDocumentGetImage(0)     // The current image being processed
	imagename = curr.GetName()    // Display name of image 

	GetScale(curr,scalex,scaley)
	result("Image "+imagename+" X scale: "+scalex+" Y scale:"+scaley+"\n")
	barwidth=nmscale/scalex     // number of pixels a bar of nmscale would actually be

	//loop through annotation index
	NumAnn = CountAnnotations(Curr)     // Get number of annotations in current image
	for (number j=0; j<NumAnn; j++)
	{
		AnnId = GetNthannotationId(curr, j)
		annType=AnnotationType(curr,AnnID)

		if(annType==31)    // type 31 seems to be the scalebars
		{
	  		result("scale bar found: ")
	  		GetAnnotationRect(Curr, AnnId, top, left, bottom, right)
			result("scalebar box: L:"+left+",R:"+right+",B:"+bottom+",T:"+top+"\n")
	  		SetAnnotationRect(Curr, AnnId, top,left, bottom, left+barwidth)     // Same position, lengthen bar to length of nmscale
	  		SetAnnotationSize(Curr, AnnId, FontSize)   // Set the font size
		}
	}
}

result("All Images Done.\n")
