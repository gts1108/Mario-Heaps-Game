import hxd.res.FontBuilder;
import h2d.Font;
import hxd.Res;
import hxd.snd.Channel;
import hxd.res.DefaultFont;
class Global
{
    public static var currentScale:Int = 1;
    public static var savedCurrentScale:Int;

    public static var coinCount:Int = 0;
    public var maxCoinCount:Int = 100;
    public static var hp = 2;
    public static var points:Int;
    public static var time:Int = 400;  
    
    public static var world:Int = 1;
    public static var level:Int = 1;
    
    

    public static function setWindowScale(scale:Int) {
        Main.inst.isResizing = true;
        currentScale = scale;
        var window = hxd.Window.getInstance();
        window.resize(Const.WIDTH * scale, Const.HEIGHT * scale);
        Main.inst.isResizing = false;
    }



   
}