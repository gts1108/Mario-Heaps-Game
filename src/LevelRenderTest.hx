package;

import h2d.RenderContext;
import h2d.Text;
import ent.Entity;
import h2d.Object;
import h2d.Bitmap;
import echo.World;
import echo.Body;
import ent.Mario;
class LevelRenderTest extends BaseScene
{
    var bg:Bitmap;  
    var p:Data;
    var mario:Mario;
    var physicsWorld:World;
    var textDebug:Text;
    private var playerGroup:Array<Body> = [];
    private var groundGroup:Array<Body> = [];

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
        
        physicsWorld = new World({
            width:level.pxWid,
            height: level.pxHei,
            gravity_y: 900,
            iterations: 100 // High enough to prevent visual physics micro-jitter
        });
        

        this.addChild(level.l_Collisions.render());
        
        for(playerData in level.l_Entities.all_Player)
        {
            mario = new Mario(playerData.pixelX, playerData.pixelY,this);
            physicsWorld.add(mario.body);
            playerGroup.push(mario.body);

            entities.push(mario);
        }

        var collisionLayer = level.l_Collisions;
        var gridSize = collisionLayer.gridSize;

        for (cy in 0...collisionLayer.cHei) {
            var startCx = -1;
            var length = 0;

            for (cx in 0...collisionLayer.cWid) {
                // Check if the current grid space is set to a solid marker
                var isSolid = collisionLayer.getInt(cx, cy) == 1; 

                if (isSolid) {
                    if (startCx == -1) {
                        startCx = cx; // Mark the beginning of our horizontal shape
                    }
                    length++;
                }
                
                // If we reach empty space OR hit the horizontal border of the map
                if (startCx != -1 && (!isSolid || cx == collisionLayer.cWid -1)) {
                    
                        var widthPixels = length * gridSize;
                        var heightPixels = gridSize;
                        
                        // Centered pixel positions matching Echo transforms
                        var pixelX = (startCx * gridSize) + (widthPixels * 0.5);
                        var pixelY = (cy * gridSize) + (heightPixels * 0.5);

                        var groundTile = new Entity(pixelX, pixelY, this, {
                            x: pixelX,
                            y: pixelY,
                            mass: 0, 
                            elasticity: 0.0, // Fixed bouncy issue via constructor
                            shape: { 
                                type: RECT, 
                                width: widthPixels, 
                                height: heightPixels 
                            }
                        });

                        physicsWorld.add(groundTile.body);
                        entities.push(groundTile);
                        groundGroup.push(groundTile.body); 

                        // Reset row trackers
                        startCx = -1;
                        length = 0;
                    }
                }
            }
        
        
        physicsWorld.listen(playerGroup, groundGroup, {
            separate: true,
            stay:(playerBody, groundBody, collisions) ->{
                var marioInstance:Mario = cast playerBody.entity;
                for(col in collisions)
                {
                    if(col.normal.y >0)
                    {
                        trace("Mario UP");
                        marioInstance.isOnGround = true;
                    }
                }
            }});
        
        textDebug = new Text(hxd.res.DefaultFont.get(),this);
        
        textDebug.x = 10;
        textDebug.y = 10;
    }

    override function update(dt:Float) 
    {
       // 1. Reset the flag BEFORE the engine evaluates collisions this frame
        physicsWorld.step(dt);

        for(entity in entities) {
            entity.update(dt);
        }

        textDebug.text = mario.debugInfo();
    }

    /**
     * REALLY IMPORTANT HOLY SHIT
     * 
     */
    override function sync(ctx:RenderContext) 
    {
        for(entity in entities)
        {
            entity.syncVisuals();
        }
        super.sync(ctx);

    }
}