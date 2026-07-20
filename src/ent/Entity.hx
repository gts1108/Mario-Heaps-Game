package ent;

import h2d.Bitmap;
import h2d.Anim;
import h2d.Object;
import echo.data.Options.BodyOptions;
import echo.Body;
import hxd.Pad;

class Entity
{

    public var isDead:Bool;
    private var sprite:Bitmap;

    private var direction:Int; //-1 left 1 right     
    private var game:Main;
    
    private var anim:Anim;
    
    public var obj:Object;
    public var body:Body;

    public var disposed:Bool;
    public var isMoving = false;
    public var isOnGround:Bool = false;
    
    public function new(x:Float, y:Float, parent:Object,bodyOptions:BodyOptions)
    {
        obj = new Object(parent);
        obj.x = x;
        obj.y = y;

        body = new Body(bodyOptions);

        body.entity = this;

        isDead = false;
        
    }

   

    public function update(dt:Float)
    {
        if(disposed)return;
        if(isDead) return;
        if (obj.x != body.x) obj.x = body.x;
        if (obj.y != body.y) obj.y = body.y;
        if (obj.rotation != body.rotation) obj.rotation = body.rotation;
    }
    
    public function dispose()
    {
       if (disposed) return;
        if (obj != null) {
            obj.remove();
            obj = null;
        }
        anim = null;
        if (body != null) {
            body.dispose();
            body.entity = null;
            body = null;
        }

        disposed = true;
        
    }

    public function dead()
    {
        isDead = true;
        body.velocity.x = 0;
        body.velocity.y = 0;
        body.acceleration.x = 0;
        body.acceleration.y = 0;
    }
}