package scenes;

import hxd.Key;
import hxd.res.DefaultFont;
import ent.Mario;
import hxd.Res;
import h2d.Bitmap;
import h2d.Font;
import haxe.Template;
import h2d.Text;
import h2d.Object;
import h2d.Scene;

class MainMenu extends UIScene
{
    
    var superMarioLogo:Bitmap;
    var groundSprite:Bitmap;
    var marioSprite:Mario;

    var mushroomSprite:Bitmap;
    
    var menuOptions = ["1 PLAYER GAME", "2 PLAYER GAME", "OPTIONS"];
    var menuOptionsIndex:Int;

    var menuOptionX:Int = 89;
    var menuOptionY:Int = 144;
    var optionSpacing:Float = Const.GRID * 1.5;
    

    override function init() 
    {
        super.init();
        
        superMarioLogo = new Bitmap(Res.Sprites.Title.toTile(), this);
        superMarioLogo.setPosition(40, 35);
        
        groundSprite = new Bitmap(Res.Sprites.ground.toTile(), this);
        groundSprite.setPosition(0,Const.HEIGHT - (Const.GRID*2) );

        marioSprite = new Mario(Const.GRID*3,groundSprite.y - (Const.GRID*0.5),this );

        for(i in 0...menuOptions.length)
        {
            var text = new Text(DefaultFont.get(), this); 
            text.text = menuOptions[i];
            text.x = menuOptionX;
            text.y = menuOptionY + (i*optionSpacing);
        }
        var spritesheet = Res.Sprites.Font.toTile();

        var index = spritesheet.grid(8,0,0);
        mushroomSprite = new Bitmap(index[8][2],this);

        updateMushroomPosition();
    }
    
    

    override function update(dt:Float) 
    {
        super.update(dt);

        if(Key.isPressed(Key.UP))
        {
            menuOptionsIndex--;
            if (menuOptionsIndex < 0) {
                menuOptionsIndex = menuOptions.length - 1; 
            }
            updateMushroomPosition();
        }
        else if (Key.isPressed(Key.DOWN) || Key.isPressed(Key.S)) 
        {
            menuOptionsIndex++;
            if (menuOptionsIndex >= menuOptions.length) {
                menuOptionsIndex = 0; 
            }
            updateMushroomPosition();
        }

        if(Key.isPressed(Key.ENTER))
        {
            switch(menuOptionsIndex)
            {
                case 0:
                    Main.inst.switchScene(new GameScene());
                case 1:
                    Main.inst.switchScene(new GameScene());
                case 2:
                    Main.inst.switchScene(new SettingsMenu());
            }
        }
    }

    private function updateMushroomPosition() 
    {
        mushroomSprite.x = menuOptionX - 16; 
        mushroomSprite.y = menuOptionY + (menuOptionsIndex * optionSpacing +5);
    }
}