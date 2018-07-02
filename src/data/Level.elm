module Data.Level exposing (tilesData, Tile)

import Dict exposing (Dict)
import Exts.Dict exposing (groupBy)


type alias Tile =
    { x : Float
    , y : Float
    , name : String
    , isSolid : Bool
    }


type alias TileRange =
    { name : String
    , rectangle : ( Int, Int, Int, Int )
    , isSolid : Bool
    }


tilesData : Dict Float (List Tile)
tilesData =
    let
        ranges =
            [ { name = "ground"
              , rectangle = ( 0, 12, 68, 13 )
              , isSolid = True
              }
            , { name = "ground"
              , rectangle = ( 71, 12, 85, 13 )
              , isSolid = True
              }
            , { name = "ground"
              , rectangle = ( 89, 12, 152, 13 )
              , isSolid = True
              }
            , { name = "ground"
              , rectangle = ( 155, 12, 211, 13 )
              , isSolid = True
              }
            ]
                ++ (hill 0 9)
                ++ (smallHill 16 10)
                ++ (hill 48 9)
                ++ (smallHill 64 10)
                ++ (hill 96 9)
                ++ (smallHill 112 10)
                ++ [ { name = "hill-1"
                     , rectangle = ( 144, 11, 144, 11 )
                     , isSolid = False
                     }
                   , { name = "hill-1"
                     , rectangle = ( 145, 10, 145, 10 )
                     , isSolid = False
                     }
                   , { name = "hill-4"
                     , rectangle = ( 145, 11, 145, 11 )
                     , isSolid = False
                     }
                   , { name = "hill-5"
                     , rectangle = ( 146, 11, 146, 11 )
                     , isSolid = False
                     }
                   , { name = "hill-4"
                     , rectangle = ( 146, 10, 146, 10 )
                     , isSolid = False
                     }
                   , { name = "hill-2"
                     , rectangle = ( 146, 9, 146, 9 )
                     , isSolid = False
                     }
                   , { name = "hill-3"
                     , rectangle = ( 147, 10, 147, 10 )
                     , isSolid = False
                     }
                   , { name = "hill-4"
                     , rectangle = ( 147, 11, 147, 11 )
                     , isSolid = False
                     }
                   ]
                ++ (smallHill 160 10)
                ++ (hill 192 9)
                ++ (smallHill 208 10)
                ++ (nBush 3 11 11)
                ++ (nBush 1 23 11)
                ++ (nBush 2 41 11)
                ++ (nBush 3 59 11)
                ++ (nBush 1 71 11)
                ++ (nBush 2 89 11)
                ++ (nBush 3 107 11)
                ++ (nBush 1 119 11)
                ++ [ { name = "bush-2"
                     , rectangle = ( 138, 11, 139, 11 )
                     , isSolid = False
                     }
                   ]
                ++ [ { name = "bush-3"
                     , rectangle = ( 159, 11, 159, 11 )
                     , isSolid = False
                     }
                   ]
                ++ (nBush 1 167 11)
                ++ [ { name = "bush-3"
                     , rectangle = ( 207, 11, 207, 11 )
                     , isSolid = False
                     }
                   ]
                ++ (nCloud 1 8 2)
                ++ (nCloud 1 19 1)
                ++ (nCloud 3 27 2)
                ++ (nCloud 2 36 1)
                ++ (nCloud 1 56 2)
                ++ (nCloud 1 67 1)
                ++ (nCloud 3 75 2)
                ++ (nCloud 2 84 1)
                ++ (nCloud 1 104 2)
                ++ (nCloud 1 115 1)
                ++ (nCloud 3 123 2)
                ++ (nCloud 2 132 1)
                ++ (nCloud 1 152 2)
                ++ (nCloud 1 163 1)
                ++ (nCloud 3 171 2)
                ++ (nCloud 2 180 1)
                ++ (nCloud 1 200 2)
                ++ (nPipe 1 28 10)
                ++ (nPipe 2 38 9)
                ++ (nPipe 3 46 8)
                ++ (nPipe 3 57 8)
                ++ (nPipe 1 163 10)
                ++ (nPipe 1 179 10)
                ++ (lootBox 16 8)
                ++ (lootBox 22 4)
                ++ (lootBox 21 8)
                ++ (lootBox 23 8)
                ++ (lootBox 78 8)
                ++ (lootBox 94 4)
                ++ (lootBox 106 8)
                ++ (lootBox 109 8)
                ++ (lootBox 109 4)
                ++ (lootBox 112 8)
                ++ (lootBox 129 4)
                ++ (lootBox 130 4)
                ++ (lootBox 170 8)
                ++ (brick 20 8)
                ++ (brick 22 8)
                ++ (brick 24 8)
                ++ (brick 77 8)
                ++ (brick 79 8)
                ++ (brick 80 4)
                ++ (brick 81 4)
                ++ (brick 82 4)
                ++ (brick 83 4)
                ++ (brick 84 4)
                ++ (brick 85 4)
                ++ (brick 86 4)
                ++ (brick 87 4)
                ++ (brick 91 4)
                ++ (brick 92 4)
                ++ (brick 93 4)
                ++ (brick 94 8)
                ++ (brick 100 8)
                ++ (brick 118 8)
                ++ (brick 121 4)
                ++ (brick 122 4)
                ++ (brick 123 4)
                ++ (brick 128 4)
                ++ (brick 129 8)
                ++ (brick 130 8)
                ++ (brick 131 4)
                ++ (brick 168 8)
                ++ (brick 169 8)
                ++ (brick 171 8)
                ++ [ { name = "hard-brick"
                     , rectangle = ( 134, 11, 137, 11 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 135, 10, 137, 10 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 136, 9, 137, 9 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 137, 8, 137, 8 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 140, 11, 143, 11 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 140, 10, 142, 10 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 140, 9, 141, 9 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 140, 8, 140, 8 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 148, 11, 152, 11 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 149, 10, 152, 10 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 150, 9, 152, 9 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 151, 8, 152, 8 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 155, 11, 158, 11 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 155, 10, 157, 10 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 155, 9, 156, 9 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 155, 8, 155, 8 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 181, 11, 189, 11 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 182, 10, 189, 10 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 183, 9, 189, 9 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 184, 8, 189, 8 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 185, 7, 189, 7 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 186, 6, 189, 6 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 187, 5, 189, 5 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 188, 4, 189, 4 )
                     , isSolid = True
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 198, 11, 198, 11 )
                     , isSolid = True
                     }
                   ]
                ++ castle 202 7
    in
        generateTiles ranges


