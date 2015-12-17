package trucxanh.component.quiztype {
	import com.greensock.TweenLite;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Trung
	 */
	public class ItemImage extends Sprite {
		
		public var loader: Loader;
		public var answerMovie: Sprite;
		public var pointMovie: Sprite;
		
		private var loaderW: int;
		private var loaderH: int;
		
		private var parentW: int;
		private var parentH: int;
		
		private var isCorrect: Boolean = false;
		private var rectArr:Array = [];
		private var rectList:Array = [];
		
		public function ItemImage(xml: XML, w: int, h: int) {
			parentW = w;
			parentH = h;
			
			var imageUrl: String = xml.question_image_url;
			
			loaderW = uint(xml.question_image_url.@width);
			loaderH = uint(xml.question_image_url.@height);
			
			loader = new Loader();
			addChild(loader);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			loader.load(new URLRequest(imageUrl));
			
			answerMovie = new Sprite();
			answerMovie.graphics.beginFill(0xFFFF00, 0.5);
			rectArr = xml.question_answer.toString().split("+");
			for (var i: int = 0, size = rectArr.length; i < size; i++) {
				var pointArr: Array = String(rectArr[i]).split(":");
				answerMovie.graphics.drawRect(pointArr[0], pointArr[1], pointArr[2], pointArr[3]);
				
				rectList.push(new Rectangle(pointArr[0], pointArr[1], pointArr[2], pointArr[3]));
			}
			answerMovie.graphics.endFill();
			answerMovie.visible = false;
			addChild(answerMovie);
			
			pointMovie = new Sprite();
			addChild(pointMovie);
			
			buttonMode = true;
			
			addEventListener(MouseEvent.CLICK, mouseClickHandler, false, 0, true);
		}
		
		private function mouseClickHandler(e:MouseEvent):void {
			pointMovie.graphics.clear();
			pointMovie.graphics.beginFill(0xFF0000, 0.7);
			pointMovie.graphics.drawCircle(mouseX, mouseY, 10);
			pointMovie.graphics.endFill();
			
			isCorrect = false;
			for (var i: int = 0, size = rectList.length; i < size && !isCorrect; i++) {
				isCorrect = Rectangle(rectList[i]).containsPoint(new Point(mouseX, mouseY));
			}
			//trace( "isCorrect : " + isCorrect );
		}
		
		public function ShowAnswer(value: Boolean = true): Boolean {
			answerMovie.visible = value;
			answerMovie.alpha = 0;
			TweenLite.to(answerMovie, 0.5, { alpha:1 } );
			
			return isCorrect;
		}
		
		private function loaderCompleteHandler(e:Event):void {
			if (loaderW > 0 && loaderH > 0) {
				this.width = loaderW;
				this.height = loaderH;
			}
			
			this.x = (parentW - this.width) / 2;
		}
		
		private function errorHandler(e:IOErrorEvent):void {
			
		}
		
	}

}