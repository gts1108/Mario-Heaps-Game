package scenes;

import hxd.res.DefaultFont;
import hxd.Res;
import hxd.snd.Channel;
import h2d.Interactive;
import hxd.Key;
import hxsl.Types.Texture;
import h2d.Text;

class SettingsMenu extends BaseScene
{
    var text:Text;
    var setting_scale:Text;
    

    public function new()
    {
        super();

        text = new Text(DefaultFont.get(),this);
        text.text = "SETTINGS";

        setting_scale = new Text(DefaultFont.get(), this);
        
        var btn2x = new Text(hxd.res.DefaultFont.get(), this);
        btn2x.text = "[ Set Scale to 2x ]";
        btn2x.y = 50;
        var click2x = new Interactive(btn2x.textWidth, btn2x.textHeight, btn2x);
        click2x.onClick = function(_) {
            G.setWindowScale(2);
        };

        var btn3x = new Text(hxd.res.DefaultFont.get(), this);
        btn3x.text = "[ Set Scale to 3x ]";
        btn3x.y = 80;
        var click3x = new Interactive(btn3x.textWidth, btn3x.textHeight, btn3x);
        click3x.onClick = function(_) {
            G.setWindowScale(3);
        };
        
        var btn4x = new Text(hxd.res.DefaultFont.get(), this);
        btn4x.text = "[ Set Scale to 4x ]";
        btn4x.y = 110;

        var click4x = new Interactive(btn4x.textWidth, btn4x.textHeight, btn4x);
        click4x.onClick = function(_) {
            G.setWindowScale(4);
        };
    }

    override function update(dt:Float) {
        super.update(dt);
        setting_scale.text = 'Resolution: ${hxd.Window.getInstance().width}x${hxd.Window.getInstance().height}';

        if(Key.isPressed(Key.ENTER))
        {
            Main.inst.switchScene(new GameScene());
        }

    }
}