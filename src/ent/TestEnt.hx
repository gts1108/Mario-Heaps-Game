package ent;

import haxe.rtti.CType.Rights;
import hxd.Key;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;

class TestEnt extends Entity
{
    public function new(x:Float,y:Float,parent:Object)
    {
        super(x,y,parent,{
            x:x,
            y:y,
            mass:2,
            shape:{
                type:RECT,
                width:15,
                height:15
            }
        });

        body.material.elasticity = 0.5;

        sprite = new Bitmap(Tile.fromColor(0xFF0000,15,15),obj);

        sprite.tile.setCenterRatio();



    }

    override function update(dt:Float) {
        super.update(dt);

        

    }
}