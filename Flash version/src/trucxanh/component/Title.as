package trucxanh.component {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author Trung đẹp trai
	 */
	public class Title extends Sprite {
		public var captionText: TextField;
		
		public function Title() {
			captionText.autoSize = TextFieldAutoSize.LEFT;
			this.text = "";
		}
		
		public function set text(value: String): void {
			captionText.htmlText = value;
		}
		
		public function get text(): String {
			return captionText.text;
		}
	}

}