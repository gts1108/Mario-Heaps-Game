package ent;


import ent.Entity;
import hxd.res.DynamicText;
import hxd.Pad;
import h2d.col.Point;
import sys.ssl.Key;
import h2d.Tile;
import hxd.res.TiledMap;
import h3d.Engine;
import h2d.Anim;
import hxd.Res;
import h2d.Bitmap;
import h2d.Object;
import h2d.Particles;

enum Direction
{
    LEFT;
    RIGHT;
}

class Mario extends Entity
{
       
    private var idleFrames:Array<Tile>;
    private var walkFrames:Array<Tile>;
    private var jumpFrames:Array<Tile>;
    private var currentFrames:Array<Tile>;

    private static inline var MOVE_SPEED = 90;
    private static inline var RUN_SPEED = 150;
    private static inline var JUMP_FORCE = -270;
    
    public var pad:Pad;

    public function new(x:Float, y:Float, parent:Object)
    {
        super(x,y,parent, {
            x:x,
            y:y,
            mass: 1,
            shape: {
                type:RECT,
                width: Const.GRID,
                height: Const.GRID
            },
            elasticity: 0
        });
        hxd.Pad.wait(onPad);

        var spritesheet = Res.mario_spritesheet.toTile();

        var animation_array:Array<Tile> = spritesheet.gridFlatten(Const.GRID);
        
        for(tile in animation_array)
        {
            tile.setCenterRatio();
            tile.getTexture().filter = Nearest;
        }
            
        idleFrames = [animation_array[0]];
        walkFrames = [animation_array[1],animation_array[2],animation_array[3]];
        jumpFrames = [animation_array[5]];
        anim = new Anim(idleFrames,12,obj);

        direction = 1; 
    }

    public function setAnimationState(state:String, direction:Int) {
        var targetFrames = idleFrames;

        switch(state) {
            case "walk":  targetFrames = walkFrames;
            case "jump":  targetFrames = jumpFrames;
            case "idle":  targetFrames = idleFrames;
            default:      targetFrames = idleFrames;
        }

        if (currentFrames != targetFrames) {
            currentFrames = targetFrames;
            anim.play(targetFrames);
        }

        //CHANGE THIS PIECE OF SHIT LATER :)))
        if(direction > 1 || direction < -1 || direction ==0 )
        {
            hxd.System.reportError('Direction = $direction\nIt only can be 1 or -1' );
        }
        

        anim.scaleX = direction;

    }

    private function onPad(p:Pad)
    {
        pad = p;
        
        if( !p.connected )
			throw "Pad not connected ?";
		p.onDisconnect = function(){
			if( p.connected )
				throw "OnDisconnect called while still connected ?";
		
		
		}
    }
    override function update(dt:Float)
    {
        isMoving = false;
        
        if (!hxd.Key.isDown(hxd.Key.LEFT) && !hxd.Key.isDown(hxd.Key.RIGHT) && (pad == null || Math.abs(pad.values[pad.config.analogX]) <= 0.3)) {
           body.velocity.x *= 0.5; 
            if (Math.abs(body.velocity.x) < 1) body.velocity.x = 0;
        }

        if(hxd.Key.isDown(hxd.Key.LEFT))
        {
            direction =-1;
            move(direction,dt);
        }
        
        if(hxd.Key.isDown(hxd.Key.RIGHT))
        {
            direction = 1;
            move(direction, dt);
        }

        if(hxd.Key.isPressed(hxd.Key.C) && isOnGround)
        {
            jump(dt);
        }
   
        if(hxd.Key.isReleased(hxd.Key.C) && body.velocity.y < 0)
        {
            body.velocity.y *= 0.5;
        }
   
        if(pad != null && pad.connected)
        {
            var conf = pad.config;
            var stickX = pad.values[conf.analogX];
            
            if (Math.abs(stickX) > 0.3) 
            { 
                if(stickX >0.3)
                {
                    direction = 1;
                }
                else if(stickX<-0.3)
                {
                    direction = -1;
                }
                move(direction,dt);  
            }

            if(pad.isDown(conf.A) && isOnGround ) {
                jump(dt);
            }

            if(pad.isReleased(conf.A) && body.velocity.y <0)
            {
                body.velocity.y *=0.5;
            }
        }

        if(isMoving && isOnGround)
        {
            setAnimationState("walk",direction);
        }
        else if(!isOnGround)
        {
            setAnimationState("jump", direction);
        }
        else
        {
            setAnimationState("idle",direction);
        }

        trace(debugInfo());
        
    }

    
    private function move(dir:Float,dt:Float)
    {
        if(pad != null && pad.connected)
        {
            body.velocity.x = pad.isDown(pad.config.X) ? dir*RUN_SPEED : dir*MOVE_SPEED;
        }
        else
        {
            body.velocity.x = hxd.Key.isDown(hxd.Key.X) ? dir*RUN_SPEED : dir*MOVE_SPEED;
        }
        
        isMoving = true;
        
    }

    private function jump(dt:Float)
    {
        body.velocity.y = JUMP_FORCE;
        isOnGround = false;
        
    }

    public function debugInfo():String
    {
        //Add debug info to display/trace

        return 'Body X: ${body.x}\nBody Y: ${body.y}\nisMoving: ${isMoving}\nisOnGround: ${isOnGround}';
    }
}