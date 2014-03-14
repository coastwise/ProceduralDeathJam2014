package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import openfl.Assets;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	/**
	 * Some static constants for the size of the tilemap tiles
	 */
	private static inline var TILE_WIDTH:Int = 16;
	private static inline var TILE_HEIGHT:Int = 16;
	
	/**
	 * The FlxTilemap we're using
	 */
	private var _collisionMap:FlxTilemap;


	private var _player:Player;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		// Creates a new tilemap with no arguments
		_collisionMap = new FlxTilemap();

		// Initializes the map using the generated string, the tile images, and the tile size
		_collisionMap.loadMap(Assets.getText("assets/data/test_tilemap.txt"), "assets/images/wall1_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
		add(_collisionMap);

		_player = new Player(64, 220);		
		add(_player);
	}
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		// IMPORTANT: Always collide the map with objects, not the other way around. 
		//			  This prevents odd collision errors (collision separation code off by 1 px).
		if (FlxG.overlap(_collisionMap, _player, null, FlxObject.separate)) {

			// Resetting the movement flag if the player hits the wall 
			// is crucial, otherwise you can get stuck in the wall
			_player.moveToNextTile = false;
		}
	}

	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		_player = null;
		_collisionMap = null;
	}

}