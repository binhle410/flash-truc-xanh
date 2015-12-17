package trucxanh.component.quiztype {
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Trung
	 */
	public class ItemMatching extends Sprite {
		
		public var contentText: TextField;
		
		private var coverMovie: Sprite;
		
		public function ItemMatching(bgColor: uint = 0xEEEEEE) {
			contentText.border = true;
			contentText.borderColor = 0x000000;
			contentText.background = true;
			contentText.backgroundColor = bgColor;
			
			coverMovie = new Sprite();
			coverMovie.graphics.beginFill(0, 0.3);
			coverMovie.graphics.drawRect(0, -this.height/2, this.width, this.height);
			coverMovie.graphics.endFill();
			addChild(coverMovie);
			
			buttonMode = true;
		}
		
		public function set text(value: String): void {
			contentText.htmlText = value;
			
			coverMovie.width = contentText.width;
		}
	}

}