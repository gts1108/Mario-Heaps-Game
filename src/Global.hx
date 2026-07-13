import hxd.res.DefaultFont;
class Global
{
    public static var currentScale:Int = 1;
    public static function getFont()
    {
        return DefaultFont.get();
    }
    
    public static function setWindowScale(scale:Int) {
        Main.inst.isResizing = true;
        currentScale = scale;
        var window = hxd.Window.getInstance();
        window.resize(Const.WIDTH * scale, Const.HEIGHT * scale);
        Main.inst.isResizing = false;
    }
}