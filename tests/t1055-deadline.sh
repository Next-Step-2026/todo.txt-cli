#!/usr/bin/env bash

test_description='deadline actions and expired task filtering

Test adding, changing and removing deadlines, plus list behavior for expired tasks.
'
. ./test-lib.sh

mkdir -p .todo.actions.d
cp "$TEST_DIRECTORY/../actions/add" "$TEST_DIRECTORY/../actions/deadline" "$TEST_DIRECTORY/../actions/rmdeadline" .todo.actions.d/
chmod +x .todo.actions.d/add .todo.actions.d/deadline .todo.actions.d/rmdeadline

test_todo_session 'add and display a deadline' <<'EOF'
>>> todo.sh add prepare breakfast -d 2009-02-13
1 prepare breakfast due:13/02/2009 23:59
TODO: 1 added.

>>> todo.sh -p ls
1 prepare breakfast start:1234489200 due:13/02/2009 23:59
--
TODO: 1 of 1 tasks shown
EOF

test_todo_session 'change and remove a deadline' <<'EOF'
>>> todo.sh deadline 1 2009-02-14
Deadline configurado para a tarefa 1 com sucesso! (Timestamp: 1234655999)

>>> todo.sh -p ls
1 prepare breakfast start:1234489200 due:14/02/2009 23:59
--
TODO: 1 of 1 tasks shown

>>> todo.sh rmdeadline 1
Deadline removido da tarefa 1.

>>> todo.sh -p ls
1 prepare breakfast
--
TODO: 1 of 1 tasks shown
EOF

cat > todo.txt <<'EOF'
expired task due:1234480000
current task due:1234500000
future task due:1234503600
ordinary metadata due:2018-12-31
EOF

test_todo_session 'hide only expired numeric deadlines' <<'EOF'
>>> todo.sh -p ls
2 current task due:13/02/2009 04:40
3 future task due:13/02/2009 05:40
--
TODO: 2 of 4 tasks shown

EOF

cat > todo.txt <<'EOF'
far task start:1234400000 due:1234600000
soon task start:1234400000 due:1234518000
EOF
test_expect_success 'deadline is soon in the final 25 percent' '
	output=$(todo.sh -c listfile todo.txt) &&
	printf "%s\n" "$output" | grep -Fq "soon task $(printf "\\033[1;33m")due:" &&
	! printf "%s\n" "$output" | grep -Fq "far task $(printf "\\033[1;33m")due:"
'

test_todo_session 'alarm rejects invalid deadlines' <<EOF
>>> bash "$TEST_DIRECTORY/../actions/alarme.sh"
=== 1
Erro! Uso correto: ./alarme.sh <timestamp_expiracao>

>>> bash "$TEST_DIRECTORY/../actions/alarme.sh" 1234490000
=== 1
Erro: Esse prazo já passou ou falta menos de 1 minuto para expirar!
EOF

test_done
