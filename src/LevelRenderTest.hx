package src;

import h2d.Object;
import h2d.Bitmap;

class LevelRenderTest extends BaseScene
{
    var bg:Bitmap;  
    var levelContainer:Object;
    var p:Data;
    var mario:Mario;

    public function new()
    {
        super();
        
        p = new Data();
        var level = p.all_worlds.Default.all_levels.Level_0;

        bg = new h2d.Bitmap(h2d.Tile.fromColor(0x333333), this);
    
        bg.x = 0;
        bg.y = 0;
        bg.scaleX = this.width;
        bg.scaleY = this.height;

        levelContainer = new h2d.Object(this);
        
        this.addChild(level.l_Collisions.render());
        
        for(player in level.l_Entities.all_Player)
        {
            mario = new Mario(player.pixelX, player.pixelY,this);

        }
        
    }
    override function update(dt:Float) {
        

        mario.update(dt);
    }
}