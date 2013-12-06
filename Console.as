package com.adobe.flascc
{
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.display.Stage3D;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.display3D.Context3D;
  import flash.display3D.Context3DProfile;
  import flash.display3D.Context3DRenderMode;
  import flash.events.AsyncErrorEvent;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.ProgressEvent;
  import flash.events.SampleDataEvent;
  import flash.events.SecurityErrorEvent;
  import flash.geom.Rectangle;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.net.LocalConnection;
  import flash.net.URLLoader;
  import flash.net.URLLoaderDataFormat;
  import flash.net.URLRequest;
  import flash.text.TextField;
  import flash.ui.Keyboard;
  import flash.utils.ByteArray;
  import flash.utils.Endian;
  import flash.utils.getTimer;
  import flash.text.TextField;

  import com.adobe.flascc.CModule;
  import com.adobe.flascc.vfs.InMemoryBackingStore;
  import com.adobe.flascc.vfs.ISpecialFile;

  import com.adobe.flascc.vfs.myfs;
  import GLS3D.GLAPI;


  public class Console extends Sprite implements ISpecialFile
  {

    private var _tf:TextField;

    private function createTf():void
    {

        _tf = new TextField;
        _tf.multiline = true;
        _tf.x = 200;
        _tf.y = 200;
        _tf.width = 250;//stage.stageWidth;
        _tf.height = 150;//stage.stageHeight ;

        inputContainer.addChild(_tf);

        _tf.border = true;
    }


    
    private var mainloopTickPtr:int;
    private var inputContainer;

    private var s3d:Stage3D;
    private var ctx3d:Context3D;
    private var rendered:Boolean = false;
    private var inited:Boolean = false
    private const emptyVec:Vector.<int> = new Vector.<int>();

    private var fs:InMemoryBackingStore;


    public function Console(container:DisplayObjectContainer = null)
    {
      CModule.rootSprite = container ? container.root : this

      if(CModule.runningAsWorker()) {
        return;
      }

      if(container) {
        container.addChild(this)
        init(null)
      } else {
        addEventListener(Event.ADDED_TO_STAGE, init)
      }
    }


    protected function init(e:Event):void
    {
      inputContainer = new Sprite()
      addChild(inputContainer);

      createTf();

      stage.frameRate = 60;
      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      
      
      s3d = stage.stage3Ds[0];
      s3d.addEventListener(Event.CONTEXT3D_CREATE, context_created);
      s3d.requestContext3D(Context3DRenderMode.AUTO)
    }


    private function context_created(e:Event):void
    {
      ctx3d = s3d.context3D
      ctx3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, true /*enableDepthAndStencil*/ )
      ctx3d.enableErrorChecking = false;
      consoleWrite("Stage3D context: " + ctx3d.driverInfo);

      if(ctx3d.driverInfo.indexOf("Software") != -1) {
          consoleWrite("Software mode unsupported...");
          return;
      }
      
      GLAPI.init(ctx3d, null, stage);
      GLAPI.instance.context.clear(1.0, 1.0, 0.0);
      GLAPI.instance.context.configureBackBuffer(640, 480, 2, true /*enableDepthAndStencil*/ );
      
      // file system
      CModule.vfs.console = this;
      fs = new myfs();
      CModule.vfs.addBackingStore(fs, null);

      // starting c code
      CModule.startAsync(this, new <String>["/main.swf"]);

      GLAPI.instance.context.present();

      //stage.addEventListener (Event.ENTER_FRAME, enterFrame);
      //stage.addEventListener (Event.ENTER_FRAME, onFrame);
    }

    private function onFrame (e:Event):void
    {
      
      GLAPI.instance.context.clear(1.0, 1.0, 0.0);
      GLAPI.instance.context.present();
    }
    
    private function stageResize(event:Event):void
    {
        // need to reconfigure back buffer
        ctx3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, true /*enableDepthAndStencil*/ )
    }

    private function onError(e:Event):void
    {
      consoleWrite ( e.toString() );
    }

    public var exitHook:Function;

    public function exit(code:int):Boolean
    {
      // default to unhandled
      return exitHook ? exitHook(code) : false;
    }

    public function write(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int
    {
      var str:String = CModule.readString(bufPtr, nbyte)
      consoleWrite(str)
      return nbyte
    }
    
    public function read(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int
    {
      return 0
    }

    public function fcntl(fd:int, com:int, data:int, errnoPtr:int):int
    {
      return 0
    }

    public function ioctl(fd:int, com:int, data:int, errnoPtr:int):int
    {
      vglttyargs[0] = fd
      vglttyargs[1] = com
      vglttyargs[2] = data
      vglttyargs[3] = errnoPtr
      return CModule.callI(CModule.getPublicSymbol("vglttyioctl"), vglttyargs);
    }
    private var vglttyargs:Vector.<int> = new Vector.<int>()
  
    protected function consoleWrite(s:String):void
    {
      trace(s)

        _tf.appendText(s + "\n")
        _tf.scrollV = _tf.maxScrollV

    }

    protected function enterFrame(e:Event):void
    {
      if(!inited) {
        inited = true;
        mainloopTickPtr = CModule.getPublicSymbol("_Z4drawv");
      }

      CModule.callI(mainloopTickPtr, emptyVec);
      GLAPI.instance.context.present();
    }
  }
}
