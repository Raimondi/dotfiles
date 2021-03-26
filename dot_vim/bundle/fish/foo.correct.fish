set foo bar
if set -q foo
	echo \
				continued\
				lines
end
switch $foo
	case 'abc'
		echo 14
	case 'def'
		echo 15
	case '*'
		echo 16
end

if set -q foo
	if blah
		#kajshc
		echo 2
	else
	end
else
	if bleh
		echo 3
	end

	switch $foo
		case 'knkn'
			echo 4
		case 'uoio'
			echo 5
		case '*'
			echo 6
	end
end

if begin
		echo 7
		and echo 8
	end
	echo 9
else
	echo 10
end

while test -z "$foo"
	echo 11
	while begin
			test -z "$foo"
			and test "$foo" = "bar
	 three spaces
		 five here"
		end
		echo 12
	end
end
end

function foobar
	echo 13
	if test 0 -eq 0
	end
end
echo Test1
echo -n '
		begin
			echo hi


end | cat | cat | begin ; echo hi ; end | begin ; begin ; echo hi ; end ; end arg
					' | ../fish_indent

echo \nTest2
echo -n '
			switch aloha

		 case alpha
						 echo sup

			case beta gamma
							echo hi

						end
						' | ../fish_indent

echo \nTest3
echo -n '
							function hello_world

		begin
				 echo hi
							end | cat

		 echo sup; echo sup
				echo hello;

					 echo hello
			 end 
			 ' | ../fish_indent

echo \nTest4
echo -n '

echo Test1
echo -n '
begin
	echo hi

	# This is more than the current indent function can handle:
	#end | cat | cat | begin ; echo hi ; end | begin ; begin ; echo hi ; end ; end arg
end | cat | cat | begin
	echo hi
end | begin
	begin
		echo hi
	end
end arg
' | ../fish_indent

echo \nTest2
echo -n '
switch aloha

	case alpha
		echo sup

	case beta gamma
		echo hi

end
' | ../fish_indent

echo \nTest3
echo -n '
function hello_world

	'begin'
	echo hi
end | cat

echo sup; echo sup
echo hello;

echo hello
end 
' | ../fish_indent

echo \nTest4
echo -n '
echo alpha				 #comment1
#comment2

#comment3
for i in abc #comment1
	#comment2
	echo hi
end

switch foo #abc
	# bar
case bar
	echo baz\
				qqq
case "*"
	echo sup
end' | ../fish_indent

echo \nTest5
echo -n '
if true
else if false
	echo alpha
	switch beta
		case gamma
			echo delta
	end
end
' | ../fish_indent -i

echo \nTest6
# Test errors
echo -n '
begin
	echo hi
else
	echo bye
end; echo alpha "
' | ../fish_indent

echo \nTest7
# issue 1665
echo -n '
if begin ; false; end; echo hi ; end
while begin ; false; end; echo hi ; end
' | ../fish_indent
switch foo
	case a
		echo 1
	case b
		if begin
				echo 2
			end
			echo 3
	end
end

vim: set noet list listchars=tab:\|\ ,trail:·
