module Data.Sprites exposing (characters)

import Sprites exposing (SpritesData, Direction(..), Action(..))
import Array


characters : String -> SpritesData
characters imageUrl =
    { imageUrl = imageUrl
    , sprites =
        [ { name = "mario", action = Standing, direction = Left, animation = Array.fromList [ [ 222, 44, 16, 16 ] ], animationSpeed = 1 }
        , { name = "mario", action = Jumping, direction = Left, animation = Array.fromList [ [ 142, 44, 16, 16 ] ], animationSpeed = 1 }
        , { name = "mario", action = Falling, direction = Left, animation = Array.fromList [ [ 142, 44, 16, 16 ] ], animationSpeed = 1 }
        , { name = "mario", action = Walking, direction = Left, animation = Array.fromList [ [ 206, 44, 16, 16 ], [ 193, 44, 16, 16 ], [ 177, 44, 16, 16 ] ], animationSpeed = 0.25 }
        , { name = "mario", action = Standing, direction = Right, animation = Array.fromList [ [ 275, 44, 16, 16 ] ], animationSpeed = 1 }
        , { name = "mario", action = Jumping, direction = Right, animation = Array.fromList [ [ 355, 44, 16, 16 ] ], animationSpeed = 1 }
        , { name = "mario", action = Falling, direction = Right, animation = Array.fromList [ [ 355, 44, 16, 16 ] ], animationSpeed = 1 }
        , { name = "mario", action = Walking, direction = Right, animation = Array.fromList [ [ 291, 44, 16, 16 ], [ 304, 44, 16, 16 ], [ 320, 44, 16, 16 ] ], animationSpeed = 0.25 }
        ]
    }
