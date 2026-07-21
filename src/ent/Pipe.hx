package ent;

import h2d.Object;

class Pipe extends Entity
{
    public function new(x:Float,y:Float, parent:Object, ldtkData:Dynamic)
    {
        super(x,y,parent,{
            x:x,
            y:y,
            mass: 0,
            shape: { type: RECT, width: ldtkData.width, height: ldtkData.height }
        });
        
    }
}