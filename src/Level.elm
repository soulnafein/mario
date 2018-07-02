module Level exposing (init, draw, Level, update, solidTiles)

import Sprites exposing (TileSprites, drawTile)
import Svg exposing (..)
import Svg
import Messages exposing (Msg)
import Data.Sprites
import Dict exposing (Dict)
import Data.Level exposing (tilesData, Tile)


type alias Level =
    { visibleTiles : List Tile
    , horizontalOffset : Float
    , tileSprites : TileSprites
    }


init : String -> Level
init tilesPath =
    { visibleTiles = tilesAtOffset 0 tilesData
    , horizontalOffset = 0
    , tileSprites = Data.Sprites.tiles tilesPath
    }


update : Float -> Float -> Level -> Level
update dt horizontalOffsetIncrease level =
    let
        horizontalOffset =
            level.horizontalOffset + horizontalOffsetIncrease
    in
        { level
            | horizontalOffset = horizontalOffset
            , visibleTiles = tilesAtOffset horizontalOffset tilesData
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


solidTiles : Level -> List Tile
solidTiles level =
    level.visibleTiles
        |> List.filter .isSolid
        |> List.map
            (\tile ->
                { tile
                    | x = tile.x * 16
                    , y = tile.y * 16
                }
            )


draw : Level -> Svg Msg
draw level =
    let
        tiles =
            level.visibleTiles

        tileSprites =
            level.tileSprites

        offset =
            round level.horizontalOffset
    in
        g [] (List.map (\tile -> drawTile (round tile.x) (round tile.y) offset tile.name tileSprites) tiles)
