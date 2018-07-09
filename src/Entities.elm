module Entities exposing (Entity, EntityType(..), Action(..), Direction(..))


type alias Entity =
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
    , type_ : EntityType
    }


type EntityType
    = Mario
    | Goomba


type Action
    = Jumping
    | Standing
    | Falling
    | Walking


type Direction
    = Left
    | Right
