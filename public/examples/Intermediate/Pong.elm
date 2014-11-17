-- See this document for more information on making Pong:
-- http://elm-lang.org/blog/Pong.elm

import Keyboard
import Text
import Window
import Char
import Debug

-- Inputs

restartKey : Int
restartKey = Char.toCode 'r'

pauseKey : Int
pauseKey = Char.toCode 'p'

type Input = { space:Bool, keys: [Keyboard.KeyCode],  dir2:Int, delta:Time }--dir1:Int,

delta = inSeconds <~ fps 35

input = sampleOn delta (Input <~ Keyboard.space
                               ~ Keyboard.keysDown
                               --~ lift .y Keyboard.wasd
                               ~ lift .y Keyboard.arrows
                               ~ delta)


-- Model

(gameWidth,gameHeight) = (600,400)
(halfWidth,halfHeight) = (300,200)

data State = Play | Pause

type Ball = { x:Float, y:Float, vx:Float, vy:Float }
type Player = { x:Float, y:Float, vx:Float, vy:Float, score:Int }
type Game = { state:State, ball1:Ball,ball2:Ball, player1:Player, player2:Player }

player : Float -> Player
player x = { x=x, y=0, vx=0, vy=0, score=0 }

defaultGame : Game
defaultGame =
  { state   = Pause,
    ball1    = { x=0, y=8, vx=200, vy=200 },
    ball2    = { x=0, y=-8, vx=-200, vy=200 },
    player1 = player (20-halfWidth) ,
    player2 = player (halfWidth-20) }

stepObj t ({x,y,vx,vy} as obj) =
    { obj | x <- x + vx*t, y <- y + vy*t }

near k c n = n >= k-c && n <= k+c
within ball paddle = (ball.x |> near paddle.x 8)
                  && (ball.y |> near paddle.y 20)

flipY ball paddle =
  if | not (ball.y |> near paddle.y 15) -> 0 - ball.vy
     | not (paddle.vy == 0) -> (0 - ball.vy)+0.5*paddle.vy
     | otherwise -> ball.vy

stepV ball p1 p2 =
  if | (ball `within` p1) -> (abs ball.vx, flipY ball p1)
     | (ball `within` p2) -> (0 - abs ball.vx, flipY ball p2)
     | (ball.y < 7-halfHeight) -> (ball.vx, abs ball.vy)
     | (ball.y > halfHeight-7) -> (ball.vx, 0 - abs ball.vy)
     | otherwise      -> (ball.vx, ball.vy)

-- stepV vx ball (ball `within` p1) p1 (ball `within` p2) p2
-- stepV vy ball (y < 7-halfHeight || ball `within` p1) p1 (y > halfHeight-7 || ball `within` p2) p2
stepBall : Time -> Ball -> Player -> Player -> Ball
stepBall t ({x,y,vx,vy} as ball) p1 p2 =
  if not (ball.x |> near 0 halfWidth)
  then { ball | x <- 0, y <- 0 }
  else stepObj t { ball | vx <- fst (stepV ball p1 p2), vy <- snd (stepV ball p1 p2) }

stepPlyr : Time -> Int -> Int -> Player -> Player
stepPlyr t dir points player =
  let player1 = stepObj  t { player | vy <- toFloat dir * 200 }
  in  { player1 | y <- clamp (22-halfHeight) (halfHeight-22) player1.y
                , score <- player.score + points }

nearer : Player -> Ball -> Ball -> Ball
nearer player ball1 ball2 = if (ball1.x < ball2.x) then ball1 else ball2

corDir : Player -> Ball -> Int
corDir player ball = if (player.y < ball.y) then 1 else -1

simpleAI : Game -> Int
simpleAI ({state,ball1,ball2,player1,player2} as game) =
  if (state == Play) then let nBall = nearer player1 ball1 ball2 in (corDir player1 nBall) else 0

stepGame : Input -> Game -> Game
stepGame {space,keys,dir2,delta} ({state,ball1,ball2,player1,player2} as game) = if (any ((==)restartKey) keys) then defaultGame else
  let score1 = if (ball1.x > halfWidth || ball2.x > halfWidth) then 1 else 0
      score2 = if (ball1.x < -halfWidth || ball2.x < -halfWidth) then 1 else 0
  in  {game| state   <- if | space            -> Play
                           | (any ((==)pauseKey) keys)             -> Pause
                           --| score1 /= score2 -> Pause
                           | otherwise        -> state
           , ball1    <- if state == Pause then ball1 else
                            stepBall delta ball1 player1 player2
           , ball2    <- if state == Pause then ball2 else
                            stepBall delta ball2 player1 player2
           , player1 <- stepPlyr delta (simpleAI game) score1 player1
           , player2 <- stepPlyr delta dir2 score2 player2 } |> Debug.watch "game"

gameState = foldp stepGame defaultGame input


-- Display

pongGreen = rgb 60 100 60
textGreen = rgb 160 200 160
txt f = toText >> Text.color textGreen >> monospace >> f >> leftAligned
msg = "SPACE to start, 'p' to pause,   'r' to restart, WS and &uarr;&darr; to move"
make obj shape =
    shape |> filled white
          |> move (obj.x,obj.y)

display : (Int,Int) -> Game -> Element
display (w,h) {state,ball1,ball2,player1,player2} =
  let scores : Element
      scores = txt (Text.height 50) (show player1.score ++ "  " ++ show player2.score)
  in container w h middle <| collage gameWidth gameHeight
       [ rect gameWidth gameHeight |> filled pongGreen
       , oval 15 15 |> make ball1
       , oval 15 15 |> make ball2
       , rect 10 40 |> make player1
       , rect 10 40 |> make player2
       , rect 0 gameHeight |> outlined (dashed textGreen)
       , toForm scores |> move (0, gameHeight/2 - 40)
       , toForm (if state == Play then spacer 1 1 else txt identity msg)
           |> move (0, 40 - gameHeight/2)
       ]

main = lift2 display Window.dimensions gameState
