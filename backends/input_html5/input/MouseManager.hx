/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package input;

import types.Vector2;
import js.JQuery;
import js.Browser;
import js.html.Element;

import input.Mouse;
import input.MouseButtonEventData;

import html5_appdelegate.HTML5AppDelegate;

@:access(input.Mouse)
class MouseManager
{
    private static inline var MAX_CLICK_MOVE_DISTANCE: Int = 10;
	private static var mouseInstance : MouseManager;

	private var mainMouse : Mouse;
	private var mouses : Map<String, Mouse>;
	private var mouseButtonEventData: MouseButtonEventData;
	private var mouseMovementEventData: MouseMovementEventData;
	private var jquery : JQuery;
	private var canvas : JQuery;

	private function new()
	{
		mainMouse = new Mouse();
		mouses = new Map();
		jquery = new JQuery(Browser.window);
		canvas = new JQuery(HTML5AppDelegate.instance().rootView);

		mouseButtonEventData = new MouseButtonEventData();
		mouseMovementEventData = new MouseMovementEventData();

        mainMouse.onCursorChange.add(updateHandCursor);
        mainMouse.inside = false;
        updateHandCursor(mainMouse);
	}

	public function getMainMouse() : Mouse
	{
		return mainMouse;
	}

	public function getMouse(mouseIdentifier : String) : Mouse
	{
		return mouses[mouseIdentifier];
	}

	public function getMouses() : Iterator<String>
	{
		return mouses.keys();
	}

	public static inline function instance() : MouseManager
	{
		return mouseInstance;
	}

	public static function initialize(finishedCallback : Void -> Void) : Void
	{
		mouseInstance = new MouseManager();

		mouseInstance.attachToNative(finishedCallback);
	}

