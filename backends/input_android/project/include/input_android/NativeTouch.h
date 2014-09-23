#ifndef __INPUT_ANDROID_NATIVE_TOUCH__
#define __INPUT_ANDROID_NATIVE_TOUCH__

#include <hx/CFFI.h>

namespace input_android
{

DECLARE_KIND(k_NativeTouch) 


class NativeTouch
{
	public: 
		int x;
		int y;
		int id;
		int state; ///0 began, 1 moved, 2 stationary, 3 ended, 4 cancelled

	static value createHaxePointer();
};

}

#endif //__INPUT_ANDROID_NATIVE_TOUCH__