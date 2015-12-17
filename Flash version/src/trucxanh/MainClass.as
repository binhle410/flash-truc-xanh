package trucxanh {
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import trucxanh.common.Constant;
	import trucxanh.component.QuestionCell;
	import trucxanh.component.QuestionContent;
	import trucxanh.component.QuestionTable;
	import trucxanh.component.Title;
	/**
	 * ...
	 * @author Trung đẹp trai
	 */
	public class MainClass extends Sprite {
		public var xml: XML;
		public var titleMovie: Title;
		public var bgMovie: Sprite;
		public var hiddenMovie: Sprite;
		public var tableMovie: QuestionTable;
		public var contentBgMovie: DisplayObject;
		public var fullscreenMovie: Sprite;
		public var lightOffMovie: Sprite;
		public var showAllMovie: Sprite;
		
		private var currentActiveCell: QuestionCell;
		
		public function MainClass() {
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
		}
		
		private function addedToStageHandler(event: Event): void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			init();
			initEvent();
		}
		
		private function initEvent():void {
			this.addEventListener(Constant.EVENT_CELL_CLICK, cellClickHandler, false, 0, true);
			//this.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullscreenChangeHandler, false, 0, true);
			//this.stage.addEventListener(Event.RESIZE, resizeHandler, false, 0, true);
		}
		
		private function resizeHandler(event: Event): void {
			fullscreenChangeHandler(null);
		}
		
		private function fullscreenChangeHandler(event: FullScreenEvent): void {
			if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				this.width = stage.fullScreenWidth;
				this.height = stage.fullScreenHeight;
			}
			else {
				this.width = stage.stageWidth;
				this.height = stage.stageHeight;
			}
			Constant.MOVIE_WIDTH = this.width;
			Constant.MOVIE_HEIGHT = this.height;
		}
		
		private function cellClickHandler(event: Event): void {
			currentActiveCell = event.target as QuestionCell;
			
			var questionMovie: QuestionContent = new QuestionContent();
			this.addChild(questionMovie);
			//questionMovie.setData(currentActiveCell.text, currentActiveCell.contentQuestion, currentActiveCell.answerQuestion, hiddenMovie.width, hiddenMovie.height, contentBgMovie);
			questionMovie.setDataXML(currentActiveCell.dataXML, hiddenMovie.width, hiddenMovie.height, contentBgMovie);
			questionMovie.width = hiddenMovie.width;
			questionMovie.height = hiddenMovie.height;
			questionMovie.alpha = 0;
			var sPoint: Point = currentActiveCell.parent.localToGlobal(new Point(currentActiveCell.x, currentActiveCell.y));
			questionMovie.x = sPoint.x + currentActiveCell.width / 2;
			questionMovie.y = sPoint.y + currentActiveCell.height / 2;
			
			questionMovie.addEventListener(Constant.EVENT_CORRECT, questionResultHandler, false, 0, true);
			questionMovie.addEventListener(Constant.EVENT_WRONG, questionResultHandler, false, 0, true);
			questionMovie.addEventListener(Constant.EVENT_CLOSE, questionResultHandler, false, 0, true);
			questionMovie.scaleX = 0.001;
			questionMovie.scaleY = 0.001;
			TweenLite.to(questionMovie, 0.7, {alpha: 1, x: hiddenMovie.x, y: hiddenMovie.y, scaleX: 1, scaleY: 1});
		}
		
		private function questionResultHandler(event: Event): void {
			switch (event.type) {
				case Constant.EVENT_CLOSE:
				
				break;
				case Constant.EVENT_CORRECT:
					currentActiveCell.openCell();
				break;
				case Constant.EVENT_WRONG:
					currentActiveCell.markCell();
				break;
			}
			
			var questionMovie: QuestionContent = event.currentTarget as QuestionContent;
			var sPoint: Point = currentActiveCell.parent.localToGlobal(new Point(currentActiveCell.x, currentActiveCell.y));
			TweenLite.to(questionMovie, 0.7, { alpha: 0, x: sPoint.x + currentActiveCell.width / 2, y: sPoint.y + currentActiveCell.height / 2, width: 1, height: 1, onComplete: tweenCompleteHandler } );
			function tweenCompleteHandler():void {
				questionMovie.parent.removeChild(questionMovie);
			}
			
			currentActiveCell = null
		}
		
		private function init():void {
			loadXMLData();
			
			initBackground();
			initTitle();
			initHidden();
			initTable();
			initFullscreen();
			initLightOff();
			initShowAll();
		}
		
		private function initShowAll():void {
			showAllMovie = new ShowAllButton();
			showAllMovie.buttonMode = true;
			this.addChild(showAllMovie);
			showAllMovie.addEventListener(MouseEvent.CLICK, showAllClickHandler, false, 0, true);
		}
		
		private function showAllClickHandler(event: MouseEvent): void {
			tableMovie.visible = !tableMovie.visible;
		}
		
		private function initFullscreen():void {
			fullscreenMovie = new FullscreenButton();
			fullscreenMovie.buttonMode = true;
			this.addChild(fullscreenMovie);			
			fullscreenMovie.addEventListener(MouseEvent.CLICK, fullscreenClickHandler, false, 0, true);
		}
		
		private function initLightOff():void {
			lightOffMovie = new LightOffButton();
			lightOffMovie.buttonMode = true;
			this.addChild(lightOffMovie);			
			lightOffMovie.addEventListener(MouseEvent.CLICK, lightOffClickHandler, false, 0, true);
		}
		
		private function lightOffClickHandler(e:MouseEvent):void {
			bgMovie.visible = !bgMovie.visible;
			titleMovie.visible = bgMovie.visible;
			
			showAllMovie.alpha = (bgMovie.visible) ? 1 : 0.4;
			fullscreenMovie.alpha = showAllMovie.alpha;
			lightOffMovie.alpha = showAllMovie.alpha;
		}
		
		private function fullscreenClickHandler(event: MouseEvent): void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			else {
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		private function initBackground():void {
			bgMovie = new Sprite();
			this.addChild(bgMovie);
		}
		
		private function initHidden():void {
			hiddenMovie = new Sprite();
			this.addChild(hiddenMovie);
			hiddenMovie.filters = [new GlowFilter(0x000000)];
		}
		
		private function initTable():void {
			tableMovie = new QuestionTable();
			this.addChild(tableMovie);
			tableMovie.addEventListener(Event.COMPLETE, tableLoadCompleteHandler, false, 0, true);
		}
		
		private function tableLoadCompleteHandler(event: Event): void {
			hiddenMovie.visible = true;
			titleMovie.visible = true;
			reArrangeAll();
		}
		
		private function reArrangeAll():void {			
			var w: Number = stage.stageWidth;			
			var h: Number = stage.stageHeight;
			
			/*if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				w = stage.fullScreenWidth;
				h = stage.fullScreenHeight;
			}*/
			
			titleMovie.x = (w - titleMovie.width) / 2;
			hiddenMovie.x = (w - hiddenMovie.width) / 2;
			tableMovie.x = hiddenMovie.x;
			
			titleMovie.y = 10;
			hiddenMovie.y = titleMovie.y + titleMovie.height + 20;
			tableMovie.y = hiddenMovie.y;
			
			fullscreenMovie.x = w - fullscreenMovie.width;
			fullscreenMovie.y = 0;
			
			lightOffMovie.x = fullscreenMovie.x - lightOffMovie.width - 5;
			lightOffMovie.y = 0;
			
			//showAllMovie.x = w - showAllMovie.width;
			//showAllMovie.y = h - showAllMovie.y
		}
		
		private function initTitle():void {
			titleMovie = new Title();
			this.addChild(titleMovie);
		}
		
		private function loadXMLData():void {
			var url: String = this.loaderInfo.parameters["xmlUrl"];
			if (!url || url == "" || url == "undefined")	url = "xml/data.xml";
			var urlLoader: URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, urlLoaderCompleteHandler, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			urlLoader.load(new URLRequest(url));
		}
		
		private function urlLoaderCompleteHandler(event: Event): void {
			xml = new XML(event.currentTarget.data);
			processXML(xml);
		}
		
		private function processBackground():void {
			var loader: Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgLoaderCompleteHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			loader.load(new URLRequest(xml.config.background_image_url.toString()));
		}
		
		private function bgLoaderCompleteHandler(event: Event): void {
			bgMovie.addChild(event.currentTarget.loader.content);
			bgMovie.width = stage.stageWidth;
			bgMovie.height = stage.stageHeight;
		}
		
		private function processTitle():void {
			titleMovie.text = xml.title.toString();
		}
		
		private function processXML(xml:XML):void {
			if (!xml)	return;
			
			processContentBackground();
			processTitle();
			processBackground();
			loadHidden();
			
			var url: String = xml.config.sound_correct_url.toString();
			if (url)	Constant.soundCorrecUrl = url;
			url = xml.config.sound_wrong_url.toString();
			if (url)	Constant.soundWrongUrl = url;
			url = xml.config.image_correct_url.toString();
			if (url)	Constant.imageCorrectUrl = url;
			url = xml.config.image_wrong_url.toString();
			if (url)	Constant.imageWrongUrl = url;
			
			reArrangeAll();
		}
		
		private function processContentBackground():void {
			var loader: Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, contentBgLoaderCompleteHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			loader.load(new URLRequest(xml.config.content_background_image_url.toString()));
		}
		
		private function contentBgLoaderCompleteHandler(event: Event): void {
			contentBgMovie = event.currentTarget.loader.content;
			
			reArrangeAll();
		}
		
		private function loadHidden():void {
			var loader: Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			loader.load(new URLRequest(xml.hidden_image_url.toString()));
		}
		
		private function loaderCompleteHandler(event: Event): void {
			var content: DisplayObject = event.currentTarget.loader.content;
			var targetW: Number = stage.stageWidth - 40;
			var targetH: Number = stage.stageHeight - (titleMovie.y + titleMovie.height + 40);
			if (content.width / content.height > targetW / targetH)	content.scaleX = content.scaleY = targetW / content.width;
			else	content.scaleX = content.scaleY = targetH / content.height;
			
			hiddenMovie.visible = false;
			hiddenMovie.addChild(event.currentTarget.loader.content);			
			
			processTable(hiddenMovie.width, hiddenMovie.height);
			
			reArrangeAll();
		}
		
		private function processTable(w:Number, h:Number):void {
			while (tableMovie.numChildren)	tableMovie.removeChildAt(0);
			tableMovie.graphics.beginFill(0, 0);
			tableMovie.graphics.drawRect(0, 0, w, h);
			tableMovie.graphics.endFill();
			
			tableMovie.setData(xml.list_cell, int(xml.config.column.toString()), int(xml.config.row.toString()));
		}
		
		private function ioErrorHandler(event: IOErrorEvent): void {
			trace(event.text);
		}
		
	}

}