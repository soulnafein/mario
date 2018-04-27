module Models.Keys exposing (..)


type alias Keys =
    { leftPressed : Bool
    , rightPressed : Bool
    , jumpPressed : Bool
    , keyPressed : String
    }


create : Keys
create =
    { leftPressed = False
    , rightPressed = False
    , jumpPressed = False
    , keyPressed = "N/A"
    }
