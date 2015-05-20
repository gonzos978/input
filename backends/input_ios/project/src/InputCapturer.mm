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

#import <input_ios/InputCapturer.h>

#import <input_ios/DUELLGestureRecognizer.h>

@implementation InputCapturer

+ (void) initializeCapturer
{
	if ([UIApplication sharedApplication].keyWindow == nil)
	{
		@throw(@"Error: There is currently no window associated with this application. \
			    Please initialize a library (e.g. opengl) that initializes a window, so the input library can attach to that.");
	}

	if ([UIApplication sharedApplication].keyWindow.rootViewController == nil)
	{
		@throw(@"Error: There is currently no root view controller associated with the key window. \
			    Please initialize a library (e.g. opengl) that initializes a window, so the input library can attach to that.");
	}

	UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;

	DUELLGestureRecognizer *recognizer = [[DUELLGestureRecognizer alloc] initWithTarget:nil action:nil];
    [view addGestureRecognizer:recognizer];

    [recognizer initializeTouchCapturing];
}

@end
