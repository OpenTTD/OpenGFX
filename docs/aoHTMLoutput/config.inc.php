<?php
//database config
$cfg_db['server'] = 'localhost';
$cfg_db['user'] = 'root';
$cfg_db['pass'] = '';
$cfg_db['db'] = 'foobar_ogfx';
$cfg_db['table'] = 'authors';

//csv config
$cfg_csv['location'] = 'http://mz.openttdcoop.org/hg/opengfx/raw-file/tip/docs/authoroverview.csv'; //where to find the csv file
$cfg_csv['header'] = TRUE; //has .csv a header row?
$cfg_csv['delimiter'] = ';'; //Set the field delimiter (one character only).

//other config
$cfg['ticket_url'] = 'http://dev.openttdcoop.org/issues/'; //append ticket number to this for url to tracker
$cfg['current_rev_url'] = 'http://mz.openttdcoop.org/bundles/opengfx/nightlies/REV'; //url to get latest revision
$cfg['lastupdate_file'] = 'lastupdate.txt'; //filename to store last update revision in

$cfg['display_32bpp'] = FALSE; //only set to TRUE if 32bpp images reside on local server and local path is used in $bpp32[] below.

//set columns for spritelist
$columns[0] = 'file';
$columns[1] = 'range_start';
$columns[2] = 'range_end';
$columns[3] = 'num_sprites';
$columns[4] = 'description';
$columns[5] = 'graphics';
$columns[6] = 'alignment';
$columns[7] = 'ticket';

//filename to internal identifier translation table
$files['ogfx1_base'] = '1';
$files['ogfxc_arctic'] = 'c';
$files['ogfxh_tropical'] = 'h';
$files['ogfxi_logos'] = 'i';
$files['ogfxt_toyland'] = 't';
$files['ogfxe_extra'] = 'e';

//internal identifier to opengfx images translation table
//http://mz.openttdcoop.org/opengfx/ogfxh/data/sprite4.png
$ogfx['1'] = 'http://mz.openttdcoop.org/opengfx/ogfx1/data/';
$ogfx['c'] = 'http://mz.openttdcoop.org/opengfx/ogfxc/data/';
$ogfx['h'] = 'http://mz.openttdcoop.org/opengfx/ogfxh/data/';
$ogfx['i'] = 'http://mz.openttdcoop.org/opengfx/ogfxi/data/';
$ogfx['t'] = 'http://mz.openttdcoop.org/opengfx/ogfxt/data/';

//internal identifier to ttd images translation table
//http://mz.openttdcoop.org/opengfx/trghr/data/sprite4.png
$ttd['1'] = 'http://mz.openttdcoop.org/opengfx/trg1r/data/';
$ttd['c'] = 'http://mz.openttdcoop.org/opengfx/trgcr/data/';
$ttd['h'] = 'http://mz.openttdcoop.org/opengfx/trghr/data/';
$ttd['i'] = 'http://mz.openttdcoop.org/opengfx/trgir/data/';
$ttd['t'] = 'http://mz.openttdcoop.org/opengfx/trgtr/data/';	

//internal identifier to 32bpp images translation table
//http://mz.openttdcoop.org/opengfx/32bpp/sprites/trg1r/1.png
$bpp32['1'] = 'http://mz.openttdcoop.org/opengfx/32bpp/sprites/trg1r/';
$bpp32['c'] = 'http://mz.openttdcoop.org/opengfx/32bpp/sprites/trgcr/';
$bpp32['h'] = 'http://mz.openttdcoop.org/opengfx/32bpp/sprites/trghr/';
$bpp32['i'] = 'http://mz.openttdcoop.org/opengfx/32bpp/sprites/trgir/';
$bpp32['t'] = 'http://mz.openttdcoop.org/opengfx/32bpp/sprites/trgtr/';
?>