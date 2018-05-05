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
    , walkingDistance : Float
    }


create : Mario
create =
    { x = 0
    , y = 0
    , direction = Left
    , action = Standing
    , horizontalVelocity = 0
    , verticalVelocity = 0
    , jumpDistance = 0
    , walkingDistance = 0
    }


type Action
    = Jumping
    | Standing
    | Falling
    | Walking


type Direction
    = Left
    | Right


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
        action =
            if mario.jumpDistance > 0 && mario.verticalVelocity > 0 then
                Jumping
            else if mario.jumpDistance > 0 && mario.verticalVelocity <= 0 then
                Falling
            else if mario.horizontalVelocity > 0 then
                Walking
            else
                Standing
    in
        { mario | action = action }


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

        walkingDistance =
            if mario.action == Walking then
                mario.walkingDistance + horizontalMovementAmount
            else
                0
    in
        { mario | x = x, y = y, jumpDistance = jumpDistance, walkingDistance = walkingDistance }


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


draw : Mario -> String -> Svg Msg
draw mario spritesPath =
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

        leftSprites =
            Array.fromList
                [ Array.fromList [ "222 44 16 16" ]
                , Array.fromList [ "142 44 16 16" ]
                , Array.fromList [ "206 44 16 16", "193 44 16 16", "177 44 16 16" ]
                ]

        rightSprites =
            Array.fromList
                [ Array.fromList [ "275 44 16 16" ]
                , Array.fromList [ "355 44 16 16" ]
                , Array.fromList [ "291 44 16 16", "304 44 16 16", "320 44 16 16" ]
                ]

        xPos =
            round mario.x

        yPos =
            round mario.y

        sprites =
            case mario.direction of
                Left ->
                    leftSprites

                Right ->
                    rightSprites

        spritePosition =
            case mario.action of
                Standing ->
                    getFramePosition sprites standingAnimation 0

                Jumping ->
                    getFramePosition sprites jumpingAnimation 0

                Falling ->
                    getFramePosition sprites jumpingAnimation 0

                Walking ->
                    getFramePosition sprites walkingAnimation ((round (mario.walkingDistance / 20)) % 3)
    in
        g [ (transform ("translate(" ++ toString xPos ++ " " ++ toString yPos ++ ")")) ]
            [ svg [ x "0", y "0", width "16px", height "16px", viewBox spritePosition, version "1.1" ]
                [ image [ imageRendering "pixelated", x "0px", y "0px", width "513px", height "401px", xlinkHref spritesPath ] []
                ]
            ]


getFramePosition : Array (Array String) -> Int -> Int -> String
getFramePosition sprites animationNumber frameNumber =
    let
        animation =
            Array.get animationNumber sprites |> Maybe.withDefault (Array.fromList [])
    in
        Array.get frameNumber animation |> Maybe.withDefault ""
