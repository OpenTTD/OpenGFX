<?php

// This script does not generate a webpage,
// and is meant to be run on the commandline.

/*
Sprite compiler for TTD Box Editor.
Copyright (C) 2009 Frode Austvik
GPLv2, see the ttd-box-editor.html file for the full copyright notice.

This code takes an nfo file with PNGs and "compiles" the sprites into JSON that
the box editor can read.

Requires PHP5 with GD2, and may only work on *nix systems (others not tested).
*/

if (isset($_SERVER['SERVER_NAME'])) {
	header('Content-Type: text/plain');
	if (file_exists($_SERVER['PHP_SELF'])) {
		readfile($_SERVER['PHP_SELF']);
	} elseif (file_exists(basename($_SERVER['PHP_SELF']))) {
		readfile(basename($_SERVER['PHP_SELF']));
	} else {
		echo "This script does not generate a webpage, ";
		echo "and is meant to be run on the commandline.\n";
		echo "Further, the source file could not be located, ";
		echo "so could not be displayed.\n";
	}
	exit(0);
}

$nfofile='opengfx-nightly/sprites/ogfx1_base.nfo';

$sc=new SpriteCompiler($nfofile);
$sc->run();

class SpriteCompiler {
	var $nfofile=null;
	var $nfobasedir=null;
	var $outdir=null;
	var $fh=null;
	var $lastReadLine=null;
	var $sprite=null;
	var $lastImageFile=null;
	var $imageResource=null;
	
	function __construct($nfofile,$outdir='sprites') {
		$this->nfofile=$nfofile;
		$this->nfobasedir=dirname(dirname($nfofile));
		while ($outdir!='' && substr($outdir,-1)=='/') {
			$outdir=substr($outdir,0,-1);
		}
		if ($outdir=='') {
			$outdir='.';
		}
		$this->outdir=$outdir;
	}
	
	function run() {
		if (!$this->openFile()) {
			echo "Error: unable to open ".$this->nfofile."\n";
			return false;
		}
		echo "File opened.\n";
		if (!$this->checkFile()) {
			$this->closeDown();
			return false;
		}
		$count=0;
		$saved=0;
		while ($this->findNextSprite()) {
			$count++;
			if ($this->readSpriteImage()) {
				if ($this->saveSprite()) {
					$saved++;
				} else {
					echo "Save failed for sprite ".$this->sprite['num']."\n";
				}
			} else {
				//echo "Read failed for sprite ".$this->sprite['num']."\n";
			}
			if (($count%100)==0) {
				echo "\r".$count."  \r";
			}
		}
		if ($count>0) {
			echo "Found ".$count." sprites, ".$saved." saved.\n";
		} else {
			echo "No sprites found.\n";
		}
		$this->closeDown();
		return true;
	}
	
	function openFile() {
		$this->fh=fopen($this->nfofile,'rb');
		if (!$this->fh) {
			return false;
		}
		return true;
	}
	
	function closeDown() {
		fclose($this->fh);
		if ($this->imageResource) {
			imagedestroy($this->imageResource);
			$this->imageResource=null;
		}
	}
	
	function checkFile() {
		$verOK=false;
		$formatOK=false;
		for(
			$line=fgets($this->fh);
			!feof($this->fh) && ($line=='' || substr($line,0,2)=='//');
			$line=fgets($this->fh)
		) {
			if (substr($line,0,17)=='// (Info version ') {
				if (rtrim($line)=='// (Info version 7)') {
					$verOK=true;
				} else {
					echo "Error: unknown file version.\n";
					return false;
				}
			} elseif (substr($line,0,10)=='// Format:') {
				if (rtrim($line)=='// Format: spritenum pcxfile xpos ypos compression ysize xsize xrel yrel') {
					$formatOK=true;
				} else {
					echo "Error: unknown format in file.\n";
					return false;
				}
			}
		}
		if (!$verOK) {
			echo "Version not found in the file, aborting.\n";
			return false;
		}
		if (!$formatOK) {
			echo "Format not found in the file, aborting.\n";
			return false;
		}
		if (feof($this->fh)) {
			echo "Prematurely reached end of file (no sprites?).\n";
			return false;
		}
		$this->lastReadLine=$line;
		return true;
	}
	
