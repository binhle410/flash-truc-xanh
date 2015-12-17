package trucxanh.component.quiztype {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Trung
	 */
	public class ItemSelect extends MovieClip {
		
		public var contentText: TextField;
		
		public function ItemSelect() {
			stop();
			
			contentText.autoSize = "left";
			
			var coverMovie: Sprite = new Sprite();
			coverMovie.graphics.beginFill(0, 0);
			coverMovie.graphics.drawRect(0, -this.height/2, this.width, this.height);
			coverMovie.graphics.endFill();
			addChild(coverMovie);
			
			buttonMode = true;
		}
		
		public function SetActive(isActive: Boolean): void {
			gotoAndStop((isActive) ? 2 : 1 );
		}
		
		public function GetActive(): Boolean {
			return (currentFrame == 2);
		}
		
		public function SetHighlight(value: Boolean): void {
			contentText.background = value;
			contentText.backgroundColor = 0xFFFF00;
		}
	}

}