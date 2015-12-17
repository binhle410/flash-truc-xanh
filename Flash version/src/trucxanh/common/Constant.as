package trucxanh.common {
	/**
	 * ...
	 * @author Trung đẹp trai
	 */
	public class Constant {

		//	Events
		public static const EVENT_CORRECT: String = "event_correct";
		public static const EVENT_WRONG: String = "event_wrong";
		public static const EVENT_CLOSE: String = "event_close";
		public static const EVENT_HINT: String = "event_hint";
		public static const EVENT_CELL_CLICK: String = "event_cell_click";
		
		public static const TYPE_FREE: String = "TYPE_FREE";
		public static const TYPE_SELECT_ONE: String = "TYPE_SELECT_ONE";
		public static const TYPE_SELECT_MANY: String = "TYPE_SELECT_MANY";
		public static const TYPE_MATCHING: String = "TYPE_MATCHING";
		public static const TYPE_INPUT: String = "TYPE_INPUT";
		public static const TYPE_IMAGE: String = "TYPE_IMAGE";
		
		public static var MOVIE_WIDTH: int = 1024;
		public static var MOVIE_HEIGHT: int = 768;
		
		public static var soundCorrecUrl: String = "sound/correct.mp3";
		public static var soundWrongUrl: String = "sound/wrong.mp3";
		public static var imageCorrectUrl: String = "images/correct.png";
		public static var imageWrongUrl: String = "images/wrong.png";
		
		public function Constant() {
			
		}
		
	}

}