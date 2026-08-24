#!/usr/bin/env bats

# ====================================================================
# SETUP: Configuração do ambiente de teste
# ====================================================================
# A função setup() roda ANTES de cada teste para garantir um ambiente limpo
setup() {
  # Cria um diretório temporário para não alterar suas tarefas reais!
  export TEST_DIR="$(mktemp -d)"
  export TODO_FILE="$TEST_DIR/todo.txt"
  export TODO_CFG="$TEST_DIR/todo.cfg"
  
  # Cria um arquivo de configuração temporário apontando para o ambiente de teste
  echo "export TODO_DIR=\"$TEST_DIR\"" > "$TODO_CFG"
  echo "export TODO_FILE=\"$TODO_FILE\"" >> "$TODO_CFG"
  echo "export DONE_FILE=\"$TEST_DIR/done.txt\"" >> "$TODO_CFG"
  echo "export REPORT_FILE=\"$TEST_DIR/report.txt\"" >> "$TODO_CFG"

  # Força o fuso horário para UTC-3 para evitar falhas de expiração
  # caso o teste rode em um servidor de CI/CD em outro país
  export TZ="America/Sao_Paulo"
}

# A função teardown() roda DEPOIS de cada teste
teardown() {
  # Apaga o diretório temporário e limpa a sujeira
  rm -rf "$TEST_DIR"
}

# ====================================================================
# SUÍTE DE TESTES AUTOMATIZADOS
# ====================================================================

@test "1. Mensagem de criação de TO-DO usa o formato ano-dia-mes (YYYY-DD-MM)" {
  # Captura a data de hoje no formato modificado pela sua branch
  DATA_ATUAL=$(date +"%Y-%d-%m")
  
  run ./todo.sh -d "$TODO_CFG" add "Comprar café"
  
  # status 0 significa que o comando rodou sem erros
  [ "$status" -eq 0 ]
  # Verifica se a data formatada corretamente aparece na saída do terminal
  [[ "$output" == *"$DATA_ATUAL"* ]]
}

@test "2 e 3. Função add_deadline recebe e salva data, hora e minuto" {
  ./todo.sh -d "$TODO_CFG" add "Entregar relatório"
  
  # IMPORTANTE: Ajuste a linha abaixo caso a sintaxe do seu comando seja 
  # um pouco diferente (ex: com aspas, ou usando deadline: direto)
  run ./todo.sh -d "$TODO_CFG" add_deadline 1 2026-24-08 14:30
  
  [ "$status" -eq 0 ]
  
  # Verifica se a data e a hora foram gravadas com sucesso no arquivo físico
  run cat "$TODO_FILE"
  [[ "$output" == *"2026-24-08"* ]]
  [[ "$output" == *"14:30"* ]]
}

@test "4 e 5a. Comando 'list' oculta tarefas com deadline expirado e mantém IDs estáveis" {
  # Injetamos tarefas diretamente no .txt para manipular o tempo com precisão
  echo "Tarefa 1 Futura deadline:2050-01-01 10:30" >> "$TODO_FILE"
  echo "Tarefa 2 Expirada deadline:2000-01-01 10:30" >> "$TODO_FILE"
  echo "Tarefa 3 Futura deadline:2050-01-01 10:30" >> "$TODO_FILE"

  run ./todo.sh -d "$TODO_CFG" list
  
  [ "$status" -eq 0 ]
  # O output deve mostrar as futuras
  [[ "$output" == *"Tarefa 1 Futura"* ]]
  [[ "$output" == *"Tarefa 3 Futura"* ]]
  
  # O output NÃO deve mostrar a expirada
  [[ "$output" != *"Tarefa 2 Expirada"* ]]

  # Verifica se a numeração (ID) foi preservada. 
  # A Tarefa 3 ainda tem que ser listada com o número "3" na frente dela, 
  # para que comandos futuros como 'do 3' continuem funcionando.
  [[ "$output" =~ 3.*"Tarefa 3 Futura" ]]
}

@test "5b. Comando 'listall' exibe tarefas expiradas" {
  echo "Tarefa Expirada deadline:2000-01-01 10:30" >> "$TODO_FILE"

  run ./todo.sh -d "$TODO_CFG" listall
  
  [ "$status" -eq 0 ]
  # No listall, a tarefa do passado TEM que aparecer
  [[ "$output" == *"Tarefa Expirada"* ]]
}

@test "5c. Tarefas expiradas NÃO são deletadas do todo.txt (histórico mantido)" {
  echo "Tarefa Expirada deadline:2000-01-01 10:30" >> "$TODO_FILE"

  # Roda o list (que sabemos que oculta a tarefa do terminal)
  run ./todo.sh -d "$TODO_CFG" list
  [[ "$output" != *"Tarefa Expirada"* ]]
  
  # Agora checa o arquivo original para garantir que ela ainda está lá
  run cat "$TODO_FILE"
  [[ "$output" == *"Tarefa Expirada"* ]]
}
