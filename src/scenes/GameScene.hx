package scenes;


import ent.Enemy;
import Data._Tmp;
import ent.Block;
import ldtk.Level;
import h2d.Camera;
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

class GameScene extends UIScene
{
     
    var p:Data;
    var mario:Mario;
    var physicsWorld:World;
   

    private var playerGroup:Array<Body> = [];
    private var groundGroup:Array<Body> = [];
    private var blockGroup :Array<Body> = [];
    private var enemyGroup :Array<Body> = [];

    private var debugGraphics:Graphics;
   
    private var showHitbox = true;
   
    private var levelWidth:Float;
    private var debugText:Text;

    override function init() {
        super.init();

        p = new Data();
         
        //music = Res.Stressed.play(true);
        debugGraphics = new Graphics(this);

        var level = p.all_worlds.Default.all_levels.Level_0;
        levelWidth = level.pxWid;

        physicsWorld = new World({
            width:level.pxWid,
            height: level.pxHei,
            gravity_y: 900,
            iterations: 20 
        });


        
        bg.x = 0;
        bg.y = 0;
        bg.scaleX = level.pxWid;
        bg.scaleY = this.height;

        this.addChild(level.l_Collisions.render());
        this.addChild(level.l_Tiles.render());
        
        
        for(playerData in level.l_Entities.all_Player)
        {
            mario = new Mario(playerData.pixelX, playerData.pixelY,this);
            physicsWorld.add(mario.body);
            playerGroup.push(mario.body);
            entities.push(mario);
        }

        //Blocks
        for(blockData in level.l_Entities.all_Block)
        {
            var interactiveBlock = new Block(
                blockData.pixelX, 
                blockData.pixelY, 
                this, 
                blockData
            );
            physicsWorld.add(interactiveBlock.body);
            blockGroup.push(interactiveBlock.body);
            entities.push(interactiveBlock);
        }
        
        for(enemyData in level.l_Entities.all_Enemy)
        {
            var enemy = new Enemy(enemyData.pixelX,enemyData.pixelY, this, enemyData);

            physicsWorld.add(enemy.body);
            enemyGroup.push(enemy.body);

            entities.push(enemy);
        }

        var collisionLayer = level.l_Collisions;
        var gridSize = collisionLayer.gridSize;

        var visited:Array<Array<Bool>> = [for(cy in 0...collisionLayer.cHei)[for(cx in 0...collisionLayer.cWid) false]];

        for (cy in 0...collisionLayer.cHei) {
            for (cx in 0...collisionLayer.cWid) {
                
                
                if (collisionLayer.getInt(cx, cy) > 0 && !visited[cy][cx]) 
                {
                    var runWidth = 0;
                    while ((cx + runWidth) < collisionLayer.cWid 
                           && collisionLayer.getInt(cx + runWidth, cy) > 0
                           && !visited[cy][cx + runWidth]) {
                        runWidth++;
                    }
                    
                    var runHeight = 1;
                    var canExpandDown = true;                

                    while ((cy + runHeight) < collisionLayer.cHei && canExpandDown) {
                        for (rx in 0...runWidth) {
                            if (collisionLayer.getInt(cx + rx, cy + runHeight) == 0 || visited[cy + runHeight][cx + rx]) {
                                canExpandDown = false;
                                break;
                            }
                        }
                        
                        if (canExpandDown) {
                            runHeight++;
                        }
                    }

                    
                    for (h in 0...runHeight) {
                        for (w in 0...runWidth) {
                            visited[cy + h][cx + w] = true;
                        }
                    }

                    var widthPixels = runWidth * gridSize;
                    var heightPixels = runHeight * gridSize;
                    
                    
                    var pixelX = (cx * gridSize) + (widthPixels * 0.5);
                    var pixelY = (cy * gridSize) + (heightPixels * 0.5);
                    
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
                    
                    groundGroup.push(groundTile.body);
                }
            }
        }

        
        physicsWorld.listen(playerGroup, groundGroup, {
            separate: true,
            enter:(playerBody, groundBody, collisions) ->
            {
                    var marioInstance:Mario = cast playerBody.entity;
                    if (collisions.length > 0 && collisions[0].normal.y > 0) {
                        marioInstance.isOnGround = true;
                    }
                }
            });

           
        physicsWorld.listen(playerGroup, blockGroup, {
            separate: true,
            enter: (playerBody, blockBody, collisions)->
            {
                
                var marioInstance:Mario = cast playerBody.entity;
                var blockInstance:Block = cast blockBody.entity;

                if (collisions.length > 0) 
                {
                    var normalY = collisions[0].normal.y;
                

                    if (normalY >= 0.5) 
                    {
                        marioInstance.isOnGround = true;
                        blockInstance.onPlayerLand(playerBody, marioInstance);

                        trace("LANDEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
                    }
                    else if (normalY < -0.5) 
                    {
                        blockInstance.onPlayerHeadbutt(playerBody, marioInstance);
                    }
                }
                for (c in collisions) 
                {
                    if (Math.abs(c.normal.y) >= 0.5 && mario.isOnGround) {
                        
                        return; 
                    }
                }
                
                
            }
        
        });
 
        physicsWorld.listen(enemyGroup,groundGroup , {
            separate: true
        });
        
        physicsWorld.listen(playerGroup, enemyGroup,{
            separate: false,
            enter: (playerBody, enemyBody, collision) ->
            {
                var marioInstance:Mario = cast playerBody.entity;
                var enemyInstance:Enemy = cast enemyBody.entity;

                if (collision.length > 0 && collision[0].normal.y > 0) 
                {
                    enemyInstance.playerJumpOnTop();
                }
                else
                {
                    marioInstance.dead();
                }   
            }
        });
  
        this.addChild(debugGraphics);


        //debugText = new Text(G.getFont(), this);

    }

    override function update(dt:Float) 
    {
        

        var clampedDt = hxd.Math.min(dt, 0.1); 
        physicsWorld.step(clampedDt);

        for(entity in entities) {
            entity.update(dt);
        }
        
        var screenWidth = Const.WIDTH;
        var halfScreen = screenWidth * 0.5;

        if (mario.body.x > this.camera.x + halfScreen) {
            this.camera.x = mario.body.x - halfScreen;
            
        }
        
        if (this.camera.x > levelWidth - screenWidth) {
            this.camera.x = levelWidth - screenWidth;
        }

        this.camera.y = 0;

        var screenLeftBoundary = this.camera.x;
        if (mario.body.x < screenLeftBoundary) {
            
            mario.body.x = screenLeftBoundary;
            if (mario.body.velocity.x < 0) 
            {
               mario.body.velocity.x = 0; 
            }

        }
        
        //debugText.text = 'Player: {${mario.debugInfo()}}';
        //this.debugText.x = this.camera.x + 100;
        
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
                    
                    if(shape != null)
                    {
                        debugGraphics.drawRect(entity.body.x - (bounds.width * 0.5), 
                        entity.body.y - (bounds.height * 0.5), 
                        bounds.width, 
                        bounds.height);
                    }
                    else
                    {
                        return;
                    }
                    
                }

                if(entity.isDead)
                {
                    showHitbox = false;
                }
            }
        }
    }

}