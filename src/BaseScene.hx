package;

import h2d.Text;
import hxd.res.DefaultFont;
import ent.Entity;
import echo.util.AABB;
import h2d.RenderContext;
import h2d.Scene;


class BaseScene extends Scene
{
    public var entities:Array<ent.Entity> = [];

    public function new()
    {
        super();

        #if debug

        #end
        
    }
    public function update(dt:Float)
    {

    }

    
}