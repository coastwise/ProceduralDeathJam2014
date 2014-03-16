package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
using flixel.util.FlxSpriteUtil;

class GameOverSubState extends FlxSubState
{
	override public function create():Void 
	{
		bgColor = 0xAA000000;
		
		var t = new FlxText(0, 90, FlxG.width, "Game Over", 32);
		t.alignment = "center";
		add(t);
		
		var t2 = new FlxText(0, 170, FlxG.width, 
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