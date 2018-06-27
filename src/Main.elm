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
    , level : Level.Level
    , keys : Keys.Keys
    , characterSprites : CharacterSprites
    , gameRunning : Bool
    }


type alias Flags =
    { charactersPath : String
    , tilesPath : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { mario = Mario.create
      , level = Level.init flags.tilesPath
      , keys = Keys.create
      , characterSprites = Data.Sprites.characters flags.charactersPath
      , gameRunning = True
      }
    , Cmd.none
    )



---- UPDATE ----


onTimeUpdatePhysicsInterval : Float -> Model -> Model
onTimeUpdatePhysicsInterval dt model =
    let
        solidTiles =
            Level.solidTiles model.level

        mario =
            Mario.update dt model.keys solidTiles model.mario

        horizontalOffsetIncrease =
            if Mario.isWalkingPastTheMiddleOfTheLevel mario then
                mario.horizontalVelocity * dt
            else
                0

        level =
            Level.update dt horizontalOffsetIncrease model.level
    in
        { model
            | mario = mario
            , level = level
        }


physicsInterval : Float
physicsInterval =
    0.05


onTimeUpdate : Float -> Model -> Model
onTimeUpdate dt model =
    if dt > physicsInterval then
        onTimeUpdatePhysicsInterval physicsInterval model
            |> onTimeUpdate (dt - physicsInterval)
    else
        onTimeUpdatePhysicsInterval dt model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate dt ->
            ( onTimeUpdate (dt / 1000) model, Cmd.none )

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

                gameRunning =
                    if keyCode == 80 && not isPressed then
                        not model.gameRunning
                    else
                        model.gameRunning
            in
                ( { model | gameRunning = gameRunning, keys = { updatedKeys | keyPressed = keyPressed } }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.div []
        [ svg
            [ width "768"
            , height "672"
            , viewBox "0 0 256 224"
            ]
            [ rect [ width "100%", height "100%", fill "#73ADF9" ] []
            , Level.draw model.level
            , Mario.draw model.mario model.characterSprites
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        subs =
            [ Keyboard.downs (KeyChanged True)
            , Keyboard.ups (KeyChanged False)
            ]
                ++ if model.gameRunning then
                    [ AnimationFrame.diffs TimeUpdate ]
                   else
                    []
    in
        Sub.batch subs



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