	function findNextSprite() {
		if ($this->lastReadLine!=null) {
			$line=$this->lastReadLine;
			$this->lastReadLine=null;
		} else {
			$line=fgets($this->fh);
		}
		// spritenum pcxfile xpos ypos compression ysize xsize xrel yrel
		$re='/^ *(\d+) (.*\.[pP][cC][xX]) (\d+) (\d+) ([^ ]+) (\d+) (\d+) (-?\d+) (-?\d+)$/';
		while (!feof($this->fh) && !preg_match($re,$line)) {
			$line=fgets($this->fh);
		}
		$match=array();
		if (!feof($this->fh) && preg_match($re,$line,$match)) {
			$this->sprite=array(
				'line'=>$match[0],
				'num'=>$match[1],
				'file'=>$match[2],
				'xpos'=>$match[3],
				'ypos'=>$match[4],
				'compression'=>$match[5],
				'xsize'=>$match[7],
				'ysize'=>$match[6],
				'xrel'=>$match[8],
				'yrel'=>$match[9],
			);
			return true;
		}
		$this->sprite=null;
		return false;
	}
	
	
	function loadImage() {
		if ($this->lastImageFile!=$this->sprite['file']) {
			if ($this->imageResource) {
				imagedestroy($this->imageResource);
				$this->imageResource=null;
			}
			$this->lastImageFile=$this->sprite['file'];
			$imgfile=$this->nfobasedir.'/'.$this->lastImageFile.'.png';
			if (!file_exists($imgfile)) {
				echo "File does not exist: ".$imgfile."\n";
				return false;
			}
			$this->imageResource=imagecreatefrompng($imgfile);
			if (!$this->imageResource) {
				echo "Unable to load image file ".$imgfile."\n";
				return false;
			}
		}
		if (!$this->imageResource) {
			return false;
		}
		return true;
	}
	
	function readSpriteImage() {
		if (!$this->loadImage()) {
			return false;
		}
		$image=array();
		$ymax=$this->sprite['ypos']+$this->sprite['ysize'];
		$xpos=$this->sprite['xpos'];
		$xmax=$xpos+$this->sprite['xsize'];
		if ($xmax>1024) {
			echo "Warning: sprite ".$this->sprite['num']." has X out of bounds.\n";
		}
		if ($ymax>768) {
			echo "Warning: sprite ".$this->sprite['num']." has Y out of bounds.\n";
		}
		for($y=$this->sprite['ypos'];$y<$ymax;$y++) {
			$line=array();
			for($x=$xpos;$x<$xmax;$x++) {
				$line[]=@imagecolorat($this->imageResource,$x,$y);
			}
			$image[]='['.implode(',',$line).']';
		}
		$this->sprite['image']='['.implode(',',$image).']';
		return true;
	}
	
	
	function saveSprite() {
		$filename=$this->outdir.'/'.$this->sprite['num'].'.json';
		$fh=fopen($filename,'wb');
		if (!$fh) {
			echo "Unable to open ".$filename." for writing.\n";
			return false;
		}
		$data='{';
		foreach($this->sprite as $key=>$value) {
			$data.=$key.':';
			if ($key=='line' || $key=='file' || $key=='compression') {
				$data.="'".$value."'";
			} else {
				$data.=$value;
			}
			$data.=',';
		}
		$data=substr($data,0,-1).'}';
		$len=strlen($data);
		$wrote=fwrite($fh,$data,$len);
		$ok=fclose($fh);
		if ($wrote!=$len) {
			echo "Wrote ".$wrote." of ".$len." bytes.\n";
			return false;
		}
		if (!$ok) {
			echo "File close failed.\n";
			return false;
		}
		return true;
	}
	
	
}

?>
