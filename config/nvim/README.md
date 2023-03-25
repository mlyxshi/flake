https://missing.csail.mit.edu/2020/editors/

http://vimcasts.org/episodes/

https://pragprog.com/titles/dnvim2/practical-vim-second-edition/


# Normal Mode

## move
Words: w (next word), b (beginning of word), e (end of word)
Scroll: Ctrl-u (up), Ctrl-d (down)
0   move cursor to line begin
^   move cursor to begin of non-empty
$   move cursor to line end
w   move 1 word forward
b   move 1 mord backword
2w  move cursor 2 word forward


## delete
x   delete char
d0  delete cursor to line begin
d$  delete cursor to line end
dw  delete one word
daw delete a word
d2w delete two word

dd  delete whole one line
2dd delete whole two line

## put/copy/paste 
p  put deleted thing to cursor ||thing

y copy/yank(Pre:v)
yy whole line
p paste




## undo
u   undo last command
U   undo whole line
CTRL-R undo the undo


## change[delete + insert]
rx  replace char
ce  replace to word end
cb  replace to word begin
cc  replace whole line
c$  replace to line end
c0  replace to line begin
R   replace mode



## cursor location
gg  start 
G   end
5G  move to line 5


## () [] {} "" ''
%     move cursor to matched () [] {}
ci[   change thing in []
di(   delete thing in ()
da(   delete all ()

## insert
i  insert [before cursor]  
I  insert [begin]
a  append [append cursor] 
A  append [end] 
o  open line below
O  open line above

## quit
:q! quit without save
:wq quit with save


## search
/   forward search
?   backward search
n   search next
N   search opposite next
//default
CTRL_O  go back 
CTRL_I  go forward
//self reverse

## sed
:s/old/new     substitute old to new(Once)
:s/old/new/g   g:whole line

:%s/old/new/gc  %:whole file,  g:whole file with confirm


## execute external command
:! ls  


## File
:w NAME  save to NAME(Pre: v)
:r NAME  retrive from NAME

# window
CTRL_W jump to another window



## visual selection
v         select 
shift+v   line select
CTRL_V    select block

under visual mode, run normal mode command
: norm <COMMAND>

# Case
~ 

## Macros
q{character} to start recording a macro in register {character}

q to stop recording

@{character} replays the macro

{number}@{character} executes a macro {number} times

:reg show 
