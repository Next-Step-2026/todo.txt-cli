#!/usr/bin/env bats

# ====================================================================
# SETUP: Configuração do ambiente (Padrão de Add-ons da Equipe)
# ====================================================================
setup() {
  export TEST_DIR="$(mktemp -d)"
  export TODO_FILE="$TEST_DIR/todo.txt"
  export TODO_CFG="$TEST_DIR/todo.cfg"
  export DONE_FILE="$TEST_DIR/done.txt"
  export REPORT_FILE="$TEST_DIR/report.txt"
  
  touch "$TODO_FILE" "$DONE_FILE" "$REPORT_FILE"
  
  echo "export TODO_DIR=\"$TEST_DIR\"" > "$TODO_CFG"
  echo "export TODO_FILE=\"$TODO_FILE\"" >> "$TODO_CFG"
  echo "export DONE_FILE=\"$DONE_FILE\"" >> "$TODO_CFG"
  echo "export REPORT_FILE=\"$REPORT_FILE\"" >> "$TODO_CFG"
  echo "export TODOTXT_DATE_ON_ADD=1" >> "$TODO_CFG"
  
  # Ação CRUCIAL: Aponta o sistema para ler os scripts da sua pasta actions/
  echo "export TODO_ACTIONS_DIR=\"$PWD/actions\"" >> "$TODO_CFG"

  # Força o ambiente para o fuso brasileiro UTC-3 
  export TZ="America/Sao_Paulo"
  
  export TODO_SH="./todo.sh -d $TODO_CFG"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# ====================================================================
# SUÍTE DE TESTES (V1 - Extensões de Prazo e Alarme)
# ====================================================================

@test "1. Mensagem de sucesso do 'add -d' formata a data no terminal (DD/MM/YYYY HH:MM)" {
  run $TODO_SH add "Comprar cafe" -d 2026-08-30 14:30
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"30/08/2026 14:30"* ]]
}

@test "2 e 3. Comando 'deadline' recebe e salva no arquivo txt como Timestamp Unix" {
  $TODO_SH add "Entregar relatorio"
  
  run $TODO_SH deadline 1 2026-08-24 14:30
  [ "$status" -eq 0 ]
  
  # Calcula matematicamente o Timestamp exato que o bash deveria gerar
  TIMESTAMP_ESPERADO=$(date -d "2026-08-24 14:30" +%s)
  
  # Verifica se a sua aplicação gravou a TAG corretamente com os segundos
  run cat "$TODO_FILE"
  [[ "$output" == *"due:$TIMESTAMP_ESPERADO"* ]]
}

@test "4 e 5a. Comando 'list' formata a exibição, oculta expiradas e mantem ID estável" {
  TIMESTAMP_PASSADO=$(date -d "2000-01-01 10:30" +%s)
  TIMESTAMP_FUTURO=$(date -d "2050-01-01 10:30" +%s)

  # Injeta as tarefas simulando o banco de dados
  echo "Tarefa 1 Futura due:$TIMESTAMP_FUTURO" >> "$TODO_FILE"
  echo "Tarefa 2 Expirada due:$TIMESTAMP_PASSADO" >> "$TODO_FILE"
  echo "Tarefa 3 Futura due:$TIMESTAMP_FUTURO" >> "$TODO_FILE"

  run $TODO_SH list
  [ "$status" -eq 0 ]
  
  # Verifica se modificou o console corretamente
  [[ "$output" == *"Tarefa 1 Futura due:01/01/2050 10:30"* ]]
  [[ "$output" == *"Tarefa 3 Futura due:01/01/2050 10:30"* ]]
  
  # A tarefa 2 deve ter sido oculta e removida do output
  [[ "$output" != *"Tarefa 2 Expirada"* ]]
  
  # ID Estável: A tarefa 3 deve continuar listada com o numero '3' na frente dela
  [[ "$output" =~ 3.*"Tarefa 3 Futura" ]]
}

@test "5b. Comando 'listall' exibe tarefas expiradas formatadas" {
  TIMESTAMP_PASSADO=$(date -d "2000-01-01 10:30" +%s)
  echo "Tarefa Expirada due:$TIMESTAMP_PASSADO" >> "$TODO_FILE"

  run $TODO_SH listall
  [ "$status" -eq 0 ]
  
  # No comando lsa, ela TEM que aparecer
  [[ "$output" == *"Tarefa Expirada due:01/01/2000 10:30"* ]]
}

@test "5c. Filtragem NÃO causa perda de dados (histórico mantido no todo.txt)" {
  TIMESTAMP_PASSADO=$(date -d "2000-01-01 10:30" +%s)
  echo "Tarefa Expirada due:$TIMESTAMP_PASSADO" >> "$TODO_FILE"

  # Roda list (para que o console processe o ocultamento)
  $TODO_SH list > /dev/null
  
  # Lê o .txt puro para garantir que a linha continua persistida fisicamente
  run cat "$TODO_FILE"
  [[ "$output" == *"Tarefa Expirada due:$TIMESTAMP_PASSADO"* ]]
}