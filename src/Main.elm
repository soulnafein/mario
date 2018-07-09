module Main exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html exposing (Html)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Mario
import Goomba
import Level
import Data.Level exposing (Tile)
import Viewport
import Keys
import Sprites exposing (..)
import Messages exposing (Msg(..))
import Data.Sprites
import Physics
import Entities exposing (Entity)
import Time exposing (Time)


---- MODEL ----


type alias Model =
    { entities : List Entity
    , level : Level.Level
    , viewport : Viewport.Viewport
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
    ( { entities = [ Mario.create, Goomba.create ]
      , level = Level.create flags.tilesPath
      , viewport = Viewport.create
      , keys = Keys.create
      , characterSprites = Data.Sprites.characters flags.charactersPath
      , gameRunning = True
      }
    , Cmd.none
    )



---- UPDATE ----


onTimeUpdatePhysicsInterval : Time -> Model -> Model
onTimeUpdatePhysicsInterval dt model =
    let
        mario =
            getMario model.entities

        keys =
            model.keys

        solidTiles =
            Level.solidTiles model.level

        entities =
            List.map (updateEntity dt keys solidTiles) model.entities

        viewport =
            Viewport.update mario.x mario.horizontalVelocity dt model.viewport

        level =
            Level.update viewport dt model.level
    in
        { model
            | entities = entities
            , level = level
            , viewport = viewport
        }


getMario : List Entity -> Entity
getMario entities =
    entities
        |> List.filter (\e -> e.type_ == Entities.Mario)
        |> List.head
        |> Maybe.withDefault Mario.create


updateEntity : Time -> Keys.Keys -> List Tile -> Entity -> Entity
updateEntity dt keys solidTiles entity =
    let
        updatedEntity =
            case entity.type_ of
                Entities.Mario ->
                    Mario.update dt keys entity

                Entities.Goomba ->
                    Goomba.update dt entity
    in
        Physics.update dt solidTiles updatedEntity


physicsInterval : Float
physicsInterval =
    0.01


onTimeUpdate : Time -> Model -> Model
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
            ([ rect [ width "100%", height "100%", fill "#73ADF9" ] []
             , Level.draw model.viewport model.level
             ]
                ++ (viewEntities model.viewport model.characterSprites model.entities)
            )
        ]


viewEntities : Viewport.Viewport -> CharacterSprites -> List Entity -> List (Svg Msg)
viewEntities viewport characterSprites entities =
    List.map (Sprites.drawEntity viewport characterSprites) entities


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
