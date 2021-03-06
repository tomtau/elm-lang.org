
import Touch
import Window

main : Signal Element
main =
    lift2 scene Window.dimensions Touch.taps

scene : (Int,Int) -> { x:Int, y:Int } -> Element
scene (w,h) {x,y} =
    let positioned = move (toFloat x - toFloat w/2, toFloat h/2 - toFloat y) 
        taps = collage w h [ positioned (filled purple (circle 40)) ]
    in
        layers [ taps, message ]

message = [markdown|

<a href="/examples/Reactive/Taps.elm" target="_top">Try it fullscreen</a>
if you are on iOS or Android.

|]

