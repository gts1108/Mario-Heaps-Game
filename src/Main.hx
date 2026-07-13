package;
    


//import utils.MemoryMonitor;
import hxd.Timer;
import h2d.filter.Filter;
import h2d.filter.Filter;
import hxd.res.Image;
import hxd.System;
import hxd.Key;
import h2d.Scene.ScaleModeAlign;
import h3d.Vector4;
import h2d.Text;
import hxd.res.DefaultFont;
import h2d.Bitmap;
import hxd.fmt.grd.Data.Color;
import h2d.Tile;
import h2d.Object;
import hxd.Window;
import h2d.Scene.ScaleMode;
import hxd.res.Font;
import hxd.Res;
import ent.Mario;

@:publicFields 
class Main extends hxd.App {

    private var mario:Mario; 
    private var obj:Object;
    

    public var scale:Int = 1; //320x180
    private var bg:Bitmap;
    static var inst:Main;

    var currentScene:BaseScene;

    
    
    #if debug
    private var debugText:Text;
    #end 
    
    override function init() 
    {
        super.init();
	   
        trace(System.getDefaultFrameRate());
        
        
       
        s2d.scaleMode = LetterBox(Const.WIDTH, Const.HEIGHT, true,Center,Center);
    
        Image.DEFAULT_FILTER = Nearest;
        switchScene(new LevelRenderTest());

        #if debug
        debugText = new Text(getFont(),s2d);
        debugText.x = 10;
        debugText.y = 10;

        #end
    }
    
    public static function getFont()
    {
        return DefaultFont.get();
    }

    public function switchScene(newScene:BaseScene)
    {
        if(currentScene != null)
        {
            currentScene.dispose();
            currentScene.remove();
        }

        currentScene = newScene;

        this.setScene2D(currentScene);

    }

    override function update(dt:Float) 
    {
        super.update(dt);
        var currentFps = Math.round(hxd.Timer.fps());

        //trace('FPS: ${currentFps}');

        
        #if debug
        //var realMemory = MemoryMonitor.getRealMemoryMB();
        //debugText.text = 'Real Memory Use: ${realMemory}';
        
        #end
        
        var scaleChanged = false;
        
        if (currentScene != null)
            currentScene.update(dt);
        
        /*
        if(hxd.Key.isPressed(Key.UP))
        {
            scale++;
            scaleChanged = true;

        }
        if(Key.isPressed(Key.DOWN))
        {
            scale--;
            if(scale < 1) scale = 1;
            scaleChanged = true;
        }
        
        if(scaleChanged) 
        {
            s2d.scaleMode = Zoom(scale);
            var win = @:privateAccess hxd.Window.getInstance();
            win.resize(Const.WIDTH * scale, Const.HEIGHT * scale);
        }
        */
        if(Key.isPressed(Key.ESCAPE))
        {
            System.exit();
        }
    }
    
    override function onResize() {
        super.onResize();
    }
    
    static function main() 
    {
        Res.initEmbed();    
        inst = new Main();
    }
    
}
 