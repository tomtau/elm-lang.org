import Website.Skeleton (skeleton)
import Website.Tiles as Tile
import Window

port title : String
port title = "Elm 0.12.3 - WebGL"

main = skeleton "Blog" everything <~ Window.dimensions

everything wid =
    let w = min 600 wid
    in  flow down
        [ width w intro
        , exampleBlock w
        , width w rest
        ]

exampleBlock w =
    Tile.examples w [ map Tile.webgl [ "Triangle", "Cube", "Thwomp", "FirstPerson" ] ]

intro = [markdown|

<h1><div style="text-align:center">Elm 0.12.3
<div style="padding-top:4px;font-size:0.5em;font-weight:normal">Hardware accelerated 3D rendering with WebGL</div></div>
</h1>

Elm now supports 3D rendering with WebGL! Huge thank you to
[John P. Mayer](https://github.com/johnpmayer/) for designing and implementing
such a simple API for this. It has been really fun to work with so far and we
are excited to see what people can do with it!

This is the first public exploration of using alternate renders with Elm. Our
goal is to be great for all kinds of UI tasks, so 3D is just the first step on
the road to more traditional renderers such as [the D3 backend for
Elm](https://github.com/seliopou/elm-d3). Future exploration will focus on
more traditional kinds of UI, all [super easy to
embed](https://github.com/evancz/elm-html-and-js) as a component in an existing
JS app.

This release also comes with some changes to the `Color` library, making it
easier to create colors programmatically. The initial motivation was to make
`Color` play nice with WebGL, but the library came out a lot friendlier to use
in general.

## Functional 3D Rendering

We of course need to start with an example. As you move your mouse within the
grey box, [Thwomp](http://www.mariowiki.com/Thwomp#Super_Mario_64) will stare
at you. Too far away to crush you, but waiting...

<iframe src="/examples/WebGL/Thwomp.elm"
        frameborder="0"
        width="600"
        height="300"
        style="background-color: #D8DDE1;">
</iframe>

Typically, working with WebGL in JS means wrestling with a huge 90s era C++ API
with a great deal of [incidental
complexity](http://en.wikipedia.org/wiki/Accidental_complexity).
[John](https://github.com/johnpmayer/) has done a great job simplifying and
modernizing this API for Elm, only exposing details that are truly essential
to 3D rendering and efficient use of the GPU.
He has released the API as [`elm-webgl`][webgl] for 3D rendering and
[`elm-linear-algebra`][algebra] for working with vectors and matrices.

 [webgl]: http://library.elm-lang.org/catalog/johnpmayer-elm-webgl/latest/
 [algebra]: http://library.elm-lang.org/catalog/johnpmayer-elm-linear-algebra/latest/

The best way to get started is to read about [the architecture of WebGL in
Elm](https://github.com/johnpmayer/elm-webgl/blob/master/README.md) and
then play around with some examples to get a feel for actually using this API:

|]

rest = [markdown|

We can create triangles, build up arbitrary shapes such as cubes, load textures,
write shaders, and efficiently load them all onto the GPU. The immediate next
steps for WebGL are to begin building on this foundation. This could be things
like:

  * Write libraries for extruding 2D shapes into 3D.
  * Find a way to load meshes from 3D modeling programs.
  * Create an EDSL for dynamically creating shaders.
  * Use [Pointer Lock](https://developer.mozilla.org/en-US/docs/WebAPI/Pointer_Lock)
    to do proper first person navigation.
  * Integrate with [the time traveling debugger](http://debug.elm-lang.org/).

There is a lot to explore here! John's API significantly lowers the barrier to
entry, so we hope you [learn more about
it](https://github.com/johnpmayer/elm-webgl/blob/master/README.md) and have fun
working in 3D!

To work with [`elm-webgl`][webgl] and [`elm-linear-algebra`][algebra] locally,
install the new [Elm Platform](/Install.elm), navigate to a fresh directory,
and run:

```bash
elm-get install elm-webgl
elm-get install elm-linear-algebra
```

 [webgl]: http://library.elm-lang.org/catalog/johnpmayer-elm-webgl/latest/
 [algebra]: http://library.elm-lang.org/catalog/johnpmayer-elm-linear-algebra/latest/

## Colors

[The `Color` library](http://library.elm-lang.org/catalog/elm-lang-Elm/latest/Color)
underwent a breaking change by switching from HSV to HSL. If those letters do
not mean anything to you, your code will be fine and you are about to learn
about a very useful color space! HSV and HSL are very closely related, so
upgrading should be easy. The library also got some new functions that make it
possible to generate colors and color schemes programmatically!

#### Switching to HSL

<img src="http://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/HSL_color_solid_cylinder_alpha_lowgamma.png/320px-HSL_color_solid_cylinder_alpha_lowgamma.png"
     style="float:right; padding-left:10px;"
     width="160"
     height="120">

HSL stands for Hue-Saturation-Lightness. Hue determines a particular color on
[the color wheel](http://colorschemedesigner.com/). The saturation level is how
vibrant the color is, like a dial between grey and bright colors. The lightness
level is a dial between white and black. Once you internalize how this system
works, possibly by reading [the wikipedia
article](http://en.wikipedia.org/wiki/HSL_and_HSV) a few times, it is a really
easy way to turn the *idea* of a color into some concrete numbers in code. It
is totally worth the effort to learn to think in HSL!

We switched away from Hue-Saturation-Value (HSV) because Value is a bit more
confusing than Lightness. For example, it is fairly easy to deduce that pastel
colors are light and desaturated. In HSL, you turn down saturation and turn up
lightness. Pretty easy. In HSV, there is not really a dial for lightening
things up, so it is trickier to deduce how to create a pastel color.

#### Algorithmic Colors

The new color library includes two new functions that make it possible to work
with colors programmatically:

```haskell
toRgb : Color -> { red:Int, green:Int, blue:Int, alpha:Float }

toHsl : Color -> { hue        : Float
                 , saturation : Float
                 , lightness  : Float
                 , alpha      : Float
                 }
```

This makes it easy to use Elm's built-in colors in [the cube
example](/edit/examples/WebGL/Cube.elm), but these new functions are much more
general than that!

[The color wheel](http://colorschemedesigner.com/) can be really helpful for
creating color schemes. The relationships between colors could be the foundation
for a library that lets you easily create triads or [analogous
colors](http://en.wikipedia.org/wiki/Analogous_colors). You could also generate
lighter or darker or greener versions of a color, so your programs could be easy
to update when the color scheme changes. You could also create a
[color conversion site](http://rem.im/rgb2hex.html) that actually lets you
convert back-and-forth between color spaces. Easily discoverable sites for this
tend to work only in one direction (hex to RGB) and often are not very pleasant
to look at or use. Please someone fix this!

## Thank you!

Thank you to [Max Goldstein](https://github.com/mgold) who made it possible
for [`Array`](http://library.elm-lang.org/catalog/elm-lang-Elm/latest/Array)
to flow through ports.

Thanks also to [Max New](https://github.com/maxsnew) who has been making a
bunch of contributions, particularly for handling the recent outbreak of cabal
issues with Travis CI. Cabal hell is a very dark place, so thank you! Max also
added the `--get-runtime` flag which tells you the absolute path to Elm's
runtime (along with renaming `--runtime` to `--set-runtime` for consistency).

Finally, thank you again to [John P. Mayer](https://github.com/johnpmayer/) who
designed and implemented the WebGL libraries! The Elm community has been
wondering about this from very early on, and it is great to finally see it in
practice!

|]
