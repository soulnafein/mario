module Mario exposing (..)

import Keys exposing (Keys)
import Time exposing (Time)
import Sprites exposing (CharacterSprites, drawCharacter, Direction(..), Action(..))
import Svg exposing (Svg)
import Messages exposing (Msg)


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
        groundY =
            10 * 16
    in
        if (mario.y) > groundY then
            { mario | verticalVelocity = 0, y = groundY, jumpDistance = 0 }
        else
            mario


updatePosition : Time -> Mario -> Mario
updatePosition dt mario =
    let
        horizontalMovementAmount =
            mario.horizontalVelocity * dt

        x =
            applyHorizontalMovement mario.direction mario.x horizontalMovementAmount
                |> applyMidScreenWall

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


applyHorizontalMovement : Direction -> Float -> Float -> Float
applyHorizontalMovement direction x horizontalMovementAmount =
    case direction of
        Left ->
            x - horizontalMovementAmount

        Right ->
            x + horizontalMovementAmount


applyMidScreenWall : Float -> Float
applyMidScreenWall x =
    let
        midScreenX =
            100
    in
        if x > midScreenX then
            midScreenX
        else
            x


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


isWalkingPastTheMiddleOfTheLevel : Mario -> Bool
isWalkingPastTheMiddleOfTheLevel mario =
    mario.x == 100


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


draw : Mario -> CharacterSprites -> Svg Msg
draw mario characterSprites =
    let
        xPos =
            round mario.x

        yPos =
            round mario.y
    in
        drawCharacter xPos yPos "mario" mario.action mario.actionDuration mario.direction characterSprites
