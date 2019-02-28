% Rosie's Roses
% Hunter Casillas
% Logic Puzzle 1

customer(hugh).
customer(ida).
customer(jeremy).
customer(leroy).
cutomer(stella).

rose(cottage_beauty).
rose(golden_sunset).
rose(mountain_bloom).
rose(pink_paradise).
rose(sweet_dreams).

event(anniversary).
event(charity_auction).
event(retirement).
event(senior_prom).
event(wedding).

item(ballons).
item(candles).
item(chocolates).
item(place_cards).
item(streamers).

solve:-
    % This predicate first chooses some roses.
    % It will choose the same rose for everybody, then repeatedly backtrack
    % choosing different roses, until the all_different predicate is satisfied.
    rose(HughRose), rose(IdaRose), rose(JeremyRose), rose(LeroyRose), rose(StellaRose),
    all_different([HughRose, IdaRose, JeremyRose, LeroyRose, StellaRose]),

    % It then does the same thing for events.
    event(HughEvent), event(IdaEvent), event(JeremyEvent), event(LeroyEvent), event(StellaEvent),
    all_different([HughEvent, IdaEvent, JeremyEvent, LeroyEvent, StellaEvent]),

    % It then does the same thing for items.
    % There is a more efficent way of doing this, but this is the simplest.
    item(HughItem), item(IdaItem), item(JeremyItem), item(LeroyItem), item(StellaItem),
    all_different([HughItem, IdaItem, JeremyItem, LeroyItem, StellaItem]),

    % Each list is a quadruple [customer, rose, event, item]
    % Notice we specify the customer (this is arbitrary we could have specified
    % the rose as long as we cover all four dimentions).
    Quads=[[hugh, HughRose, HughEvent, HughItem],
          [ida, IdaRose, IdaEvent, IdaItem],
          [jeremy, JeremyRose, JeremyEvent, JeremyItem],
          [leroy, LeroyRose, LeroyEvent, LeroyItem],
          [stella, StellaRose, StellaEvent, StellaItem]],

    % Jeremy made a purchase for the senior prom.
    % Stella (who didn't choose flowers for a wedding) picked
    % the Cottage Beauty variety.
    member([jeremy, _, senior_prom, _], Quads),
    member([stella, cottage_beauty, _, _], Quads),

    % Negation isn't difficult, but it's tricky.
    % Here's what you need to remember about negation:
    % Whether negation succeeds or fails, it cannot
    % ever unify (instantiate) anything.
    % You can use negation to prevent certain unifications,
    % as below, but you cannot use it to find out anything.
    \+ member([stella, _ , wedding, _], Quads),

    % Hugh (who selected the Pink Paradise blooms) didn't choose
    % flowers for either the charity auction or the wedding
    member([hugh, pink_paradise, _, _], Quads),
    \+ member([hugh, _, charity_auction, _], Quads),
    \+ member([hugh, _, wedding, _], Quads),

    % The customer who picked roses for an anniversary party also bought streamers.
    % The one shopping for a wedding chose the balloons.
    member([_, _, anniversary, streamers],Quads),
    member([_, _, wedding, ballons], Quads),

    % The customer who bought the Sweet Dreams variety also bought gourmet chocolates.
    % Jeremy didn't pick the Mountain Bloom variety.
    member([_, sweet_dreams, _, chocolates], Quads),
    \+ member([jeremy, mountain_bloom, _, _], Quads),

    % Leroy was shopping for the retirement banquet.
    % The customer in charge of decorating the senior prom also bought the candles.
    member([leroy, _, retirement, _], Quads),
    member([_, _, senior_prom, candles], Quads),

    tell(hugh, HughRose, HughEvent, HughItem),
    tell(ida, IdaRose, IdaEvent, IdaItem),
    tell(jeremy, JeremyRose, JeremyEvent, JeremyItem),
    tell(leroy, LeroyRose, LeroyEvent, LeroyItem),
    tell(stella, StellaRose, StellaEvent, StellaItem).

% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(W, X, Y, Z) :-
    write(W), write(' chose the '), write(X), write(' rose'),
    write(', went to the '), write(Y), write(', and ordered '),
    write(Z), write('.'), nl.
