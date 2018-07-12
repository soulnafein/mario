module Entities.Mario exposing (..)

import Keys exposing (Keys)
import Time exposing (Time)
import Entity exposing (Entity, EntityType(Mario), Direction(..), Action(..))
import Physics.CollisionType exposing (CollisionType(..))
import Tile exposing (Tile)


create : Entity
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
    , type_ = Mario
    }


jumpSpeed : Float
jumpSpeed =
    350


jumpLimit : Float
jumpLimit =
    64


walkingSpeed : Float
walkingSpeed =
    100


update : Time -> Keys -> Entity -> Entity
update dt keys mario =
    mario
        |> applyJumpLimit
        |> changeAction dt
        |> applyLeftMovement dt keys
        |> applyRightMovement dt keys
        |> applyJump dt keys


boundedBox : Float -> Float -> ( Float, Float, Float, Float )
boundedBox x y =
    let
        ceilX =
            toFloat (ceiling x)

        ceilY =
            toFloat (ceiling y)
    in
        ( ceilY, ceilX + 15, ceilY + 15, ceilX )


resolveCollision : CollisionType -> Tile -> Entity -> Entity
resolveCollision collisionType tile entity =
    let
        ( tileTop, tileRight, tileBottom, tileLeft ) =
            boundedBox tile.x tile.y
    in
        case collisionType of
            FromTop ->
                { entity | verticalVelocity = 0, y = tileTop - 16, oldY = tileTop - 16, jumpDistance = 0 }

            FromBottom ->
                { entity | verticalVelocity = -1, y = tileBottom + 1, jumpDistance = 0 }

            FromLeft ->
                { entity | horizontalVelocity = 0, x = tileLeft - 16 }

            FromRight ->
                { entity | horizontalVelocity = 0, x = tileRight + 1 }


changeAction : Time -> Entity -> Entity
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


applyJumpLimit : Entity -> Entity
applyJumpLimit mario =
    if mario.jumpDistance > jumpLimit then
        { mario | verticalVelocity = -1 }
    else
        mario


applyLeftMovement : Time -> Keys -> Entity -> Entity
applyLeftMovement dt keys mario =
    if keys.leftPressed then
        mario
            |> updateHorizontalVelocity walkingSpeed
            |> changeDirection Left
    else
        mario


applyRightMovement : Time -> Keys -> Entity -> Entity
applyRightMovement dt keys mario =
    if keys.rightPressed then
        mario
            |> updateHorizontalVelocity walkingSpeed
            |> changeDirection Right
    else
        mario


applyJump : Time -> Keys -> Entity -> Entity
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


changeDirection : Direction -> Entity -> Entity
changeDirection direction mario =
    { mario | direction = direction }


updateHorizontalVelocity : Float -> Entity -> Entity
updateHorizontalVelocity velocity mario =
    { mario | horizontalVelocity = velocity }


updateVerticalVelocity : Float -> Entity -> Entity
updateVerticalVelocity velocity mario =
    { mario | verticalVelocity = velocity }
