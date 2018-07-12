module Entity
    exposing
        ( Entity
        , EntityType(..)
        , Action(..)
        , Direction(..)
        , changeDirection
        , updateHorizontalVelocity
        , updateVerticalVelocity
        , updateJumpDistance
        , updateX
        , updateY
        , updateAction
        , updateActionDuration
        )

import Time exposing (Time)


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
    , jumpReleased : Bool
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


changeDirection : Direction -> Entity -> Entity
changeDirection direction entity =
    { entity | direction = direction }


updateHorizontalVelocity : Float -> Entity -> Entity
updateHorizontalVelocity velocity entity =
    { entity | horizontalVelocity = velocity }


updateVerticalVelocity : Float -> Entity -> Entity
updateVerticalVelocity velocity entity =
    { entity | verticalVelocity = velocity }


updateJumpDistance : Float -> Entity -> Entity
updateJumpDistance jumpDistance entity =
    { entity | jumpDistance = jumpDistance }


updateY : Float -> Entity -> Entity
updateY y entity =
    { entity | y = y, oldY = entity.y }


updateX : Float -> Entity -> Entity
updateX x entity =
    { entity | x = x, oldX = entity.x }


updateAction : Action -> Entity -> Entity
updateAction action entity =
    { entity | action = action }


updateActionDuration : Time -> Entity -> Entity
updateActionDuration duration entity =
    { entity | actionDuration = duration }
