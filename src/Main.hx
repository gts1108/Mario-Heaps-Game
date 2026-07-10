package src;
    

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

@:publicFields 
class Main extends hxd.App {

    private var mario:Mario; 
    private var obj:Object;
    private var width = 320;    
    private var height = 180;

    public var scale:Int = 1; //320x180
    private var bg:Bitmap;
    static var inst:Main;

    var currentScene:BaseScene;

    
    var text:Text;

    override function init() 
    {
        super.init();
	   
        trace(System.getDefaultFrameRate());
        Timer.wantedFPS = 120;
        
        s2d.scaleMode = LetterBox(width, height, true,Center,Center);
    
        Image.DEFAULT_FILTER = Nearest;
        switchScene(new LevelRenderTest());
        /*
        bg = new h2d.Bitmap(h2d.Tile.fromColor(0x333333), s2d);
    
        bg.x = 0;
        bg.y = 0;
        bg.scaleX = s2d.width;
        bg.scaleY = s2d.height;

        
        obj = new Object(s2d);
        obj.x = Std.int(s2d.width / 2);
        obj.y = Std.int(s2d.height / 2);



        var tile = Tile.fromColor(0xFF0000,25,25,1);
        tile = tile.center();

        //var bitmap = new Bitmap(tile,obj);
        
        text = new Text(getFont(), obj);
        text.text = "Hello, heaps";
        text.color = new Vector4(255,255,255);

        
        mario = new Mario(100,50);
        */
        
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
        
        var scaleChanged = false;
        if (currentScene != null)
            currentScene.update(dt);
        
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
            win.resize(width * scale, height * scale);
        }
        
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
 