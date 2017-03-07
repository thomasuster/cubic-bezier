# cubic-bezier

CSS style cubic easing for haxe. A port of https://github.com/gre/bezier-easing

[![](https://raw.githubusercontent.com/thomasuster/cubic-bezier/master/img/example360.png)
](http://gre.github.io/bezier-easing-editor/example/)

### Getting Started

1.  
    ```git clone git@github.com:thomasuster/cubic-bezier.git```
1.  
    ```haxelib dev cubic-bezier cubic-bezier```
1. Use the visual editor to find the 4 ease values you want
	http://greweb.me/bezier-easing-editor/example/

1. Plug them in!
```haxe
var cb:CubicBezier = new CubicBezier(0.00, 0.55, 1.00, 0.11); //The 4 values

//Do something with your ease function! 
var time:Float = 0.2;
var percentage:Float = cb.ease(time);
trace(percentage);
```