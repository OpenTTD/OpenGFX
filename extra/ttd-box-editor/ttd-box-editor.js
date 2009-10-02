/*
Javascript for TTD Box Editor.
Copyright (C) 2009 Frode Austvik
GPLv2, see the ttd-box-editor.html file for the full copyright notice.
*/
function spriteEditor3D(x,y) {
	var editor=new spriteEditor(x,y);
	for(var f in editor) {
		if (typeof(this[f])=='undefined') {
			this[f]=editor[f];
		}
	}
}
spriteEditor3D.prototype={
	fillRight:function spriteEditor3D_fillRight(pattern,fromRight) {
		if (!pattern) return;
		if (typeof(fromRight)!='boolean') fromRight=false;
		var xmax=Math.floor(this.xs/2);
		var ymax=this.ys-xmax;
		var xofs=0;
		if (fromRight) {
			xofs=(pattern[0].length)-(xmax%(pattern[0].length));
		}
		var py=pattern.length;
		for(var x=0;x<xmax;x++) {
			var xpos=xmax+x;
			var ybase=xmax-Math.floor(x/2);
			for(var y=0;y<ymax;y++) {
				var row=pattern[y%py];
				var color=row[(x+xofs)%(row.length)];
				if (color!=0 && color!='c0') {
					this.putPixel(xpos,ybase+y,color);
				}
			}
		}
	},
	fillLeft:function spriteEditor3D_fillLeft(pattern,fromRight) {
		if (!pattern) return;
		if (typeof(fromRight)!='boolean') fromRight=false;
		var xmax=Math.floor(this.xs/2);
		var ymax=this.ys-xmax;
		var xofs=0;
		if (fromRight) {
			xofs=(pattern[0].length)-(xmax%(pattern[0].length));
		}
		var py=pattern.length;
		for(var x=0;x<xmax;x++) {
			var xpos=x;
			var ybase=xmax-Math.floor((xmax-x-1)/2);
			for(var y=0;y<ymax;y++) {
				var row=pattern[y%py];
				var color=row[(x+xofs)%(row.length)];
				if (color!=0 && color!='c0') {
					this.putPixel(xpos,ybase+y,color);
				}
			}
		}
	},
	fillTop:function spriteEditor3D_fillTop(pattern,fromRight) {
		if (!pattern) return;
		if (typeof(fromRight)!='boolean') fromRight=false;
		var py=pattern.length;
		var xmax=Math.floor(this.xs/2);
		var ymax=xmax+1;
		var yofs=py-((xmax)%(py));
		var xofs=0;
		if (fromRight) {
			xofs=(pattern[0].length)-(xmax%(pattern[0].length));
		}
		for(var y=0;y<ymax;y++) {
			var row=pattern[(y+yofs)%py];
			var px=row.length;
			for(var x=0;x<xmax;x++) {
				var mx=xmax+x-y;
				var my=Math.floor((y+x+1)/2);
				var color=row[(x+xofs)%px];
				if (color!=0 && color!='c0') {
					view3d.putPixel(mx,my,color);
				}
			}
		}
	},
	fillRearRight:function spriteEditor3D_fillRearRight(pattern,fromRight) {
		if (!pattern) return;
		if (typeof(fromRight)!='boolean') fromRight=false;
		var xmax=Math.floor(this.xs/2);
		var ymax=this.ys-xmax;
		var ybased=Math.floor(xmax/2);
		var xofs=0;
		if (fromRight) {
			xofs=(pattern[0].length)-(xmax%(pattern[0].length));
		}
		var py=pattern.length;
		for(var x=0;x<xmax;x++) {
			var xpos=xmax+x;
			var ybase=ybased-Math.floor((xmax-x-1)/2);
			for(var y=0;y<ymax;y++) {
				var row=pattern[y%py];
				this.putPixel(xpos,ybase+y,row[(this.xs-1-x-xofs)%(row.length)]);
			}
		}
	},
	fillRearLeft:function spriteEditor3D_fillRearLeft(pattern,fromRight) {
		if (!pattern) return;
		if (typeof(fromRight)!='boolean') fromRight=false;
		var xmax=Math.floor(this.xs/2);
		var ymax=this.ys-xmax;
		var ybased=Math.floor(xmax/2);
		var xofs=0;
		if (fromRight) {
			xofs=(pattern[0].length)-(xmax%(pattern[0].length));
		}
		var py=pattern.length;
		for(var x=0;x<xmax;x++) {
			var xpos=x;
			var ybase=ybased-Math.floor(x/2);
			for(var y=0;y<ymax;y++) {
				var row=pattern[y%py];
				this.putPixel(xpos,ybase+y,row[(xmax-1-x-xofs)%(row.length)]);
			}
		}
	},
	drawContent:function spriteEditor3D_drawContent(content) {
		if (typeof(content.image)=='undefined') return;
		var xpos=Math.floor(this.xs/2)-1;
		var ypos=this.ys-31;
		xpos+=content.xrel;
		ypos+=content.yrel;
		var xstart=(xpos<0?-xpos:0);
		var ystart=(ypos<0?-ypos:0);
		for(var y=ystart;y<content.image.length && y+ypos<this.ys;y++) {
			var line=content.image[y];
			for(var x=xstart;x<line.length && x+xpos<this.xs;x++) {
				if (line[x]!=0) {
					this.putPixel(x+xpos,y+ypos,line[x]);
				}
			}
		}
	},
	fill3D:function spriteEditor3D_fill3D(pattern,adjust) {
		if (typeof(adjust)!='number') adjust=0;
		
		var insideColor=this.getDominantColor(pattern);
		var value=Math.max(0,Math.min(255,insideColor+adjust));
		
		var patternDark=this.adjustPixelValues(pattern,adjust);
		var patternDarker=this.adjustPixelValues(patternDark,adjust);
		
		this.fill([[0]]);
		if (value>0) {
			var rearDark=this.clearKeepTransparent(pattern,value);
			var rearDarker=this.adjustPixelValues(rearDark,adjust);
			this.fillRearLeft(rearDark);
			this.fillRearRight(rearDarker);
		}
		if (typeof(boxContent.lastSprite)!='undefined') {
			this.drawContent(boxContent.lastSprite);
		}
		this.fillTop(pattern,true);
		this.fillRight(patternDark);
		this.fillLeft(patternDarker,true);
	},
	fillAll:function spriteEditor3D_fillAll(patternTop,patternRight,patternLeft,patternRearRight,patternRearLeft) {
		this.fill([[0]]);
		if (typeof(patternRearLeft)!='undefined') this.fillRearLeft(patternRearLeft);
		if (typeof(patternRearRight)!='undefined') this.fillRearRight(patternRearRight);
		if (typeof(boxContent.lastSprite)!='undefined') this.drawContent(boxContent.lastSprite);
		this.fillTop(patternTop,false);
		this.fillRight(patternRight);
		this.fillLeft(patternLeft,true);
	}
}
function fillSides(pattern,adjust) {
	sideTop.fill(pattern,true,0,-sideTop.ys);
	if (typeof(adjust)=='number' && adjust!=0) {
		pattern=sideRight.adjustPixelValues(pattern,adjust);
	}
	sideRight.fill(pattern);
	sideRearLeft.fill(pattern,true,-sideLeft.xs);
	if (typeof(adjust)=='number' && adjust!=0) {
		pattern=sideRight.adjustPixelValues(pattern,adjust);
	}
	sideLeft.fill(pattern,true);
	sideRearRight.fill(pattern,false,sideRight.xs);
}
function setBoxHeight() {
	var hbox=document.getElementById('box-height');
	if (hbox && hbox.value!='') {
		var height=parseInt(hbox.value);
		if (typeof(height)=='number' && height>0) {
			sideLeft.setSize(sideLeft.xs,height);
			sideRight.setSize(sideRight.xs,height);
			sideRearLeft.setSize(sideRearLeft.xs,height);
			sideRearRight.setSize(sideRearRight.xs,height);
			view3d.setSize(view3d.xs,height+sideLeft.xs);
		}
	}
}
function setBoxWidth(width) {
	if (typeof(width)!='number') width=32;
	if (width<4 || width>256) return;
	sideTop.setSize(width,width);
	sideLeft.setSize(width,sideLeft.ys);
	sideRight.setSize(width,sideRight.ys);
	sideRearLeft.setSize(width,sideRearLeft.ys);
	sideRearRight.setSize(width,sideRearRight.ys);
	view3d.setSize(width*2,sideLeft.ys+width);
}
function saveImageData(image) {
	var data=image.getImageData();
	if (data.toSource) {
		document.getElementById('image-data').value=data.toSource();
	} else {
		alert('This browser does not support the toSource method, so saving is not currently supported.');
	}
}
function loadImageData(image) {
	var data=eval(document.getElementById('image-data').value);
	if (typeof(data.length)!='number' || data.length<1) {
		alert('Invalid data given. Must be a 2D array with image data (JSON format).');
	} else {
		image.fill(data);
	}
}
function openTheBox(weighting) {
	if (typeof(weighting)=='undefined') weighting=0;
	// First find the most used color on the top
	var topColor=sideTop.getDominantColor();
	if (topColor==0) {
		// Top is already transparent, look at the other sides
		topColor=findTopColor(sideRearLeft.getImageData());
		if (topColor<0) return;
		var topColor2=findTopColor(sideLeft.getImageData());
		if (topColor2<0) return;
		if (topColor==0) topColor=topColor2;
		if (topColor!=topColor2) return;
		topColor2=findTopColor(sideRight.getImageData());
		if (topColor2<0) return;
		if (topColor==0) topColor=topColor2;
		if (topColor!=topColor2) return;
		topColor2=findTopColor(sideRearRight.getImageData());
		if (topColor2<0) return;
		if (topColor==0) topColor=topColor2;
		if (topColor!=topColor2) return;
	}
	if (topColor==0) {
		// Everything is transparent apparently...
		return;
	}
	// Grab data for all sides and make it easier to work with
	var rl=sideRearLeft.getImageData();
	var l=sideLeft.getImageData();
	var r=sideRight.getImageData();
	var rr=sideRearRight.getImageData();
	var data=openTheBox_getHeights(rl,l,r,rr);
	var ym=rl.length-4;
	var xs=rl[0].length;
	var xm=xs*4;
	// Randomly move down the top of each side
	for(var i=0;i<500;i++) {
		var x=Math.floor(xm*Math.random());
		if (weighting!=0 && (i%weighting)==0) {
			x=(x+Math.floor(xm*Math.random()))/2;
		}
		if (data[x]<ym) {
			data[x]++;
			var x2=x;
			var x3=(x+1)%xm
			while (data[x3]<ym && data[x2]-data[x3]>1) {
				data[x3]++;
				x3=(x3+1)%xm;
				x2=(x2+1)%xm;
			}
			x2=x;
			x3=(x+xm-1)%xm
			while (data[x3]<ym && data[x2]-data[x3]>1) {
				data[x3]++;
				x3=(x3+xm-1)%xm;
				x2=(x2+xm-1)%xm;
			}
		}
	}
	// Draw the changes into the side data
	for(var x=0;x<xs;x++) {
		for(var y=0;y<data[x];y++) {
			rl[y][x]=0;
		}
		rl[data[x]][x]=topColor;
		for(var y=0;y<data[x+xs];y++) {
			l[y][x]=0;
		}
		l[data[x+xs]][x]=topColor;
		for(var y=0;y<data[x+xs*2];y++) {
			r[y][x]=0;
		}
		r[data[x+xs*2]][x]=topColor;
		for(var y=0;y<data[x+xs*3];y++) {
			rr[y][x]=0;
		}
		rr[data[x+xs*3]][x]=topColor;
	}
	// Fill the sides with the new data, and clear the top
	sideRearLeft.fill(rl);
	sideLeft.fill(l);
	sideRight.fill(r);
	sideRearRight.fill(rr);
	sideTop.fill([[0]]);
}
function openTheBox_getHeights(rl,l,r,rr) {
	var data={rl:[],l:[],r:[],rr:[]};
	var xs=rl[0].length;
	var ym=rl.length-1;
	for(var x=0;x<xs;x++) {
		var drl=true;
		var dl=true;
		var dr=true;
		var drr=true;
		for(var y=0;y<ym && (drl || dl || dr || drr);y++) {
			if (drl && rl[y][x]!=0) {
				data.rl.push(y);
				drl=false;
			}
			if (dl && l[y][x]!=0) {
				data.l.push(y);
				dl=false;
			}
			if (dr && r[y][x]!=0) {
				data.r.push(y);
				dr=false;
			}
			if (drr && rr[y][x]!=0) {
				data.rr.push(y);
				drr=false;
			}
		}
	}
	return data.rl.concat(data.l,data.r,data.rr);
}
function findTopColor(data) {
	var ys=data.length;
	var xs=data[0].length;
	var topColor=0;
	for(var x=0;x<xs;x++) {
		for(var y=0;y<ys;y++) {
			if (data[y][x]!=0) {
				if (topColor==0) {
					topColor=data[y][x];
					break;
				} else if (topColor==data[y][x]) {
					// Done with this line, move on to next
					break;
				} else {
					// Found a different top color.
					return -1;
				}
			}
		}
	}
	return topColor;
}
function loadOpenGFXSprite_done(sprite) {
	if (typeof(sprite.num)=='undefined' || !sprite.xsize || !sprite.ysize || !sprite.image) {
		alert("Load of OpenGFX sprite failed, bad data returned.");
		return;
	}
	boxContent.setSize(sprite.xsize,sprite.ysize);
	boxContent.fill(sprite.image);
	boxContent.lastSprite=sprite;
	var info='<hr/>';
	info+='Sprite:<br/>'+sprite.num+'<br/>';
	info+='Size:<br/>'+sprite.xsize+'x'+sprite.ysize+'<br/>';
	info+='Rel:<br/>'+sprite.xrel+'x'+sprite.yrel+'<br/>';
	if (typeof(boxContent.loadedSpriteInfo)=='undefined') {
		boxContent.loadedSpriteInfo=document.createElement('div');
		boxContent.loadedSpriteInfo.className='box-content-loaded-sprite-info';
		boxContent.spriteInfo.appendChild(boxContent.loadedSpriteInfo);
	}
	boxContent.loadedSpriteInfo.innerHTML=info;
}
function loadOpenGFXSprite() {
	var number=document.getElementById('opengfx-sprite-number');
	number=number.value;
	if (number=='') {
		alert("Must give the number of the sprite (as given in ogfx1_base.nfo)");
		return;
	}
	number=new Number(number);
	if (number>=0) {
		var spriterequest=ajaxRequest();
		if (!spriterequest) {
			alert("Couldn't get AJAX request object - does your browser support it?");
			return;
		}
		// Most ov the code in this function was copied from
		// http://www.javascriptkit.com/dhtmltutors/ajaxgetpost4.shtml
		spriterequest.onreadystatechange=function() {
			if (spriterequest.readyState==4) {
				if (spriterequest.status==200 || window.location.href.indexOf("http")==-1) {
					var jsondata=eval("("+spriterequest.responseText+")") //retrieve result as an JavaScript object
					loadOpenGFXSprite_done(jsondata);
				} else {
					alert("An error has occured while loading the OpenGFX sprite.");
				}
			}
		}
		spriterequest.open('GET','sprite-source/sprites/'+number+'.json',true);
		spriterequest.send(null);
	}
}
// this function is copied verbatim from http://www.javascriptkit.com/dhtmltutors/ajaxgetpost4.shtml
function ajaxRequest() {
	var activexmodes=["Msxml2.XMLHTTP", "Microsoft.XMLHTTP"] //activeX versions to check for in IE
	if (window.ActiveXObject){ //Test for support for ActiveXObject in IE first (as XMLHttpRequest in IE7 is broken)
		for (var i=0; i<activexmodes.length; i++){
			try{
				return new ActiveXObject(activexmodes[i])
			}
			catch(e){
				//suppress error
			}
		}
	}
	else if (window.XMLHttpRequest) // if Mozilla, Safari etc
		return new XMLHttpRequest()
	else
		return false
}