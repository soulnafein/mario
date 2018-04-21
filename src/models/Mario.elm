module Models.Mario exposing (move, draw, create)

import Models.Entity exposing (Entity, Direction(..))
import Time exposing (Time)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg
import Messages exposing (Msg)


create : Entity
create =
    { x = 320, y = 200, direction = Left, horizontalVelocity = 0 }


move : Time -> String -> Entity -> Entity
move dt keyPressed mario =
    applyVelocity keyPressed mario
        |> applyFriction dt
        |> updatePosition dt


applyFriction : Time -> Entity -> Entity
applyFriction dt mario =
    let
        horizontalVelocity =
            if mario.horizontalVelocity <= 0 then
                0
            else
                mario.horizontalVelocity - (30 * (dt / 100))
    in
        { mario | horizontalVelocity = horizontalVelocity }


updatePosition : Time -> Entity -> Entity
updatePosition dt mario =
    let
        movementAmount =
            mario.horizontalVelocity * (dt / 1000)

        x =
            case mario.direction of
                Left ->
                    mario.x - movementAmount

                Right ->
                    mario.x + movementAmount
    in
        { mario | x = x }


applyVelocity : String -> Entity -> Entity
applyVelocity keyPressed mario =
    let
        leftArrow =
            "37"

        rightArrow =
            "39"
    in
        if keyPressed == leftArrow then
            { mario | horizontalVelocity = 100, direction = Left }
        else if keyPressed == rightArrow then
            { mario | horizontalVelocity = 100, direction = Right }
        else
            mario


draw : Entity -> String -> Svg Msg
draw mario spritesPath =
    let
        spriteWidth =
            16

        spriteHeight =
            16

        marioLeftSprite =
            "222 44 16 16"

        marioRightSprite =
            "275 44 16 16"

        spritePosition =
            case mario.direction of
                Left ->
                    marioLeftSprite

                Right ->
                    marioRightSprite
    in
        svg [ x (toString mario.x), y (toString mario.y), width "16px", height "16px", viewBox spritePosition, version "1.1" ]
            [ image [ x "0px", y "0px", width "513px", height "401px", xlinkHref spritesPath ] []
            ]
