module Game exposing (State, init, update, view)

import Level
import Viewport
import Time exposing (Time)
import Entities exposing (Entity)
import Keys
import Sprites exposing (CharacterSprites)
import Svg exposing (Svg, svg, rect)
import Svg.Attributes exposing (width, height, viewBox, fill)
import Messages exposing (Msg(..))
import Mario
import Goomba
import Physics
import Data.Level exposing (Tile)
import Data.Sprites


type alias State =
    { entities : List Entity
    , level : Level.Level
    , viewport : Viewport.Viewport
    , keys : Keys.Keys
    , characterSprites : CharacterSprites
    , gameRunning : Bool
    , lastSpawnedEnemyX : Float
    }


init : String -> String -> State
init tilesPath charactersPath =
    { entities = [ Mario.create, Goomba.create 200 0 ]
    , level = Level.create tilesPath
    , viewport = Viewport.create
    , keys = Keys.create
    , characterSprites = Data.Sprites.characters charactersPath
    , gameRunning = True
    , lastSpawnedEnemyX = 0
    }


update : Time -> State -> State
update dt state =
    let
        mario =
            getMario state.entities

        keys =
            state.keys

        solidTiles =
            Level.solidTiles state.level

        spawnedEntities =
            spawnEntities state.viewport.x state.lastSpawnedEnemyX Data.Level.enemiesData

        lastSpawnedEnemyX =
            List.maximum (List.map .x spawnedEntities)
                |> Maybe.withDefault state.lastSpawnedEnemyX

        entities =
            List.map (updateEntity dt keys solidTiles) (state.entities ++ spawnedEntities)

        viewport =
            Viewport.update mario.x mario.horizontalVelocity dt state.viewport

        level =
            Level.update viewport dt state.level
    in
        { state
            | entities = entities
            , level = level
            , viewport = viewport
            , lastSpawnedEnemyX = lastSpawnedEnemyX
        }


spawnEntities : Float -> Float -> List Entity -> List Entity
spawnEntities offset lastSpawnedEnemyX entitiesData =
    entitiesData
        |> List.filter (\e -> (e.x > lastSpawnedEnemyX) && (e.x > offset + 100) && (e.x < offset + 300))


view : State -> Svg Msg
view state =
    svg
        [ width "768"
        , height "672"
        , viewBox "0 0 256 224"
        ]
        ([ rect [ width "100%", height "100%", fill "#73ADF9" ] []
         , Level.draw state.viewport state.level
         ]
            ++ (viewEntities state.viewport state.characterSprites state.entities)
        )


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


viewEntities : Viewport.Viewport -> CharacterSprites -> List Entity -> List (Svg Msg)
viewEntities viewport characterSprites entities =
    List.map (Sprites.drawEntity viewport characterSprites) entities
