module Entities.Entity exposing (update, resolveCollision)

import Entities.Mario as Mario
import Entities.Goomba as Goomba
import Keys exposing (Keys)
import Time exposing (Time)
import Tile exposing (Tile)
import Entity exposing (Entity)
import Physics.CollisionType exposing (CollisionType)


update : Time -> Keys -> List Tile -> Entity -> Entity
update dt keys solidTiles entity =
    case entity.type_ of
        Entity.Mario ->
            Mario.update dt keys entity

        Entity.Goomba ->
            Goomba.update dt entity


resolveCollision : CollisionType -> Tile -> Entity -> Entity
resolveCollision collisionType tile entity =
    case entity.type_ of
        Entity.Mario ->
            Mario.resolveCollision collisionType tile entity

        Entity.Goomba ->
            Goomba.resolveCollision collisionType tile entity
