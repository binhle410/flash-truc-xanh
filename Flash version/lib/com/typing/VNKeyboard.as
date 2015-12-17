/*********************************************************************/
/*** Free / Open Source Script written by Dang Tran Hoang 08/12/2007 */
/*** htbn_hoang@yahoo.com                                            */
/*** GNU/GPL License                                                 */
/*** Based on PPTrung's code				                         */
/*********************************************************************/

/*
	Usage:
		You can type Vietnamese in all textfield in target after the code below
			var obj:VNKeyboard = new VNKeyboard(target);
		
		To dispose this object, just call
			obj.dispose();
 */

package com.typing {
	import flash.display.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	public class VNKeyboard {
		private var NEWV: Number = 1;
		private var ON_OFF: Number;
		private var SPELL:Number=1;
		private var MOD:int = 0;
		private var ESC:Boolean;
		private var code2:Number;
		private var li:Number;
		private var ENGLISH:Boolean = false;
		private var CODE:Number;
		private var changed:Boolean = false;
		
		private var VOW:Array = new Array(
				97,225,224,7843,227,7841,65,193,192,7842,195,7840,//a
				226,7845,7847,7849,7851,7853,194,7844,7846,7848,7850,7852,//a^
				259,7855,7857,7859,7861,7863,258,7854,7856,7858,7860,7862,//a(
				111,243,242,7887,245,7885,79,211,210,7886,213,7884,//o
				244,7889,7891,7893,7895,7897,212,7888,7890,7892,7894,7896,//o^
				417,7899,7901,7903,7905,7907,416,7898,7900,7902,7904,7906,//o+
				101,233,232,7867,7869,7865,69,201,200,7866,7868,7864,//e
				234,7871,7873,7875,7877,7879,202,7870,7872,7874,7876,7878,//e^
				-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
				117,250,249,7911,361,7909,85,218,217,7910,360,7908,//u
				-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
				432,7913,7915,7917,7919,7921,431,7912,7914,7916,7918,7920,//u+
				105,237,236,7881,297,7883,73,205,204,7880,296,7882,//i
				-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
				-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
				121,253,7923,7927,7929,7925,89,221,7922,7926,7928,7924,//y
				-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
				-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
				100,273,273,68,272,272//dd
			)	
		
		private var charCode: int;
		private var target: Sprite;
		
		private var _textFieldsMap: Dictionary = null;
		
		public function VNKeyboard(target:Sprite) {
			this.target = target;
			
			target.addEventListener(KeyboardEvent.KEY_DOWN, onKeydownHandler);
			target.addEventListener(Event.CHANGE, onChangeHandler);
		}
		
		public function dispose():void {
			target.removeEventListener(KeyboardEvent.KEY_DOWN, onKeydownHandler);
			target.removeEventListener(Event.CHANGE, onChangeHandler);
		}
		
		private function onKeydownHandler(evt:KeyboardEvent):void {
			if (_textFieldsMap && _textFieldsMap[evt.target]) {
				charCode = evt.charCode;
				kdIni(evt.keyCode);
			}
		}
		
		private function kdIni(k:int):void {
			if (k == 32 || k == 13 || k == 8) {
				ENGLISH = false;
			}
			
			if (k == 118) { // F7
				NEWV = 1 - NEWV;
			} else if (k == 119) { // F8
				ON_OFF = 1;
				MOD++;
				MOD %= 4;
			} else if (k == 120) { // F9
				SPELL = 1 - SPELL;
			} else if (k == 123) { // F12
				ON_OFF = 1 - ON_OFF;
			}
		}
		
		private function onChangeHandler(evt:Event):void {
			if (_textFieldsMap && _textFieldsMap[evt.target]) {
				kpIni(charCode, TextField(evt.target));
			}
		}

		private function kpIni(charCode:int, textField:TextField):void {
			if (ON_OFF == 0 || ENGLISH) {
				return;
			}
			
			var chr:String = String.fromCharCode(charCode);
			var chr1:String = chr.toUpperCase();
			if (chr == '\\' && (MOD == 3)) {
				ESC = true;
				return;
			}
			
			if (string_test("SFRXJDAEOWZ1234567890/\'?~.`-^#(+*", chr1)) {
				viewViet(textField, chr);
			} else if(string_test('CINT', chr1)) {
				correcturAccent(textField, chr);
			}
			
			ESC = false;
		}
	
		private function findCorrecturWord(wrd:String):String {
			var idx:int = vietIdx(code1);
			var keyx:int = idx % 6;
			
			var wrdA:Array = wrd.split('');
			wrdA.push(keyx);
			
			var lenx:int = wrd.length;
			if (lenx < 3) {
				return null;
			}
			
			var code1:int = wrdA[lenx-3].charCodeAt(0);
			var chr2:String = wrdA[lenx-2];
			
			if (idx > 126 || keyx < 1) {
				return null;
			}
			
			//aA a+ a^ A+ A^
			if (!string_test('aA' + String.fromCharCode(0x00E2,0x00C2,0x0103,0x0102) + 'eEiIyY', chr2)) {
				return null;
			}
			
			wrdA[lenx-3] = String.fromCharCode(VOW[idx-keyx]);
			wrd = wrdA.join('');
			var typ:int=MOD;
			MOD = 1;
			wrd = toViet(wrd, String(keyx));
			MOD = typ;
			return wrd;
		}
		
		private function correcturAccent(textField:TextField, char:String):void {
			var arr:Array = getSelectWord(textField);
			var i:int = arr[0];
			var wrd:String = arr[1];
			
			if (!(wrd = findCorrecturWord(wrd + char))) {
				return;
			}
			
			if (changed) {
				replaceWord(textField, wrd, i)
			}
		}
		
		private function string_test(s:String, c:String, case_sentitive:Boolean = true):Boolean { 
			var s1:String = case_sentitive ? s : s.toLowerCase();
			var c1:String = case_sentitive ? c : c.toLowerCase();		
			
			return (s1.indexOf(c1)>=0);
		}
		
		private function viewViet(textField:TextField, char:String):void {
			var arr:Array = getSelectWord(textField);
			var i:int = arr[0];
			var wrd:String = arr[1];
			
			if (string_test('w', char) && (!wrd || !SPELL || !notviet(wrd)) && string_test('uo', wrd)) { //apply u+ feature
				wrd += char == 'w' ? 'u' : 'U';   
			}
			
			var wrd1:String = toViet(wrd, char);
			if (wrd == '') {
				return;
			}
			
			if (changed) {
				replaceWord(textField, wrd1, i);
			}
			
			ESC = false;
		}

		private function getSelectWord(textField:TextField):Array {
			var caret:Array = new Array(); 
			caret[1] = caret[0] = textField.caretIndex - 1;// bypass the last input char
			
			var caret2:Array = caret;
			var wrd:String = "";
			var i:int = 0;
			var chrx:String;
			var len:int;
			var obj_curword:Array;
			
			while (i<9999) {
	 			if (caret2[0] > 0) {
					caret2[0]--; 
				} else {
					break;
				}
				
	 			obj_curword = caret2;
	 			len = obj_curword[1] - obj_curword[0];

				if (len == wrd.length) {
					break;
				}
				
				wrd = textField.text.slice(obj_curword[0], obj_curword[1]);
				chrx = wrd.substring(0, 1);
				if (notWord(chrx)) {
					//if (chrx.charCodeAt(0) == 13) {
					//	wrd = wrd.substr(1);
					//} else {
					wrd = wrd.substr(1);
					//}
					
					break;
				}
				
				i++;
			}
			
			var arr:Array=new Array()
			arr[0] = i;
			arr[1] = wrd;
			
			return arr;
		}
		
		private function vietIdx(code:int):int {
			for(var i:int = 0; i < VOW.length; i++) {
				if (code == VOW[i]) {
					return i;
				}
			}
			return -1;
		}
		
		private function toViet(str1:String, k:String):String {
			if (ENGLISH || !str1) {
				return str1;
			}
			
			if (SPELL == 1 && notviet(str1)) {
				return str1;
			}
			
			var c2:String = '' + k;
			var sx:String = '';
			
			//except
			if (MOD != 1 && MOD != 0 && (Number(k) == 1 || Number(k) == 2 || Number(k) == 6)) {
				return str1;
			}
			
			sx = UNI(str1, c2)
	
			if (string_test('zZ0', c2)) {
				sx = UNIZZ(str1,c2);
			}
			
			if (CODE) {
				changed = true;
			}
			
			if (sx != '') {
				str1 = sx;
			}
			
			return str1;
		}
	
		private function replaceWord(textField:TextField, wrd:String, index:int):void {
			var pos:int = textField.caretIndex;
			textField.setSelection(pos - index - 1, pos);
			textField.replaceSelectedText(wrd);
		}
	
		private function notviet(wrd:String):Boolean {
			/*
			wrd = wrd.toLowerCase();
			//ngoai. le^.
			var yes:String = "giac|giam|gian|giao|giap|giat|giay|giua|giuo|ngoam|ngoao|ngoeo|ngup|quam";
			var reg:RegExp = new RegExp(yes);
			var res:Boolean = reg.test(wrd);
			if (res) {
				return false;
			}
			
			var no:String = "f|j|w|z|aa|ab|ad|ae|ag|ah|ak|al|aq|ar|as|av|ax|bb|bc|bd|bg|bh|bk|bl|bm|bn|bp|bq|br|bs|bt|bv|bx|by|cb|cc|cd|ce|cg|ci|ck|cl|cm|cn|cp|cq|cr|cs|ct|cv|cx|cy|db|dc|dg|dh|dk|dl|dm|dn|dp|dq|dr|ds|dt|dv|dx|dy|ea|eb|ed|ee|eg|eh|ei|ek|el|eq|er|es|ev|ex|ey|gb|gc|gd|gg|gk|gl|gm|gn|gp|gq|gr|gs|gt|gv|gx|gy|hb|hc|hd|hg|hh|hk|hl|hm|hn|hp|hq|hr|hs|ht|hv|hx|ib|id|ig|ih|ii|ik|il|iq|ir|is|iv|ix|iy|kb|kc|kd|kg|kk|kl|km|kn|kp|kq|kr|ks|kt|kv|kx|khy|lb|lc|ld|lg|lh|lk|ll|lm|ln|lp|lq|lr|ls|lt|lv|lx|mb|mc|md|mg|mh|mk|ml|mm|mn|mp|mq|mr|ms|mt|mv|mx|nb|nc|nd|nk|nl|nm|nn|np|nq|nr|ns|nt|nv|nx|ob|od|og|oh|ok|ol|oo|oq|or|os|ov|ox|oy|pa|pb|pc|pd|pe|pg|pi|pk|pl|pm|pn|po|pp|pq|pr|ps|pt|pu|pv|px|py|phy|qa|qb|qc|qd|qe|qg|qh|qi|qk|ql|qm|qn|qo|qp|qq|qr|qs|qt|qv|qx|qy|rb|rc|rd|rg|rh|rk|rl|rm|rn|rp|rq|rr|rs|rt|rv|rx|ry|sb|sc|sd|sg|sh|sk|sl|sm|sn|sp|sq|sr|ss|st|sv|sx|tb|tc|td|tg|tk|tl|tm|tn|tp|tq|ts|tt|tv|tx|ub|ud|ug|uh|uk|ul|uq|ur|us|uv|ux|vb|vc|vd|vg|vh|vk|vl|vm|vn|vp|vq|vr|vs|vt|vv|vx|xb|xc|xd|xg|xh|xk|xl|xm|xn|xp|xq|xr|xs|xt|xv|xx|xy|yb|yd|yg|yh|yi|yk|yl|ym|yo|yp|yq|yr|ys|yv|yx|yy"
	+"aca|aco|acu|aia|aic|aie|aim|ain|aio|aip|ait|aiu|ama|ame|ami|amo|amu|amy|ana|ane|ani|ano|anu|any|aoa|aoc|aoe|aoi|aom|aon|aop|aot|aou|apa|ape|aph|api|apo|apu|ata|ate|ath|ati|ato|atr|atu|aty|aua|auc|aue|aui|aum|aun|auo|aup|aut|auu|auy|aya|aye|ayn|ayt|ayu|bec|bem|bio|boa|boe|bom|bou|bue|buy|chy|coa|coe|cou|cue|cuy|dio|doe|dou|duu|eca|eco|ecu|ema|eme|emi|emo|emu|emy|ena|ene|eni|eno|enu|eny|eoa|eoc|eoe|eoi|eom|eon|eop|eot|eou|epa|epe|eph|epi|epo|epu|eta|ete|eth|eti|eto|etr|etu|ety|eua|euc|eue|eui|eum|eun|euo|eup|eut|euu|euy|gec|geo|get|geu|gha|gho|ghu|ghy|gic|gip|git|goe|gou|gua|gue|gum|gup|guu|hio|hou|hya|hye|hyn|hyt|hyu|iac|iam|ian|iao|iap|iat|iay|ica|ico|icu|ima|ime|imi|imo|imu|imy|ina|ine|ing|ini|ino|inu|iny|ioa|ioe|iou|ipa|ipe|iph|ipi|ipo|ipu|ita|ite|ith|iti|ito|itr|itu|ity|iua|iue|iuo|iuu|iuy|kac|kai|kam|kan|kao|kap|kat|kau|kay|kea|key|khy|kio|koa|koc|koe|koi|kom|kon|kop|kot|kou|kua|kuc|kue|kui|kum|kun|kuo|kup|kut|kuu|kuy|kya|kye|kyn|kyt|kyu|lio|lou|lue|lya|lye|lyn|lyt|lyu|mio|mip|miu|moa|moe|mou|mue|mup|muy|mya|mye|myn|myt|myu|ngi|nge|nhy|nim|nio|nip|noe|nue|nuy|nya|nye|nyn|nyt|nyu|oam|oap|oeo|oao|oau|oca|och|oco|ocu|oec|oem|oep|oeu|oia|oic|oie|oim|oin|oio|oip|oit|oiu|oma|ome|omi|omo|omu|omy|ona|one|onh|oni|ono|onu|ony|opa|ope|oph|opi|opo|opu|ota|ote|oth|oti|oto|otr|otu|oty|oua|ouc|oue|oui|oum|oun|ouo|oup|out|ouu|ouy|quc|qum|qun|qup|qut|quu|rec|rio|roa|roe|rou|rue|sec|sia|sic|sin|sio|sip|sit|siu|soe|sop|sou|sue|sum|sup|sya|sye|syn|syt|syu|thy|tio|tou|tya|tye|tyn|tyt|tyu|uam|uca|uch|uco|ucu|uec|uem|uep|ueu|uia|uic|uie|uim|uin|uio|uip|uma|ume|umi|umo|umu|umy|una|une|unh|uni|uno|unu|uny|uoa|uoe|upa|upe|uph|upi|upo|upu|uta|ute|uth|uti|uto|utr|utu|uty|uua|uuc|uue|uui|uum|uun|uuo|uup|uut|uuu|uuy|vec|vep|vic|vim|vio|vip|voa|voe|vou|vue|vum|vup|vuu|vuy|vya|vye|vyn|vyt|vyu|xim|xio|xip|xou|xuu|yac|yai|yam|yan|yao|yap|yat|yau|yay|yec|yem|yeo|yep|yna|yne|yng|yni|yno|ynu|yny|yta|yte|yth|yti|yto|ytr|ytu|yty|yua|yuc|yue|yui|yum|yun|yuo|yup|yut|yuu|yuy";
			reg = new RegExp(no);
			res = reg.test(wrd);
			return res;
			*/
			return false;
		}
		
		private function notWord(cc:String):Boolean {
			return (" \r\n#,\\;.:-_()<>+-*/=?!\"§$%{}[]\'~|^°€ß²³@&´`0123456789".indexOf(cc) >= 0);
		}
		
		private function UNI(str1:String, k:String):String {
			var lenX:int = str1.length;
			var sX1:String;
			var sX2:String;
			var c1X:String;
			var c2X:String;
			var c3X:String;
			var c4X:String;
			var code:int;
			var code1:int;
			var first:int = 1;
			var idx:int;
			var keyx:int;
			var i:int;
			
			var ACC:Boolean = "sfrxjSFRXJ12345/\'-`?#~.".indexOf(k) >= 0;
			
			if (ACC) { // erase accent
				var kid:int;
	 			var keynr:String = '' + k;
	 			keynr = keynr.toLowerCase();
				
	 			if (MOD == 1 || MOD==0) {
					kid = "_12345".indexOf(keynr);
					
					if (kid > 0) {
						keyx = kid;
					}
				}
				
				if (MOD == 2 || MOD == 0) {
	   				kid = "_sfrxj".indexOf(keynr);
					
					if (kid > 0) {
						keyx = kid;
					}
				}
				
	  			if (MOD == 3 || MOD == 0) {
	   				kid = "_'-?~.".indexOf(keynr);
					
					if (kid > 0) {
						keyx = kid;
					} else {
						kid = "_/`?#.".indexOf(keynr);
					}
					
					if (kid>0) {
						keyx=kid;
					}
	  			}
				
	  			var arr:Array = str1.split('');
	  			var accent:int;
	 			for(i = 0; i < arr.length; i++) {
	   				idx = vietIdx(arr[i].charCodeAt(0));
	   				accent = idx % 6;
	   				
					if (idx < 0 || idx > 215 || accent == keyx) {
						continue;
					}
					
	   				if (accent > 0) {
						arr[i] = String.fromCharCode(VOW[idx-accent]);
					}
				}
	  			
				str1 = arr.join('');
			}
	
			ACC = ACC || string_test('aAeE', k);
			//CODE=''

			var vx1:int;
			var vx2:int;
			var vx3:int;
			
			for (i = lenX; i >= 0; i--) {
	 			sX1 = str1.substring(0, i - 1);
	 			sX2 = str1.substring(i, lenX);
	 			c1X = str1.substring(i - 1, i);
				code2 = c1X.charCodeAt(0);
	 			c2X = str1.substring(i - 2, i - 1);
				code = c2X.charCodeAt(0);
				c3X = str1.substring(i - 3, i - 2);
				code1 = c3X.charCodeAt(0);
	 			c4X=(c3X+c2X).toLowerCase()
				vx1 = vietIdx(code2);
	 			vx2 = vietIdx(code);
	 			vx3 = vietIdx(code1);

				if (!k && (code1 == 432 || code1 == 431) && (code == 417 || code == 416)) {//Z+0 and u'o'->undo
	 				c3X = (code1 == 432) ? 'u' : 'U';
					c2X = (code == 417) ? 'o' : 'O';
	 				CODE = 1;
	 				return sX1.substring(0, sX1.length - 2) + c3X + c2X + c1X + sX2;
				}
				
				if (k && string_test("6oO^", k)) { // u+o+ u+o+' u+o+`
	 				if (c2X && string_test(String.fromCharCode(0x01B0, 0x01AF), c2X) && c1X && vx1 >= 60 && vx1 < 72) {
	   					c2X = (c2X == String.fromCharCode(0x01B0)) ? 'u' : 'U';
	   					idx = vietIdx(c1X.charCodeAt(0));
	   					c1X = String.fromCharCode(VOW[idx-12]);
	   					changed = true;
						CODE = 1;
	   					return sX1.substring(0, sX1.length - 1) + c2X + c1X + sX2;
	  				}
				}
				
				if (k && string_test("6aAeE^", k)) { 
					// u'a u`a u?a u~a u.a or // u'e u`e u?e u~e u.e
	 				if (c2X && (vx2 >= 108 && vx2 < 144) && ((string_test('a|A', c1X) && !string_test('e|E', k)) || (string_test('e|E', c1X) && !(string_test('a|A', k))))) {
	   					idx = vietIdx(c2X.charCodeAt(0));
	   					keyx = idx % 6;
	   					li = Math.floor(idx / 6);
						c2X = (li == 18 || li== 22) ? 'u' : 'U';
	   					idx = vietIdx(c1X.charCodeAt(0));
	   					c1X = String.fromCharCode(VOW[idx + 12 + keyx]);
	   					changed = true;
						CODE = 1;
	   					return sX1.substring(0, sX1.length - 1) + c2X + c1X + sX2;
	  				}
					
	 				// u'ye u`ye u?ye u~ye u.ye
	 				if (c3X && !string_test('u|U', c3X) && vx3 >= 108 && vx3 < 120 && string_test('y|Y', c2X) && string_test('e|E', c1X)) {
	   					idx = vietIdx(c3X.charCodeAt(0));
	   					keyx = idx % 6;
	   					c3X = String.fromCharCode(VOW[idx-keyx]);
	   					idx = vietIdx(c1X.charCodeAt(0));
	   					c1X = String.fromCharCode(VOW[idx+12+keyx]);
	  					changed = true;
						CODE = 1;
	   					return sX1.substring(0, sX1.length - 2) + c3X + c2X + c1X + sX2;
	 				}
					
	 				// i'e i`e i?e i~e i.e // y'e y`e y?e y~e y.e
	 				if (c2X && !string_test('iIyY', c2X) && ((vx2 >= 144 && vx2 < 156) || (vx2 >= 180 && vx2 < 192)) && string_test('e|E', c1X) && !string_test('a|A', k)) {
	   					idx = vietIdx(c2X.charCodeAt(0));
	  					keyx = idx % 6;
	   					c2X = String.fromCharCode(VOW[idx-keyx]);
	   					idx = vietIdx(c1X.charCodeAt(0));
	   					c1X = String.fromCharCode(VOW[idx+12+keyx]);
	   					changed = true;
						CODE = 1;
	   					return sX1.substring(0, sX1.length - 1) + c2X + c1X + sX2;
	 				}
				}
	
				if (k && string_test("wW78+*(", k) && ((string_test('w|W', k) && MOD == 2) || (string_test('7|8', k) && MOD == 1) || (string_test("+|*|(", k) && MOD >= 3) || MOD == 0)) {
					var s1:String = str1.toLowerCase();
					var s2:String = s1.substring(0,2);
					var s3:String = s1.substring(0,3);
					idx = vietIdx(s1.charCodeAt(3));
					
					if (s2 == 'qu' || s1 == 'thuo' || (s1.length == 4 && s3 == 'thu' && idx >= 48 && idx < 60)){}
					else if (c4X == 'uo') {//uon
						c3X = String.fromCharCode((c3X == 'u') ? 432 : 431);
						c2X = String.fromCharCode((c2X == 'o') ? 417 : 416);
						changed = true;
						CODE = 1;
						return sX1.substring(0, sX1.length - 2) + c3X + c2X + c1X + sX2;
					} else if (c2X && string_test('u|U', c2X) && vx1 >= 36 && vx1 < 48) { //uo' uo` uo? ...
						c2X = String.fromCharCode((c2X == 'u') ? 0x01B0 : 0x01AF);//u+:U+
						idx = vietIdx(c1X.charCodeAt(0));
						c1X = String.fromCharCode(VOW[idx+24]);
						changed = true;
						CODE = 1;
						return sX1.substring(0, sX1.length - 1) + c2X + c1X + sX2;
					} else if (c2X && string_test('u|U', c2X) && vx1 >= 48 && vx1 < 60) {//uo^' uo^` uo^? ...
						c2X = String.fromCharCode((c2X == 'u') ? 0x01B0 : 0x01AF);//u+:U+
						idx = vietIdx(c1X.charCodeAt(0));
						c1X = String.fromCharCode(VOW[idx+12]);
						changed = true;
						CODE = 1;
						return sX1.substring(0, sX1.length - 1) + c2X + c1X + sX2;
					} else if (c2X && string_test('u|U', c2X) && vx1 >= 12 && vx1 < 24) {//ua^' ua^` ua^..
						idx = vietIdx(c1X.charCodeAt(0));
						keyx = idx % 6; //accent of c1
						c2X = String.fromCharCode((c2X=='u') ? 0x01B0 : 0x01AF);//u+:U+
						idx = vietIdx(c2X.charCodeAt(0));
						c2X = String.fromCharCode(VOW[idx + keyx]);
						idx = vietIdx(c1X.charCodeAt(0));
						li = Math.floor(idx / 6);
						c1X = (li == 2 || li == 4) ? 'a' : 'A';
						changed = true;
						CODE = 1;
						return sX1.substring(0, sX1.length - 1) + c2X + c1X + sX2;
					}
		 
					if (c2X && vx2 >= 0 && vx2 < 12 && string_test('u|U', c1X)) { //au
						idx = vietIdx(c2X.charCodeAt(0));
						c2X = String.fromCharCode(VOW[idx + 12]);
						changed = true;
						CODE = 1
						return sX1.substring(0, sX1.length - 1) + c2X + c1X + sX2;
					}
					
					if (string_test('aAeE', c1X) && (i < lenX || c4X == 'qu')){}//qua,que
					else if(c2X && string_test('o|O', c2X) && string_test('u|U', c1X) >= 0) {//ou by no'u'
						continue;
					} else if (c2X && vx2 >= 108 && vx2 < 120 && string_test('uUaA', c1X)) {//u u' u`u? u~ u. uu, ua
						continue;
					}
				}
				
				if (c4X == 'gi' && c1X && string_test('aAuU', c1X)){}
				else if(c2X && c1X && string_test('o|O', c2X) && string_test('o|O', c1X)) {}
				else if(c2X && c1X && string_test('i|I', c2X) && string_test('aAuU', c1X)) { //ia,iu
					continue;
				} else if (NEWV == 1 && ACC && c2X && ((string_test('eEyY', c1X) && string_test('oOuU', c2X)) || (string_test('aA', c1X) && string_test('o|O', c2X)))) {}//oa,oe,uy NEWV
				else if ((string_test('aAeEiIyY', c1X) && (i < lenX || c4X == 'qu')) || (c2X && string_test('i|I', c2X))) {}//--qua,que,qui,quy,ia,i..
				else if (ACC && string_test('o|O', c1X) && c2X && string_test('u|U', c2X)) {}//uo and ACCent
				else if (ACC && string_test('e|E', c1X) && c2X && string_test('y|Y', c2X)) {}// ye and ACC
				else if (ACC && first && string_test('aAeEiIoOuUyY', c1X) && !((string_test('a|A', c1X) || string_test('e|E', c1X)) && i < lenX)) {
					first = 0;
					continue;
				}
	
				CODE = Number(chgViCode(c1X.charCodeAt(0), k));
				if (CODE) {
					break;
				}
				
				if ((!CODE || CODE < 0) && !first) {
					ACC = false;
					first = 1;
					i = lenX + 1;
					continue;
				}
			}
		
			if (!CODE) {
				return str1 + k;
			}
			
			if (isNaN(CODE)) {
				str1 = sX1 + CODE + sX2 + k;
				ENGLISH = true
			} else {
				str1 = sX1 + String.fromCharCode(CODE) + sX2;
			}
			
			return str1;
		}
	
		private function UNIZZ(str1:String, k:String):String {
			if ((MOD == 1 && Number(k) != 0) || (MOD == 2 && k !='z' && k != 'Z')) {
				return '';
			}
			
			var str2:String = eraseAccent(str1);
			if (str2 != str1) {
				changed = true;
				return str2;
			}
			
			ENGLISH = false;
			return str1 + k;
		}
	
		private function eraseAccent(str1:String):String {
			var code:int;
			var idx:int;
			var nid:int;
			var grp:Number;
			var li:Number
			var accent:Number;
			var arr:Array = str1.split('');
			var time:int;
			var i:int;
			var found:Boolean;
			
			for (time = 0; time < 3; time++) {
				found = false;
				for (i = 0; i < arr.length; i++) {
					code = arr[i].charCodeAt(0);
					idx = vietIdx(code);
					grp = idx % 36;
					li = grp % 12;
					accent = li % 6;
					nid = -1;
					
					if (idx && idx < 192 && VOW[idx] > 0) { 
						if (time == 0 && accent) {//accent
							nid = Math.floor(idx / 36) * 36 + Math.floor(grp / 12) * 12 + Math.floor(li / 6) * 6;
						} else if (time == 1) {//without '-?~.
							nid = Math.floor(idx / 36) * 36;
							if(nid != -1 && nid != idx) {
								arr[i] = String.fromCharCode(VOW[nid]);
								found = true;
								if (accent) {
									break;
								}
							}
						} else if(time == 2) {
							if (code == 273) {
								arr[i] = 'd';
								found = true;
								break;
							} else if (code == 272) {
								arr[i] = 'D';
								found = true;
								break;
							}
						}
					}
				}
					
				if (found) {
					return arr.join('');
				}
			}
			
			return str1;
		}
		
		private function chgViCode(oldcode:Number, kk:String):String {
			var idx:int = vietIdx(oldcode);
			var k:Number = chgTypeKey(idx, kk);
			
			if (!Number(k) || idx < 0 || (Number(k) != 9 && idx > 191)) {
				return "";
			}
			
			
			var grp:int = idx % 36
			var li:int = grp % 12;
			var nid:int;
			
			if (k == 6) {
				nid = Math.floor(idx / 36) * 36 + 12 + li;
			} else if (k == 7 || k == 8) {
				nid = Math.floor(idx / 36) * 36 + 24 + li;
			} else if (k >= 1 && k <= 5) {
				nid = Math.floor(idx / 6) * 6 + k;
			} else if (k == 9 && idx > 191) {
				nid = idx + 1;
			} else {
				return "";
			}
			
			var res:int = VOW[nid];
			if (res < 0) {
				return "";
			}
			
			if (res != oldcode) {
				return res.toString();
			}
	
			if (k == 9 && idx > 191) {
				nid = idx - 1;
			} else if (k >= 6) {
				nid = Math.floor(idx / 36) * 36 + li;
			} else if (k >= 1) {
				nid = Math.floor(idx / 6) * 6;
			}
			
			return String.fromCharCode(VOW[nid]);
		}

		private function chgTypeKey(idx:Number, k:String):int {
			if ((MOD == 1 || MOD == 0) && string_test('0123456789', k)) {
				return int(k);
			}
			
			k = k.toUpperCase();
			if (MOD == 2 || MOD == 0) {
	 			if (k == 'D') return 9;
	 			if (k == 'S') return 1;
	 			if (k == 'F') return 2;
				if (k == 'R') return 3;
	 			if (k == 'X') return 4;
	 			if (k == 'J') return 5;
	 			if (k == 'W') return 7;
	 			if ((k == 'A' && idx < 36) || (k == 'O' && idx >= 36 && idx < 72) || (k == 'E' && idx >= 72 && idx < 108)) {
					return 6;
				}
				
	 			if (k =='Z') return 0;
			}
			
			if (MOD == 3 || MOD == 0) {
	 			if (k == 'D') return 9;
	 			if (k == '/' || k == '\'' || k == '1') return 1;
	 			if (k == '-'|| k == '\`' || k == '2') return 2;
	 			if (k == '?') return 3;
	 			if (k == '\~' || k == '\#') return 4;
	 			if (k == '.') return 5;
	 			if (k == '^') return 6;
	 			if (k == '+' || k == '*' || k == '(' ) return 7;
			}
			
			return -1;
		}
		
		public function get textFieldsList():Array { 
			var resultList: Array = [];
			for each (var textField: TextField in _textFieldsMap) resultList.push(textField);
			
			return resultList; 
		}
		
		public function set textFieldsList(value:Array):void {
			_textFieldsMap = new Dictionary(true);
			for (var i: int = 0; i < value.length; i++) _textFieldsMap[value[i]] = true;
		}
	}
}