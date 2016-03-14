%%%-------------------------------------------------------------------
%%% @author lich
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 三月 2016 15:19
%%%-------------------------------------------------------------------
-module(menu).
-author("lich").

%% API
-export([init/0, loop/1]).
-export([order/1, order/0, cancel/1, checkout/0]).
-export([start/0]).
-vsn(1.0).

start() ->
  register(menu, spawn(menu, init, [])).

init() ->
  orderlist = {get_menu(), []},
  loop(orderlist).

get_menu() -> #{tofu => 3.0, chicken=> 4.0, pork=>5.0}.

call(Message) ->
  menulist ! {request, self(), Message},
  receive
    {reply, Reply}-> Reply
  end.

checkout()-> call(checkout).
order()-> call({order}).
order(Dishes)-> call({order, Dishes}).
cancel(Dishes)-> call({cancel, Dishes}).


loop(Orderlist)->
  receive
    {request, Pid, {order}}->
      Reply = myOrders(Orderlist, Pid),
      reply(Pid, Reply),
      loop(Orderlist);
    {request, Pid , {order, Dishes}} ->
      {Orders, Reply} =  order(Orderlist, Dishes, Pid),
      reply(Pid, Reply),
      loop(Orders);
    {request, Pid, {cancel, Dishes}} ->
      {Orders, Reply} = cancel(Orderlist, Dishes, Pid),
      reply(Pid, Reply),
      loop(Orders);
    {request, Pid, checkOut} ->
      Reply = checkout(Orderlist, Pid),
      reply(Pid, Reply)
  end.

myOrders({_Menu, []}, _Pid) -> [];
myOrders({_Menu,  Orders}, Pid)-> [Order || {Order, Pid} <- Orders].

checkout(Orderlist, Pid) ->
  MyOrders = myOrders(Orderlist, Pid),
  {Menu, _Order} = Orderlist,
  if
    MyOrders == [] ->
      0;
    true ->
      MenuList = maps:to_list(Menu),
      Recipe = [Dish, Price || {}]
  end.





order(Orderlist, [], _Pid) ->  {Orderlist, {ordered}};
order({Menu, Ordered}, [Dish | Dishes], Pid)  ->
  ValidOrder = maps:is_key(Dish, Menu),
  if
     ValidOrder ->
       order({Menu, [{Dish, Pid} | Ordered]}, Dishes, Pid);
     true->
       order({Menu, [{Dish, Pid} | Ordered]}, Dishes, Pid)
  end.




reply(Pid, Reply)->
  Pid ! {reply, Reply}.
