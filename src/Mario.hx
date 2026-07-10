package src;

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

enum State
{
    Walking;
    Idle;
}
class Mario
{
    public var isSolid(get,null):Bool = true;

    private var obj:Object;
    private var game:Main;
    
    private var anim:Anim;
    
    private var idleFrames:Array<Tile>;
    private var walkFrames:Array<Tile>;
    private var jumpFrames:Array<Tile>;
    private var currentFrames:Array<Tile>;

    
    private var velocity:Point;

    private static inline var GRAVITY = 0.7;
    private static inline var MOVE_SPEED = 2;
    private static inline var RUN_SPEED = 5;
    private static inline var JUMP_FORCE = -11;
    
    
    private var isOnGround:Bool;
    
    private var canJump:Bool = true; 
    public var pad:Pad;
    
    
    public function new(x:Float, y:Float, parent:Object)
    {
        game = Main.inst;
        
        hxd.Pad.wait(onPad);
        
        obj = new Object(parent);
        obj.x = x;
        obj.y = y;
        
        velocity = new Point();
        
        var spritesheet = Res.mario_spritesheet.toTile();

        var animation_array:Array<Tile> = spritesheet.gridFlatten(16);
        
        for(tile in animation_array)
        {
            tile.setCenterRatio();
            tile.getTexture().filter = Nearest;
        }
            
        idleFrames = [animation_array[0]];
        walkFrames = [animation_array[1],animation_array[2],animation_array[3]];
        jumpFrames = [animation_array[5]];
        anim = new Anim(idleFrames,12,obj);

        
    }

   public function setAnimationState(state:String, facingRight:Bool) {
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

        //anim.speed = (state == "walk") ? 14 : 0;

        anim.scaleX = facingRight ? 1.0 : -1.0;
    
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
    public function update(dt:Float)
    {
        velocity.x = 0;

        var isMoving = false;
        var isfacingRight = anim.scaleX>0;

        if(hxd.Key.isDown(hxd.Key.LEFT))
        {
            velocity.x = hxd.Key.isDown(hxd.Key.X) ? -RUN_SPEED : -MOVE_SPEED;
            
            isMoving = true;
            isfacingRight = false;
               
        }
        
        if(hxd.Key.isDown(hxd.Key.RIGHT))
        {
            velocity.x = hxd.Key.isDown(hxd.Key.X) ? RUN_SPEED : MOVE_SPEED;
            
            isMoving = true;
            isfacingRight = true;
        }

        if(hxd.Key.isPressed(hxd.Key.C) && isOnGround &&canJump )
        {
            
            velocity.y = JUMP_FORCE;
            isOnGround = false;
            canJump = false;
        }
   
        if(hxd.Key.isReleased(hxd.Key.C) && velocity.y < 0)
        {
            velocity.y *= 0.5;
            //isOnGround = false;
            //canJump = false;
        }
   
        if(pad != null && pad.connected)
        {
            var conf = pad.config;
            var stickX = pad.values[conf.analogX];
            
            if (Math.abs(stickX) > 0.3) 
            { 
                velocity.x = hxd.Key.isDown(hxd.Key.X) ? stickX*RUN_SPEED : stickX* MOVE_SPEED;
                isMoving = true;
                isfacingRight = stickX > 0;
            }


            
            if(pad.isDown(conf.A) && isOnGround ) {
                velocity.y = JUMP_FORCE;
                isOnGround = false;
            }

            if(pad.isReleased(conf.A) && velocity.y <0)
            {
                velocity.y = JUMP_FORCE*0.5;
                isOnGround = false;
            }
        }
        velocity.y += GRAVITY ; 

        obj.x += velocity.x;
        obj.y += velocity.y;
        
        if(obj.y >= 150)
        {
            obj.y = 150;
            isOnGround = true;
            canJump = true;
            velocity.y= 0;            
        }
        if(isMoving && isOnGround)
        {
            setAnimationState("walk",isfacingRight);
        }
        else if(!isOnGround)
        {
            setAnimationState("jump", isfacingRight);
        }
        else
        {
            setAnimationState("idle",isfacingRight);
        }
        
    }

    

    function get_isSolid():Bool 
    {
        return isSolid;
    }
}