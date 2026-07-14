package;

import hxd.Res;
import h2d.Graphics;
import h2d.RenderContext;
import h2d.Text;
import ent.Entity;
import h2d.Object;
import h2d.Bitmap;
import echo.World;
import echo.Body;
import ent.Mario;
import echo.util.Debug;

class GameScene extends BaseScene
{
    var bg:Bitmap;  
    var p:Data;
    var mario:Mario;
    var physicsWorld:World;
    private var playerGroup:Array<Body> = [];
    private var groundGroup:Array<Body> = [];
    private var debugGraphics:Graphics;
    private var showHitbox = true;

    
    public function new()
    {
        super();

        p = new Data();
        music = Res.Stressed.play(true);
        debugGraphics = new Graphics(this);

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

        var visited:Array<Array<Bool>> = [for(cy in 0...collisionLayer.cHei)[for(cx in 0...collisionLayer.cWid) false]];

        for (cy in 0...collisionLayer.cHei) {
            for (cx in 0...collisionLayer.cWid) {
                
                // If it's a solid tile and HASN'T been merged into a hitbox yet
                if (collisionLayer.getInt(cx, cy) == 1 && !visited[cy][cx]) 
                {
                    
                    // First, find out how far this block can stretch to the RIGHT (Width)
                    var runWidth = 0;
                    while ((cx + runWidth) < collisionLayer.cWid 
                           && collisionLayer.getInt(cx + runWidth, cy) == 1 
                           && !visited[cy][cx + runWidth]) {
                        runWidth++;
                    }
                    // Next, see how far this exact horizontal span can stretch DOWN (Height)
                    var runHeight = 1;
                    var canExpandDown = true;                

                    while ((cy + runHeight) < collisionLayer.cHei && canExpandDown) {
                        // Check if the entire horizontal stretch underneath is solid and unvisited
                        for (rx in 0...runWidth) {
                            if (collisionLayer.getInt(cx + rx, cy + runHeight) != 1 || visited[cy + runHeight][cx + rx]) {
                                canExpandDown = false;
                                break;
                            }
                        }
                        
                        if (canExpandDown) {
                            runHeight++;
                        }
                    }

                    // Mark all tiles within this newly calculated big box as visited
                    for (h in 0...runHeight) {
                        for (w in 0...runWidth) {
                            visited[cy + h][cx + w] = true;
                        }
                    }


                    // Convert tile dimensions to actual pixel scales
                    var widthPixels = runWidth * gridSize;
                    var heightPixels = runHeight * gridSize;
                    
                    // Centered pixel transforms matching Echo physics engine
                    var pixelX = (cx * gridSize) + (widthPixels * 0.5);
                    var pixelY = (cy * gridSize) + (heightPixels * 0.5);

                    // Create the optimized giant ground tile
                    var groundTile = new Entity(pixelX, pixelY, this, {
                        x: pixelX,
                        y: pixelY,
                        mass: 0, 
                        elasticity: 0.0,
                        shape: { 
                            type: RECT, 
                            width: widthPixels, 
                            height: heightPixels 
                        }
                    });

                    physicsWorld.add(groundTile.body);
                    entities.push(groundTile);
                    groundGroup.push(groundTile.body);
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
                    
                        marioInstance.isOnGround = true;
                    }
                }
            }});

        this.addChild(debugGraphics);
    }

    override function update(dt:Float) 
    {
       // 1. Reset the flag BEFORE the engine evaluates collisions this frame
        physicsWorld.step(dt);

        for(entity in entities) {
            entity.update(dt);
        }

        showHitbox = true;

        showDebugHitbox();
        
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

    private function showDebugHitbox()
    {
        debugGraphics.clear();
        if(showHitbox)
        {
            for(entity in entities)
            {
                debugGraphics.lineStyle(1, 0x00FF00, 1.0);

                for(shape in entity.body.shapes)
                {
                    var bounds = shape.bounds();

                    debugGraphics.drawRect(entity.body.x - (bounds.width * 0.5), 
                        entity.body.y - (bounds.height * 0.5), 
                        bounds.width, 
                        bounds.height);
                }
            }
        }
    }
}