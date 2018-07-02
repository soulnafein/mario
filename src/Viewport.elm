module Viewport exposing (Viewport, update, create)


type alias Viewport =
    { x : Float
    }


create : Viewport
create =
    { x = 0 }


update : Float -> Float -> Float -> Viewport -> Viewport
update marioX marioHorizontalVelocity dt viewport =
    if (marioX - viewport.x) > 100 then
        { viewport | x = viewport.x + (marioHorizontalVelocity * dt) }
    else
        viewport
