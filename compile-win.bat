copy ogfx1.pnfo ogfx1.nfo
copy ogfxc.pnfo ogfxc.nfo
copy ogfxh.pnfo ogfxh.nfo
copy ogfxi.pnfo ogfxi.nfo
copy ogfxt.pnfo ogfxt.nfo
copy ogfxe.pnfo ogfxe.nfo

grfcodec -e -p 2 ogfx1.grf sprites/
echo "Now processing ogfxc"
grfcodec -e -p 2 ogfxc.grf sprites/
echo "Now processing ogfxh"
grfcodec -e -p 2 ogfxh.grf sprites/
echo "Now processing ogfxi"
grfcodec -e -p 2 ogfxi.grf sprites/
echo "Now processing ogfxt"
grfcodec -e -p 2 ogfxt.grf sprites/
echo "Now processing ogfxe"
grfcodec -e -p 2 ogfxe.grf sprites/

PAUSE
