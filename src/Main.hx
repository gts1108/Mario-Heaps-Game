package;
    


//import utils.MemoryMonitor;
import hxd.snd.Manager;
import hxd.Event;
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
class Main extends hxd.App 
{
    
    private var lastFrameTime:Float = 0.0;

    private var mario:Mario; 
    private var obj:Object;
    

    //320x180
    private var bg:Bitmap;
    public static var inst:Main;
    public var isResizing:Bool = false;
    
    var currentScene:BaseScene;
    private var viewMask:h2d.Mask;    
    
    #if debug
    private var debugText:Text;
    private var debugTextInfo:String;
    #end 
    
    
    
    
    override function init() 
    {
        super.init();
        
        inst = this;
		setFPS(120);
        lastFrameTime = haxe.Timer.stamp();
        hxd.Window.getInstance().vsync = false;
        
        s2d.scaleMode = LetterBox(Const.WIDTH, Const.HEIGHT, true,Center,Center);
        //s2d.defaultSmooth = false;

        Image.DEFAULT_FILTER = Nearest;
        

        #if debug
        debugText = new Text(Global.getFont(),s2d);
        debugText.x = 10;
        debugText.y = 10;
        #end

        hxd.snd.Manager.get();
		hxd.Timer.skip(); // needed to ignore heavy Sound manager init frame
        hxd.Window.getInstance().onClose = function(){
            try
            {
                trace("Clean up audio before exiting and shit");
                Manager.get().stopAll();
                Manager.get().suspended = true;
                Manager.get().dispose();
            }
            catch(e:Dynamic)
            {
                trace("Audio clean up failed: "+ e);
            }
            return true;
        };

        
        Global.setWindowScale(Global.currentScale);
        switchScene(new SettingsMenu());
    }
    
    public function switchScene(newScene:BaseScene)
    {
        if(currentScene != null)
        {
            currentScene.dispose();
            currentScene.remove();
        }

        currentScene = newScene;

        if (viewMask == null) {
            viewMask = new h2d.Mask(Const.WIDTH, Const.HEIGHT, s2d);
            viewMask.x = 0;
            viewMask.y = 0;
        }

        viewMask.addChild(currentScene);

        #if debug
        // 3. Always bring the debug text to the absolute top layer
        if (debugText != null) {
            s2d.addChild(debugText);
        }
        #end

    }
    override function update(dt:Float) 
    {
        super.update(dt);
        var currentFps = Math.round(hxd.Timer.fps());
        debugTextInfo = 'FPS: ${currentFps}\nCurrent Scene: ${currentScene}';
        debugText.text = debugTextInfo;
        
        
        if (currentScene != null)
            currentScene.update(dt);
       
        if(Key.isPressed(Key.ESCAPE))
        {
            System.exit();
        }
    }
    
    
    
    override function onResize() {
        super.onResize();

        if(isResizing) return;

        var window = hxd.Window.getInstance();

        var targetWidth = Const.WIDTH * Global.currentScale;
        var targetHeight = Const.HEIGHT * Global.currentScale;

        if (window.width != targetWidth || window.height != targetHeight) {
            isResizing = true;
            window.resize(targetWidth, targetHeight);
            isResizing = false;
        }
    }

    override function mainLoop() 
    {
        var currentTime = haxe.Timer.stamp();
        var elapsed = currentTime - lastFrameTime;
        var minFrameTime = 1.0/Const.FPS;
        
        if (elapsed < minFrameTime) {
            var sleepTime = minFrameTime - elapsed;
            Sys.sleep(sleepTime);
        }
        lastFrameTime = haxe.Timer.stamp();
        super.mainLoop();
    }
    
    public static function setFPS(newFPS:Int)
    {
        Const.FPS = newFPS;
    }

    static function main() 
    {
        Res.initEmbed();
        new Main();    
    }
    
}
 