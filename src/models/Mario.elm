module Models.Mario exposing (..)

import Models.Keys exposing (Keys)
import Time exposing (Time)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg
import Messages exposing (Msg)
import Array exposing (Array)


type alias Mario =
    { x : Float
    , y : Float
    , direction : Direction
    , action : Action
    , horizontalVelocity : Float
    , verticalVelocity : Float
    , jumpDistance : Float
    }


create : Mario
create =
    { x = 320
    , y = 200
    , direction = Left
    , action = Standing
    , horizontalVelocity = 0
    , verticalVelocity = 0
    , jumpDistance = 0
    }


type Action
    = Jumping
    | Standing
    | Falling


type Direction
    = Left
    | Right


jumpSpeed =
    200


gravity =
    1000


jumpLimit =
    50


jumpApex =
    jumpLimit * 0.75


walkingSpeed =
    100


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
        { mario | verticalVelocity = 0, action = Falling }
    else
        mario


applyGravity : Time -> Mario -> Mario
applyGravity dt mario =
    { mario | verticalVelocity = mario.verticalVelocity - (gravity * dt) }


checkCollisions : Mario -> Mario
checkCollisions mario =
    if (mario.y + 16) > 320 then
        { mario | verticalVelocity = 0, y = 320 - 16, jumpDistance = 0, action = Standing }
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
    in
        { mario | x = x, y = y, jumpDistance = jumpDistance }


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
    in
        if keys.jumpPressed && not (mario.action == Falling) then
            { mario | action = Jumping }
                |> updateVerticalVelocity newVelocity
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

        leftSprites =
            Array.fromList [ "222 44 16 16", "142 44 16 16" ]

        rightSprites =
            Array.fromList [ "275 44 16 16", "355 44 16 16" ]

        sprites =
            case mario.direction of
                Left ->
                    leftSprites

                Right ->
                    rightSprites

        spritePosition =
            case mario.action of
                Standing ->
                    getFramePosition sprites 0

                Jumping ->
                    getFramePosition sprites 1

                Falling ->
                    getFramePosition sprites 1
    in
        svg [ x (toString (round mario.x)), y (toString (round mario.y)), width "16px", height "16px", viewBox spritePosition, version "1.1" ]
            [ image [ imageRendering "pixelated", x "0px", y "0px", width "513px", height "401px", xlinkHref spritesPath ] []
            ]


getFramePosition : Array String -> Int -> String
getFramePosition sprites frameNumber =
    Array.get frameNumber sprites |> Maybe.withDefault ""
