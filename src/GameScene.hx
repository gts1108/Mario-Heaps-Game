package src;

import hxd.res.DefaultFont;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import h2d.Text;
import h2d.Tile;
import h3d.Vector4;

class GameScene extends BaseScene
{
    private var mario:Mario; 
    private var obj:Object;
    private var bg:Bitmap;

    var text:Text;

    var project:Data;
    public function new() {
        super();
        bg = new h2d.Bitmap(h2d.Tile.fromColor(0x333333), this);
    
        bg.x = 0;
        bg.y = 0;
        bg.scaleX = this.width;
        
        bg.scaleY = this.height;

        
        obj = new Object(this);
        obj.x = Std.int(this.width / 2);
        obj.y = Std.int(this.height / 2);

        var tile = Tile.fromColor(0xFF0000,25,25,1);
        tile = tile.center();

        text = new Text(Main.getFont(), obj);
        text.text = "Hello, heaps";
        text.color = new Vector4(255,255,255);

        
        mario = new Mario(100,50,this);
    }

    override function update(dt:Float) 
    {
        super.update(dt);
        mario.update(dt);
        
    }
}