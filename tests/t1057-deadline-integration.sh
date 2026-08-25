#!/usr/bin/env bash

test_description='deadline integration with task operations

Test deadline behavior with:
- Task filtering
- Task listing variations
- Task metadata preservation
- Multiple deadline modifications
'
. ./test-lib.sh

mkdir -p .todo.actions.d
cp "$TEST_DIRECTORY/../actions/add" "$TEST_DIRECTORY/../actions/deadline" "$TEST_DIRECTORY/../actions/rmdeadline" .todo.actions.d/
chmod +x .todo.actions.d/add .todo.actions.d/deadline .todo.actions.d/rmdeadline

cat /dev/null > todo.txt
test_expect_success 'search tasks with deadline' '
	todo.sh add "buy @store" -d 2009-02-15 >/dev/null &&
	todo.sh add "sell items" >/dev/null &&
	output=$(todo.sh ls buy) &&
	printf "%s\n" "$output" | grep -q "buy" &&
	printf "%s\n" "$output" | grep -q "due:15/02/2009"
'

cat /dev/null > todo.txt
test_expect_success 'list tasks by context showing deadline' '
	todo.sh add "work task office" -d 2009-02-16 >/dev/null &&
	todo.sh add "home task" >/dev/null &&
	output=$(todo.sh ls office) &&
	printf "%s\n" "$output" | grep -q "work task" &&
	printf "%s\n" "$output" | grep -q "due:16/02/2009"
'

cat /dev/null > todo.txt
test_expect_success 'deadline survives multiple modifications' '
	todo.sh add "original" -d 2009-02-17 >/dev/null &&
	todo.sh deadline 1 2009-02-22 >/dev/null &&
	todo.sh deadline 1 2009-02-20 >/dev/null &&
	output=$(todo.sh ls) &&
	printf "%s\n" "$output" | grep -q "original" &&
	printf "%s\n" "$output" | grep -q "due:20/02/2009"
'

cat /dev/null > todo.txt
test_expect_success 'mix of deadline and non-deadline tasks' '
	todo.sh add "urgent" -d 2009-02-15 >/dev/null &&
	todo.sh add "normal" >/dev/null &&
	todo.sh add "another urgent" -d 2009-02-18 >/dev/null &&
	output=$(todo.sh ls) &&
	printf "%s\n" "$output" | grep -q "urgent" &&
	printf "%s\n" "$output" | grep -q "normal" &&
	due_count=$(printf "%s\n" "$output" | grep -c "due:") &&
	[ "$due_count" -eq 2 ]
'

cat /dev/null > todo.txt
test_expect_success 'deadline format is consistent DD/MM/YYYY HH:MM' '
	todo.sh add "format check" -d 2009-02-14 >/dev/null &&
	output=$(todo.sh ls | grep "format check") &&
	printf "%s\n" "$output" | grep -qE "due:14/02/2009 23:59"
'

test_done
