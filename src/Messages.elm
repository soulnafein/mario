module Messages exposing (Msg(..))

import Time exposing (Time)
import Keyboard exposing (KeyCode)


type Msg
    = KeyDown KeyCode
    | KeyUp KeyCode
    | TimeUpdate Time
