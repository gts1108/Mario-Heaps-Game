package scenes;


import hxd.Timer;
import h2d.Anim;
import h2d.Tile;
import hxd.res.DefaultFont;
import hxd.Res;
import hxd.res.FontBuilder;
import h2d.Flow;
import h2d.Text;
import h2d.Font;
import h2d.Bitmap;

class UIScene extends BaseScene
{
    public var bg:Bitmap;  
    
    public var font:Font;
    
    public var topUIFlow:Flow;

    
    private var mario_text:Text;
    private var mario_points_text:Text;
    
    private var coin_flow:Flow;
    private var coin:Bitmap;
    private var coins_Frames:Array<Tile>;
    private var coin_anim:Anim;
    private var coin_text:Text;
    
    private var world_title_text:Text;
    private var world_name_text:Text;

    
    private var time_title_text:Text;
    private var time_count_text:Text;

    private var timeAccumulator:Float = 0.0;
    private var isInGame:Bool;

    public function new()
    {
        super();
        init();
        initFlowOnTop();
    }
    
    public function init()
    {
        //SUPPOSED TO BE OVERRIDEN
        
        bg = new h2d.Bitmap(h2d.Tile.fromColor(0x5C94FC), this);
        bg.x = 0;
        bg.y = 0;

        bg.scaleX = Const.WIDTH;
        bg.scaleY = Const.HEIGHT;
    }


    public function initFlowOnTop()
    {
        topUIFlow = new h2d.Flow(this);
        topUIFlow.layout = Horizontal;
        topUIFlow.horizontalSpacing = 24; // Adjust column spacing based on your resolution
        topUIFlow.setPosition(Const.GRID * 1.5, Const.GRID * 0.5);

        
        var scoreCol = new h2d.Flow(topUIFlow);
        scoreCol.layout = Vertical;

        
        mario_text = new Text(DefaultFont.get(), scoreCol);
        mario_text.text = "MARIO";
        
        mario_points_text = new Text(DefaultFont.get(), scoreCol);
        mario_points_text.text = "000000";

        
        var coinCol = new h2d.Flow(topUIFlow);
        coinCol.layout = Vertical;

        
        var emptySpace = new Text(DefaultFont.get(), coinCol);
        emptySpace.text = " "; 

        coin_flow = new h2d.Flow(coinCol);
        coin_flow.layout = Horizontal;
        coin_flow.verticalAlign = Bottom;

        
        var coin_spritesheet = Res.Sprites.UI_Coins.toTile();
        var coin_animation_array:Array<Tile> = coin_spritesheet.gridFlatten(8);
        
        for (tile in coin_animation_array) 
        {
            tile.setCenterRatio(0.5,0.5);
            tile.getTexture().filter = Nearest;
        }
        coins_Frames = [coin_animation_array[0], coin_animation_array[1], coin_animation_array[2]];
        
        coin_anim = new Anim(coins_Frames, 5, coin_flow);
        
        
        coin_text = new Text(DefaultFont.get(), coin_flow);
        coin_text.text = "x00";

       
        var worldCol = new h2d.Flow(topUIFlow);
        worldCol.layout = Vertical;

        world_title_text = new Text(DefaultFont.get(), worldCol);
        world_title_text.text = "WORLD";

        world_name_text = new Text(DefaultFont.get(), worldCol);
        world_name_text.text = '${G.world}-${G.level}';

       
        var timeCol = new h2d.Flow(topUIFlow);
        timeCol.layout = Vertical;

        time_title_text = new Text(DefaultFont.get(), timeCol);
        time_title_text.text = "TIME";

        time_count_text = new Text(DefaultFont.get(), timeCol);
        time_count_text.text = Std.string(G.time);
    }

    override function update(dt:Float) 
    {
        super.update(dt);

        mario_points_text.text = StringTools.lpad(Std.string(G.points), "0", 6);        
        coin_text.text = "x" + StringTools.lpad(Std.string(G.coinCount), "0", 2);
        time_count_text.text = StringTools.lpad(Std.string(G.time), "0", 3);
        if(isInGame)
        {
            if(G.time > 0)
            {
                timeAccumulator += dt;

                if(timeAccumulator >= 1.5)
                {
                    G.time--;
                    timeAccumulator -= 1.5;
                }

            }
            else
            {
                G.time = 0;
            }
        }
    }
}