module Mario exposing (..)

import Keys exposing (Keys)
import Time exposing (Time)
import Data.Level exposing (Tile)
import Sprites exposing (Direction(..), Action(..))
import Sprites exposing (CharacterSprites, drawCharacter)
import Svg exposing (Svg)
import Messages exposing (Msg)
import Viewport exposing (Viewport)


type alias Mario =
    { x : Float
    , y : Float
    , oldX : Float
    , oldY : Float
    , direction : Direction
    , action : Action
    , actionDuration : Float
    , horizontalVelocity : Float
    , verticalVelocity : Float
    , jumpDistance : Float
    , justJumped : Bool
    }


create : Mario
create =
    { x = 0
    , y = 0
    , oldX = 0
    , oldY = 0
    , direction = Left
    , action = Falling
    , actionDuration = 0
    , horizontalVelocity = 0
    , verticalVelocity = 0
    , jumpDistance = 0
    , justJumped = False
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
        |> checkCollisions solidTiles
        |> applyJumpLimit
        |> changeAction dt


changeAction : Time -> Mario -> Mario
changeAction dt mario =
    let
        ( action, duration ) =
            if mario.verticalVelocity > 0 then
                ( Jumping, 0 )
            else if mario.verticalVelocity < 0 then
                ( Falling, 0 )
            else if mario.horizontalVelocity > 0 then
                case mario.action of
                    Walking ->
                        ( mario.action, mario.actionDuration + dt )

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
    case solidTiles of
        [] ->
            mario

        tile :: other ->
            checkCollisions other (checkCollision tile mario)


boundedBox : Float -> Float -> ( Float, Float, Float, Float )
boundedBox x y =
    let
        ceilX =
            x

        ceilY =
            y
    in
        ( ceilY, ceilX + 15, ceilY + 15, ceilX )


checkCollision : Tile -> Mario -> Mario
checkCollision tile mario =
    let
        ( top, right, bottom, left ) =
            boundedBox mario.x mario.y

        ( tileTop, tileRight, tileBottom, tileLeft ) =
            boundedBox tile.x tile.y

        hasCollided =
            not
                ((bottom + 1 < tileTop)
                    || (top - 1 > tileBottom)
                    || (left > tileRight)
                    || (right < tileLeft)
                )
    in
        if hasCollided then
            applyCollision tile mario
        else
            mario


applyCollision : Tile -> Mario -> Mario
applyCollision tile mario =
    let
        ( top, right, bottom, left ) =
            boundedBox mario.x mario.y

        ( oldTop, oldRight, oldBottom, oldLeft ) =
            boundedBox mario.oldX mario.oldY

        ( tileTop, tileRight, tileBottom, tileLeft ) =
            boundedBox tile.x tile.y

        fromLeft =
            (oldRight <= tileLeft) && (right >= tileLeft)

        fromRight =
            oldLeft > tileRight

        fromTop =
            oldBottom < tileTop

        fromBottom =
            oldTop > tileBottom

        updatedMario =
            if fromTop then
                { mario | verticalVelocity = 0, y = tileTop - 16, oldY = mario.y, jumpDistance = 0 }
            else if fromLeft then
                { mario | horizontalVelocity = 0, x = tileLeft - 16 }
            else if fromRight then
                { mario | horizontalVelocity = 0, x = tileRight + 1 }
            else if fromBottom then
                { mario | verticalVelocity = -1, y = tileBottom + 1, jumpDistance = 0 }
            else
                mario
    in
        updatedMario


updateHorizontalPosition : Time -> Mario -> Mario
updateHorizontalPosition dt mario =
    let
        horizontalMovementAmount =
            mario.horizontalVelocity * dt

        oldX =
            mario.x

        x =
            applyHorizontalMovement mario.direction mario.x horizontalMovementAmount
    in
        { mario
            | x = x
            , oldX = oldX
        }


updateVerticalPosition : Time -> Mario -> Mario
updateVerticalPosition dt mario =
    let
        verticalMovementAmount =
            mario.verticalVelocity * dt

        oldY =
            mario.y

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
    in
        { mario
            | y = y
            , oldY = oldY
            , jumpDistance = jumpDistance
        }


updatePosition : Time -> Mario -> Mario
updatePosition dt mario =
    mario
        |> updateHorizontalPosition dt
        |> updateVerticalPosition dt


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


isWalkingPastTheMiddleOfTheLevel : Mario -> Float -> Bool
isWalkingPastTheMiddleOfTheLevel mario offset =
    (mario.x - offset) > 100


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

        onTheGround =
            not (List.member mario.action [ Jumping, Falling ])

        justJumped =
            if onTheGround && not keys.jumpPressed then
                False
            else
                True

        updatedMario =
            { mario | justJumped = justJumped }
    in
        if keys.jumpPressed && (mario.action == Jumping || not mario.justJumped) then
            updatedMario |> updateVerticalVelocity newVelocity
        else
            updatedMario


changeDirection : Direction -> Mario -> Mario
changeDirection direction mario =
    { mario | direction = direction }


updateHorizontalVelocity : Float -> Mario -> Mario
updateHorizontalVelocity velocity mario =
    { mario | horizontalVelocity = velocity }


updateVerticalVelocity : Float -> Mario -> Mario
updateVerticalVelocity velocity mario =
    { mario | verticalVelocity = velocity }


draw : Mario -> Viewport -> CharacterSprites -> Svg Msg
draw mario viewport characterSprites =
    let
        xPos =
            round mario.x

        yPos =
            round mario.y

        offset =
            round viewport.x
    in
        drawCharacter xPos yPos offset "mario" mario.action mario.actionDuration mario.direction characterSprites
