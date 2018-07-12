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
    , jumpReleased = True
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
                entity
                    |> Entity.updateVerticalVelocity 0
                    |> Entity.updateY (tileTop - 16)
                    |> Entity.updateJumpDistance 0

            FromBottom ->
                entity
                    |> Entity.updateVerticalVelocity -1
                    |> Entity.updateY (tileBottom + 1)
                    |> Entity.updateJumpDistance 0

            FromLeft ->
                entity
                    |> Entity.updateHorizontalVelocity 0
                    |> Entity.updateX (tileLeft - 16)

            FromRight ->
                entity
                    |> Entity.updateHorizontalVelocity 0
                    |> Entity.updateX (tileRight + 1)


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
        mario
            |> Entity.updateAction action
            |> Entity.updateActionDuration duration


applyJumpLimit : Entity -> Entity
applyJumpLimit mario =
    if mario.jumpDistance > jumpLimit then
        mario
            |> Entity.updateVerticalVelocity -1
    else
        mario


applyLeftMovement : Time -> Keys -> Entity -> Entity
applyLeftMovement dt keys mario =
    if keys.leftPressed then
        mario
            |> Entity.updateHorizontalVelocity walkingSpeed
            |> Entity.changeDirection Left
    else
        mario


applyRightMovement : Time -> Keys -> Entity -> Entity
applyRightMovement dt keys mario =
    if keys.rightPressed then
        mario
            |> Entity.updateHorizontalVelocity walkingSpeed
            |> Entity.changeDirection Right
    else
        mario


applyJump : Time -> Keys -> Entity -> Entity
applyJump dt keys mario =
    let
        velocity =
            mario.verticalVelocity

        newVelocity =
            (1 / logBase 5 (mario.jumpDistance + 2)) * jumpSpeed

        onTheGround =
            not (List.member mario.action [ Jumping, Falling ])

        justJumped =
            if onTheGround && not keys.jumpPressed then
                False
            else
                True

        jumpReleased =
            if onTheGround && keys.jumpPressed then
                False
            else if not keys.jumpPressed then
                True
            else
                mario.jumpReleased

        updatedMario =
            { mario | justJumped = justJumped, jumpReleased = jumpReleased }
    in
        if keys.jumpPressed && ((mario.action == Jumping && not jumpReleased) || not mario.justJumped) then
            updatedMario
                |> Entity.updateVerticalVelocity newVelocity
        else
            updatedMario
