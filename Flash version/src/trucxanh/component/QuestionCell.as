package trucxanh.component {
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import trucxanh.common.Constant;
	/**
	 * ...
	 * @author Trung đẹp trai
	 */
	public class QuestionCell extends Sprite {
		public var maskMovie: Sprite;
		public var captionText: TextField;
		public var contentQuestion: String = "";
		public var answerQuestion: String = "";
		public var dataXML: XML = null;
		
		private var cellWidth: Number = 0;
		private var cellHeight: Number = 0;
		
		
		public function QuestionCell() {
			this.text = "";
			
			captionText.filters = [];
			
			maskMovie = new Sprite();
			maskMovie.graphics.beginFill(0, 0);
			maskMovie.graphics.drawRect(0, 0, 10, 10);
			maskMovie.graphics.endFill();
			this.addChild(maskMovie);
			
			buttonMode = true;
			
			this.addEventListener(MouseEvent.CLICK, mouseHandler, false, 0, true);
		}
		
		private function mouseHandler(event: MouseEvent): void {
			switch (event.type) {
				case MouseEvent.CLICK:
					//this.visible = false;	//////////////////////
					this.dispatchEvent(new Event(Constant.EVENT_CELL_CLICK, true));
				break;
			}
		}
		
		public function openCell(): void {
			TweenLite.to(this, 0.5, {alpha: 0, onComplete: openTweenCompleteHandler} );
		}
		
		public function markCell(): void {
			var colorTransform: ColorTransform = new ColorTransform();
			colorTransform.redOffset = 75;
			colorTransform.greenOffset = 75;
			colorTransform.blueOffset = 75;
			this.transform.colorTransform = colorTransform;
		}
		
		private function openTweenCompleteHandler():void {
			if (parent)	parent.removeChild(this);
		}
		
		public function set text(value: String): void {
			captionText.htmlText = value;
		}
		
		public function get text(): String {
			return captionText.text;
		}
		
		public function setData(cell: XML, w: Number, h: Number): void {
			dataXML = cell;
			
			this.cellWidth = w;
			this.cellHeight = h;
			
			captionText.width = cellWidth;
			captionText.y = (cellHeight - captionText.height) / 2;
			
			maskMovie.width = this.cellWidth;
			maskMovie.height = this.cellHeight;
			
			this.text = cell.label.toString();
			
			var loader: Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			loader.load(new URLRequest(cell.image_url.toString()));
			
			contentQuestion = cell.question_content.toString();
			answerQuestion = cell.question_answer.toString();
		}
		
		private function loaderCompleteHandler(event: Event): void {
			var content: DisplayObject = event.currentTarget.loader.content;
			if (content.width / content.height < cellWidth / cellHeight)	content.scaleX = content.scaleY = cellWidth / content.width;
			else	content.scaleX = content.scaleY = cellHeight / content.height;
			//content.width = cellWidth;
			//content.height = cellHeight;
			
			content.y = (cellHeight - content.height) / 2;
			this.addChild(content);
			content.mask = maskMovie;
			content.filters = [new GlowFilter(0x000000)];
			this.setChildIndex(captionText, this.numChildren - 1);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function ioErrorHandler(event: IOErrorEvent): void {
			trace(event.text);
		}
	}

}