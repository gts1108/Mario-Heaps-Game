package src;

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

class Mario
{
   
    private var direction:Int; //-1 left 1 right     

    private var obj:Object;
    private var game:Main;
    
    private var anim:Anim;
    
    private var idleFrames:Array<Tile>;
    private var walkFrames:Array<Tile>;
    private var jumpFrames:Array<Tile>;
    private var currentFrames:Array<Tile>;

    
    private var velocity:Point;

    private static inline var GRAVITY = 29.2;
    private static inline var MOVE_SPEED = 83;
    private static inline var RUN_SPEED = 150;
    private static inline var JUMP_FORCE = -458;
    
    
    private var isOnGround:Bool;

    private var canJump:Bool = true; 
    public var isSolid(get,null):Bool = true;
    public var pad:Pad;
    public var isMoving = false;
    
    
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
    public function update(dt:Float)
    {
        
        velocity.x = 0;
        isMoving = false;

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

        if(hxd.Key.isPressed(hxd.Key.C) && isOnGround &&canJump )
        {
            jump(dt);
        }
   
        if(hxd.Key.isReleased(hxd.Key.C) && velocity.y < 0)
        {
            velocity.y *= 0.5;
        }
   
        if(pad != null && pad.connected)
        {
            var conf = pad.config;
            var stickX = pad.values[conf.analogX];
            trace(stickX);
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

            if(pad.isReleased(conf.A) && velocity.y <0)
            {
                velocity.y *=0.5;
            }
        }
        velocity.y += GRAVITY *dt; 

        obj.x += velocity.x ;
        obj.y += velocity.y;
        
        if(obj.y >= 150)
        {
            obj.y = 150;
            onGround();         
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
        
    }

    

    function get_isSolid():Bool 
    {
        return isSolid;
    }

    private function move(dir:Float,dt:Float)
    {
        if(pad != null && pad.connected)
        {
            velocity.x = pad.isDown(pad.config.X) ? dir*RUN_SPEED * dt: dir*MOVE_SPEED*dt;
        }
        else
        {
            velocity.x = hxd.Key.isDown(hxd.Key.X) ? dir*RUN_SPEED * dt: dir*MOVE_SPEED*dt;
        }
        
        isMoving = true;
        
    }

    private function jump(dt:Float)
    {
        velocity.y = JUMP_FORCE*dt;
        isOnGround = false;
        canJump = false;
    }

    private function onGround()
    {
        isOnGround = true;
        canJump = true;
        velocity.y= 0;   
    }
}