lootBox : Int -> Int -> List TileRange
lootBox x y =
    [ { name = "loot-box"
      , rectangle = ( x, y, x, y )
      , isSolid = True
      }
    ]


tile : Int -> Int -> String -> List TileRange
tile x y name =
    [ { name = name
      , rectangle = ( x, y, x, y )
      , isSolid = True
      }
    ]


castle : Int -> Int -> List TileRange
castle x y =
    []
        ++ (brick x (y + 3))
        ++ (brick x (y + 4))
        ++ (brick (x + 1) (y + 3))
        ++ (brick (x + 1) (y + 4))
        ++ (brick (x + 3) (y + 3))
        ++ (brick (x + 3) (y + 4))
        ++ (brick (x + 4) (y + 3))
        ++ (brick (x + 4) (y + 4))
        ++ (brick (x + 2) (y + 1))
        ++ (tile (x + 1) y "castle-1")
        ++ (tile (x + 2) y "castle-1")
        ++ (tile (x + 3) y "castle-1")
        ++ (tile (x + 2) (y + 4) "castle-6")
        ++ (tile (x + 2) (y + 3) "castle-5")
        ++ (tile (x + 1) (y + 2) "castle-4")
        ++ (tile (x + 2) (y + 2) "castle-4")
        ++ (tile (x + 3) (y + 2) "castle-4")
        ++ (tile x (y + 2) "castle-1")
        ++ (tile (x + 4) (y + 2) "castle-1")
        ++ (tile (x + 1) (y + 1) "castle-2")
        ++ (tile (x + 3) (y + 1) "castle-3")


brick : Int -> Int -> List TileRange
brick x y =
    [ { name = "brick-1"
      , rectangle = ( x, y, x, y )
      , isSolid = True
      }
    ]


nPipe : Int -> Int -> Int -> List TileRange
nPipe n x y =
    [ { name = "pipe-1"
      , rectangle = ( x, y, x, y )
      , isSolid = True
      }
    , { name = "pipe-2"
      , rectangle = ( x + 1, y, x + 1, y )
      , isSolid = True
      }
    ]
        ++ (List.range 1 n
                |> List.concatMap
                    (\relativeY ->
                        [ { name = "pipe-3"
                          , rectangle = ( x, y + relativeY, x, y + relativeY )
                          , isSolid = True
                          }
                        , { name = "pipe-4"
                          , rectangle = ( x + 1, y + relativeY, x + 1, y + relativeY )
                          , isSolid = True
                          }
                        ]
                    )
           )


