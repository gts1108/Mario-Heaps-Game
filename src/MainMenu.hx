package src;

import haxe.Template;
import h2d.Text;
import h2d.Object;
import h2d.Scene;

class MainMenu extends BaseScene
{
    var text:Text;

    public function new()
    {
        super();
        text = new Text(hxd.res.DefaultFont.get(),this);
        text.text = "Main Menu";
        //text.textAlign = Center;
        
        //text.x = 20; 
        //text.y = 250;
        //; // Keep it nice and crisp

    }

    override function update(dt:Float) {
        super.update(dt);

        //text.scale(Main.inst.scale);
        if (hxd.Key.isPressed(hxd.Key.MOUSE_LEFT)) {
            Main.inst.switchScene(new GameScene());
        }
    }
}