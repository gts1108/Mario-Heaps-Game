package ent;

import hxd.Res;
import h2d.Anim;
import h2d.Tile;
import h2d.Object;


class Enemy extends Entity
{
    private var empty_Frames:Array<Tile>;

    private var gumba_Frames_Alive:Array<Tile>;
    private var gumba_Frames_Dead:Array<Tile>;

    private var beetle_Frames_Alive:Array<Tile>;
    private var beetle_Frames_Steped:Array<Tile>;


    private static var enemyTiles:Array<h2d.Tile> = null;
    
    private var current_Frames:Array<Tile>;
    private var initial_Frames:Array<Tile>;
    private var currentStateName:String;
    

    private var type:Dynamic;
    private var typeStr:String;
    

    private var isBreakable:Bool;
    private var MOVESPEED:Float = 0;
    private var isCrushed:Bool = false;
    
    private var crushedTimer:Float = 0;
    private static inline var CRUSHED_DURATION:Float = 0.533;

    public var canKill:Bool;
    
    public function new(x:Float,y:Float,parent:Object, ldtkData:Dynamic)
    {
        super(x,y,parent,
        {
            x:x,
            y:y,
            mass: 1,
            shape: {
                type:RECT,
                width: ldtkData.width, 
                height: ldtkData.height
            },
            elasticity: 0
        });
        
        //trace("Available fields on Enemy ldtkData: " + Reflect.fields(ldtkData));

        this.isDead = false;
        this.isCrushed = false;
        this.isMoving = true;
        this.canKill  =true;

        this.type = ldtkData.f_EnemyType;
        this.typeStr = Type.enumConstructor(this.type);
        

        if(enemyTiles == null)
        {
            var spritesheet = Res.Sprites.Enemy_Spritesheet.toTile();
            enemyTiles = spritesheet.gridFlatten(Const.GRID);
            for (tile in enemyTiles)
            {
                tile.setCenterRatio(0.5, 0.5);
                tile.getTexture().filter = Nearest;
            }
        }
        
        empty_Frames = [enemyTiles[7]]; //Defaults

        gumba_Frames_Alive = [enemyTiles[0],enemyTiles[1]];
        gumba_Frames_Dead  = [enemyTiles[2]];
        
        setupEnemy(this.typeStr);
        
        
        current_Frames = this.initial_Frames;
        
        direction = -1;

        anim = new Anim(current_Frames,5,obj);
    }

    public function setAnimationState(state:String, direction:Int) {
        var targetFrames = empty_Frames;

        switch(state) {
            case "Gumba_Alive":  targetFrames = gumba_Frames_Alive;
            case "Gumba_Dead" :  targetFrames = gumba_Frames_Dead;
            default           :  targetFrames = empty_Frames;
        }

        if (current_Frames != targetFrames) {
            current_Frames = targetFrames;
            currentStateName = state;

            //trace("Enemy state changed to: " + currentStateName + " (Total frames: " + current_Frames.length + ")");

            anim.play(targetFrames);
        }

        //CHANGE THIS PIECE OF SHIT LATER :)))
        if(direction > 1 || direction < -1 || direction ==0 )
        {
            hxd.System.reportError('Direction = $direction\nIt only can be 1 or -1' );
        }
    
        anim.scaleX = direction;

    }

    private function setupEnemy(typeString:String)
    {
        switch (typeString) 
        {
            case "Gumba":
                this.initial_Frames = gumba_Frames_Alive;
                this.MOVESPEED = 30; 
                this.isBreakable = true; 

            case "Beetle":
            
            default:
                this.initial_Frames = empty_Frames;
                this.MOVESPEED = 0;
                
        }
    }


    override function update(dt:Float) 
    {
        if(isCrushed)
        {
            crushedTimer+= dt;
            if(crushedTimer>=CRUSHED_DURATION)
            {
                dispose();
                return;
            }
            
        }
        
        super.update(dt);

        if(isCrushed)
            isMoving = false;
        
        if(isMoving)
        {
            body.velocity.x = direction * MOVESPEED;
        }
        switch(typeStr)
        {
            case "Gumba": 
                if (isMoving && !isCrushed)
                {
                    setAnimationState("Gumba_Alive", direction);
                }
                else
                {
                    setAnimationState("Gumba_Dead", direction);
                }

            default:
        }

        
    }

    public function playerJumpOnTop() {
    
        if(!isBreakable) return;

        isCrushed = true;
        canKill = false;

        body.active = false;
        
        
        switch (typeStr)
        {
            case "Gumba":

        }
    }
}