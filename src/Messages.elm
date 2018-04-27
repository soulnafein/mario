module Messages exposing (Msg(..))

import Time exposing (Time)
import Keyboard exposing (KeyCode)


type Msg
    = KeyChanged Bool KeyCode
    | TimeUpdate Time
