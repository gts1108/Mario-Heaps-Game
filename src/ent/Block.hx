package ent;

import h2d.Bitmap;
import echo.util.TileMap;
import echo.Body;
import hxd.fmt.hmd.Library.GeometryBuffer;
import echo.data.Options.BodyOptions;
import h2d.Object;
import h2d.Tile;



class Block extends Entity
{
    public var type:Dynamic;
    private var localTile:Tile;

    public var isBreakable:Bool;
    public var bounciness:Float = 0;
    //public var playerFriction:Float = 1;


    private static var blockTiles:Array<h2d.Tile> = null;
    
    public function new(x:Float, y:Float, parent:Object, ldtkData:Dynamic)
    {   
        super(x, y, parent, {
            x: x,
            y: y,
            mass: 0, 
            shape: { type: RECT, width: ldtkData.width, height: ldtkData.height }
        });
    
        this.type = ldtkData.f_BlockType;
        
        var typeStr = Type.enumConstructor(this.type);
        setupBlock(typeStr);
        
        
        if (blockTiles == null) 
        {
            var spritesheet = hxd.Res.Sprites.overworld_spritesheet.toTile();
            blockTiles = spritesheet.gridFlatten(Const.GRID); 
    
        }

        
        var chosenTile:h2d.Tile = null;
        
        switch(typeStr)
        {
            case "Stone":               chosenTile = blockTiles[2];
            case "Wood":                chosenTile = blockTiles[1];
            case "Block":               chosenTile = blockTiles[5];
            default:                    chosenTile = blockTiles[0];
        }

        
        if (chosenTile != null) 
        {
            this.sprite = new Bitmap(chosenTile, this.obj);
            this.sprite.tile.setCenterRatio(0.5, 0.5);
        }

         
        this.body.material.friction = 0;
    }

    private function drawFallbackBox(w:Float, h:Float) {
        var g = new h2d.Graphics(this.obj);
        g.beginFill(0xFF0000, 1.0); // Solid Red Box
        g.drawRect(-w * 0.5, -h * 0.5, w, h);
        g.endFill();
    }

    private function setupBlock(typeStr:String)
    {

        if(typeStr == "Wood")
        {
            this.isBreakable = false; 
            
        }
        else if(typeStr == "Block")
        {
            this.isBreakable = false;
            
        }
        else if(typeStr == "Stone")
        {
            this.isBreakable = false;
        }
        else if (typeStr == "EmptyBlock")
        {
            this.isBreakable = false;
        }
     
    }
    public function onPlayerLand(playerBody:Body, mario:Entity) 
    {
        mario.isOnGround = true;
        
      
        //playerBody.velocity.x *= playerFriction;

        if (bounciness > 0) 
        {
            playerBody.velocity.y = -350 * bounciness;
        }
    }
    
    public function onPlayerHeadbutt(playerBody:Body, mario:Entity) 
    {
        if (isBreakable) 
        {
            breakApart();
        }

        var typeStr = Type.enumConstructor(this.type);

        if(typeStr=="Block")
        {
            
            setupBlock("Stone"); 
            
            var enumType = Type.getEnum(this.type);
            this.type = Type.createEnum(enumType, "Stone");

            if (this.sprite != null && blockTiles != null) 
            {
                var newTile = blockTiles[2].clone();
                newTile.setCenterRatio(0.5, 0.5); 
                this.sprite.tile = newTile;
            }
        }
        


    }

    public function breakApart() {
        if (!isBreakable) return;

        if (this.body != null) {
            this.body.remove(); 
        }

        this.obj.remove();
        this.isDead = true;
    }
}