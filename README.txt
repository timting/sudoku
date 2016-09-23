This sudoku solver solves the majority of easy and medium sudoku puzzles. It fails
on some harder sudoku puzzles (I've included one in the tests for illustration).
Currently, it doesn't check the validity of the inputted board - this could be
easily added.

1. How does your algorithm work?
I did research into Sudoku strategies and implemented some of them. In broad
strokes, my algorithm works as follows
 - Initialize squares so all have possibilities and impossibilities calculated
 (from numbers in the row, column, and group). If there's just one possibility,
 populate it.
 - Run subgroup exclusion (http://www.sudokudragon.com/tutorialsharedsubgroup.htm)
 to find squares that must be a certain number. Along the way, if there's ever
 just one possibility, populate it
 - Loop over the following until we have no progress
   - Find naked twins (http://www.sudokudragon.com/tutorialnakedtwins.htm) and
   hidden twins (http://www.sudokudragon.com/tutorialhiddentwins.htm) and use
   these to further reduce possibilities in open squares in the same groups these
   are found.
   - Run subgroup exclusion

2. Give and explain the big­O notation of the best, worst, and expected run­time
of your program.
For my calculations, I'm taking n to be the number of open squares.
Best: O(n)
In the best case, the initialize_board method in board.rb, when run, solves the
puzzle. That method takes O(n) time. Then, the loop in line 101 of board.rb never
runs.

Worst: O(n^n)
I think the most relevant portion here is in board.rb, in the solve method. The
loop in lines 101-107 is going to have the greatest effect. The two methods in
line 97-98 are both O(n), as are the three methods in lines 104-106. Everything
else (initialization, etc) is either constant or O(n) time.So, the question is,
in the worst case, how many times would the loop run? In the worst case, we would
fill one square each run through, which would cause us to run the loop n times.
This gives us a worst case runtime of O(n^n)

Expected: O(n^n)
Without doing a ton of analysis, it's hard to say anything here. But, generally,
I would say that the best case with an average sudoku is unrealistic, and in
practice, we're going to be closer to the worst case than the best case scenario.
So, I'll say O(n^n), but that bound is definitely looser if we're looking at
expected runtime.

3. Why did you design your program the way you did?
I tried to design my program to match the architecture of a Sudoku board. From
that goal, it made sense to have a Board and Square class. I decided to have most
of the logic which solved the board in the Board class since putting it in the
Square class didn't really make sense - a Square doesn't have everything it needs
to solve the board. As strategies multiplied, I put them into their own module as
an initial step for multiple Strategies which you could toss your board to and
get the modified board back.

4. What are some other decisions you could have made. How might they have been
better? How might they have been worse?
One decision would have been to put all the possibilities generation in the Square
class. This makes sense in some respects - a square should be able to determine
its own possibilities. The downside to this is that the square would have to reach
out to the board to get other relevant squares, since it's only in the analysis
of other squares that a square could determine its possibilities. That breaks
encapsulation. Instead, I have the board doing all the calculations. This makes
sense, but it makes the board class a bit of a messy place.

There are also options regarding how to represent the squares. We could probably
have stored them as a pretty simple hash structure. This would have saved space
and probably increased speed, at the cost of the structure not being expressed
clearly in a class of its own. That cost would probably make maintaining this
code slightly more difficult.

How best to store the squares within the board is another decision. We could have
stored them in a hash to allow for quick access of specific squares. Select, which
I'm using, is not as fast as hash access. For our use case, though, we didn't
really seem to need specific access to a particular square. Mostly, we're just
accessing open squares, and I think the access methods I build work reasonably
well.
