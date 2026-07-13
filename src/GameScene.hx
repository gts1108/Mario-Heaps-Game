package;

import ent.Mario;
import hxd.Key;
import ent.Entity;
import h2d.RenderContext;
import ent.TestEnt;
import echo.Shape;
import echo.data.Options.BodyOptions;
import echo.Body;
import echo.data.Options.WorldOptions;
import echo.World;
import hxd.res.DefaultFont;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import h2d.Text;
import h2d.Tile;
import h3d.Vector4;
import echo.util.Debug;

class GameScene extends BaseScene
{
    private var textDebug:Text;
    private var physicsWorld:World;
    private var player:Mario;
    private var testEnt:TestEnt;

    private var bg:Bitmap;
    private var floorBmp:Bitmap;

    private var echo_debug_drawer:HeapsDebug;

    
    public function new() {

        super();

        physicsWorld = new World({
            width: Const.WIDTH,
            height: Const.HEIGHT, 
            gravity_y: 1000 ,
            iterations: 100
        });
        echo_debug_drawer = new HeapsDebug(this);
        //physicsWorld.quadtree.max_depth = 3;
        //physicsWorld.static_quadtree.max_depth = 3;
        
       
        bg = new h2d.Bitmap(h2d.Tile.fromColor(0x333333), this);
        bg.x = 0;
        bg.y = 0;
        bg.scaleX = this.width;
        bg.scaleY = this.height;
        
        var floorX = Const.WIDTH*0.5;
        var floorY = Const.HEIGHT *0.8;

        var ground = new Entity(floorX, floorY, this, {
            x: floorX,
            y: floorY,
            mass: 0, // Mass 0 makes the body completely static/immovable
            shape: {
                type: RECT,
                width: 300,
                height: 20
            },
            elasticity: 0
        });

        floorBmp = new Bitmap(Tile.fromColor(0x00ff00, 300, 20), ground.body.entity.obj);
        floorBmp.tile.setCenterRatio();

        physicsWorld.add(ground.body);
        entities.push(ground);

        player= new Mario(Const.WIDTH*0.5, 60,this);
        testEnt = new TestEnt(Const.WIDTH*0.5, 60,this);

        physicsWorld.add(player.body);
        entities.push(player);
    
        physicsWorld.listen(player.body, ground.body, {
            separate: true,
            stay:(playerBody, groundBody, collisions) ->{
                player.isOnGround = true;
            }});

        
    }

    override function update(dt:Float) 
    {
        super.update(dt);
        
        physicsWorld.step(dt);
        

        for(entity in entities)
        {
            entity.update(dt);
        }

        echo_debug_drawer.canvas.visible = true;
        echo_debug_drawer.draw(physicsWorld);

        //textDebug.text = player.debugInfo();
    }

    override function sync(ctx:RenderContext) 
    {
        for(entity in entities)
        {
            entity.syncVisuals();
        }
        super.sync(ctx);

    }
}