from model import Game, Constants, Order, Vec2, ActionOrder, UnitOrder
from typing import Optional
from debug_interface import DebugInterface


class MyStrategy:
    def __init__(self, constants: Constants):
        pass

    def get_order(self, game: Game, debug_interface: Optional[DebugInterface]) -> Order:
        orders = {}
        for unit in game.units:
            if unit.player_id != game.my_id:
                continue
            orders[unit.id] = UnitOrder(
                Vec2(-unit.position.x, -unit.position.y),
                Vec2(-unit.direction.y, unit.direction.x),
                ActionOrder.Aim(True),
            )
        order = Order(orders)
        print(order)
        return order

    def debug_update(self, displayed_tick: int, debug_interface: DebugInterface):
        pass

    def finish(self):
        pass
