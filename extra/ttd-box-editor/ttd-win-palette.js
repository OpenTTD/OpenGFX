/*
TTDW Palette, provides a DHTML/JS palette with the colors from TTD-Windows.
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
*/

var palette={
	generate:function palette_generate(container) {
		var box=document.createElement('div');
		box.className='palette-box';
		box.appendChild(document.createTextNode('Palette:'));
		var table=document.createElement('table');
		table.cellSpacing=0;table.cellPadding=0;table.border=0;
		table.className='palette';
		box.appendChild(table);
		var newRow={
			c1:1,c10:1,c88:1,c198:1,
			c206:1,c216:1,c227:1,c232:1,c239:1,
			c241:1,c245:1,c246:1,c255:1
		};
		var tr=null;
		for(var i=0;i<256;i++) {
			if ((i%16)==0) {
				tr=table.insertRow(table.rows.length);
			}
			if (typeof(newRow['c'+i])!='undefined') {
				var td=document.createElement('td');
				td.colSpan=16-(i%16);
				tr.appendChild(td);
				tr=table.insertRow(table.rows.length);
				td=document.createElement('td');
				td.colSpan=(i%16);
				tr.appendChild(td);
			}
			var td=document.createElement('td');
			td.className='c'+i;
			tr.appendChild(td);
		}
		tr.cells[tr.cells.length-1].style.border="1px solid #808080";
		var selCol=document.createElement('div');
		selCol.className='selected-color c255';
		box.appendChild(selCol);
		selCol.appendChild(document.createTextNode('Selected: c255'));
		selCol.appendChild(document.createElement('br'));
		selCol.appendChild(document.createTextNode('rgb(255,255,255)'));
		selCol.appendChild(document.createElement('br'));
		selCol.appendChild(document.createTextNode(''));
		var palHover=document.createElement('div');
		palHover.className='palette-hover';
		box.appendChild(palHover);
		palette.initPalette(table,palHover,selCol);
		if ('undefined'==typeof(container) || !container.appendChild) {
			container=document.getElementsByTagName('body')[0];
		}
		container.appendChild(box);
		palette.table=table;
		palette.selCol=selCol;
	},
	getSelectedColor:function palette_getSelectedColor() {
		return this.lastSelectedColor;
	},
	selectColor:function palette_selectColor(color) {
		if (color=='') return;
		var cells=this.table.getElementsByTagName('td');
		for(var i=0;i<cells.length;i++) {
			if (cells[i].className==color) {
				cells[i].onclick();
			}
		}
	},
	lastSelectedColor:'c255',
	groups:{
		c0:'Transparent',
		c1:'WinAPI',
		c10:'',
		c80:'Patch Company 2',
		c88:'',
		c198:'Company',
		c206:'',
		c216:'Water Cycle',
		c227:'Block Cycles',
		c232:'Fire',
		c239:'Red Cycle',
		c241:'Yellow flash',
		c245:'',
		c246:'???',
		c255:''
	},
	initPalette:function palette_initPalette(paletteTable,palHover,palSelected) {
		palette.attachTDEvent(
			paletteTable,'onmouseover',
			function() {
				if (this.className=='') return;
				if (!palHover.firstChild || palHover.firstChild==palHover.lastChild) {
					while (palHover.firstChild) {
						palHover.removeChild(palHover.firstChild);
					}
					palHover.appendChild(document.createTextNode('Pointing at:'));
					palHover.appendChild(document.createElement('br'));
					palHover.appendChild(document.createTextNode('nothing'));
				}
				palHover.firstChild.nodeValue='Pointing at: '+this.className;
				palHover.lastChild.nodeValue=palette.getBackgroundColor(this);
			}
		);
		palette.attachTDEvent(
			paletteTable,'onmouseout',
			function() {
				while (palHover.firstChild) {
					palHover.removeChild(palHover.firstChild);
				}
			}
		);
		palette.attachTDEvent(
			paletteTable,'onclick',
			function() {
				if (this.className=='') return;
				palette.lastSelectedColor=this.className;
				palSelected.className='selected-color '+this.className;
				palSelected.firstChild.nodeValue='Selected: '+this.className;
				palSelected.firstChild.nextSibling.nextSibling.nodeValue=palette.getBackgroundColor(this);
				for(var i=new Number(this.className.substr(1));i>=0;i--) {
					if ('undefined'!=typeof(palette.groups['c'+i])) {
						palSelected.lastChild.nodeValue=palette.groups['c'+i];
						break;
					}
				}
				palSelected.style.color=palette.getBackgroundColor(this,true);
			}
		);
	},
	getBackgroundColor:function palette_getBackgroundColor(el,invert) {
		if (typeof(invert)!='boolean') invert=false;
		var bg=null;
		if (el.currentStyle) {
			bg=el.currentStyle.backgroundColor;
		} else if (document.defaultView) {
			bg=document.defaultView.getComputedStyle(el, '');
			bg=bg.getPropertyValue('background-color');
		}
		if (bg!=null && bg.substr(0,1)=='#') {
			var len=2;
			var start=1;
			if (bg.length==4) { len=1; }
			if (bg.length>7) { start=bg.length-6; }
			var r=parseInt(bg.substr(start,len),16);
			var g=parseInt(bg.substr(start+len,len),16);
			var b=parseInt(bg.substr(start+len+len,len),16);
			if (len==1) {
				r+=r*16;
				g+=g*16;
				b+=b*16;
			}
			bg='rgb('+r+','+g+','+b+')';
		}
		if (bg!=null) {
			switch(bg.toLowerCase()) {
				case 'black'  :bg='rgb(0,0,0)';break;
				case 'white'  :bg='rgb(255,255,255)';break;
				case 'gray'   :bg='rgb(128,128,128)';break;
				case 'red'    :bg='rgb(255,0,0)';break;
				case 'green'  :bg='rgb(0,128,0)';break;
				case 'blue'   :bg='rgb(0,0,255)';break;
				case 'yellow' :bg='rgb(255,255,0)';break;
				case 'orange' :bg='rgb(255,165,0)';break;
				case 'purple' :bg='rgb(128,0,128)';break;
				case 'silver' :bg='rgb(192,192,192)';break;
				case 'maroon' :bg='rgb(128,0,0)';break;
				case 'fuchsia':bg='rgb(255,0,255)';break;
				case 'olive'  :bg='rgb(128,128,0)';break;
				case 'lime'   :bg='rgb(0,255,0)';break;
				case 'navy'   :bg='rgb(0,0,128)';break;
				case 'aqua'   :bg='rgb(0,255,255)';break;
				case 'teal'   :bg='rgb(0,128,128)';break;
			}
		}
		if (invert && bg!=null && bg.toLowerCase().substr(0,3)=='rgb') {
			var rgb=bg.split('(');
			if (rgb.length>1) {
				rgb=rgb[1].split(')')[0].split(',');
				if (rgb[0]>200 || rgb[1]>200) {
					bg='rgb(0,0,0)';
				} else if (rgb[0]>150 && rgb[1]>150 && rgb[2]>150) {
					bg='rgb(0,0,0)';
				} else if (rgb[0]<100 && rgb[1]<100) {
					bg='rgb(255,255,255)';
				} else {
					rgb[0]^=0x80;rgb[1]^=0x80;rgb[2]^=0x80;
					bg='rgb('+rgb[0]+','+rgb[1]+','+rgb[2]+')';
				}
			} else {
				// Color value not recognized, use a default
				bg='rgb(255,255,255)';
			}
		}
		return bg;
	},
	attachTDEvent:function palette_attachTDEvent(table,event,func) {
		if ('undefined'==typeof(event)) {
			event='onclick';
		}
		if ('undefined'==typeof(table.rows) && 'undefined'!=typeof(table.length)) {
			// table is an array apparently
			for(var i=0;i<table.length;i++) {
				palette.attachTDEvent(table[i],func,event);
			}
		} else {
			var rows=table.rows.length;
			for(var i=0;i<rows;i++) {
				var rowcells=table.rows[i].cells;
				var cells=rowcells.length;
				for(var j=0;j<cells;j++) {
					rowcells[j][event]=func;
				}
			}
		}
	}
}
