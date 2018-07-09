module Goomba exposing (..)

import Time exposing (Time)
import Entities exposing (Entity, EntityType(Goomba), Direction(..), Action(..))


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
        |> updateHorizontalVelocity walkingSpeed
        |> changeDirection Left


changeDirection : Direction -> Entity -> Entity
changeDirection direction goomba =
    { goomba | direction = direction }


updateHorizontalVelocity : Float -> Entity -> Entity
updateHorizontalVelocity velocity goomba =
    { goomba | horizontalVelocity = velocity }


updateVerticalVelocity : Float -> Entity -> Entity
updateVerticalVelocity velocity goomba =
    { goomba | verticalVelocity = velocity }
