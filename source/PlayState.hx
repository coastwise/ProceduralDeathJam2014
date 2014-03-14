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


	private var _player:FlxSprite;
	
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

		setupPlayer();
	}

	public function setupPlayer():Void {
		_player = new FlxSprite(64, 220);
		_player.loadGraphic("assets/images/player.png", true, true, 16);
		_player.animation.add("idle", [0, 1], 2);
		
		add(_player);
	}
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		// Tilemaps can be collided just like any other FlxObject, and flixel
		// automatically collides each individual tile with the object.
		FlxG.collide(_player, _collisionMap);

		updatePlayer();

		super.update();
	}

	public function updatePlayer():Void {
		_player.animation.play("idle");

		if (FlxG.keys.anyJustPressed(["LEFT", "A"])) {
			_player.facing = FlxObject.LEFT;
			_player.x -= 16;

		} else if (FlxG.keys.anyJustPressed(["RIGHT", "D"])) {
			_player.facing = FlxObject.RIGHT;
			_player.x += 16;
		}

		if (FlxG.keys.anyJustPressed(["UP", "W"])) {
			_player.y -= 16;
		} else if (FlxG.keys.anyJustPressed(["DOWN", "S"])) {
			_player.y += 16;
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