	private function attachToNative(finishedCallback : Void -> Void)
	{
        var buttonDownCoordinates: Map<MouseButton, Vector2> = new Map<MouseButton, Vector2>();
        var anyButtonDown: Bool = false;
        var validButtonClick: Bool = false;
        var lastButtonUpCoordinates: Vector2 = null;

        jquery.ready(function(e):Void
        {
            jquery.mousedown(function(e:Dynamic)
            {
                var button: MouseButton = getButton(e.button);
                if (button != null && e.toElement == canvas.context)
                {
                    anyButtonDown = true;

                    var coordinates: Vector2 = new Vector2();
                    coordinates.setXY(e.pageX - canvas.offset().left, e.pageY - canvas.offset().top);
                    buttonDownCoordinates[button] = coordinates;

                    mouseButtonEventData.button = button;
                    mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDown;
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateDown;
                    mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                }
            });

            jquery.mousemove(function(e) : Void
            {
                if (anyButtonDown || mainMouse.inside)
                {
                    var calculatedScreenPositionX: Int = e.pageX - canvas.offset().left;
                    var calculatedScreenPositionY: Int = e.pageY - canvas.offset().top;
                    mouseMovementEventData.deltaX = calculatedScreenPositionX - mainMouse.screenPosition.x;
                    mouseMovementEventData.deltaY = calculatedScreenPositionY - mainMouse.screenPosition.y;
                    mainMouse.screenPosition.x = calculatedScreenPositionX;
                    mainMouse.screenPosition.y = calculatedScreenPositionY;
                    mainMouse.onMovementEvent.dispatch(mouseMovementEventData);
                }
            });

            jquery.mouseup(function(e:Dynamic)
            {
                var button: MouseButton = getButton(e.button);
                if (button != null && buttonDownCoordinates[button] != null)
                {
                    mouseButtonEventData.button = button;
                    mouseButtonEventData.newState = MouseButtonState.MouseButtonStateUp;
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateUp;
                    mainMouse.onButtonEvent.dispatch(mouseButtonEventData);

                    lastButtonUpCoordinates = buttonDownCoordinates[button];
                    buttonDownCoordinates.remove(button);
                    anyButtonDown = buttonDownCoordinates.keys().hasNext();
                }
                else
                {
                    lastButtonUpCoordinates = null;
                }
            });

			jquery.click(function(e:Dynamic)
			{
                var button: MouseButton = getButton(e.button);

                validButtonClick = button != null &&
                        mainMouse.inside &&
                        lastButtonUpCoordinates != null &&
                        Vector2.distance(lastButtonUpCoordinates, mainMouse.screenPosition) <= MAX_CLICK_MOVE_DISTANCE;

                if (validButtonClick)
                {
                    mouseButtonEventData.button = button;
                    mouseButtonEventData.newState = MouseButtonState.MouseButtonStateClick;
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateClick;
                    mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateUp;
                }
			});

            jquery.dblclick(function(e:Dynamic)
            {
                var button: MouseButton = getButton(e.button);
                if (validButtonClick && button != null)
                {
                    mouseButtonEventData.button = button;
                    mouseButtonEventData.newState = MouseButtonState.MouseButtonStateDoubleClick;
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateDoubleClick;
                    mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                    mainMouse.state[button] = MouseButtonState.MouseButtonStateUp;
                }
            });

            jquery.mouseenter(function(e:Dynamic)
            {
                if (canvas.context == e.toElement && !mainMouse.inside)
                {
                    mainMouse.inside = true;

                    var calculatedScreenPositionX: Int = Std.int(e.pageX) - canvas.offset().left;
                    var calculatedScreenPositionY: Int = Std.int(e.pageY) - canvas.offset().top;
                    mouseMovementEventData.deltaX = calculatedScreenPositionX - mainMouse.screenPosition.x;
                    mouseMovementEventData.deltaY = calculatedScreenPositionY - mainMouse.screenPosition.y;
                    mainMouse.screenPosition.x = calculatedScreenPositionX;
                    mainMouse.screenPosition.y = calculatedScreenPositionY;
                    mainMouse.onMovementEvent.dispatch(mouseMovementEventData);
                }
            });

            jquery.mouseleave(function(e:Dynamic)
            {
                if (canvas.context == e.fromElement && mainMouse.inside)
                {
                    mainMouse.inside = false;
                    mainMouse.onMovementEvent.dispatch(mouseMovementEventData);
                }
            });

            var mouseWheelHandler : Dynamic -> Void = function (e: Dynamic): Void
            {
                if (mainMouse.inside)
                {
                    // Prevents the page scrolling while mouse pointer is inside of the scene
                    e.preventDefault();

                    var wheelDelta: Float = 0.0;

                    if(untyped Browser.window.event)
                    {
                        untyped e = Browser.window.event;
                    }

                    if(untyped e.wheelDelta)
                    {
                        wheelDelta = e.wheelDelta / 120.0;
                    }
                    else
                    {
                        wheelDelta = -e.detail / 3.0;
                    }
                    mouseButtonEventData.button = MouseButton.MouseButtonWheel(wheelDelta);
                    mouseButtonEventData.newState = MouseButtonState.MouseButtonStateNone;
                    mainMouse.onButtonEvent.dispatch(mouseButtonEventData);
                }
            };


            /// Mousewheel Events
            if (untyped Browser.window.addEventListener)
            {
                // IE9, Chrome, Safari, Opera
                untyped Browser.window.addEventListener("mousewheel", mouseWheelHandler, false);
                // Firefox
                untyped Browser.window.addEventListener("DOMMouseScroll", mouseWheelHandler, false);
            }
            else
            {	// IE 6/7/8
                untyped Browser.window.attachEvent("onmousewheel", mouseWheelHandler);
            }

            finishedCallback();
		});
	}

    private function getButton(id: Int): MouseButton
    {
        switch (id)
        {
            case 0:
                return MouseButton.MouseButtonLeft;
            case 1:
                return MouseButton.MouseButtonMiddle;
            default:
                // The rest of the buttons are not tracked in HTML5
                return null;
        }
    }

    private function updateHandCursor(mouse: Mouse): Void
    {
        canvas.context.style.cursor = mouse.usePointerCursor ? 'pointer' : 'auto';
    }
}
