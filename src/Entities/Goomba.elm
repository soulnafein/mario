module Entities.Goomba exposing (..)

import Time exposing (Time)
import Entity exposing (Entity, EntityType(Goomba), Direction(..), Action(..))
import Physics.CollisionType exposing (CollisionType(..))
import Tile exposing (Tile)


create : Float -> Float -> Entity
create x y =
    { x = x
    , y = y
    , oldX = 0
    , oldY = 0
    , direction = Left
    , action = Standing
    , actionDuration = 0
    , horizontalVelocity = 0
    , verticalVelocity = 0
    , jumpDistance = 0
    , justJumped = False
    , type_ = Goomba
    }


walkingSpeed : Float
walkingSpeed =
    30


update : Time -> Entity -> Entity
update dt goomba =
    goomba
        |> changeAction dt
        |> move dt


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
                    |> Entity.updateY (tileTop - 16)
                    |> Entity.updateVerticalVelocity 0
                    |> Entity.updateJumpDistance 0

            FromBottom ->
                entity
                    |> Entity.updateY (tileBottom + 1)
                    |> Entity.updateVerticalVelocity -1
                    |> Entity.updateJumpDistance 0

            FromLeft ->
                entity
                    |> Entity.updateX (tileLeft - 16)
                    |> Entity.changeDirection Left

            FromRight ->
                entity
                    |> Entity.updateX (tileRight + 1)
                    |> Entity.changeDirection Right


changeAction : Time -> Entity -> Entity
changeAction dt goomba =
    let
        ( action, duration ) =
            if goomba.verticalVelocity > 0 then
                ( Jumping, 0 )
            else if goomba.verticalVelocity < 0 then
                ( Falling, 0 )
            else if goomba.horizontalVelocity > 0 then
                case goomba.action of
                    Walking ->
                        ( goomba.action, goomba.actionDuration + dt )

                    _ ->
                        ( Walking, 0 )
            else
                ( Standing, 0 )
    in
        { goomba | action = action, actionDuration = duration }


move : Time -> Entity -> Entity
move dt goomba =
    goomba
        |> Entity.updateHorizontalVelocity walkingSpeed
