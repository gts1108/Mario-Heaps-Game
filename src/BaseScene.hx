package;

import hxd.snd.Channel;
import h2d.Text;
import hxd.res.DefaultFont;
import ent.Entity;
import echo.util.AABB;
import h2d.RenderContext;
import h2d.Scene;


class BaseScene extends Scene
{
    public var entities:Array<ent.Entity> = [];
    public var music:Channel;

    public function new()
    {
        super();        
    }
    public function update(dt:Float)
    {

    }

    override function dispose() {
        super.dispose();
        music.sound.stop();
        music.sound.dispose();
        music = null;
        
    }
}