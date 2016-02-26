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

package input.util;

import js.html.KeyboardEvent;
import input.KeyDefine;

extern class KeyUtils
{
    static public function getKeyDefine(keyCode: Int): KeyDefine
    {
        return switch (keyCode)
        {
            case KeyboardEvent.DOM_VK_BACK_SPACE: KeyDefine.Backspace;
            case KeyboardEvent.DOM_VK_DELETE: KeyDefine.Delete;
            case KeyboardEvent.DOM_VK_RETURN: KeyDefine.Return;
            case KeyboardEvent.DOM_VK_LEFT: KeyDefine.ArrowLeft;
            case KeyboardEvent.DOM_VK_RIGHT: KeyDefine.ArrowRight;
            case KeyboardEvent.DOM_VK_UP: KeyDefine.ArrowUp;
            case KeyboardEvent.DOM_VK_DOWN: KeyDefine.ArrowDown;
            default: null; // Undefined keyCode
        }
    }
}