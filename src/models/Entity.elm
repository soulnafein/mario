module Models.Entity exposing (..)


type alias Entity =
    { x : Float
    , y : Float
    , direction : Direction
    , horizontalVelocity : Float
    }


type Direction
    = Left
    | Right
