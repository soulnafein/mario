module Level exposing (create, draw, Level, update, solidTiles)

import Sprites exposing (TileSprites, drawTile)
import Svg exposing (..)
import Svg
import Messages exposing (Msg)
import Data.Sprites
import Dict exposing (Dict)
import Data.Level exposing (tilesData, Tile)
import Viewport exposing (Viewport)
import Time exposing (Time)


type alias Level =
    { visibleTiles : List Tile
    , tileSprites : TileSprites
    , elapsedTime : Time
    }


create : String -> Level
create tilesPath =
    { visibleTiles = tilesAtOffset 0 tilesData
    , tileSprites =
        Data.Sprites.tiles tilesPath
    , elapsedTime = 0
    }


update : Viewport -> Time -> Level -> Level
update viewport dt level =
    let
        horizontalOffset =
            viewport.x
    in
        { level
            | visibleTiles = tilesAtOffset horizontalOffset tilesData
            , elapsedTime = level.elapsedTime + dt
        }


tilesAtOffset : Float -> Dict Float (List Tile) -> List Tile
tilesAtOffset offset tiles =
    let
        gridXMin =
            round (offset / 16) - 1

        gridXMax =
            gridXMin + 16 + 2

        result =
            List.range gridXMin gridXMax
                |> List.map (\gridX -> Dict.get (toFloat gridX) tiles |> Maybe.withDefault [])
                |> List.concat
    in
        result


solidTiles : ( Float, Float, Float, Float ) -> Level -> List Tile
solidTiles ( top, right, bottom, left ) level =
    level.visibleTiles
        |> List.filter .isSolid
        |> List.map
            (\tile ->
                { tile
                    | x = tile.x * 16
                    , y = tile.y * 16
                }
            )
        |> List.filter
            (\t ->
                (t.y > top)
                    && (t.y < bottom)
                    && (t.x > left)
                    && (t.x < right)
            )


draw : Viewport -> Level -> Svg Msg
draw viewport level =
    let
        tiles =
            level.visibleTiles

        tileSprites =
            level.tileSprites

        offset =
            round viewport.x
    in
        g [] (List.map (\tile -> drawTile (round tile.x) (round tile.y) offset tile.name tileSprites level.elapsedTime) tiles)
