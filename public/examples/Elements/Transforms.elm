
hexagon : Color -> Form
hexagon clr = outlined (solid clr) (ngon 6 40)

main : Element
main =
    collage 300 300
        [ hexagon red
        , scale 2 (hexagon purple)
        , move (100,0) (hexagon green)
        , rotate (degrees 30) (hexagon blue)
        ]