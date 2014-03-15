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

	private var _dungeonBuilder:DungeonBuilder;

	private var _distMap:FlxTilemap;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		_dungeonBuilder = new DungeonBuilder();
		_dungeonBuilder.generate(63,63,64,20,64);

		_distMap = new FlxTilemap();
		_distMap.scale.set(16,16);
		var arr:Array<Int> = new Array<Int>();

		var map = "";
		for (y in 0 ... _dungeonBuilder.mapHeight) {
			for (x in 0 ... _dungeonBuilder.mapWidth) {
				if (_dungeonBuilder.mapArr[y][x] == 2) {	// wall
					map += "1,";
				} else {
					map += "0,";
					if (_player == null && _dungeonBuilder.mapArr[y][x] == 0) {
						// spawn the player on a walkable tile (0)
						_player = new Player(x * 16, y * 16);
					}
				}

				arr.push(0);
			}
			map += "0\n";
			arr.push(0);
		}

		// Creates a new tilemap with no arguments
		_collisionMap = new FlxTilemap();

		// Initializes the map using the generated string, the tile images, and the tile size
		_collisionMap.loadMap(map, "assets/images/wall1_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
		add(_collisionMap);

		_distMap.widthInTiles = _collisionMap.widthInTiles;
		_distMap.heightInTiles = _collisionMap.heightInTiles;
		_distMap.loadMap(arr, "assets/images/heat.png",1,1);

		FlxG.worldBounds.set(0, 0, _collisionMap.width, _collisionMap.height);
		//FlxG.worldBounds = _collisionMap.getBounds();

		add(_player);

		FlxG.camera.follow(_player);

		updateDistance(_player, _distMap, _collisionMap);
	}

	private function updateDistance(mcguffin:FlxSprite, distmap:FlxTilemap, tilemap:FlxTilemap):Void 
	{
		var startX:Int = Std.int((mcguffin.y/16 * tilemap.widthInTiles) + mcguffin.x/16);
		var endX:Int = 0;
		if (startX == endX)
			endX = 1;
	
		var distances:Array<Int>;
		var tempDistances = tilemap.computePathDistance(startX, endX, true, false);
		
		if (tempDistances == null)
			return;
		else
			distances = tempDistances; // safe to assign
		
		var maxDistance:Int = 1;
		for (dist in distances) 
		{
			if (dist > maxDistance)
				maxDistance = dist;
		}
		
		for (i in 0...distances.length) 
		{
			var disti:Int = 0;
			if (distances[i] < 0) 
				disti = 1000;
			else
				disti = Std.int(999 * (distances[i] / maxDistance));
				
			distmap.setTileByIndex(i, disti, true);
		}
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