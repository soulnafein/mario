module Main exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html exposing (Html)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Mario as Mario
import Level as Level
import Keys as Keys
import Sprites exposing (..)
import Messages exposing (Msg(..))
import Data.Sprites


---- MODEL ----


type alias Model =
    { mario : Mario.Mario
    , keys : Keys.Keys
    , characterSprites : CharacterSprites
    , tileSprites : TileSprites
    }


type alias Flags =
    { charactersPath : String
    , tilesPath : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { mario = Mario.create
      , keys = Keys.create
      , characterSprites = Data.Sprites.characters flags.charactersPath
      , tileSprites = Data.Sprites.tiles flags.tilesPath
      }
    , Cmd.none
    )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate dt ->
            ( { model | mario = Mario.move (dt / 1000) model.keys model.mario }, Cmd.none )

        KeyChanged isPressed keyCode ->
            let
                keys =
                    model.keys

                updatedKeys =
                    case keyCode of
                        37 ->
                            { keys | leftPressed = isPressed }

                        39 ->
                            { keys | rightPressed = isPressed }

                        90 ->
                            { keys | jumpPressed = isPressed }

                        _ ->
                            keys

                keyPressed =
                    if isPressed then
                        toString keyCode
                    else
                        "N/A"
            in
                ( { model | keys = { updatedKeys | keyPressed = keyPressed } }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.div []
        [ svg
            [ width "100%"
            , height "100%"
            , viewBox "0 0 256 208"
            ]
            [ rect [ width "100%", height "100%", fill "black" ] []
            , Level.draw model.tileSprites
            , Mario.draw model.mario model.characterSprites
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs (KeyChanged True)
        , Keyboard.ups (KeyChanged False)
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