nBush : Int -> Int -> Int -> List TileRange
nBush n x y =
    [ { name = "bush-1"
      , rectangle = ( x, y, x, y )
      , isSolid = False
      }
    ]
        ++ ((List.range 1 n)
                |> List.map (\relativeX -> { name = "bush-2", rectangle = ( relativeX + x, y, relativeX + x, y ), isSolid = False })
           )
        ++ [ { name = "bush-3"
             , rectangle = ( x + n + 1, y, x + n + 1, y )
             , isSolid = False
             }
           ]


nCloud : Int -> Int -> Int -> List TileRange
nCloud n x y =
    [ { name = "cloud-1"
      , rectangle = ( x, y, x, y )
      , isSolid = False
      }
    ]
        ++ ((List.range 1 n)
                |> List.map (\relativeX -> { name = "cloud-2", rectangle = ( relativeX + x, y, relativeX + x, y ), isSolid = False })
           )
        ++ [ { name = "cloud-3"
             , rectangle = ( x + n + 1, y, x + n + 1, y )
             , isSolid = False
             }
           ]
        ++ [ { name = "cloud-4"
             , rectangle = ( x, y + 1, x, y + 1 )
             , isSolid = False
             }
           ]
        ++ ((List.range 1 n)
                |> List.map (\relativeX -> { name = "cloud-5", rectangle = ( relativeX + x, y + 1, relativeX + x, y + 1 ), isSolid = False })
           )
        ++ [ { name = "cloud-6"
             , rectangle = ( x + n + 1, y + 1, x + n + 1, y + 1 )
             , isSolid = False
             }
           ]


smallHill : Int -> Int -> List TileRange
smallHill x y =
    [ { name = "hill-1"
      , rectangle = ( x, y + 1, x, y + 1 )
      , isSolid = False
      }
    , { name = "hill-4"
      , rectangle = ( x + 1, y + 1, x + 1, y + 1 )
      , isSolid = False
      }
    , { name = "hill-2"
      , rectangle = ( x + 1, y, x + 1, y )
      , isSolid = False
      }
    , { name = "hill-3"
      , rectangle = ( x + 2, y + 1, x + 2, y + 1 )
      , isSolid = False
      }
    ]


hill : Int -> Int -> List TileRange
hill x y =
    [ { name = "hill-1"
      , rectangle = ( x, y + 2, x, y + 2 )
      , isSolid = False
      }
    , { name = "hill-1"
      , rectangle = ( x + 1, y + 1, x + 1, y + 1 )
      , isSolid = False
      }
    , { name = "hill-4"
      , rectangle = ( x + 1, y + 2, x + 1, y + 2 )
      , isSolid = False
      }
    , { name = "hill-5"
      , rectangle = ( x + 2, y + 2, x + 2, y + 2 )
      , isSolid = False
      }
    , { name = "hill-4"
      , rectangle = ( x + 2, y + 1, x + 2, y + 1 )
      , isSolid = False
      }
    , { name = "hill-2"
      , rectangle = ( x + 2, y, x + 2, y )
      , isSolid = False
      }
    , { name = "hill-3"
      , rectangle = ( x + 3, y + 1, x + 3, y + 1 )
      , isSolid = False
      }
    , { name = "hill-4"
      , rectangle = ( x + 3, y + 2, x + 3, y + 2 )
      , isSolid = False
      }
    , { name = "hill-3"
      , rectangle = ( x + 4, y + 2, x + 4, y + 2 )
      , isSolid = False
      }
    ]


generateTiles : List TileRange -> Dict Float (List Tile)
generateTiles ranges =
    ranges
        |> List.concatMap generateTilesFromRange
        |> groupBy .x


generateTilesFromRange : TileRange -> List Tile
generateTilesFromRange range =
    let
        ( x1, y1, x2, y2 ) =
            range.rectangle
    in
        List.range y1 y2
            |> List.concatMap (generateTileRow x1 x2 range.name range.isSolid)


generateTileRow : Int -> Int -> String -> Bool -> Int -> List Tile
generateTileRow x1 x2 name isSolid y =
    List.range x1 x2
        |> List.map (\x -> { x = toFloat x, y = toFloat y, name = name, isSolid = isSolid })
