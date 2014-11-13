package input;
import msignal.Signal;

import de.polygonal.ds.pooling.DynamicObjectPool;

import js.JQuery;
import js.Browser;
import input.Touch;
class TouchManager
{
	public var onTouches (default, null) : Signal1<Array<Touch>>;
    private var touchPool: DynamicObjectPool<Touch>;
    private var touchesToSend : Array<Touch>;
    private var touchPoolSize : Int = 40; 

	static private var touchInstance : TouchManager;
	
	private var jquery : JQuery;

	private function new()
	{
		jquery = new JQuery(Browser.window);
		onTouches = new Signal1();

        touchPool = new DynamicObjectPool<Touch>(Touch);
        touchesToSend = [];
	}

	static public function instance() : TouchManager
	{
		return touchInstance;
	}

	public static function initialize(finishedCallback : Void->Void) : Void
	{
		touchInstance  = new TouchManager();
		
		///same as $(function(){}) in javascript
		touchInstance.jquery.ready(function(e):Void {
			
			Browser.document.addEventListener('touchstart', function(e:Dynamic) {
				    e.preventDefault();
				    touchInstance.parseTouchObjects(e.touches, TouchState.TouchStateBegan);
			}, false);

			Browser.document.addEventListener('touchend', function(e:Dynamic) {
				    e.preventDefault();
				    touchInstance.parseTouchObjects(e.touches, TouchState.TouchStateEnded);

			}, false);

			Browser.document.addEventListener('touchmove', function(e:Dynamic) {
				    e.preventDefault();
				    touchInstance.parseTouchObjects(e.touches, TouchState.TouchStateMoved);
			}, false);
			
			Browser.document.addEventListener('touchcancel', function(e:Dynamic) {
				    e.preventDefault();
				    touchInstance.parseTouchObjects(e.touches, TouchState.TouchStateCancelled);
				    
			}, false);
		
		});

		finishedCallback();
	}
	private function parseTouchObjects(touches:Array<Dynamic>, state:TouchState) : Void
	{
        if (touches.length > touchesToSend.length)
        {
            for (i in touchesToSend.length...touches.length)
            {
                touchesToSend.push(touchPool.get());
            }
        }
        else if (touches.length < touchesToSend.length)
        {
        	var unusedObjectsCount = touchesToSend.length - touches.length;
            var unusedObjects = touchesToSend.splice(touches.length, unusedObjectsCount);

            for(o in unusedObjects) touchPool.put(o);
        }

        for(i in 0...touches.length)
        {
            setupWithNativeTouch(touchesToSend[i], touches[i], state);
        }
		touchInstance.onTouches.dispatch(touchInstance.touchesToSend);

	}
	private function setupWithNativeTouch(touch : Touch, nativeTouchDynamic : Dynamic, state:TouchState):Void
	{
	    touch.x = nativeTouchDynamic.clientX;
	    touch.y = nativeTouchDynamic.clientY;
	    touch.id = nativeTouchDynamic.identifier;
	    touch.state = state;
	}
}