package {
	
	import flash.display.MovieClip;
	import toolbox.MovieClipInfo;
	
	import toolbox.EventHandler;
	import toolbox.ButtonCreator;
	
	import Activity;
	
	public class Activity_ComputerVictim extends Activity {
		
		public function Activity_ComputerVictim() {
		}
		
		public override function start( game:Game ):void {
			this.visible = true;
			__mci = new MovieClipInfo( this );
			__activity = this;		
			__emailDone = false;
			__documentDone = false;
			setupImaging();
		}
		
		public override function activityExit():void {
			this.visible = false;
			if (!__emailDone) {
				EventHandler.getInstance().dispatchEvent( new GameEvent( GameEvent.GIVE_CLUE, false, false, { clueName:'EmailPOI' } ) );	
			}
			if (!__documentDone) {
				EventHandler.getInstance().dispatchEvent( new GameEvent( GameEvent.GIVE_CLUE, false, false, { clueName:'DrugAddiction' } ) );				
			}
			EventHandler.getInstance().dispatchEvent( new GameEvent( GameEvent.ACTIVITY_COMPLETE,false,false,{activityName:"ComputerVictim"} ) );
		}
		
		public function setXML(xml:XML):void {
			__xml = xml;
		}
		
		//-------------------------------------
		private var __xml:XML;
		private var __activity:MovieClip;
		private var __mci:MovieClipInfo;
		private var __screen:MovieClip;
		
		private var __email1:Boolean, __email2:Boolean, __email3:Boolean = false;
		private var __emailDone:Boolean, __documentDone:Boolean, __articleDone:Boolean = false;
		
		private function gotoAndSetup(screenName:String, func:Function):Function {
			return function():void { trace("setting up", screenName); __mci.addScript(__activity, screenName, func); __activity.gotoAndStop(screenName);}
		}	
		
		private function setupImaging():void {		
			__activity.gotoAndStop("imaging");		
			__activity.imaging.gotoAndPlay("in");
			__activity.imaging.loading.tf.text = __xml.imaging;
			var mci:MovieClipInfo = new MovieClipInfo(__activity.imaging);
			mci.addScriptAtEnd(__activity.imaging, "in", gotoAndSetup("desktop",setupDesktop) );
		}
		
		private function setupDesktop():void {
			__activity.desktop.gotoAndPlay("in");
			
			__activity.desktop.document.tf.text = __xml.desktop.icon.(@num == 1);
			__activity.desktop.article.tf.text = __xml.desktop.icon.(@num == 2);
			__activity.desktop.email.tf.text = __xml.desktop.icon.(@num == 3);
			
			ButtonCreator.CreateFromMovieClip(__activity.desktop.email, gotoAndSetup("email", setupEmail), { normal:"n", hover:"h", group:"victimComputer" } );
			ButtonCreator.CreateFromMovieClip(__activity.desktop.document, gotoAndSetup("document", setupDocument), { normal:"n", hover:"h", group:"victimComputer" } );
			ButtonCreator.CreateFromMovieClip(__activity.desktop.article, gotoAndSetup("article", setupArticle), { normal:"n", hover:"h", group:"victimComputer" } );
			if (__articleDone && __documentDone && __emailDone) {
				__activity.desktop.continueBtn.visible = true;
				__activity.desktop.continueBtn.tf.text = __xml.continueBtn;
				ButtonCreator.CreateFromMovieClip(__activity.desktop.continueBtn, activityExit, {normal:"n",hover:"h" } );
			}
			else {
				__activity.desktop.continueBtn.visible = false;
			}
		}
		
		private function gotoDesktop(e:GameEvent):void {
			EventHandler.getInstance().removeEventListener(GameEvent.ACTION_COMPLETE, gotoDesktop);
			__activity.gotoAndStop("desktop");
			__activity.desktop.gotoAndStop("done");
			if (__articleDone && __documentDone && __emailDone) {
				__activity.desktop.continueBtn.visible = true;
				__activity.desktop.continueBtn.tf.text = __xml.continueBtn;
				ButtonCreator.CreateFromMovieClip(__activity.desktop.continueBtn, activityExit, {normal:"n",hover:"h" } );
			}
		}
		
		private function setupEmail():void {
			__screen = __activity.email.client;
			__screen.title.text = __xml.emailClient.clientName;
			__screen.inbox.tf.text = __xml.emailClient.inbox;
			__screen.sent.tf.text = __xml.emailClient.sent;
			__screen.trash.tf.text = __xml.emailClient.trash;
			__screen.from.text = __xml.emailClient.fromLabel;
			__screen.subject.text = __xml.emailClient.subject;
			gotoInbox();
		}
		
		private function gotoSentBox():void {
			ButtonCreator.RemoveAllGroupRegisteredMovieClips("emailz");
			ButtonCreator.CreateFromMovieClip(__screen.inbox, gotoInbox, { normal:"n", hover:"h", group:"emailz" } );
			ButtonCreator.CreateFromMovieClip(__screen.trash, gotoTrashBox, {normal:"n",hover:"h",group:"emailz" } );
			__screen.sent.gotoAndStop("i");
			__screen.inbox.gotoAndStop("n");
			__screen.trash.gotoAndStop("n");
			//nothing here, clear all thingies
			__activity.email.client.gotoAndStop("normal");
			__screen.email1.gotoAndStop("n");
			__screen.email1.from.text = "";
			__screen.email1.subject.text = "";
			__screen.email2.gotoAndStop("n");
			__screen.email2.from.text = "";
			__screen.email2.subject.text = "";
			__screen.email2.y = -100;
			__screen.fromLine.text = "";
			__screen.toLine.text = "";
			__screen.dateLine.text = "";
			__screen.content.text = "";			
			if(tStatus == 1){
				__screen.trash.tBlink.gotoAndStop(1);
			}
		}
		
		var tStatus = 0;
		
		private function gotoTrashBox():void {
			__screen.trash.gotoAndStop("i");
			__screen.inbox.gotoAndStop("n");
			__screen.sent.gotoAndStop("n");
			ButtonCreator.RemoveAllGroupRegisteredMovieClips("emailz");
			ButtonCreator.CreateFromMovieClip(__screen.sent, gotoSentBox, { normal:"n", hover:"h", group:"emailz" } );
			ButtonCreator.CreateFromMovieClip(__screen.inbox, gotoInbox, { normal:"n", hover:"h", group:"emailz" } );
			
			__screen.email1.from.text = __xml.emailClient.email.(@num == 2).from;
			__screen.email1.subject.text = __xml.emailClient.email.(@num == 2).subject;			
			__screen.email2.from.text = __xml.emailClient.email.(@num == 3).from;
			__screen.email2.subject.text = __xml.emailClient.email.(@num == 3).subject;
			
			showEmail2();
			
		}
		
		private function showEmail2():void {
			//the advertisement
			__screen.email2.y = 128.40;
			__email2 = true;
			__screen.gotoAndStop("advertisement");
			__screen.email1.gotoAndStop("i");
			__screen.email2.gotoAndStop("n");
			ButtonCreator.CreateFromMovieClip(__screen.email2, showEmail3, { normal:"n", hover:"h", group:"emailz" } );
			
			var __text:XMLList = __xml.emailClient.email.(@num == 2);
			__screen.pane.source = __screen.ad;
			__screen.ad.fromLine.text = String(__xml.emailClient.fromPrefix) + " " + __text.from;
			__screen.ad.toLine.text = String(__xml.emailClient.toPrefix) + " " + __text.to;
			__screen.ad.dateLine.text = String(__xml.emailClient.datePrefix) + " " + __text.date;
			//ad content
			__screen.ad.header.text = __text.content.title;
			__screen.ad.bullets.htmlText = __text.content.textBox;
			__screen.ad.nevada.text = __text.content.nevada;
			__screen.ad.painTitle.text = __text.content.graphTitle;
			for (var i:uint = 1; i <= 4; i++) {
				__screen.ad["num"+i].text = __text.content.bar.(@num == i);	
				__screen.ad["label"+i].text = __text.content.label.(@num == i);				
			}
			if (__email1 && __email2 && __email3) {
				__screen.closeBtn.visible = true;
				__screen.email2.emailDot.alpha = 0;
				ButtonCreator.CreateFromMovieClip(__screen.closeBtn, finishEmail, {normal:"n",hover:"h" } );
			}
			else {
				__screen.closeBtn.visible = false;
			}
		}
		
		private function showEmail3():void {
			//the other one
			tStatus = 1;
			__screen.email2.emailDot.alpha = 0;
			__email3 = true;
			__screen.gotoAndStop("normal");
			__screen.email1.gotoAndStop("n");
			__screen.email2.gotoAndStop("i");
			ButtonCreator.CreateFromMovieClip(__screen.email1, showEmail2, { normal:"n", hover:"h", group:"emailz" } );
			
			var __text:XMLList = __xml.emailClient.email.(@num == 3);
			__screen.fromLine.text = String(__xml.emailClient.fromPrefix) + " " + __text.from;
			__screen.toLine.text = String(__xml.emailClient.toPrefix) + " " + __text.to;
			__screen.dateLine.text = String(__xml.emailClient.datePrefix) + " " + __text.date;
			__screen.content.text = __text.content;
			if (__email1 && __email2 && __email3) {
				__screen.closeBtn.visible = true;
				ButtonCreator.CreateFromMovieClip(__screen.closeBtn, finishEmail, {normal:"n",hover:"h" } );
			}
			else {
				__screen.closeBtn.visible = false;
			}
		}
		
		private function gotoInbox():void {
			ButtonCreator.RemoveAllGroupRegisteredMovieClips("emailz");
			ButtonCreator.CreateFromMovieClip(__screen.sent, gotoSentBox, { normal:"n", hover:"h", group:"emailz" } );
			ButtonCreator.CreateFromMovieClip(__screen.trash, gotoTrashBox, {normal:"n",hover:"h",group:"emailz" } );
			__screen.gotoAndStop("normal");
			__screen.inbox.gotoAndStop("i");
			//read first email first
			var __text:XMLList = __xml.emailClient.email.(@num == 1);
			__screen.email1.gotoAndStop("i");
			__screen.email1.from.text = __text.from;
			__screen.email1.subject.text = __text.subject;
			__screen.email2.gotoAndStop("n");
			__screen.email2.from.text = "";
			__screen.email2.subject.text = "";
			__screen.email2.y = -100;
			__screen.fromLine.text = String(__xml.emailClient.fromPrefix) + " " + __text.from;
			__screen.toLine.text = String(__xml.emailClient.toPrefix) + " " + __text.to;
			__screen.dateLine.text = String(__xml.emailClient.datePrefix) + " " + __text.date;
			__screen.content.text = __text.content;
			__email1 = true;			
			if (__email1 && __email2 && __email3) {
				__screen.closeBtn.visible = true;
				ButtonCreator.CreateFromMovieClip(__screen.closeBtn, finishEmail, {normal:"n",hover:"h" } );
			}
			else {
				__screen.closeBtn.visible = false;
			}
			if(tStatus == 1){
				__screen.trash.tBlink.gotoAndStop(1);
			}
		}
		
		private function finishEmail():void {
			trace("DONE EMAIL");
			ButtonCreator.RemoveAllGroupRegisteredMovieClips("emailz");
			//give clue sender POI
			if (!__emailDone) {				
				__emailDone = true;
				EventHandler.getInstance().dispatchEvent( new GameEvent( GameEvent.GIVE_CLUE, false, false, { clueName:'EmailPOI' } ) );
				EventHandler.getInstance().addEventListener(GameEvent.ACTION_COMPLETE, gotoDesktop);
			}
			else {
				gotoDesktop(null);
			}
		}
		
		private function setupDocument():void {
			__screen = __activity.document.doc;
			__activity.document.client.docName.text = __xml.document.fileName;
			__activity.document.client.pane.source = __activity.document.doc;
			__activity.document.client.ui1.htmlText = __xml.document.ui.(@num == 1);
			__activity.document.client.ui2.text = __xml.document.ui.(@num == 2);
			__activity.document.client.ui3.text = __xml.document.ui.(@num == 3);
			__screen.title.text = __xml.document.title;
			__screen.note.text = __xml.document.note;
			__screen.subtitle.text = __xml.document.text;
			__screen.chartTitle.text = __xml.document.chartTitle;
			__screen.yAxis.text = __xml.document.yAxis;
			__screen.xAxis.text = __xml.document.xAxis;
			for (var i:uint = 0; i <= 6; i++) {
				__screen["label" + i].text = __xml.document.y.(@num == i);
			}
			__screen.legend1.htmlText = __xml.document.blueLine;
			__screen.legend2.htmlText = __xml.document.greenLine;
			__screen.legend3.htmlText = __xml.document.redLine;
			ButtonCreator.CreateFromMovieClip(__activity.document.client.closeBtn, finishDocument, {normal:"n",hover:"h" } );
		}
		
		private function finishDocument():void {
			if (!__documentDone) {			
				__documentDone = true;	
				EventHandler.getInstance().dispatchEvent( new GameEvent( GameEvent.GIVE_CLUE, false, false, { clueName:'DrugAddiction' } ) );
				EventHandler.getInstance().addEventListener(GameEvent.ACTION_COMPLETE, gotoDesktop);
			}
			else {
				gotoDesktop(null);
			}
		}
		
		private function setupArticle():void {
			__screen = __activity.article.client;
			__screen.title.text = __xml.article.title;
			__screen.slogan.text = __xml.article.subtitle;
			__screen.date.text = __xml.article.date;
			
			__screen.headline.text = __xml.article.headline;
			__screen.subtitle.text = __xml.article.subheadline;
			__screen.content.text = __xml.article.content;			
			__screen.bullets.htmlText = __xml.article.medsBox;
			__screen.caption.htmlText = __xml.article.caption;
			__screen.available.htmlText = __xml.article.available;
			ButtonCreator.CreateFromMovieClip(__screen.closeBtn, finishArticle, {normal:"n",hover:"h" } );
		}
		
		private function finishArticle():void {
			__articleDone = true;	
			gotoDesktop(null);
		}
		
	}
	
}