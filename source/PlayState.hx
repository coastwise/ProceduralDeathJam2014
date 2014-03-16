package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import openfl.Assets;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	public static inline var SPEED:Int = 64;
	
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
	private var _pos:FlxPoint;

	private var _minotaur:Seeker;
	private var _dungeonBuilder:DungeonBuilder;

	private var _distMap:FlxTilemap;
	private var _fogMap:FlxTilemap;

	public var distances:Array<Int>;
	public var endX:Int;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		FlxG.camera.bgColor = FlxColor.WHITE;
		
		_dungeonBuilder = new DungeonBuilder();
		_dungeonBuilder.generate(63,63,64,20,64);

		_distMap = new FlxTilemap();
		_distMap.scale.set(16,16);
		var arr:Array<Int> = new Array<Int>();

		_fogMap = new FlxTilemap();

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

					if (_dungeonBuilder.mapArr[y][x] == 0) {
						// note the last index inside the dungeon
						endX = y * (_dungeonBuilder.mapWidth+1) + x;
					}
				}

				arr.push(7);
			}
			map += "0\n";
			arr.push(7);
		}

		// Creates a new tilemap with no arguments
		_collisionMap = new FlxTilemap();

		// Initializes the map using the generated string, the tile images, and the tile size
		_collisionMap.loadMap(map, "assets/images/wall1_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
		add(_collisionMap);

		_distMap.widthInTiles = _collisionMap.widthInTiles;
		_distMap.heightInTiles = _collisionMap.heightInTiles;
		_distMap.loadMap(arr, "assets/images/heat.png",1,1);

		_fogMap.widthInTiles = _collisionMap.widthInTiles;
		_fogMap.heightInTiles = _collisionMap.heightInTiles;
		_fogMap.loadMap(arr, "assets/images/dither.png",16,16);
		
		
		FlxG.worldBounds.set(0, 0, _collisionMap.width, _collisionMap.height);
		//FlxG.worldBounds = _collisionMap.getBounds();

		_pos = FlxPoint.get();
		_pos.x = Std.int(_player.x / 16);
		_pos.y = Std.int(_player.y / 16);
		add(_player);

		var x = endX % _collisionMap.widthInTiles;
		var y = (endX - x) / _collisionMap.widthInTiles;
		_minotaur = new Seeker(x*16,y*16);
		_minotaur.moveTo(x*16,y*16, SPEED);
		add(_minotaur);

		add(_fogMap);

		FlxG.camera.follow(_player);

		updateFog(Std.int(_pos.x), Std.int(_pos.y), 6);
		updateDistance(_pos, endX, _distMap, _collisionMap);
	}

	private function updateDistance(mcguffin:FlxPoint, endX:Int, distmap:FlxTilemap, tilemap:FlxTilemap):Void 
	{
		var startX:Int = Std.int((mcguffin.y * tilemap.widthInTiles) + mcguffin.x);
		if (startX == endX)
			endX++;
	
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

	public function updateSeeker(seeker:Seeker, distmap:FlxTilemap):Void {
		if (!seeker.moving)
		{
			var tx:Int = Std.int((seeker.x-seeker.offset.x) / 16);
			var ty:Int = Std.int((seeker.y-seeker.offset.y) / 16);
			
			var bestX:Int = 0;
			var bestY:Int = 0;
			var bestDist:Float = Math.POSITIVE_INFINITY;
			var neighbors:Array<Array<Float>> = [[999, 999, 999], [999, 999, 999], [999, 999, 999]];
			for (yy in -1...2) 
			{
				for (xx in -1...2) 
				{
					var theX:Int = tx + xx;
					var theY:Int = ty + yy;
					
					if (theX >= 0 && theY < distmap.widthInTiles) 
					{
						if (theY >= 0 && theY < distmap.heightInTiles) 
						{
							if (xx == 0 || yy == 0)
							{
								var distance:Float = distances[theY * distmap.widthInTiles + theX];
								neighbors[yy + 1][xx + 1] = distance;
								if (distance > 0)
								{
									if (distance < bestDist || (bestX == 0 && bestY == 0))
									{
										bestDist = distance;
										bestX = xx;
										bestY = yy;
									}
								}
							}
						}
					}
				}
			}
			
			if (!(bestX == 0 && bestY == 0))
			{
				seeker.moveTo((tx * 16) + (bestX * 16) + seeker.offset.x, (ty * 16) + (bestY * 16) + seeker.offset.y, SPEED);
			}
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

		if (Std.int(_player.x/16) != _pos.x || Std.int(_player.y/16) != _pos.y) {
			_pos.x = Std.int(_player.x / 16);
			_pos.y = Std.int(_player.y / 16);

			updateDistance(_pos, endX, _distMap, _collisionMap);
			updateFog(Std.int(_pos.x), Std.int(_pos.y), 6);
		}

		updateSeeker(_minotaur, _distMap);

		var dist = FlxMath.getDistance(FlxPoint.get(_player.x, _player.y), FlxPoint.get(_minotaur.x, _minotaur.y));
		if (dist <= 1.414213562*16) {
			remove(_player);
			add(new FlxSprite(_player.x, _player.y, "assets/images/dead.png"));
			openSubState(new GameOverSubState());
		}

	}

	public function updateFog(x:Int, y:Int, radius:Int):Void
	{
		for (j in y - radius ... y + radius) {
			if (j < 0 || j > _fogMap.widthInTiles) continue;
			
			for (i in x - radius ... x + radius) {
				if (i < 0 || i > _fogMap.heightInTiles) continue;

				var idx:Int = (j * _fogMap.widthInTiles) + i;
				var val:Int = Std.int(Math.abs(x-i) + Math.abs(y-j));
				if (_fogMap.getTileByIndex(idx) > val) {
					_fogMap.setTileByIndex(idx, val, true);
				}
			}
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