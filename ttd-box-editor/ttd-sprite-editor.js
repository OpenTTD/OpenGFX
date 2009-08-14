/*
TTD Sprite Editor, provides a DHTML/JS sprite editor for use with OpenTTD.
Copyright (C) 2009 Frode Austvik

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

----

Note that this sprite editor uses TTDW Palette, which must be included too.
See ttd-win-palette.js for that.
*/
function spriteEditor(xSize,ySize) {
	this.xs=xSize;
	this.ys=ySize;
}

spriteEditor.prototype={
	xs:0, // The X size of the sprite
	ys:0, // The Y size of the sprite
	box:null, // The box containing the editor (div)
	small:null, // The small view of the sprite (table)
	large:null, // The large view of the sprite (table)
	placeHere:function spriteEditor_placeHere(container,title,className,index) {
		if (this.xs<1 || this.ys<1) {
			return false;
		}
		if (typeof(className)=='undefined') {
			className='';
		} else {
			className=' '+className;
		}
		this.box=document.createElement('div');
		this.box.className='sprite-editor-box'+className;
		if (typeof(title)=='string' && title!='') {
			var header=document.createElement('h2');
			header.appendChild(document.createTextNode(title));
			this.box.appendChild(header);
		}
		this.small=document.createElement('table');
		this.small.cellSpacing=0;this.small.cellPadding=0;this.small.border=0;
		this.small.className='sprite-editor small';
		this.box.appendChild(this.small);
		this.large=document.createElement('table');
		this.large.cellSpacing=0;this.large.cellPadding=0;this.large.border=0;
		this.large.className='sprite-editor large';
		this.box.appendChild(this.large);
		this.createOnClick();
		this.updateSize();
		if (typeof(container)=='undefined' || !container) {
			container=document.getElementsByTagName('body')[0];
		}
		if (typeof(index)=='number' && index>=0) {
			var node=container.firstChild;
			while(index>0 && node.nextSibling) { node=node.nextSibling;index--; }
			index=node;
		}
		if (typeof(index)!='object' || index<0) {
			container.appendChild(this.box);
		} else {
			container.insertBefore(this.box,index);
		}
	},
	setSize:function spriteEditor_setSize(x,y) {
		if (x<1 || y<1) { return false; }
		if (this.xs!=x || this.ys!=y) {
			this.xs=x;
			this.ys=y;
			this.updateSize();
		}
		return true;
	},
	fill:function spriteEditor_fill(fillPattern,fromRight,offx,offy) {
		if (typeof(fromRight)!='boolean') fromRight=false;
		if (typeof(offx)!='number') offx=0;
		if (typeof(offy)!='number') offy=0;
		var pattern=this.convertPatternColors(fillPattern);
		if (!pattern) {
			// Invalid pattern, so don't fill with it
			return;
		}
		var py=pattern.length;
		var xofs=0;
		if (fromRight) {
			xofs=(pattern[0].length)-((this.xs)%(pattern[0].length));
		}
		while(offx<0) { offx+=pattern[0].length; }
		while(offy<0) { offy+=py; }
		xofs+=offx;
		for(var y=0;y<this.ys;y++) {
			var row=pattern[(y+offy)%py];
			var cellsSmall=this.small.rows[y].cells;
			var cellsLarge=this.large.rows[y].cells;
			for(var x=0;x<this.xs;x++) {
				var color=row[(x+xofs)%row.length];
				cellsSmall[x].className=color;
				cellsLarge[x].className=color;
			}
		}
	},
	shift:function spriteEditor_shift(xs,ys) {
		xs%=this.xs;
		ys%=this.ys;
		if (xs!=0 || ys!=0) {
			while(xs<0) { xs+=this.xs; }
			while(ys<0) { ys+=this.ys; }
			var data=this.getImageData();
			var out=[];
			for(var y=0;y<this.ys;y++) {
				var tmp=[];
				for(var x=0;x<this.xs;x++) {
					tmp.push(data[(y+ys)%this.ys][(x+xs)%this.xs]);
				}
				out.push(tmp);
			}
			this.fill(out);
		}
	},
	putPixel:function spriteEditor_putPixel(x,y,color) {
		if (typeof(color)=='string' && color.substr(0,1)!='c') {
			color='c'+color;
		}
		if (typeof(color)=='number') {
			color='c'+color;
		}
		if (x<0 || x>=this.xs) {
			if (x>-2 && x<this.xs+2) alert('pP: Invalid x: '+x);
			return;
		}
		if (y<0 || y>=this.ys) {
			if (y>-2 && y<this.ys+2) alert('pP: Invalid y: '+y);
			return;
		}
		this.small.rows[y].cells[x].className=color;
		this.large.rows[y].cells[x].className=color;
	},
	adjustAllPixels:function spriteEditor_adjustAllPixels(howMuch) {
		if (typeof(howMuch)!='number') return;
		if (howMuch==0) return;
		var data=this.getImageData();
		for(var y=0;y<data.length;y++) {
			for(var x=0;x<data[y].length;x++) {
				data[y][x]=Math.max(0,Math.min(255,data[y][x]+howMuch));
			}
		}
		this.fill(data);
	},
	adjustPixelValues:function spriteEditor_adjustPixelValues(data,howMuch) {
		if (typeof(howMuch)!='number') return;
		if (howMuch==0) return;
		var out=[];
		for(var y=0;y<data.length;y++) {
			var tmp=[];
			for(var x=0;x<data[y].length;x++) {
				tmp.push(Math.max(0,Math.min(255,data[y][x]+howMuch)));
			}
			out.push(tmp);
		}
		return out;
	},
	getImageData:function spriteEditor_getImageData() {
		var data=[];
		for(var y=0;y<this.ys;y++) {
			var cells=this.large.rows[y].cells;
			var dataRow=[];
			for(var x=0;x<this.xs;x++) {
				var color=cells[x].className;
				if (color.substr(0,1)=='c') {
					color=color.substr(1);
				}
				color=parseInt(color);
				dataRow.push(color);
			}
			data.push(dataRow);
		}
		return data;
	},
	convertPatternColors:function spriteEditor_convertPatternColors(pattern) {
		var out=[];
		var py=pattern.length;
		if (py<1) return false; // Abort if empty pattern
		for(var y=0;y<py;y++) {
			var px=pattern[y].length;
			if (px<1) return false; // Abort if empty pattern
			var tmp=[];
			for(var x=0;x<px;x++) {
				if (typeof(pattern[y][x])=='string' && pattern[y][x].substr(0,1)!='c') {
					tmp.push('c'+pattern[y][x]);
				} else if (typeof(pattern[y][x])=='number') {
					tmp.push('c'+pattern[y][x]);
				} else {
					tmp.push(pattern[y][x]);
				}
			}
			out.push(tmp);
		}
		return out;
	},
	getDominantColor:function spriteEditor_getDominantColor(data) {
		if (typeof(data)=='undefined') data=this.getImageData();
		var colorCounts=[];
		var datalen=data.length;
		for(var y=0;y<datalen;y++) {
			var len=data[y].length;
			for(var x=0;x<len;x++) {
				var color=data[y][x];
				while(colorCounts.length<=color) colorCounts.push(0);
				colorCounts[color]++;
			}
		}
		var max=0;
		var maxI=0;
		for(var i=1;i<colorCounts.length;i++) {
			if (colorCounts[i]>max) {
				max=colorCounts[i];
				maxI=i;
			}
		}
		return maxI;
	},
	clearKeepTransparent:function spriteEditor_clearKeepTransparent(data,clearColor) {
		if (typeof(data)=='undefined') {
			this.fill(this.clearKeepTransparent(this.getImageData()));
			return;
		}
		if (typeof(clearColor)=='undefined') clearColor=this.getDominantColor(data);
		var out=[];
		for(var y=0;y<data.length;y++) {
			var tmp=[];
			for(var x=0;x<data[y].length;x++) {
				if (data[y][x]==0) {
					tmp.push(0);
				} else {
					tmp.push(clearColor);
				}
			}
			out.push(tmp);
		}
		return out;
	},
	cellOnClick:null,
	createOnClick:function spriteEditor_createOnClick() {
		var editor=this;
		this.cellOnClick=function(e) {
			if (!e) var e=window.event;
			editor.handleOnClick(this,e);
			return false;
		}
	},
	updateSize:function spriteEditor_updateSize(table) {
		if (this.xs<1 || this.ys<1) {
			return false;
		}
		if (typeof(table)=='undefined') {
			return this.updateSize(this.large) && this.updateSize(this.small);
		}
		while (table.rows.length<this.ys) {
			var row=table.insertRow(table.rows.length);
			while (row.cells.length<this.xs) {
				var td=document.createElement('td');
				td.className='c0';
				td.onclick=this.cellOnClick;
				row.appendChild(td);
			}
		}
		while (table.rows.length>this.ys) {
			table.deleteRow(this.ys);
		}
		for(var i=0;i<this.ys;i++) {
			while (table.rows[i].cells.length<this.xs) {
				var td=document.createElement('td');
				td.className='c0';
				td.onclick=this.cellOnClick;
				table.rows[i].appendChild(td);
			}
			while (table.rows[i].cells.length>this.xs) {
				table.rows[i].deleteCell(this.xs);
			}
		}
		return true;
	},
	handleOnClick:function spriteEditor_handleOnClick(cell,e) {
		if (e.ctrlKey) {
			if (cell.className!='') {
				palette.selectColor(cell.className);
			}
			return;
		}
		var color=palette.getSelectedColor();
		var cx=cell.cellIndex;
		var row=cell;
		while (row && row.tagName!='TR' && row.parentNode) {
			row=row.parentNode;
		}
		if (!row || row.tagName!='TR') {
			// Failed to find the row this cell belongs to
			return;
		}
		var cy=row.rowIndex;
		this.putPixel(cx,cy,color);
	},
	addSizeControl:function spriteEditor_addSizeControl(name,className,funcP,funcM) {
		var tmp=document.createElement('div');
		tmp.className='size-control '+className;
		pattern.sizes.appendChild(tmp);
		tmp.appendChild(document.createTextNode(name));
		var tmp2=document.createElement('div');
		tmp2.className='controls';
		tmp.appendChild(tmp2);
		tmp=tmp2;
		var a=document.createElement('a');
		a.href='javascript:void(0);';
		a.className='size-plus';
		a.onclick=funcP;
		a.appendChild(document.createTextNode('+'));
		tmp.appendChild(a);
		var a=document.createElement('a');
		a.href='javascript:void(0);';
		a.className='size-minus';
		a.onclick=funcM;
		a.appendChild(document.createTextNode('-'));
		tmp.appendChild(a);
	},
	addSizeControls:function spriteEditor_addSizeControls() {
		pattern.sizes=document.createElement('div');
		pattern.sizes.className='pattern-size-controls';
		pattern.box.appendChild(pattern.sizes);
		pattern.addSizeControl('X','size-control-x',
			function(e) { pattern.setSize(pattern.xs+1,pattern.ys);return false; },
			function(e) { if (pattern.xs>1) pattern.setSize(pattern.xs-1,pattern.ys);return false; }
		);
		pattern.addSizeControl('Y','size-control-y',
			function(e) { pattern.setSize(pattern.xs,pattern.ys+1);return false; },
			function(e) { if (pattern.ys>1) pattern.setSize(pattern.xs,pattern.ys-1);return false; }
		);
	},
	addColorControls:function spriteEditor_addColorControls() {
		pattern.colors=document.createElement('div');
		pattern.colors.className='pattern-color-controls';
		pattern.box.appendChild(pattern.colors);
		pattern.colors.appendChild(document.createTextNode('color: '));
		var a=document.createElement('a');
		a.href='javascript:void(0);';
		a.appendChild(document.createTextNode('--'));
		a.onclick=function(e) { pattern.adjustAllPixels(-1); }
		pattern.colors.appendChild(a);
		pattern.colors.appendChild(document.createTextNode(' '));
		a=document.createElement('a');
		a.href='javascript:void(0);';
		a.appendChild(document.createTextNode('++'));
		a.onclick=function(e) { pattern.adjustAllPixels(1); }
		pattern.colors.appendChild(a);
	},
	addShiftControl:function spriteEditor_addShiftControl(text,func) {
		var a=document.createElement('a');
		a.href='javascript:void(0);';
		a.appendChild(document.createTextNode(text));
		a.onclick=func;
		this.shifts.appendChild(a);
	},
	addShiftControls:function spriteEditor_addShiftControls() {
		this.shifts=document.createElement('div');
		this.shifts.className='shift-controls';
		this.box.appendChild(pattern.shifts);
		var editor=this;
		this.shifts.appendChild(document.createTextNode('shift: '));
		this.addShiftControl('<',function(e) { editor.shift(1,0);return false; });
		this.shifts.appendChild(document.createTextNode(' '));
		this.addShiftControl('^',function(e) { editor.shift(0,1);return false; });
		this.shifts.appendChild(document.createTextNode(' '));
		this.addShiftControl('>',function(e) { editor.shift(-1,0);return false; });
		this.shifts.appendChild(document.createTextNode(' '));
		this.addShiftControl('v',function(e) { editor.shift(0,-1);return false; });
	}
}
