module Mario exposing (..)

import Keys exposing (Keys)
import Time exposing (Time)
import Sprites exposing (CharacterSprites, drawCharacter, Direction(..), Action(..))
import Svg exposing (Svg)
import Messages exposing (Msg)
import Data.Level exposing (Tile)


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
    , action = Falling
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


update : Time -> Keys -> List Tile -> Mario -> Mario
update dt keys solidTiles mario =
    mario
        |> applyLeftMovement dt keys
        |> applyRightMovement dt keys
        |> applyJump dt keys
        |> applyFriction dt
        |> applyGravity dt
        |> updatePosition dt
        |> applyJumpLimit
        |> checkCollisions solidTiles
        |> changeAction


changeAction : Mario -> Mario
changeAction mario =
    let
        ( action, duration ) =
            if mario.verticalVelocity > 0 then
                ( Jumping, 0 )
            else if mario.verticalVelocity < 0 then
                ( Falling, 0 )
            else if mario.action == Jumping && mario.verticalVelocity == 0 then
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
        { mario | verticalVelocity = -1 }
    else
        mario


applyGravity : Time -> Mario -> Mario
applyGravity dt mario =
    { mario | verticalVelocity = mario.verticalVelocity - (gravity * dt) }


checkCollisions : List Tile -> Mario -> Mario
checkCollisions solidTiles mario =
    checkVerticalCollisions solidTiles mario


checkVerticalCollisions : List Tile -> Mario -> Mario
checkVerticalCollisions solidTiles mario =
    let
        marioX1 =
            mario.x

        marioX2 =
            marioX1 + 15

        marioY1 =
            mario.y

        marioY2 =
            marioY1 + 15

        tileMarioIsStandingOn =
            solidTiles
                |> List.filter
                    (\tile ->
                        let
                            tileX1 =
                                tile.x

                            tileX2 =
                                tileX1 + 15

                            tileY1 =
                                tile.y

                            tileY2 =
                                tileY1 + 15
                        in
                            (marioX1 <= tileX2)
                                && (marioX2 >= tileX1)
                                && (marioY2 >= tileY1)
                                && (marioY2 < tileY2)
                    )
                |> List.sortBy .y
                |> List.head
    in
        case tileMarioIsStandingOn of
            Nothing ->
                mario

            Just tile ->
                { mario | verticalVelocity = 0, y = (toFloat tile.y) - 15, jumpDistance = 0 }


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
            case mario.action of
                Jumping ->
                    mario.jumpDistance + verticalMovementAmount

                Falling ->
                    mario.jumpDistance + verticalMovementAmount

                _ ->
                    mario.jumpDistance

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
