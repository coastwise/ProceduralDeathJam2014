package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
using flixel.util.FlxSpriteUtil;

class GameOverSubState extends FlxSubState
{
	private var _x:Int;
	private var _y:Int;

	public function new(x:Int, y:Int)
	{
		// X,Y: Starting coordinates
		super();
		_x = x;
		_y = y;
	}

	override public function create():Void 
	{
		bgColor = 0xAA000000;
		
		var t = new FlxText(_x - FlxG.width/2, _y+90 - FlxG.height/2, FlxG.width, "Game Over", 32);
		t.alignment = "center";
		add(t);
		
		var t2 = new FlxText(_x - FlxG.width/2, _y+170 - FlxG.height/2, FlxG.width, 
		                     "Press 'R' to restart", 16);
		t2.alignment = "center";
		add(t2);
	}

	override public function update():Void
	{
		if (FlxG.keys.anyPressed(["R"])) {
			FlxG.switchState(new PlayState());
		}
	}
}