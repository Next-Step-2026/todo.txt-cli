#!/usr/bin/env bash

test_description='alarme.sh notification message test.

This test checks that alarme.sh passes a custom message to notify-send.
'
. ./test-lib.sh

cat > notify-send <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" > notify-output
EOF
chmod +x notify-send

cat > sleep <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x sleep

test_expect_success 'custom alarm message is passed to notify-send' '
    PATH="$PWD:$PATH" bash "$TEST_DIRECTORY/../actions/alarme.sh" "$(( $(date +%s) + 61 ))" "Mensagem personalizada" > output &&
    test_cmp <(printf "%s\\n" "⏰ Lembrete de Tarefa Mensagem personalizada") notify-output
'

test_done