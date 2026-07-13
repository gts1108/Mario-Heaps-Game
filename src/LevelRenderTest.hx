package;

import ent.Mario;
import hxd.Key;
import ent.Entity;
import h2d.RenderContext;
import ent.TestEnt;
import echo.Shape;
import echo.data.Options.BodyOptions;
import echo.Body;
import echo.data.Options.WorldOptions;
import echo.World;
import hxd.res.DefaultFont;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import h2d.Text;
import h2d.Tile;
import h3d.Vector4;
import echo.util.Debug;

class LevelRenderTest extends BaseScene
{
    private var bg:Bitmap;
    
    
    public function new() {

        super();

        bg = new h2d.Bitmap(h2d.Tile.fromColor(0x333333), this);
        bg.x = 0;
        bg.y = 0;
        bg.scaleX = this.width;
        bg.scaleY = this.height;
        
        
    }

    override function update(dt:Float) 
    {
        super.update(dt);
    }

    override function sync(ctx:RenderContext) 
    {
        
    }
}