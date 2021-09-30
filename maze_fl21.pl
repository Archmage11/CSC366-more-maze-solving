% Row 1
wall([X,1]) :- X =\= 2.
% Row 2
wall([X,2]) :- X = 1; X = 4; X = 6.
% Row 3
wall([X,3]) :- X = 1; X = 2; X = 6.
% Row 4
wall([X,4]) :- X =\= 3,X =\= 5.
% Row 5
wall([X,5]) :- X = 1; X = 4; X = 6.
% Row 6
wall([X,6]) :- X =\= 2.
% Start / end
start([2,1]).
end([2,6]).
% Maze Size
mazeSize([6,6]).

badSpot([X,Y]) :- wall([X,Y]).
badSpot([X,Y]) :- X < 1; Y < 1.
badSpot([X,Y]) :- mazeSize([W, H]), (X > W; Y > H).

%up
move([CurrX, CurrY], [NextX, NextY], 0) :- NextY is CurrY - 1, NextX = CurrX.
%right
move([CurrX, CurrY], [NextX, NextY], 1) :- NextY = CurrY, NextX is CurrX + 1.
%down
move([CurrX, CurrY], [NextX, NextY], 2) :- NextY is CurrY + 1, NextX = CurrX.
%left
move([CurrX, CurrY], [NextX, NextY], 3) :- NextY = CurrY, NextX is CurrX - 1.
%up=0, right=1, down=2, left=3


turnLeft(Heading, NewHeading) :- NewHeading is mod(Heading + 3, 4).
turnRight(Heading, NewHeading) :- NewHeading is mod(Heading + 1, 4).

% A solution of the maze from our current location is [] if our current location is the end.
solve(CurrentLocation, _, Path, _) :- end(CurrentLocation), Path = [CurrentLocation].

% part 1 - follow the left wall 
solve(CurrentLocation, BeenThere, Path, Heading) :- 
        turnLeft(Heading, HeadingL), % get left heading
        turnRight(Heading, HeadingR), % get right heading
        move(CurrentLocation, NewLocation, HeadingL), % move left
        (badSpot(NewLocation) -> % try moving left: if left is badspot, recurse from right 
                (solve(CurrentLocation, BeenThere, Path, HeadingR)) ; 
                (solve(NewLocation, [NewLocation | BeenThere], RestOfPath, HeadingL))
        ),
        Path = [CurrentLocation | RestOfPath].
		
% Convenience rule
solve(Path) :- start(Start), solve(Start, [Start], Path, 2).


drawCell(Column, Row, _) :- wall([Column, Row]), write("X"), !.
drawCell(Column, Row, _) :- start([Column, Row]), write("S"), !.
drawCell(Column, Row, _) :- end([Column, Row]), write("E"), !.
drawCell(Column, Row, Path) :- member([Column, Row], Path), write("P"), !.
drawCell(_, _, _) :- write("O").

drawRow(Row, Path) :- drawCell(1, Row, Path), tab(1), drawCell(2, Row, Path), tab(1), 
        drawCell(3, Row, Path), tab(1), drawCell(4, Row, Path), tab(1), 
        drawCell(5, Row, Path), tab(1), drawCell(6, Row, Path), nl.
                
draw :- drawRow(1, []), drawRow(2, []), drawRow(3, []), drawRow(4, []), drawRow(5, []), 
        drawRow(6, []).

draw(Path) :- drawRow(1, Path), drawRow(2, Path), drawRow(3, Path), drawRow(4, Path),
        drawRow(5, Path), drawRow(6, Path).



% PART 2 ------------------------------------------------------------------------------------
% prefer moevements that lead towards the end of the maze


isCloser([CurrX, CurrY], [NextX, NextY]) :- end([EndX, EndY]), 
        sqrt((EndX-CurrX)^2 + (EndY-CurrY)^2) > sqrt((EndX-NextX)^2 + (EndY-NextY)^2).


% A solution of the maze from our current location is [] if our current location is the end.
solve2(CurrentLocation, _, Path) :- end(CurrentLocation), Path = [CurrentLocation].

solve2(CurrentLocation, BeenThere, Path) :- 
        move2(CurrentLocation, NewLocation),
        isCloser(CurrentLocation, NewLocation),
        \+ badSpot(NewLocation),
        \+ member(NewLocation, BeenThere),
        solve2(NewLocation, [NewLocation | BeenThere], RestOfPath), 
        Path = [CurrentLocation | RestOfPath].

solve2(CurrentLocation, BeenThere, Path) :- 
        move2(CurrentLocation, NewLocation),
        \+ badSpot(NewLocation),
        \+ member(NewLocation, BeenThere),
        solve2(NewLocation, [NewLocation | BeenThere], RestOfPath), 
        Path = [CurrentLocation | RestOfPath].
		
% Convenience rule
solve2(Path) :- start(Start), solve2(Start, [Start], Path). 

%up
move2([CurrX, CurrY], [CurrX, NextY]) :- NextY is CurrY - 1.
%down
move2([CurrX, CurrY], [NextX, NextY]) :- NextY is CurrY + 1, NextX = CurrX.
%left
move2([CurrX, CurrY], [NextX, NextY]) :- NextY = CurrY, NextX is CurrX - 1.
%right
move2([CurrX, CurrY], [NextX, NextY]) :- NextY = CurrY, NextX is CurrX + 1.


% part 3 -------------------------------------------------------------------
% move randomly

% A solution of the maze from our current location is [] if our current location is the end.
solve3(CurrentLocation, _, Path) :- end(CurrentLocation), Path = [CurrentLocation].

solve3(CurrentLocation, BeenThere, Path) :- 
        repeat,
        random_between(0, 4, R),
        move(CurrentLocation, NewLocation, R), % move randomly
        \+ badSpot(NewLocation),
        solve3(NewLocation, [NewLocation | BeenThere], RestOfPath), 
        Path = [CurrentLocation | RestOfPath].

% Convenience rule
solve3(Path) :- start(Start), solve3(Start, [Start], Path).


% thoughts: This algorithm moves randomly until it reaches the end. 
% This is worse. So much worse. However, interestingly enough, this solution will 
% sometimes be the best possible solution for a given maze. It is a rare occurence, but sometimes, 
% this solution is the best solution to a maze in every meaning of the word. That said, don't do this. 
% I chose this because it's really easy and I think it's hard to improve on the first two algos without significant work. 
% I also didn't want to change the representation of the maze because that's lame and boring and I don't like typing parentheses
% enough to implement it. In the future, it might be worth adding a \+ notmember(beenthere) line to prevent backtracking, 
% but I think it's funnier this way (and also, *sometimes*, potentially, more optimized)


