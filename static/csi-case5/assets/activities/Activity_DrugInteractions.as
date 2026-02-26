package {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	import toolbox.MovieClipInfo;
	
	import toolbox.EventHandler;
	import toolbox.ButtonCreator;
	import toolbox.SoundHelper;
	import toolbox.DraggableCreator;
	
	import Activity;
	
	public class Activity_DrugInteractions extends Activity {
		
		public function Activity_DrugInteractions() {
		}
		
		
		public override function start( game:Game ):void {
			this.visible = true;
			this.gotoAndPlay("in");
			__activity = this;
			__mci = new MovieClipInfo(__activity);
			ButtonCreator.CreateFromMovieClip( __activity.icon1, showTox, { hover:"h", normal:"n" } );
			ButtonCreator.CreateFromMovieClip( __activity.icon2, showAutopsy, { hover:"h", normal:"n" } );
			__activity.icon3.gotoAndStop("i");
			makeCSS();
		}
		
		public override function activityExit():void {
			this.visible = false;
			EventHandler.getInstance().dispatchEvent( new GameEvent( GameEvent.ACTIVITY_COMPLETE,false,false,{activityName:"DrugInteractions"} ) );
		}
		
		public function setXML(xml:XML):void {
			__xml = xml;
		}
		
		//-------------------------------------
		private var __xml:XML;
		private var __text:XMLList;
		private var __activity:MovieClip;
		private var __mci:MovieClipInfo;
		private var __stylesheet:StyleSheet;
		
		private function makeCSS():void {
			__stylesheet = new StyleSheet();
			__stylesheet.setStyle(".boldOrange", {fontWeight:'bold',color:'#FFE636' } );
			__stylesheet.setStyle(".boldNavy", {fontWeight:'bold',color:'#92B4E2' } );
			__stylesheet.setStyle(".boldBlue", {fontWeight:'bold',color:'#3EDDFF' } );
			__stylesheet.setStyle(".boldGreen", {fontWeight:'bold',color:'#00E176' } );
			__stylesheet.setStyle(".boldPink", { fontWeight:'bold', color:'#F488A0' } );
			__stylesheet.setStyle(".white", {color:'#FFFFFF' } );
		}
		
		private function showTox():void {
			__activity.gotoAndPlay("toxReport");
			
			__activity.report.title.text = __xml.toxReport.title;
			__activity.report.victimName.text = __xml.toxReport.name;
			__activity.report.analyst.text = __xml.toxReport.analyst;
			
			var i:uint;
			for (i = 1; i <= 3; i++) {
				__activity.report["label" + i].text = __xml.toxReport.label.(@num == i);
				//and add buttons
				__activity.report["question" + i].storetext = __xml.toxReport.popup.(@num == i).content;
				ButtonCreator.CreateFromMovieClip(__activity.report["question" + i], showToxPopup, {normal:"normal",hover:"hover", group:"toxes", passMC:true} );
			}
			
			for (i = 1; i <= 5; i++) {				
				__activity.report["row" + i].label1.text = __xml.toxReport.line.(@num == i).field.(@num == 1);
				__activity.report["row" + i].label2.text = __xml.toxReport.line.(@num == i).field.(@num == 2);
				__activity.report["row" + i].label3.text = __xml.toxReport.line.(@num == i).field.(@num == 3);
			}		
			ButtonCreator.CreateFromMovieClip(__activity.report.closeBtn, closeTox, { normal:"n",hover:"h"} );
		}
		
		private function showToxPopup(mc:MovieClip):void {
			//close all others & reset their buttons	
			ButtonCreator.RemoveAllGroupRegisteredMovieClips("toxes");
			for (var i:uint = 1; i <= 3; i++) {
				if (__activity.report["question" + i] == mc) {
					mc.gotoAndStop("open");
					mc.tf.htmlText = mc.storetext;
					ButtonCreator.CreateFromMovieClip(mc, function(mc:MovieClip):void {
						//trace(mc.name, obj.mc.name, obj.mc.closeBtn.name);
						mc.gotoAndStop("normal");
						ButtonCreator.CreateFromMovieClip(mc, showToxPopup, {normal:"normal",hover:"hover", group:"toxes", passMC:true} );
					}, {normal:"open", group:"toxes", passMC:true} );
				}
				else {
					__activity.report["question" + i].gotoAndStop("normal");
					ButtonCreator.CreateFromMovieClip(__activity.report["question" + i], showToxPopup, {normal:"normal",hover:"hover", group:"toxes", passMC:true} );
				}
			}
			
		}
		
		private function closeTox():void {	
			ButtonCreator.RemoveAllGroupRegisteredMovieClips("toxes");
			__activity.icon1.gotoAndStop("i");
			trace(__activity.icon1.currentFrameLabel, __activity.icon2.currentFrameLabel);
			if (__activity.icon1.currentFrameLabel == "i" && __activity.icon2.currentFrameLabel == "i") {
				playFirstDialog();
			}
			else {
				__activity.gotoAndPlay("toxOut");
			}
		}
		
		private function showAutopsy():void {
			__activity.gotoAndPlay("autopsy");
			
			__activity.report.title.text = __xml.autopsy.title;
			__activity.report.victimName.text = __xml.autopsy.decedent;
			__activity.report.analyst.text = __xml.autopsy.examiner;
			trace(__stylesheet.getStyle(".boldBlue").toString);
			__activity.report.content.styleSheet = __stylesheet;
			__activity.report.content.htmlText = __xml.autopsy.content;
			
			ButtonCreator.CreateFromMovieClip(__activity.report.closeBtn, closeAutopsy, { normal:"n",hover:"h"} );
		}
		
		private function closeAutopsy():void {	
			__activity.icon2.gotoAndStop("i");
			trace(__activity.icon1.currentFrameLabel, __activity.icon2.currentFrameLabel);
			if (__activity.icon1.currentFrameLabel == "i" && __activity.icon2.currentFrameLabel == "i") {
				playFirstDialog();
			}
			else {
				__activity.gotoAndPlay("autopsyOut");
			}
		}
		
		private function playFirstDialog():void {
			trace("play first dialog");
			EventHandler.getInstance().dispatchEvent( new GameEvent( GameEvent.DIALOG_START, false, false, { dialogName:'SandersDrugInteractions1' } ) );
			EventHandler.getInstance().addEventListener(GameEvent.ACTION_COMPLETE, endFirstDialog);
		}
		
		private function endFirstDialog(e:GameEvent):void {
			EventHandler.getInstance().removeEventListener(GameEvent.ACTION_COMPLETE, endFirstDialog);
			__activity.gotoAndStop("loaded");
			__activity.icon3.gotoAndStop("normal");
			ButtonCreator.CreateFromMovieClip(__activity.icon3, startInteractions, {normal:"n",hover:"h" } );
		}
		
		private function startInteractions():void {
			__text = __xml.drugInteractions.screen.(@num == 1);
			__activity.gotoAndPlay("interactionsIn");
			__activity.report.title.text = __text.title;
			__activity.report.desc.text = __text.text;
			__mci.addScriptAtEnd(__activity, "interactionsIn", function():void {
				__activity.stop();
				__activity.report.gotoAndPlay("screen1");
				__activity.report.title.text = __text.title;
				__activity.report.desc.text = __text.text;
				__activity.report.continueBtn.tf.text = __xml.continueBtn;
				ButtonCreator.CreateFromMovieClip(__activity.report.continueBtn, gotoScreen2, {normal:"n",hover:"h" } );
			});
		}
		
		private function gotoScreen2():void {
			__text = __xml.drugInteractions.screen.(@num == 2);
			__activity.report.gotoAndPlay("screen2");
			__activity.report.title.text = __text.title;
			__activity.report.desc.text = __text.text;
			__activity.report.desc2.text = __text.text2;
			//make it blink
			ButtonCreator.CreateFromMovieClip(__activity.report.wheel, gotoWheelScreen, { } );
			__activity.report.wheel.wheel.label1.text = __xml.drugInteractions.type.(@num == 1).wheel;
		}
		
		private function gotoWheelScreen():void {
			__text = __xml.drugInteractions;
			__activity.report.gotoAndPlay("wheelScreen");
			__activity.report.popupExamples.visible = false;
			__activity.report.popupEffects.visible = false;
			__activity.report.popupMechanism.visible = false;
			__activity.report.continueBtn.tf.text = __xml.continueBtn;
			ButtonCreator.CreateFromMovieClip(__activity.report.continueBtn, function():void {
				ButtonCreator.RemoveAllGroupRegisteredMovieClips("popupBtns");
				EventHandler.getInstance().dispatchEvent( new GameEvent( GameEvent.DIALOG_START, false, false, { dialogName:'SandersDrugInteractions2' } ) );
				EventHandler.getInstance().addEventListener(GameEvent.ACTION_COMPLETE, endSecondDialog);
			}, {normal:"n",hover:"h" } );
			__activity.report.continueBtn.visible = false;
			for (var i:uint = 1; i <= 5; i++) {
				__activity.report.wheel["label" + i].text = __text.type.(@num == i).wheel;
			}
			__activity.report.wheel.mouseChildren = false;
			__activity.report.wheel.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
			__activity.report.exampleBtn.tf.text = __xml.exampleBtn;
			__activity.report.effectsBtn.tf.text = __xml.effectsBtn;
			//set up structure for checking
			__done = [false, false,
				false, false,
				false, false,
				false, false,
				false, false];
			__currentIndex = 0;
			__text = __xml.drugInteractions.type.(@name == "cns");
			fillTextWheelScreen();
		}
		
		private var __origX:int;
		private var __origY:int;
		private var __done:Array = [];
		private var __currentIndex:uint;		
		private var __clickedWheel:MovieClip;
				
		private function stopMove(e:MouseEvent):void {
			SoundHelper.playSound("ClickSound");
			__activity.report.removeEventListener(MouseEvent.MOUSE_UP, stopMove);
			__activity.report.removeEventListener(MouseEvent.MOUSE_MOVE, moveWheel);
			__activity.report.wheel.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
			trace(__activity.report.wheel.rotation);
			if (__activity.report.wheel.rotation <= -19 && __activity.report.wheel.rotation > -90) {
				__activity.report.wheel.rotation = -55;
				__text = __xml.drugInteractions.type.(@name == "cns");
				__currentIndex = 0;
			}
			else if (__activity.report.wheel.rotation <= -90 && __activity.report.wheel.rotation > -164) {
				__activity.report.wheel.rotation = -127;
				__text = __xml.drugInteractions.type.(@name == "opioids");
				__currentIndex = 2;
			}
			else if (__activity.report.wheel.rotation <= -164 || __activity.report.wheel.rotation >= 121) {
				__activity.report.wheel.rotation = 161;
				__text = __xml.drugInteractions.type.(@name == "relaxant");
				__currentIndex = 4;
			}
			else if (__activity.report.wheel.rotation >= 54 && __activity.report.wheel.rotation < 121) {
				__activity.report.wheel.rotation = 89;
				__text = __xml.drugInteractions.type.(@name == "stim");
				__currentIndex = 6;
			}
			else if (__activity.report.wheel.rotation <= 54 && __activity.report.wheel.rotation > -19 ) {
				__activity.report.wheel.rotation = 17;
				__text = __xml.drugInteractions.type.(@name == "otc");
				__currentIndex = 8;
			}
			fillTextWheelScreen();
		}
		
		private function fillTextWheelScreen():void {
			__activity.report.title.text = __text.title;
			__activity.report.desc.text = __text.desc;
			if (__done[__currentIndex]) {
				ButtonCreator.CreateFromMovieClip(__activity.report.exampleBtn, showExamples, {normal:"i",hover:"h2", group:"popupBtns" } );
				__activity.report.exampleBtn.gotoAndStop("i");
			}
			else {
				ButtonCreator.CreateFromMovieClip(__activity.report.exampleBtn, showExamples, {normal:"n",hover:"h", group:"popupBtns" } );
				__activity.report.exampleBtn.gotoAndStop("n");
			}
			if (__done[__currentIndex + 1]) {
				ButtonCreator.CreateFromMovieClip(__activity.report.effectsBtn, showEffects, {normal:"i",hover:"h2", group:"popupBtns"} );
				__activity.report.effectsBtn.gotoAndStop("i");
			}
			else {
				ButtonCreator.CreateFromMovieClip(__activity.report.effectsBtn, showEffects, {normal:"n",hover:"h", group:"popupBtns" } );
				__activity.report.effectsBtn.gotoAndStop("n");
			}
		}
		
		private function showExamples():void {
			__activity.report.exampleBtn.gotoAndStop("i");
			ButtonCreator.CreateFromMovieClip(__activity.report.exampleBtn, showExamples, {normal:"i",hover:"h2", group:"popupBtns"} );
			trace("show examples", __currentIndex, __text.title);
			__activity.report.popupExamples.gotoAndStop("set" + __currentIndex);
			__activity.report.popupExamples.title.text = __text.title;
			__activity.report.popupExamples.desc.styleSheet = __stylesheet;
			__activity.report.popupExamples.desc.htmlText = __text.example;
			__activity.report.popupExamples.visible = true;
			__done[__currentIndex] = true;
			ButtonCreator.CreateFromMovieClip(__activity.report.popupExamples.closeBtn, function():void {
				__activity.report.popupExamples.visible = false;
				checkAllFirstDone();
			},{normal:"n",hover:"h"});
		}
		
		private function showEffects():void {
			trace("show effects", __currentIndex+1, __text.title);	
			__activity.report.effectsBtn.gotoAndStop("i");
			ButtonCreator.CreateFromMovieClip(__activity.report.effectsBtn, showEffects, {normal:"i",hover:"h2", group:"popupBtns"} );
			__activity.report.popupEffects.gotoAndStop("set" + __currentIndex);
			__activity.report.popupEffects.title.text = __text.title;
			__activity.report.popupEffects.desc.styleSheet = __stylesheet;
			__activity.report.popupEffects.desc.htmlText = __text.effects;
			__activity.report.popupEffects.mechanismBtn.tf.text = __xml.mechanismBtn;
			__activity.report.popupEffects.visible = true;
			ButtonCreator.CreateFromMovieClip(__activity.report.popupEffects.mechanismBtn, showMechanism,{normal:"n",hover:"h"});		
		}
		
		private function showMechanism():void {
			trace("show mechanism", __currentIndex + 1, __text.title);
			__activity.report.popupMechanism.gotoAndStop("set" + __currentIndex);
			__activity.report.popupMechanism.desc.styleSheet = __stylesheet;
			__activity.report.popupMechanism.desc.htmlText = __text.mechanism;
			__activity.report.popupMechanism.title.text = __xml.mechanismBtn;
			if (__currentIndex == 8) {
				__activity.report.popupMechanism.desc2.text = __text.caption;
			}
			__activity.report.popupMechanism.visible = true;
			__done[__currentIndex+1] = true;
			ButtonCreator.CreateFromMovieClip(__activity.report.popupMechanism.closeBtn, function():void {
				__activity.report.popupEffects.visible = false;
				__activity.report.popupMechanism.visible = false;
				checkAllFirstDone();
			},{normal:"n",hover:"h"});
		}
		
		private function checkAllFirstDone():void {
			for (var i:uint = 0; i < __done.length; i++) {
				trace(__done[i]);
				if (!__done[i]) {
					return;
				}
			}
			__activity.report.continueBtn.visible = true;
		}		
		
		private function endSecondDialog(e:GameEvent):void {
			EventHandler.getInstance().removeEventListener(GameEvent.ACTION_COMPLETE, endSecondDialog);
			gotoScreen3();
		}
		
		private function gotoScreen3():void {
			__text = __xml.drugInteractions.screen.(@num == 3);
			__activity.report.gotoAndPlay("screen3");
			__activity.report.title.text = __text.title;
			__activity.report.desc.text = __text.text;
			__activity.report.caption1.text = __text.caption.(@num == 1);
			__activity.report.caption2.text = __text.caption.(@num == 2);
			//make it blink
			__activity.report.continueBtn.tf.text = __xml.continueBtn;
			ButtonCreator.CreateFromMovieClip(__activity.report.continueBtn, gotoScreen4, {normal:"n",hover:"h" } );			
		}
		
		private function gotoScreen4():void {			
			__text = __xml.drugInteractions.screen.(@num == 4);
			__activity.report.gotoAndPlay("screen4");
			fillWheelsText();
			__activity.report.title.text = __text.title;
			__activity.report.continueBtn.tf.text = __xml.beginBtn;
			ButtonCreator.CreateFromMovieClip(__activity.report.continueBtn, gotoScreen5, {normal:"n",hover:"h" } );
		}
		
		private function gotoScreen5():void {
			__text = __xml.drugInteractions.screen.(@num == 5);
			__activity.report.gotoAndPlay("screen5");
			//fill all text
			fillWheelsText();
			__activity.report.title.text = __text.title;
			__activity.report.chart.nameTitle.text = __text.tableTitle;
			for (var i:uint = 1; i <= 3; i++) {
				__activity.report.chart["head" + i].text = __text.th.(@num == i);
				__activity.report.chart["drug" + i].text = __text.interaction.(@num == i);
				__activity.report.chart["also" + i].text = __text.interaction.(@num == i);
			}
			__activity.report.instruct.tf.text = __text.instruct;
			__activity.report.blinker1.visible = false;
			__activity.report.blinker2.visible = false;
			__activity.report.continueBtn.visible = false;
			startCombinations();
		}
		
		private var __leftNum:uint, __rightNum:uint;
		
		private function fillWheelsText():void {
			var text:XMLList;
			text = __xml.drugInteractions;
			var i:uint, j:uint, k:uint;
			for (i = 1; i <= 5; i++) {
				__activity.report.wheel1["label" + i].text = text.type.(@num == i).wheel;
				//__activity.report.wheel1["ex" + i].text = text.type.(@num == i).shortEx;
				__activity.report.wheel2["label" + i].text = text.type.(@num == i).wheel;
				//__activity.report.wheel2["ex" + i].text = text.type.(@num == i).shortEx;
			}
		}
		
		private function startCombinations():void {
			__leftNum = __rightNum = 1;
			pickWarning();
			ButtonCreator.CreateFromMovieClip(__activity.report.continueBtn, gotoScreen6, { normal:"n", hover:"h" } );
			__activity.report.wheel1.mouseChildren = false;
			__activity.report.wheel2.mouseChildren = false;
			__activity.report.wheel1.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
			__activity.report.wheel2.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
			__activity.report.target1.correctNum = 1;
			__activity.report.target2.correctNum = 2;
			__activity.report.target3.correctNum = 3;
			
			// PAUL: ADDED 11/19/13 [ Moved From: pickWarning().  Was causing target2 to read innacurate hit number. ]
			DraggableCreator.createDraggable(__activity.report.dragWarning, [__activity.report.target1, __activity.report.target2, __activity.report.target3], down, checkDragCorrect, true, true);
		}
		
		private function startMove(e:MouseEvent):void {
			__origX = e.stageX;
			__origY = e.stageY;
			__clickedWheel = MovieClip(e.target);
			__clickedWheel.removeEventListener(MouseEvent.MOUSE_DOWN, startMove);
			__activity.report.addEventListener(MouseEvent.MOUSE_MOVE, moveWheel);
			if (__clickedWheel.name == "wheel") {				
				__activity.report.addEventListener(MouseEvent.MOUSE_UP, stopMove);
			}
			else if (__clickedWheel.name == "wheel1") {
				__activity.report.addEventListener(MouseEvent.MOUSE_UP, stopMove1);
			}
			else if (__clickedWheel.name == "wheel2") {
				__activity.report.addEventListener(MouseEvent.MOUSE_UP, stopMove2);
			}
		}
		
		private function moveWheel(e:MouseEvent):void {
			var dX:int = e.stageX - __clickedWheel.x;
			var dY:int = e.stageY - __clickedWheel.y;
			var angle = Math.atan2(dY, dX) / (Math.PI / 180);
			__clickedWheel.rotation = angle;
		}
		
		//different indices
		private function stopMove1(e:MouseEvent):void {
			SoundHelper.playSound("ClickSound");
			__activity.report.removeEventListener(MouseEvent.MOUSE_UP, stopMove1);
			__activity.report.removeEventListener(MouseEvent.MOUSE_MOVE, moveWheel);
			__clickedWheel.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
			trace(__clickedWheel.rotation);
			if (__clickedWheel.rotation <= 36 && __clickedWheel.rotation > -36) {
				__clickedWheel.rotation = 0;
				__leftNum = 1;
			}
			else if (__clickedWheel.rotation <= -36 && __clickedWheel.rotation > -108) {
				__clickedWheel.rotation = -72;
				__leftNum = 2;
			}
			else if (__clickedWheel.rotation <= -108 && __clickedWheel.rotation > -180 ) {
				__clickedWheel.rotation = -144;
				__leftNum = 3;
			}
			else if (__clickedWheel.rotation <= -180 || __clickedWheel.rotation > 108 ) {
				__clickedWheel.rotation = 144;
				__leftNum = 5;
			}
			else if (__clickedWheel.rotation <= 108 && __clickedWheel.rotation > 36 ) {
				__clickedWheel.rotation = 72;
				__leftNum = 7;
			}
			pickWarning();
		}
		
		//different indices
		private function stopMove2(e:MouseEvent):void {
			SoundHelper.playSound("ClickSound");
			__activity.report.removeEventListener(MouseEvent.MOUSE_UP, stopMove2);
			__activity.report.removeEventListener(MouseEvent.MOUSE_MOVE, moveWheel);
			__clickedWheel.addEventListener(MouseEvent.MOUSE_DOWN, startMove);
			trace(__clickedWheel.rotation);
			if (__clickedWheel.rotation <= -144 || __clickedWheel.rotation > 144) {
				__clickedWheel.rotation = 180;
				__rightNum = 1;
			}
			else if (__clickedWheel.rotation <= 144 && __clickedWheel.rotation > 72) {
				__clickedWheel.rotation = 108;
				__rightNum = 2;
			}
			else if (__clickedWheel.rotation <= 72 && __clickedWheel.rotation > 0 ) {
				__clickedWheel.rotation = 36;
				__rightNum = 3;
			}
			else if (__clickedWheel.rotation <= 0 && __clickedWheel.rotation > -72) {
				__clickedWheel.rotation = -36;
				__rightNum = 5;
			}
			else if (__clickedWheel.rotation <= -72 && __clickedWheel.rotation > -144 ) {
				__clickedWheel.rotation = -108;
				__rightNum = 7;
			}
			pickWarning();
		}
		
		private function pickWarning():void {		
			trace(__leftNum, __rightNum, __leftNum * __rightNum);	
			__activity.report.dragWarning.tf.htmlText = __text.warning.(@num == __leftNum * __rightNum);
			//parse and show objects
			__activity.report.warning.warning.visible = false;
			__activity.report.warning.heart.visible = false;
			__activity.report.warning.brain.visible = false;
			__activity.report.warning.lungs.visible = false;
			__activity.report.warning.question.visible = false;
			var warnings:Array = String(__text.warning.(@num == __leftNum * __rightNum).@show).split(",");
			for each (var w:String in warnings) {
				if (__activity.report.warning[w]) {					
					__activity.report.warning[w].visible = true;
				}
			}
			//make it draggable if it isn't already in place
			// PAUL: CHANGED 11/19/13 [ Moved From: pickWarning().  Was causing target2 to read innacurate hit number. ]
			//DraggableCreator.createDraggable(__activity.report.dragWarning, [__activity.report.target1, __activity.report.target2, __activity.report.target3], down, checkDragCorrect, true, true);
		}
		
		private function down(mc:MovieClip):void { }
		private function checkDragCorrect(obj:Object, hit:MovieClip):void {		
			if(hit && hit.correctNum == (__leftNum * __rightNum)){
				obj.mc.x = obj.mc.dragOrigX;
				obj.mc.y = obj.mc.dragOrigY;
				hit.tf.text = obj.mc.tf.text;
				hit.done = true;
				//PAUL: target1 was removed, as it displayed redundant info when Drug A & Drug B were identical.
				//if (__activity.report.target1.done && __activity.report.target2.done && __activity.report.target3.done) {
				if (__activity.report.target2.done && __activity.report.target3.done) {
					__activity.report.instruct.visible = false;
					if (__activity.report.chart.currentFrameLabel == "comp3") {
						__activity.report.continueBtn.tf.text = __xml.continueBtn;
						__activity.report.continueBtn.visible = true;
					}
					else if(__activity.report.chart.currentFrameLabel == "comp2"){
						__activity.report.blinker2.visible = true;
						ButtonCreator.CreateFromMovieClip(__activity.report.blinker2, activateNextSet, { normal:"blink", hover:"h", passObj:{blinker:__activity.report.blinker2,frameLabel:"comp3"} } );
						__activity.report.blinker2.gotoAndPlay("blink");
						__activity.report.target1.correctNum = 3;
						__activity.report.target2.correctNum = 2;
						__activity.report.target3.correctNum = 9;
					}
					else if(__activity.report.chart.currentFrameLabel == "comp1"){
						__activity.report.blinker1.visible = true;
						ButtonCreator.CreateFromMovieClip(__activity.report.blinker1, activateNextSet, {normal:"blink",hover:"h", passObj:{blinker:__activity.report.blinker1,frameLabel:"comp2"} } );
						__activity.report.blinker1.gotoAndPlay("blink");
						__activity.report.target1.correctNum = 2;
						__activity.report.target2.correctNum = 4;
						__activity.report.target3.correctNum = 6;
					}
				}
				else {
					//remove target from the list and make the draggable once again
					obj.hitAreas.splice(obj.hitAreas.indexOf(hit), 1);
					obj.mc.x = obj.mc.dragOrigX;
					obj.mc.y = obj.mc.dragOrigY;
					DraggableCreator.createDraggable( obj.mc, obj.hitAreas, obj.down, obj.up, obj.mostArea, obj.snapBack );
				}
			}
			else {
				obj.mc.x = obj.mc.dragOrigX;
				obj.mc.y = obj.mc.dragOrigY;
				DraggableCreator.createDraggable( obj.mc, obj.hitAreas, obj.down, obj.up, obj.mostArea, obj.snapBack );
			}
		}
		
		private function activateNextSet(obj:Object):void {
			trace("BOOGIE FRAME LABEL: " + obj.frameLabel);
			__activity.report.chart.gotoAndStop(obj.frameLabel);
			for (var i:uint = 2; i <= 3; i++) {
				__activity.report["target"+i].done = false;
				__activity.report["target"+i].tf.text = "";
			}
			if (obj.frameLabel == "comp2") {
				trace("comp2");
				trace("target2.correctNum: " + __activity.report.target2.correctNum);
				__activity.report.chart.also2.text = __text.interaction.(@num == 1);
				__activity.report.target2.correctNum = 2;
			} else if (obj.frameLabel == "comp3") {
				trace("comp3");
				__activity.report.chart.also2.text = __text.interaction.(@num == 1);
				__activity.report.chart.also3.text = __text.interaction.(@num == 2);
				__activity.report.target2.correctNum = 3;
				__activity.report.target3.correctNum = 6;
			}
			obj.blinker.visible = false;
			__activity.report.instruct.visible = true;
			DraggableCreator.createDraggable(__activity.report.dragWarning, [__activity.report.target1, __activity.report.target2, __activity.report.target3], down, checkDragCorrect, true, true);
		}
		
		private function gotoScreen6():void {	
			DraggableCreator.removeAllDraggable();
			__text = __xml.drugInteractions.screen.(@num == 6);
			__activity.report.gotoAndPlay("screen6");
			__activity.report.title.text = __text.title;
			__activity.report.nameText.text = __text.nameLabel;
			__activity.report.drugsText.text = __text.drugTitle;
			__activity.report.drugsContent.htmlText = __text.drugContent;
			__activity.report.interactionsText.text = __text.consequenceTitle;
			__activity.report.respiratoryTitle.text = __text.respiratoryTitle;
			__activity.report.respiratoryContent.htmlText = __text.respiratoryContent;
			__activity.report.otherTitle.text = __text.otherTitle;
			__activity.report.otherContent.htmlText = __text.otherContent;
			__activity.report.continueBtn.tf.text = __xml.continueBtn;
			ButtonCreator.CreateFromMovieClip(__activity.report.continueBtn, activityExit, { normal:"n",hover:"h"} );
		}
		
	}
	
}