package;

import scenes.GameScene;
import scenes.UIScene;
import scenes.MainMenu;
import hxd.res.DefaultFont;
import scenes.SettingsMenu;
import hxd.Key;
import haxe.EnumFlags;
import hl.Profile;
import hxd.snd.Manager;
import hxd.Event;
import h2d.Scene.ScaleModeAlign;
import h2d.Text;
import hxd.fmt.grd.Data.Color;
import hxd.Window;
import h2d.Scene.ScaleMode;
import hxd.Res;
import ent.Mario;

@:publicFields 
class Main extends hxd.App 
{
	public static var inst(default, null):Main;
    
    private var lastFrameTime:Float = 0.0;

    //320x180
    
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
        
        
        

        #if debug
        debugText = new Text(DefaultFont.get(),s2d);
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
        
        
        hxd.snd.Manager.get().masterVolume = 0;
        
        G.setWindowScale(G.currentScale);

        switchScene(new MainMenu());
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
        if (debugText != null) {
            s2d.addChild(debugText);
        }
        #end

    }
    override function update(dt:Float) 
    {
        super.update(dt);
        var currentFps = Math.round(hxd.Timer.fps());
        //debugTextInfo = 'FPS: ${currentFps}\nCurrent Scene: ${currentScene}';
        //debugText.text = debugTextInfo;
        
        
        if (currentScene != null)
            currentScene.update(dt);


        if(Key.isPressed(Key.F11))
        {
            var win = Window.getInstance();
            if (win.displayMode == Fullscreen || win.displayMode == Borderless) 
            {
                
                win.displayMode = Windowed;
                G.currentScale = G.savedCurrentScale;

                win.resize(Const.WIDTH * G.currentScale, Const.HEIGHT * G.currentScale);
            } 
            else {
                G.savedCurrentScale = G.currentScale;

                G.currentScale = 1;

                win.displayMode = Borderless; 
            }
        }

        if(Window.getInstance().displayMode == Borderless)
        {
            G.currentScale = 1;
        }

        /*
        if(hxd.Key.isDown(hxd.Key.P))
        {
            trace(" ---STARTING PROFILING ---");

            hl.Profile.dump("global_track.dump", true, true);
            trace("Profile successfully saved to project folder as 'global_track.dump'!");
        }
            */
    }
    
    
    
    override function onResize() {
        super.onResize();

        if(isResizing) return;

        var window = hxd.Window.getInstance();

        var targetWidth = Const.WIDTH * G.currentScale;
        var targetHeight = Const.HEIGHT * G.currentScale;

        if (window.displayMode == Windowed) 
        {
            var targetWidth = Const.WIDTH * G.currentScale;
            var targetHeight = Const.HEIGHT * G.currentScale;

            if (window.width != targetWidth || window.height != targetHeight) {
                isResizing = true;
                window.resize(targetWidth, targetHeight);
                isResizing = false;
            }  
        } 
        else 
        {
            if(G.currentScale != 1) {
                G.currentScale = 1;
            }
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


    private function setProfile()
    {
        var flags = new EnumFlags<hl.Profile.TrackKind>();
        flags.set(TrackKind.Alloc);
        flags.set(TrackKind.Cast);
        flags.set(TrackKind.DynField);
        flags.set(TrackKind.DynCall);

        Profile.globalBits = flags;
        Profile.restart();
    }

    static function main() 
    {
        Res.initEmbed();
        new Main();    
    }
    
}
 