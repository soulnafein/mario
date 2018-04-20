module Models.Entity exposing (..)


type alias Entity =
    { x : Float
    , y : Float
    , direction : Direction
    }


type Direction
    = Left
    | Right
