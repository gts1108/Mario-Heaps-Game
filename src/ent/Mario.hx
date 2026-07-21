package ent;


import h2d.Camera;
import ent.Entity;
import hxd.res.DynamicText;
import hxd.Pad;
import h2d.col.Point;
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

enum MarioStates
{
    NORMAL;
    GROWN;
    STAR;
    GLITCHED;//Cool easter egg later
}

class Mario extends Entity
{
       
    private var idleFrames:Array<Tile>;
    private var walkFrames:Array<Tile>;
    private var jumpFrames:Array<Tile>;
    private var deadFrames:Array<Tile>;

    private var currentFrames:Array<Tile>;
    private var currentAnimState:String;
    private var lastAnimSpeed:Float = -1.0;
    
    private static inline var MOVE_SPEED = 90;
    private static inline var RUN_SPEED = 150;
    private static inline var JUMP_FORCE = -365;
    private static inline var ACCELERATION_RATE:Float = 300.0; 
    private static inline var FRICTION_RATE:Float = 400.0;
    

    public var pad:Pad;
    

    public function new(x:Float, y:Float, parent:Object)
    {
        super(x,y,parent, {
            x:x,
            y:y,
            mass: 1,
            shape: {
                type:RECT,
                width: Const.GRID -4,
                height: Const.GRID  
            },
            material: {
                friction: 0,
                elasticity: 0
            }
        });
        
        //hxd.Pad.wait(onPad);

        var spritesheet = Res.Sprites.mario_spritesheet.toTile();

        var animation_array:Array<Tile> = spritesheet.gridFlatten(Const.GRID);
        
        for(tile in animation_array)
        {
            tile.setCenterRatio();
            tile.getTexture().filter = Nearest;
        }
            
        idleFrames = [animation_array[0]];
        walkFrames = [animation_array[1],animation_array[2],animation_array[3]];
        jumpFrames = [animation_array[5]];
        deadFrames = [animation_array[6]];
        
        isMoving = false;
        direction = 1;
        
        currentFrames = idleFrames;
        currentAnimState = "idle";

        anim = new Anim(idleFrames,12,obj);
        
        //setVisualOffset(0, -1);
        
    }

    public function setAnimationState(state:String, direction:Int) {
        var targetFrames = idleFrames;

        switch(state) {
            case "walk":  targetFrames = walkFrames;
            case "jump":  targetFrames = jumpFrames;
            case "idle":  targetFrames = idleFrames;
            case "dead":  targetFrames = deadFrames;
            default:      targetFrames = idleFrames;
        }

        if (currentFrames != targetFrames) {
            currentFrames = targetFrames;
            anim.play(targetFrames);
        }

        
        if (direction > 1 || direction < -1 || direction == 0) {
            var errorMsg = 'Direction = ' + direction + '\nIt only can be 1 or -1';
            hxd.System.reportError(errorMsg);
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

        super.update(dt);
        
        if(!isDead)
        {
            var moveInput = 0;
            if(hxd.Key.isDown(hxd.Key.LEFT)) { moveInput = -1; }
            if(hxd.Key.isDown(hxd.Key.RIGHT)){ moveInput =  1; }
            
            
            var padConnected = (pad != null && pad.connected);
            if(padConnected)
            {
                var stickX = pad.values[pad.config.analogX];
                if (Math.abs(stickX) > 0.3) 
                {
                    moveInput = stickX > 0 ? 1 : -1;
                }
            }
            if(moveInput != 0)
            {
                direction = moveInput > 0 ? 1 : -1;
                move(direction,dt, padConnected);
            }
            
            else
            {
                if (body.velocity.x > 0) 
                {
                    body.velocity.x -= FRICTION_RATE ;
                    if (body.velocity.x < 0) body.velocity.x = 0;
                }
                else if (body.velocity.x < 0) 
                {
                    body.velocity.x += FRICTION_RATE ;
                    if (body.velocity.x > 0) body.velocity.x = 0;
                }
            }
        
        
            var jumpPressed = hxd.Key.isPressed(hxd.Key.C);
            var jumpReleased = hxd.Key.isReleased(hxd.Key.C);
            
            if (padConnected) 
            {
                if (pad.isPressed(pad.config.A)) jumpPressed = true;
                if (pad.isReleased(pad.config.A)) jumpReleased = true;
            }

            if (jumpPressed && isOnGround)
            {
                jump(dt);
            }
        
            if (jumpReleased && body.velocity.y < 0)
            {
                body.velocity.y *= 0.5;
            }


        }
      
        if (isDead)
        {
            setAnimationState("dead", direction);
        }
        else if (isOnGround)
        {
            
            if (Math.abs(body.velocity.x) > 2.0)
            {
                setAnimationState("walk", direction);
            }
            else
            {
                setAnimationState("idle", direction);
            }
        }
        else 
        {
            setAnimationState("jump", direction);
        }
    }
    

    private function move(dir:Float,dt:Float,padConnected:Bool)
    {

        var isRunning:Bool= true;

        if(padConnected)
        {
            isRunning = pad.isDown(pad.config.X);
        }
        else
        {
            isRunning = hxd.Key.isDown(hxd.Key.X);
        }
        
        var targetMaxSpeed = isRunning ? RUN_SPEED: MOVE_SPEED;


        body.velocity.x += dir * ACCELERATION_RATE ;

        if(body.velocity.x >= targetMaxSpeed)
        {
            body.velocity.x = targetMaxSpeed;

        }
        if(body.velocity.x <= -targetMaxSpeed)
        {
            body.velocity.x = -targetMaxSpeed;
        }
        //body.velocity.x = hxd.Math.clamp(body.velocity.x, -targetMaxSpeed, targetMaxSpeed);
        isMoving = true;
        
    }

    private function jump(dt:Float)
    {
        body.velocity.y = JUMP_FORCE;
        isOnGround = false;
        
    }

    public function debugInfo():String
    {
        return 'Body X: ${Math.round(body.x)}\n' +
               'Body Y: ${Math.round(body.y)}\n' +
               'Speed X: ${Math.round(body.velocity.x)}\n' +
               'isMoving: ${isMoving}\n' +
               'isOnGround: ${isOnGround}';
    }

    public function setVisualOffset(dx:Float, dy:Float) {
        if (anim != null) {
            anim.x = dx;
            anim.y = dy;
        }
    }

    
}


