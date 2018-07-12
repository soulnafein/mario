module Physics exposing (update)

import Time exposing (Time)
import Tile exposing (Tile)
import Entity exposing (Entity, Direction(..), Action(..))
import Entities.Entity
import Physics.CollisionType exposing (CollisionType(..))


friction : Float
friction =
    300


gravity : Float
gravity =
    1000


update : Time -> List Tile -> Entity -> Entity
update dt solidTiles entity =
    entity
        |> applyFriction dt
        |> applyGravity dt
        |> updateVerticalPosition dt
        |> checkCollisions Vertical solidTiles
        |> updateHorizontalPosition dt
        |> checkCollisions Horizontal solidTiles


applyFriction : Time -> Entity -> Entity
applyFriction dt entity =
    let
        horizontalVelocity =
            if entity.horizontalVelocity <= 0 then
                0
            else
                entity.horizontalVelocity - (friction * dt)
    in
        { entity | horizontalVelocity = horizontalVelocity }


applyGravity : Time -> Entity -> Entity
applyGravity dt entity =
    { entity | verticalVelocity = entity.verticalVelocity - (gravity * dt) }


type CollisionDirection
    = Vertical
    | Horizontal


boundedBox : Float -> Float -> ( Float, Float, Float, Float )
boundedBox x y =
    let
        ceilX =
            toFloat (ceiling x)

        ceilY =
            toFloat (ceiling y)
    in
        ( ceilY, ceilX + 15, ceilY + 15, ceilX )


checkCollisions : CollisionDirection -> List Tile -> Entity -> Entity
checkCollisions direction solidTiles entity =
    case solidTiles of
        [] ->
            entity

        tile :: other ->
            checkCollisions direction other (checkCollision direction tile entity)


checkCollision : CollisionDirection -> Tile -> Entity -> Entity
checkCollision direction tile entity =
    let
        ( top, right, bottom, left ) =
            boundedBox entity.x entity.y

        ( tileTop, tileRight, tileBottom, tileLeft ) =
            boundedBox tile.x tile.y

        hasCollided =
            not
                ((bottom < tileTop)
                    || (top > tileBottom)
                    || (left > tileRight)
                    || (right < tileLeft)
                )
    in
        if hasCollided then
            applyCollision direction tile entity
        else
            entity


applyCollision : CollisionDirection -> Tile -> Entity -> Entity
applyCollision direction tile entity =
    let
        ( top, right, bottom, left ) =
            boundedBox entity.x entity.y

        ( tileTop, tileRight, tileBottom, tileLeft ) =
            boundedBox tile.x tile.y

        ( oldTop, oldRight, oldBottom, oldLeft ) =
            boundedBox entity.oldX entity.oldY

        fromLeft =
            oldRight < tileLeft

        fromRight =
            oldLeft > tileRight

        fromTop =
            oldBottom < tileTop

        fromBottom =
            oldTop > tileBottom

        updatedEntity =
            case direction of
                Vertical ->
                    if fromTop then
                        Entities.Entity.resolveCollision FromTop tile entity
                    else if fromBottom then
                        Entities.Entity.resolveCollision FromBottom tile entity
                    else
                        entity

                Horizontal ->
                    if fromLeft then
                        Entities.Entity.resolveCollision FromLeft tile entity
                    else if fromRight then
                        Entities.Entity.resolveCollision FromRight tile entity
                    else
                        entity
    in
        updatedEntity


updateHorizontalPosition : Time -> Entity -> Entity
updateHorizontalPosition dt entity =
    let
        horizontalMovementAmount =
            entity.horizontalVelocity * dt

        oldX =
            entity.x

        x =
            applyHorizontalMovement entity.direction entity.x horizontalMovementAmount
    in
        { entity
            | x = x
            , oldX = oldX
        }


applyHorizontalMovement : Direction -> Float -> Float -> Float
applyHorizontalMovement direction x horizontalMovementAmount =
    case direction of
        Left ->
            x - horizontalMovementAmount

        Right ->
            x + horizontalMovementAmount


updateVerticalPosition : Time -> Entity -> Entity
updateVerticalPosition dt entity =
    let
        verticalMovementAmount =
            entity.verticalVelocity * dt

        oldY =
            entity.y

        y =
            entity.y - verticalMovementAmount

        jumpDistance =
            case entity.action of
                Jumping ->
                    entity.jumpDistance + verticalMovementAmount

                Falling ->
                    entity.jumpDistance + verticalMovementAmount

                _ ->
                    entity.jumpDistance
    in
        { entity
            | y = y
            , oldY = oldY
            , jumpDistance = jumpDistance
        }
