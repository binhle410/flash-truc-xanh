package trucxanh.component.quiztype {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Trung
	 */
	public class ItemInput extends Sprite{
		
		public var contentText: TextField;
		
		
		
		public function ItemInput(xml: XML, w: Number, h: Number) {
			contentText.width = w;
			contentText.autoSize = "left";
			contentText.htmlText = xml.question_input;
			contentText.visible = false;
			
			var posX: Number = 0;
			var posY: Number = 0;
			
			var lineArray: Array = String(xml.question_input).split("\n").join("<br/>").split("<br/>");
			for (var i: int = 0, size = lineArray.length; i < size; i++) {
				posX = 0;
				var partArray: Array = String(lineArray[i]).split("<input>");
				var tf: TextField;
				for (var j: int = 0, len = partArray.length-1; j < len; j++) {
					tf = CreateTF(partArray[j], posX, posY);
					addChild(tf);
					posX += tf.width;
					
					var tmpH: Number = tf.height;
					var format: TextFormat = tf.defaultTextFormat;
					format.align = TextFormatAlign.CENTER;
					
					tf = CreateTF("", posX, posY);
					tf.defaultTextFormat = format;
					tf.autoSize = TextFieldAutoSize.NONE;
					tf.width = 200;
					tf.height = tmpH;
					tf.type = TextFieldType.INPUT;
					tf.border = true;
					tf.borderColor = 0x000000;
					tf.background = true;
					tf.backgroundColor = 0xFFFFFF;
					tf.selectable = true;
					addChild(tf);
					posX += tf.width;
				}
				if (partArray.length > 0) {
					tf = CreateTF(partArray[partArray.length-1], posX, posY);
					addChild(tf);
					
					posY += tf.height;
				}
			}
		}
		
		private function CreateTF(text: String, x: Number, y: Number): TextField {
			var tf: TextField = new TextField();
			tf.defaultTextFormat = contentText.defaultTextFormat;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.embedFonts = true;
			tf.filters = contentText.filters;
			tf.htmlText = text;
			tf.selectable = false;
			tf.x = x;
			tf.y = y;
			return tf;
		}
		
		public function getAnswer(): String {
			var s: String = "";
			for (var i: int = 0, size = numChildren; i < size; i++) {
				var tf: TextField = getChildAt(i) as TextField;
				if (tf && tf.type == TextFieldType.INPUT) {
					if (s == "") {
						s = tf.text;
					} else {
						s = s + "+" + tf.text;
					}
				}
			}
			return s;
		}
	}

}