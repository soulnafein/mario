module Models.Mario exposing (..)

import Time exposing (Time)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg
import Messages exposing (Msg)


type alias Mario =
    { x : Float
    , y : Float
    , direction : Direction
    , horizontalVelocity : Float
    , verticalVelocity : Float
    , leftPressed : Bool
    , rightPressed : Bool
    , jumpPressed : Bool
    }


type Direction
    = Left
    | Right


create : Mario
create =
    { x = 320
    , y = 200
    , direction = Left
    , horizontalVelocity = 0
    , verticalVelocity = 0
    , leftPressed = False
    , rightPressed = False
    , jumpPressed = False
    }


updateLeftPressed : Bool -> Mario -> Mario
updateLeftPressed isPressed mario =
    { mario | leftPressed = isPressed }


updateRightPressed : Bool -> Mario -> Mario
updateRightPressed isPressed mario =
    { mario | rightPressed = isPressed }


updateJumpPressed : Bool -> Mario -> Mario
updateJumpPressed isPressed mario =
    { mario | jumpPressed = isPressed }


move : Time -> String -> Mario -> Mario
move dt keyPressed mario =
    mario
        |> applyLeftMovement dt
        |> applyRightMovement dt
        |> applyJump dt
        |> applyFriction dt
        |> applyGravity dt
        |> updatePosition dt
        |> checkCollisions


applyFriction : Time -> Mario -> Mario
applyFriction dt mario =
    let
        horizontalVelocity =
            if mario.horizontalVelocity <= 0 then
                0
            else
                mario.horizontalVelocity - (300 * dt)
    in
        { mario | horizontalVelocity = horizontalVelocity }


applyGravity : Time -> Mario -> Mario
applyGravity dt mario =
    let
        gravity =
            400
    in
        { mario | verticalVelocity = mario.verticalVelocity - (gravity * dt) }


checkCollisions : Mario -> Mario
checkCollisions mario =
    if (mario.y + 16) > 320 then
        { mario | verticalVelocity = 0, y = 320 - 16 }
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
    in
        { mario | x = x, y = y }


applyLeftMovement : Time -> Mario -> Mario
applyLeftMovement dt mario =
    if mario.leftPressed then
        mario
            |> updateHorizontalVelocity 100
            |> changeDirection Left
    else
        mario


applyRightMovement : Time -> Mario -> Mario
applyRightMovement dt mario =
    if mario.rightPressed then
        mario
            |> updateHorizontalVelocity 100
            |> changeDirection Right
    else
        mario


applyJump : Time -> Mario -> Mario
applyJump dt mario =
    if mario.jumpPressed then
        mario
            |> updateVerticalVelocity 100
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


draw : Mario -> String -> Svg Msg
draw mario spritesPath =
    let
        spriteWidth =
            16

        spriteHeight =
            16

        marioLeftSprite =
            "222 44 16 16"

        marioRightSprite =
            "275 44 16 16"

        spritePosition =
            case mario.direction of
                Left ->
                    marioLeftSprite

                Right ->
                    marioRightSprite
    in
        svg [ x (toString mario.x), y (toString mario.y), width "16px", height "16px", viewBox spritePosition, version "1.1" ]
            [ image [ x "0px", y "0px", width "513px", height "401px", xlinkHref spritesPath ] []
            ]