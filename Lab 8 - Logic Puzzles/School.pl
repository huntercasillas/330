% School's Out!
% Hunter Casillas
% Logic Puzzle 2

teacher(appleton).
teacher(gross).
teacher(knight).
teacher(mcevoy).
teacher(parnell).

subject(english).
subject(gym).
subject(history).
subject(math).
subject(science).

state(california).
state(florida).
state(maine).
state(oregon).
state(virginia).

activity(antiquing).
activity(camping).
activity(sightseeing).
activity(spelunking).
activity(water_skiing).

solve:-
    % This predicate first chooses some subjects.
		% It will choose the same subject for everybody, then repeatedly backtrack
    % choosing different subjects, until the all_different predicate is satisfied.
		subject(AppletonSubject), subject(GrossSubject), subject(KnightSubject), subject(McevoySubject), subject(ParnellSubject),
    all_different([AppletonSubject, GrossSubject, KnightSubject, McevoySubject, ParnellSubject]),

		% It then does the same thing for states.
  	state(AppletonState), state(GrossState), state(KnightState), state(McevoyState), state(ParnellState),
    all_different([AppletonState, GrossState, KnightState, McevoyState, ParnellState]),

		% It then does the same thing for activities.
	  % There is a more efficent way of doing this, but this is the simplest.
  	activity(AppletonActivity), activity(GrossActivity), activity(KnightActivity), activity(McevoyActivity), activity(ParnellActivity),
    all_different([AppletonActivity, GrossActivity, KnightActivity, McevoyActivity, ParnellActivity]),

		% Each list is a quadruple [teacher, subject, state, activity]
	  % Notice we specify the teacher (this is arbitrary we could have specified
	  % the subject as long as we cover all four dimentions).
  	Quads=[[appleton, AppletonSubject, AppletonState, AppletonActivity],
  				[gross, GrossSubject, GrossState, GrossActivity],
  				[knight, KnightSubject, KnightState, KnightActivity],
  				[mcevoy, McevoySubject, McevoyState, McevoyActivity],
  				[parnell, ParnellSubject, ParnellState, ParnellActivity]],

    % Ms. Gross teaches either math or science.
		(member([gross, math, _, _], Quads);
	   member([gross, science, _, _], Quads)),

		% If Ms. Gross is going antiquing, then she is going to Florida;
 		% otherwise, she is going to California.
    (member([gross, _, florida, antiquing], Quads);
	 	 member([gross, _, california, _],	Quads),

		% Negation isn't difficult, but it's tricky.
		% Here's what you need to remember about negation:
  	% Whether negation succeeds or fails, it cannot
  	% ever unify (instantiate) anything.
  	% You can use negation to prevent certain unifications,
  	% as below, but you cannot use it to find out anything.
  	\+  member([gross, _, california, antiquing], Quads)),

    % The science teacher (who is going water-skiing) is going to travel to
		% either California or Florida.
    (member([_, science, california, water_skiing],	Quads);
   	 member([_, science, florida, water_skiing], Quads)),

    % Mr. McEvoy (who is the history teacher) is going to either Maine or Oregon.
  	(member( [mcevoy, history, maine, _], Quads );
   	 member( [mcevoy, history, oregon, _], Quads)),

    % If the woman who is going to Virginia is the English teacher,
		% then she is Ms. Appleton; otherwise she is
		% Ms. Parnell (who is going spelunking).
    (member([appleton, english, virginia, _], Quads);
   	 member([parnell, _, virginia, _], Quads)),
  	 member([parnell, _, _, spelunking], Quads),

  	% The person who is going to Maine (who isn't the gym teacher)
		% isn't the one who is going sightseeing.
    \+ member([_, gym , maine, _], Quads),
  	\+ member([_, _, maine, sightseeing], Quads),

		% Ms. Gross isn't the woman who is going camping.
    \+ member([gross, _, _, camping], Quads),
		(member([appleton, _, _, camping], Quads);
  	 member([parnell, _, _, camping], Quads)),

		% One woman is going antiquing on her vacation.
    (member([appleton, _, _, antiquing], Quads);
  	 member([gross, _, _, antiquing], Quads);
  	 member([parnell, _, _, antiquing], Quads)),

    tell(appleton, AppletonSubject, AppletonState, AppletonActivity),
    tell(gross, GrossSubject, 	GrossState, GrossActivity),
    tell(knight, KnightSubject, KnightState, KnightActivity),
    tell(mcevoy, McevoySubject, McevoyState, McevoyActivity),
    tell(parnell, ParnellSubject, ParnellState, ParnellActivity).

% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(W, X, Y, Z) :-
      write(W), write(' teaches '), write(X), write(', is visiting '),
      write(Y), write(', and has '), write(Z), write(' planned.'), nl.
