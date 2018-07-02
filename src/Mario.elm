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
        |> changeAction


changeAction : Mario -> Mario
changeAction mario =
    let
        ( action, duration ) =
            if mario.verticalVelocity > 0 then
                ( Jumping, 0 )
            else if mario.verticalVelocity < 0 then
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
    case solidTiles of
        [] ->
            mario

        tile :: other ->
            checkCollisions other (checkCollision tile mario)


boundedBox : Float -> Float -> ( Float, Float, Float, Float )
boundedBox x y =
    ( y, x + 15, y + 15, x )


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
                { mario | horizontalVelocity = -10, x = tileLeft - 50, oldX = mario.x }
            else if fromRight then
                { mario | horizontalVelocity = 10 }
            else if fromBottom then
                { mario | verticalVelocity = -1, y = tileBottom + 1, jumpDistance = 0 }
            else
                mario
    in
        updatedMario


updatePosition : Time -> Mario -> Mario
updatePosition dt mario =
    let
        horizontalMovementAmount =
            mario.horizontalVelocity * dt

        oldX =
            mario.x

        x =
            applyHorizontalMovement mario.direction mario.x horizontalMovementAmount
                |> applyMidScreenWall

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

        ( action, duration ) =
            case mario.action of
                Walking ->
                    ( Walking, (mario.actionDuration + dt) )

                _ ->
                    ( mario.action, mario.actionDuration )
    in
        { mario
            | x = x
            , y = y
            , oldX = oldX
            , oldY = oldY
            , jumpDistance = jumpDistance
            , action = action
            , actionDuration = duration
        }


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


draw : Mario -> CharacterSprites -> Svg Msg
draw mario characterSprites =
    let
        xPos =
            round mario.x

        yPos =
            round mario.y
    in
        drawCharacter xPos yPos "mario" mario.action mario.actionDuration mario.direction characterSprites
