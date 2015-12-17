package trucxanh.component {
	import com.greensock.TweenLite;
	import fl.video.FLVPlayback;
	import fl.video.VideoAlign;
	import fl.video.VideoScaleMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import trucxanh.common.Constant;
	import trucxanh.common.helpers.SoundManager;
	import trucxanh.component.quiztype.ItemImage;
	import trucxanh.component.quiztype.ItemInput;
	import trucxanh.component.quiztype.ItemMatching;
	import trucxanh.component.quiztype.ItemOption;
	import trucxanh.component.quiztype.ItemSelect;
	/**
	 * ...
	 * @author Trung đẹp trai
	 */
	public class QuestionContent extends Sprite{
		public var titleText: TextField;
		public var contentText: TextField;
		public var answerText: TextField;
		public var backgroundMovie: Sprite;
		public var correctMovie: Sprite;
		public var wrongMovie: Sprite;
		public var hintMovie: Sprite;
		public var ignoreMovie: Sprite;
		
		private var listPlayer: Array;
		private var listPlayerAnswer: Array;
		private var player: FLVPlayback;
		private var imageCorrectLoader: Loader;
		private var imageWrongLoader: Loader;
		
		private var dataXML: XML = null;
		
		private var posY: int = 0;
		private var soundCorrecUrl: String;
		private var soundWrongUrl: String;
		private var imageCorrecUrl: String;
		private var imageWrongUrl: String;
		
		public function QuestionContent() {
			titleText.filters = [];
			contentText.filters = [];
			answerText.filters = [];
			
			titleText.autoSize = TextFieldAutoSize.LEFT;
			contentText.autoSize = TextFieldAutoSize.LEFT;
			answerText.autoSize = TextFieldAutoSize.LEFT;
			
			correctMovie.buttonMode = true;
			wrongMovie.buttonMode = true;
			hintMovie.buttonMode = true;
			ignoreMovie.buttonMode = true;
			
			correctMovie.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			wrongMovie.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			hintMovie.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			ignoreMovie.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			
			addEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
		}
		
		private function removeFromStageHandler(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removeFromStageHandler);
			
			if (stage.hasEventListener(MouseEvent.MOUSE_UP))
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseClickHandler);
				
			parent.removeChild(imageCorrectLoader);
			parent.removeChild(imageWrongLoader);
			
			for (var i: int = 0, size = listPlayer.length; i < size; i++) {
				listPlayer[i].stop();
				removeChild(listPlayer[i]);
			}
			listPlayer = [];
			
			for (i = 0, size = listPlayerAnswer.length; i < size; i++) {
				listPlayerAnswer[i].stop();
				removeChild(listPlayerAnswer[i]);
			}
			listPlayerAnswer = [];
		}
		
		private function clickHandler(event: MouseEvent): void {
			var i: int = 0;
			var size: int = 0;
			var type: String = dataXML.quiz_type;
			var isCorrect: Boolean;
			switch (event.currentTarget) {
				case correctMovie:
					/*switch (type.toUpperCase()) {
						case Constant.TYPE_FREE:
							SoundManager.playUrl(soundCorrecUrl);
							showResult(true);
							break;
					}*/
					showResult(true);
					setTimeout(this.dispatchEvent,500,new Event(Constant.EVENT_CORRECT));
				break;
				case wrongMovie:
					/*switch (type.toUpperCase()) {
						case Constant.TYPE_FREE:
							SoundManager.playUrl(soundWrongUrl);
							showResult(false);
							break;
					}*/
					showResult(false);
					setTimeout(this.dispatchEvent,500,new Event(Constant.EVENT_WRONG));
				break;
				case hintMovie:
					//trace( "Dap an => type : " + type);
					switch (type.toUpperCase()) {
						case Constant.TYPE_SELECT_ONE:
							var itemOption: ItemOption = optionList[dataXML.question_answer];
							itemOption.SetHighlight(true);
							isCorrect = itemOption.GetActive();
							break;
						case Constant.TYPE_SELECT_MANY:
							answerList = dataXML.question_answer.toString().split("+");
							isCorrect = true;
							var itemSelect: ItemSelect;
							for (i = 0, size = answerList.length; i < size; i++) {
								answerList[i] = int(answerList[i]);
								itemSelect = optionList[answerList[i]];
								itemSelect.SetHighlight(true);
								if (!itemSelect.GetActive()) {
									isCorrect = false;
								}
							}
							for (i = 0, size = optionList.length; i < size && isCorrect; i++) {
								itemSelect = optionList[i];
								if (itemSelect.GetActive()) {
									//trace( "answerList.indexOf("+i+") : " + answerList.indexOf(i) + " -- answerList : " + answerList);
									if (answerList.indexOf(i) < 0) {
										isCorrect = false;
									}
								}
							}
							break;
						case Constant.TYPE_MATCHING:
							for (i = 0, size = option3List.length; i < size; i++) {
								var item: ItemMatching = option3List[i];
								item.alpha = 0;
								item.visible = true;
								TweenLite.to(item, 0.3, {alpha: 1});
							}
							isCorrect = true;
							for (i = 0, size = matchingIndexList.length; i < size && isCorrect; i++) {
								if (matchingIndexList[i] != answerList[i]) {
									isCorrect = false;
								}
							}
							//trace( "matchingIndexList : " + matchingIndexList );
							//trace( "answerList : " + answerList );
							break;
						case Constant.TYPE_INPUT:
							TweenLite.to(answerText, 0.5, {alpha: 1});
							this.dispatchEvent(new Event(Constant.EVENT_HINT));
							isCorrect = itemInput.getAnswer().toLowerCase() == answerList.join("+").toLowerCase();
							break;
						case Constant.TYPE_IMAGE:
							isCorrect = itemImage.ShowAnswer(true);
							break;
						default:	// free type
							TweenLite.to(answerText, 0.5, {alpha: 1});
							this.dispatchEvent(new Event(Constant.EVENT_HINT));
							break;
					}
					/*if (type != Constant.TYPE_FREE) {
						showResult(isCorrect);
					}*/
					for (var i: int = 0, size = listPlayerAnswer.length; i < size; i++) {
						listPlayerAnswer[i].visible = true;
					}
				break;
				case ignoreMovie:
					this.dispatchEvent(new Event(Constant.EVENT_CLOSE));
				break;
			}
		}
		
		private function showResult(isCorrect: Boolean): void {
			var loader: Loader = null;
			if (isCorrect) {
				SoundManager.playUrl(soundCorrecUrl);
				loader = imageCorrectLoader;
			} else {
				SoundManager.playUrl(soundWrongUrl);
				loader = imageWrongLoader;
			}
			if (loader) {
				loader.visible = true;
				loader.alpha = 0;
				TweenLite.to(loader, 0.5, {alpha: 1});
			}
		}
		
		private function reArrangeButtons(): void {
			ignoreMovie.x = backgroundMovie.x + backgroundMovie.width - ignoreMovie.width;
			ignoreMovie.y = backgroundMovie.y + backgroundMovie.height - ignoreMovie.height;
			
			hintMovie.x = ignoreMovie.x - hintMovie.width;
			hintMovie.y = ignoreMovie.y;
			
			wrongMovie.x = hintMovie.x - wrongMovie.width;
			wrongMovie.y = hintMovie.y;
			
			correctMovie.x = wrongMovie.x - correctMovie.width;
			correctMovie.y = wrongMovie.y;
		}

		public function setDataXML(xml: XML, w: Number, h: Number, contentBgMovie: DisplayObject) {
			dataXML = xml;
			
			var url: String = xml.sound_correct_url.toString();
			
			if (url)	soundCorrecUrl = url;
			else	soundCorrecUrl = Constant.soundCorrecUrl;
			trace( "soundCorrecUrl : " + soundCorrecUrl );
			
			url = xml.sound_wrong_url.toString();
			if (url)	soundWrongUrl = url;
			else	soundWrongUrl = Constant.soundWrongUrl;
			trace( "soundWrongUrl : " + soundWrongUrl );
			
			url = xml.image_correct_url.toString();
			if (url)	imageCorrectUrl = url;
			else	imageCorrectUrl = Constant.imageCorrectUrl;
			
			url = xml.image_wrong_url.toString();
			if (url)	imageWrongUrl = url;
			else	imageWrongUrl = Constant.imageWrongUrl;
			
			contentBgMovie.width = w;
			contentBgMovie.height = h;
			while (backgroundMovie.numChildren)	backgroundMovie.removeChildAt(0);
			backgroundMovie.addChild(contentBgMovie);
			
			listPlayer = [];
			var xPos: int = 0;
			var yPos: int = 40;
			var videoURL: String;
			var skinURL: String;
			var playerW: int;
			var playerH: int;
			var videoXML: XML;
			for each (videoXML in xml.question_video.video_url) {
				videoURL = videoXML.toString();
				if (videoURL) {
					skinURL = videoXML.@skin.toString();
					if (!skinURL)	skinURL = "playerSkin.swf";
					playerW = Math.max(int(videoXML.@width), 30);
					playerH = Math.max(int(videoXML.@height), 20);
					player = new FLVPlayback();
					addChild(player);
					player.autoPlay = false;
					player.skin = skinURL;
					player.skinAutoHide = true;
					player.source = videoURL;
					player.scaleMode = VideoScaleMode.EXACT_FIT;
					player.opaqueBackground = 0x000000;
					player.width = playerW;
					player.height = playerH;
					player.x = xPos;
					player.y = yPos;
					player.fullScreenTakeOver = false;
					listPlayer.push(player);
					xPos += playerW;
					if (xPos + playerW >= w) {
						xPos = 0;
						yPos += playerH;
					}
				}
			}
			
			stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseClickHandler, false, 0, true);
			
			initBaseQuiz(xml, w, h);
			
			var type: String = xml.quiz_type;
			switch (type.toUpperCase()) {
				case Constant.TYPE_SELECT_ONE:
					initOptionQuiz(xml, w, h);
					break;
				case Constant.TYPE_SELECT_MANY:
					initSelectQuiz(xml, w, h);
					break;
				case Constant.TYPE_MATCHING:
					initMatchingQuiz(xml, w, h);
					break;
				case Constant.TYPE_INPUT:
					initInputQuiz(xml, w, h);
					break;
				case Constant.TYPE_IMAGE:
					initImageQuiz(xml, w, h);
					break;
				default:	// free type
					initFreeQuiz(xml, w, h);
					break;
			}
			
			xPos = 0;
			yPos = posY;
			listPlayerAnswer = [];
			for each (videoXML in xml.answer_video.video_url) {
				videoURL = videoXML.toString();
				if (videoURL) {
					skinURL = videoXML.@skin.toString();
					if (!skinURL)	skinURL = "playerSkin.swf";
					playerW = Math.max(int(videoXML.@width), 30);
					playerH = Math.max(int(videoXML.@height), 20);
					player = new FLVPlayback();
					addChild(player);
					player.autoPlay = false;
					player.skin = skinURL;
					player.skinAutoHide = true;
					player.source = videoURL;
					player.scaleMode = VideoScaleMode.EXACT_FIT;
					player.opaqueBackground = 0x000000;
					player.width = playerW;
					player.height = playerH;
					player.x = xPos;
					player.y = yPos;
					player.fullScreenTakeOver = false;
					listPlayerAnswer.push(player);
					xPos += playerW;
					if (xPos + playerW >= w) {
						xPos = 0;
						yPos += playerH;
					}
					player.visible = false;
				}
			}
			
			imageCorrectLoader = makeLoader(imageCorrectUrl);
			imageWrongLoader = makeLoader(imageWrongUrl);
			
			reArrangeButtons();
		}
		
		private function makeLoader(url: String): Loader {
			var loader: Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoadedHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler, false, 0, true);
			loader.load(new URLRequest(url));
			return loader;
		}
		
		private function imageLoadedHandler(e:Event):void {
			var loader: Loader = e.currentTarget.loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoadedHandler);
			loader.x = (Constant.MOVIE_WIDTH - loader.width) / 2;
			loader.y = (Constant.MOVIE_HEIGHT - loader.height) / 2;
			parent.addChild(loader);
			loader.visible = false;
			loader.addEventListener(MouseEvent.CLICK, loaderClickHandler, false, 0, true);
		}
		
		private function loaderClickHandler(e:MouseEvent):void {
			var loader: Loader = e.currentTarget as Loader;
			TweenLite.to(loader, 0.5, { alpha: 0, onComplete: function():void { loader.visible = false; }} );
		}
		
		private function errorHandler(e:IOErrorEvent):void {
			trace( "QuestionContent.errorHandler > e : " + e );
		}
		
		private var lastClick: uint = 0;
		private var playerOldX: int = 0;
		private var playerOldY: int = 0;
		private function stageMouseClickHandler(e:MouseEvent):void {
			var now: uint = getTimer();
			var delta: int = now - lastClick;
			
			var player: FLVPlayback = null;
			var playerW: int = 0;
			var playerH: int = 0;
			var videoXML: XML;
			var isAnswerPlayer: Boolean = false;
			
			for (var i: int = 0, size = listPlayer.length; i < size; i++) {
				if (!listPlayer[i].visible)	continue;
				playerW = listPlayer[i].width;
				playerH = listPlayer[i].height;
				var rect: Rectangle = new Rectangle(listPlayer[i].x, listPlayer[i].y, playerW, playerH);
				if (rect.containsPoint(new Point(mouseX, mouseY))) {
					player = listPlayer[i];
					videoXML = dataXML.question_video.video_url[i];
					break;
				}
			}
			
			for (i = 0, size = listPlayerAnswer.length; i < size && !player; i++) {
				if (!listPlayerAnswer[i].visible)	continue;
				playerW = listPlayerAnswer[i].width;
				playerH = listPlayerAnswer[i].height;
				var rect: Rectangle = new Rectangle(listPlayerAnswer[i].x, listPlayerAnswer[i].y, playerW, playerH);
				if (rect.containsPoint(new Point(mouseX, mouseY))) {
					player = listPlayerAnswer[i];
					videoXML = dataXML.answer_video.video_url[i];
					isAnswerPlayer = true;
					break;
				}
			}
			
			if (player && delta < 1000) {
				playerW = Math.max(int(videoXML.@width), 30);
				playerH = Math.max(int(videoXML.@height), 20);
				lastClick = 0;
				if (player.width <= playerW) {		// ZOOM IN
					playerOldX = player.x;
					playerOldY = player.y;
					var p: Point = globalToLocal(new Point(0, 0));
					TweenLite.to(player, 0.5, { width: Constant.MOVIE_WIDTH
											,	height: Constant.MOVIE_HEIGHT
											,	x: p.x, y: p.y } );
					for (i = 0, size = listPlayer.length; i < size; i++) {
						if (listPlayer[i] != player)	listPlayer[i].visible = false;
					}
					for (i = 0, size = listPlayerAnswer.length; i < size; i++) {
						if (listPlayerAnswer[i] != player)	listPlayerAnswer[i].visible = false;
					}
				}
				else {
					TweenLite.to(player, 0.5, { width: playerW
											,	height: playerH
											,	x: playerOldX//(backgroundMovie.width - playerW) / 2
											,	y: playerOldY
											,	onComplete: function():void {
													for (var i: int = 0, size = listPlayer.length; i < size; i++) { listPlayer[i].visible = true; }
													for (i = 0, size = listPlayerAnswer.length; i < size; i++) { listPlayerAnswer[i].visible = isAnswerPlayer; }
												}});
				}
			} else {
				lastClick = now;
			}
		}
		
		/////////......................
		private var optionList: Array;
		private var option2List: Array;
		private var option3List: Array;
		private var answerList: Array;
		private var matchingIndexList: Array;
		private var oldPoint: Point;
		private var itemImage: ItemImage;
		private var itemInput: ItemInput;
		
		private function initInputQuiz(xml: XML, w: Number, h: Number): void {
			itemInput = new ItemInput(xml, w, h);
			itemInput.x = 0;
			itemInput.y = posY + 30;
			addChild(itemInput);
			
			posY += itemInput.height + 30;
			
			var str: String = dataXML.question_input;
			answerList = String(dataXML.question_answer).split("+");
			for (var i: int = 0, size = answerList.length; i < size; i++) {
				str = str.replace("<input>", '<font color="#FF0000">' + answerList[i] + '</font>');
			}
			answerText.textColor = 0xFFFF00;
			answerText.htmlText = str;
			answerText.visible = true;
			answerText.autoSize = "left";
			answerText.width = w;
			answerText.alpha = 0;
			answerText.y = posY;
			
			posY += answerText.height;
		}
		
		private function initImageQuiz(xml: XML, w: Number, h: Number): void {
			itemImage = new ItemImage(xml, w, h);
			itemImage.x = 0;
			itemImage.y = posY + 20;
			addChild(itemImage);
		}
		
		private function initMatchingQuiz(xml: XML, w: Number, h: Number): void {
			posY += 40;
			var posY2: int = posY;
			optionList = [];
			matchingIndexList = [];
			var optionXML: XML;
			var option: ItemMatching;
			var option2: ItemMatching;
			for each (optionXML in xml.question_options.option) {
				option = new ItemMatching(uint(xml.question_options.@color));
				option.text = optionXML.toString();
				option.x = 50;
				option.y = posY;
				posY += option.height*2.2;
				addChild(option);
				optionList.push(option);
				
				matchingIndexList.push(-1);
			}
			
			option2List = [];
			for each (optionXML in xml.question_matching.option) {
				option = new ItemMatching(uint(xml.question_matching.@color));
				option.text = optionXML.toString();
				option.x = w/2 + 30;
				option.y = posY2;
				posY2 += option.height*2.2;
				addChild(option);
				option2List.push(option);
				option.addEventListener(MouseEvent.MOUSE_DOWN, matchingDownHandler, false, 0, true);
			}
			
			answerList = [];
			var tempArr: Array = xml.question_answer.toString().split("+");
			for (var i: int = 0, size = tempArr.length; i < size; i++) {
				var temp2Arr: Array = String(tempArr[i]).split(":");
				answerList[temp2Arr[0]] = temp2Arr[1];
			}
			option3List = [];
			for (i = 0, size = answerList.length; i < size; i++) {
				option = optionList[i];
				
				option2 = new ItemMatching(0xFFFF00);
				option2.text = dataXML.question_matching.option[answerList[i]].toString();
				option2.x = option.x + option.width;
				option2.y = option.y - option.height / 2;
				option2.visible = false;
				addChild(option2);
				option3List.push(option2);
			}
		}
		
		private function matchingDownHandler(e:MouseEvent):void {
			var option: ItemMatching = e.currentTarget as  ItemMatching;
			option.parent.setChildIndex(option, option.parent.numChildren-1);
			option.startDrag();
			option.addEventListener(MouseEvent.MOUSE_UP, matchingUpHandler, false, 0, true);
			oldPoint = new Point(option.x, option.y);
		}
		
		private function matchingUpHandler(e:MouseEvent):void {
			var option: ItemMatching = e.currentTarget as  ItemMatching;
			var item: ItemMatching;
			var i: int;
			var size: int;
			option.stopDrag();
			option.removeEventListener(MouseEvent.MOUSE_UP, matchingUpHandler);
			var isMatching: int = -1;
			for (i = 0, size = optionList.length; i < size; i++) {
				item = optionList[i];
				if (item.hitTestObject(option)) {
					isMatching = i;
					break;
				}
			}
			if (isMatching > -1) {
				item = optionList[isMatching];
				TweenLite.to(option, 0.3, {x: item.x + item.width, y: item.y + item.height / 2});
				var index: int = option2List.indexOf(option);
				for (i = 0, size = matchingIndexList.length; i < size; i++) {
					if (i != isMatching && matchingIndexList[i] == index) {
						matchingIndexList[i] = matchingIndexList[isMatching];
						break;
					}
				}
				if (matchingIndexList[isMatching] > -1) {
					item = option2List[matchingIndexList[isMatching]];
					TweenLite.to(item, 0.3, { x: oldPoint.x, y: oldPoint.y } );
					i = matchingIndexList.indexOf(index);
				}
				matchingIndexList[isMatching] = index;
			} else {
				TweenLite.to(option, 0.3, {x: oldPoint.x, y: oldPoint.y});
			}
		}
		
		private function initSelectQuiz(xml: XML, w: Number, h: Number): void {
			posY += 40;
			optionList = [];
			for each (var optionXML: XML in xml.question_options.option) {
				var option: ItemSelect = new ItemSelect();
				option.contentText.htmlText = optionXML.toString();
				option.x = 50;
				option.y = posY;
				posY += option.height + 15;
				addChild(option);
				optionList.push(option);
				option.addEventListener(MouseEvent.CLICK, selectClickHandler, false, 0, true);
			}
		}
		
		private function selectClickHandler(e:MouseEvent):void {
			var option: ItemSelect = e.currentTarget as ItemSelect;
			option.SetActive(!option.GetActive());
		}
		
		private function initOptionQuiz(xml: XML, w: Number, h: Number): void {
			posY += 40;
			optionList = [];
			for each (var optionXML: XML in xml.question_options.option) {
				var option: ItemOption = new ItemOption();
				option.contentText.htmlText = optionXML.toString();
				option.x = 50;
				option.y = posY;
				posY += option.height + 15;
				addChild(option);
				optionList.push(option);
				option.addEventListener(MouseEvent.CLICK, optionClickHandler, false, 0, true);
			}
		}
		
		private function optionClickHandler(e:MouseEvent):void {
			for (var i: int = 0, size = optionList.length; i < size; i++) {
				var option: ItemOption = optionList[i];
				option.SetActive(option == e.currentTarget);
			}
		}
		
		private function initFreeQuiz(xml: XML, w: Number, h: Number): void {
			answerText.visible = true;
			answerText.width = w;
			answerText.htmlText = xml.question_answer;
			answerText.alpha = 0;
			answerText.y = posY;
			
			posY += answerText.height;
		}
		
		private function initBaseQuiz(xml: XML, w: Number, h: Number): void {
			titleText.htmlText = "Câu hỏi tại ô " + xml.label;
			
			contentText.width = w;
			contentText.htmlText = xml.question_content;
			
			titleText.y = 0;
			if (player)	posY = player.y + player.height + 10;
			else	posY = titleText.y + titleText.height + 20;
			contentText.y = posY;
			
			posY = contentText.y + contentText.height;
			
			answerText.visible = false;
		}
	}

}