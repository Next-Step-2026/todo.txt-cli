#!/usr/bin/env bash

test_description='comprehensive deadline tests

Test deadline functionality including:
- Adding tasks with various deadline formats
- Modifying deadlines multiple times
- Deadline display and formatting
- Mixing tasks with and without deadlines
'
. ./test-lib.sh

mkdir -p .todo.actions.d
cp "$TEST_DIRECTORY/../actions/add" "$TEST_DIRECTORY/../actions/deadline" "$TEST_DIRECTORY/../actions/rmdeadline" .todo.actions.d/
chmod +x .todo.actions.d/add .todo.actions.d/deadline .todo.actions.d/rmdeadline

cat /dev/null > todo.txt
test_todo_session 'add task with deadline and verify display' <<'EOF'
>>> todo.sh add buy groceries -d 2009-02-15
1 buy groceries due:15/02/2009 23:59
TODO: 1 added.

>>> todo.sh ls
1 buy groceries due:15/02/2009 23:59
--
TODO: 1 of 1 tasks shown
EOF

cat /dev/null > todo.txt
test_expect_success 'add multiple tasks with different deadlines' '
	todo.sh add "task one" -d 2009-02-13 >/dev/null &&
	todo.sh add "task two" -d 2009-02-20 >/dev/null &&
	todo.sh add "task three" >/dev/null &&
	output=$(todo.sh ls) &&
	printf "%s\n" "$output" | grep -q "task one" &&
	printf "%s\n" "$output" | grep -q "task two" &&
	printf "%s\n" "$output" | grep -q "task three" &&
	due_count=$(printf "%s\n" "$output" | grep -c "due:") &&
	[ "$due_count" -eq 2 ]
'

cat /dev/null > todo.txt
test_expect_success 'modify deadline on existing task' '
	todo.sh add "project" -d 2009-02-15 >/dev/null &&
	todo.sh deadline 1 2009-02-25 >/dev/null &&
	output=$(todo.sh ls) &&
	printf "%s\n" "$output" | grep -q "project" &&
	printf "%s\n" "$output" | grep -q "due:25/02/2009"
'

cat /dev/null > todo.txt
test_expect_success 'add deadline to task without one' '
	todo.sh add "study math" >/dev/null &&
	todo.sh deadline 1 2009-02-18 >/dev/null &&
	output=$(todo.sh ls) &&
	printf "%s\n" "$output" | grep -q "study math" &&
	printf "%s\n" "$output" | grep -q "due:18/02/2009"
'

cat /dev/null > todo.txt
test_todo_session 'remove deadline from task' <<'EOF'
>>> todo.sh add clean house -d 2009-02-28
1 clean house due:28/02/2009 23:59
TODO: 1 added.

>>> todo.sh rmdeadline 1
Deadline removido da tarefa 1.

>>> todo.sh ls
1 clean house
--
TODO: 1 of 1 tasks shown
EOF

cat /dev/null > todo.txt
test_expect_success 'deadline with priority is created' '
	todo.sh add "(A) critical task" -d 2009-02-16 >/dev/null &&
	output=$(todo.sh ls) &&
	printf "%s\n" "$output" | grep -q "(A) critical task" &&
	printf "%s\n" "$output" | grep -q "due:16/02/2009"
'

cat /dev/null > todo.txt
test_todo_session 'deadline with context and project' <<'EOF'
>>> todo.sh add meeting @office +work -d 2009-02-17
1 meeting @office +work due:17/02/2009 23:59
TODO: 1 added.

>>> todo.sh ls
1 meeting @office +work due:17/02/2009 23:59
--
TODO: 1 of 1 tasks shown
EOF

cat /dev/null > todo.txt
test_todo_session 'verify deadline persistence across operations' <<'EOF'
>>> todo.sh add persistent -d 2009-02-19
1 persistent due:19/02/2009 23:59
TODO: 1 added.

>>> todo.sh ls
1 persistent due:19/02/2009 23:59
--
TODO: 1 of 1 tasks shown

>>> todo.sh ls
1 persistent due:19/02/2009 23:59
--
TODO: 1 of 1 tasks shown
EOF

test_done
