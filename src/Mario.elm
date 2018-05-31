module Mario exposing (..)

import Keys exposing (Keys)
import Time exposing (Time)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg
import Messages exposing (Msg)
import Array exposing (Array)
import Sprites exposing (SpritesData, findFrames, Direction(..), Action(..))


type alias Mario =
    { x : Float
    , y : Float
    , direction : Direction
    , action : Action
    , actionDuration : Float
    , horizontalVelocity : Float
    , verticalVelocity : Float
    , jumpDistance : Float
    }


create : Mario
create =
    { x = 0
    , y = 0
    , direction = Left
    , action = Standing
    , actionDuration = 0
    , horizontalVelocity = 0
    , verticalVelocity = 0
    , jumpDistance = 0
    }


jumpSpeed : Float
jumpSpeed =
    350


gravity : Float
gravity =
    1000


jumpLimit : Float
jumpLimit =
    64


walkingSpeed : Float
walkingSpeed =
    100


friction : Float
friction =
    300


move : Time -> Keys -> Mario -> Mario
move dt keys mario =
    mario
        |> applyLeftMovement dt keys
        |> applyRightMovement dt keys
        |> applyJump dt keys
        |> applyFriction dt
        |> applyGravity dt
        |> updatePosition dt
        |> applyJumpLimit
        |> checkCollisions
        |> changeAction


changeAction : Mario -> Mario
changeAction mario =
    let
        ( action, duration ) =
            if mario.jumpDistance > 0 && mario.verticalVelocity > 0 then
                ( Jumping, 0 )
            else if mario.jumpDistance > 0 && mario.verticalVelocity <= 0 then
                ( Falling, 0 )
            else if mario.horizontalVelocity > 0 then
                case mario.action of
                    Walking ->
                        ( mario.action, mario.actionDuration )

                    _ ->
                        ( Walking, 0 )
            else
                ( Standing, 0 )
    in
        { mario | action = action, actionDuration = duration }


applyFriction : Time -> Mario -> Mario
applyFriction dt mario =
    let
        horizontalVelocity =
            if mario.horizontalVelocity <= 0 then
                0
            else
                mario.horizontalVelocity - (friction * dt)
    in
        { mario | horizontalVelocity = horizontalVelocity }


applyJumpLimit : Mario -> Mario
applyJumpLimit mario =
    if mario.jumpDistance > jumpLimit then
        { mario | verticalVelocity = 0 }
    else
        mario


applyGravity : Time -> Mario -> Mario
applyGravity dt mario =
    { mario | verticalVelocity = mario.verticalVelocity - (gravity * dt) }


checkCollisions : Mario -> Mario
checkCollisions mario =
    let
        windowHeight =
            208
    in
        if (mario.y + 16) > windowHeight then
            { mario | verticalVelocity = 0, y = windowHeight - 16, jumpDistance = 0 }
        else
            mario


updatePosition : Time -> Mario -> Mario
updatePosition dt mario =
    let
        horizontalMovementAmount =
            mario.horizontalVelocity * dt

        x =
            case mario.direction of
                Left ->
                    mario.x - horizontalMovementAmount

                Right ->
                    mario.x + horizontalMovementAmount

        verticalMovementAmount =
            mario.verticalVelocity * dt

        y =
            mario.y - verticalMovementAmount

        jumpDistance =
            mario.jumpDistance + verticalMovementAmount

        ( action, duration ) =
            case mario.action of
                Walking ->
                    ( Walking, (mario.actionDuration + dt) )

                _ ->
                    ( mario.action, mario.actionDuration )
    in
        { mario | x = x, y = y, jumpDistance = jumpDistance, action = action, actionDuration = duration }


applyLeftMovement : Time -> Keys -> Mario -> Mario
applyLeftMovement dt keys mario =
    if keys.leftPressed then
        mario
            |> updateHorizontalVelocity walkingSpeed
            |> changeDirection Left
    else
        mario


applyRightMovement : Time -> Keys -> Mario -> Mario
applyRightMovement dt keys mario =
    if keys.rightPressed then
        mario
            |> updateHorizontalVelocity walkingSpeed
            |> changeDirection Right
    else
        mario


applyJump : Time -> Keys -> Mario -> Mario
applyJump dt keys mario =
    let
        velocity =
            mario.verticalVelocity

        newVelocity =
            (1 / logBase 5 (mario.jumpDistance + 2)) * jumpSpeed

        isNotFalling =
            case mario.action of
                Falling ->
                    False

                _ ->
                    True
    in
        if keys.jumpPressed && isNotFalling then
            mario |> updateVerticalVelocity newVelocity
        else
            mario


changeDirection : Direction -> Mario -> Mario
changeDirection direction mario =
    { mario | direction = direction }


updateHorizontalVelocity : Float -> Mario -> Mario
updateHorizontalVelocity velocity mario =
    { mario | horizontalVelocity = velocity }


updateVerticalVelocity : Float -> Mario -> Mario
updateVerticalVelocity velocity mario =
    { mario | verticalVelocity = velocity }


draw : Mario -> SpritesData -> Svg Msg
draw mario spritesData =
    let
        standingAnimation =
            0

        jumpingAnimation =
            1

        walkingAnimation =
            2

        spriteWidth =
            16

        spriteHeight =
            16

        xPos =
            round mario.x

        yPos =
            round mario.y

        spriteViewbox =
            findFrames "mario" mario.action mario.actionDuration mario.direction spritesData
    in
        drawSprite xPos yPos spriteWidth spriteHeight spriteViewbox spritesData.imageUrl


px : Int -> String
px n =
    (toString n) ++ "px"


drawSprite : Int -> Int -> Int -> Int -> String -> String -> Svg Msg
drawSprite xPos yPos spriteWidth spriteHeight spriteViewbox path =
    svg [ x (px xPos), y (px yPos), width (px spriteWidth), height (px spriteHeight), viewBox spriteViewbox ]
        [ image [ imageRendering "pixelated", xlinkHref path ] []
        ]


getFramePosition : Array String -> Int -> String
getFramePosition animation frameNumber =
    Array.get frameNumber animation |> Maybe.withDefault ""
