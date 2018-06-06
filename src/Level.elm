module Level exposing (init, draw, Level, update)

import Sprites exposing (TileSprites, drawTile)
import Svg exposing (..)
import Svg
import Messages exposing (Msg)
import Data.Sprites
import Mario exposing (Mario, isWalkingPastTheMiddleOfTheLevel)


type alias Tile =
    { x : Int
    , y : Int
    , name : String
    }


type alias TileRange =
    { name : String
    , rectangle : ( Int, Int, Int, Int )
    }


type alias Level =
    { tiles : List Tile
    , visibleTiles : List Tile
    , horizontalOffset : Float
    , tileSprites : TileSprites
    }


init : String -> Level
init tilesPath =
    let
        ranges =
            [ { name = "ground"
              , rectangle = ( 0, 11, 30, 12 )
              }
            ]
                ++ (hill 0 8)
                ++ (cloud 9 3)
                ++ (cloud 11 3)

        tiles =
            generateTiles ranges
    in
        { tiles = tiles
        , visibleTiles = tilesAtOffset 0 tiles
        , horizontalOffset = 0
        , tileSprites = Data.Sprites.tiles tilesPath
        }


update : Float -> Mario -> Level -> Level
update dt mario level =
    let
        horizontalOffsetIncrease =
            mario.horizontalVelocity * dt

        horizontalOffset =
            if isWalkingPastTheMiddleOfTheLevel mario then
                level.horizontalOffset + horizontalOffsetIncrease
            else
                level.horizontalOffset
    in
        { level
            | horizontalOffset = horizontalOffset
            , visibleTiles = tilesAtOffset horizontalOffset level.tiles
        }


tilesAtOffset : Float -> List Tile -> List Tile
tilesAtOffset offset tiles =
    let
        gridXMin =
            round (offset / 16) - 1

        gridXMax =
            gridXMin + 16 + 2
    in
        tiles
            |> List.filter (\tile -> tile.x >= gridXMin && tile.x < gridXMax)


cloud : Int -> Int -> List TileRange
cloud x y =
    [ { name = "cloud-1"
      , rectangle = ( x, y, x, y )
      }
    , { name = "cloud-2"
      , rectangle = ( x + 1, y, x + 1, y )
      }
    , { name = "cloud-3"
      , rectangle = ( x + 2, y, x + 2, y )
      }
    , { name = "cloud-4"
      , rectangle = ( x, y + 1, x, y + 1 )
      }
    , { name = "cloud-5"
      , rectangle = ( x + 1, y + 1, x + 1, y + 1 )
      }
    , { name = "cloud-6"
      , rectangle = ( x + 2, y + 1, x + 2, y + 1 )
      }
    ]


hill : Int -> Int -> List TileRange
hill x y =
    [ { name = "hill-1"
      , rectangle = ( x, y + 2, x, y + 2 )
      }
    , { name = "hill-1"
      , rectangle = ( x + 1, y + 1, x + 1, y + 1 )
      }
    , { name = "hill-4"
      , rectangle = ( x + 1, y + 2, x + 1, y + 2 )
      }
    , { name = "hill-5"
      , rectangle = ( x + 2, y + 2, x + 2, y + 2 )
      }
    , { name = "hill-4"
      , rectangle = ( x + 2, y + 1, x + 2, y + 1 )
      }
    , { name = "hill-2"
      , rectangle = ( x + 2, y, x + 2, y )
      }
    , { name = "hill-3"
      , rectangle = ( x + 3, y + 1, x + 3, y + 1 )
      }
    , { name = "hill-4"
      , rectangle = ( x + 3, y + 2, x + 3, y + 2 )
      }
    , { name = "hill-3"
      , rectangle = ( x + 4, y + 2, x + 4, y + 2 )
      }
    ]


generateTiles : List TileRange -> List Tile
generateTiles ranges =
    ranges
        |> List.concatMap generateTilesFromRange


generateTilesFromRange : TileRange -> List Tile
generateTilesFromRange range =
    let
        ( x1, y1, x2, y2 ) =
            range.rectangle
    in
        List.range y1 y2
            |> List.concatMap (generateTileRow x1 x2 range.name)


generateTileRow : Int -> Int -> String -> Int -> List Tile
generateTileRow x1 x2 name y =
    List.range x1 x2
        |> List.map (\x -> { x = x, y = y, name = name })


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
        g [] (List.map (\tile -> drawTile tile.x tile.y offset tile.name tileSprites) tiles)
