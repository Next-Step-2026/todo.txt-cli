#!/usr/bin/env bats

# ====================================================================
# SETUP: Configuração do ambiente isolado para o Fuzzing
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
  echo "export TODO_ACTIONS_DIR=\"$PWD/actions\"" >> "$TODO_CFG"
  
  export TZ="America/Sao_Paulo"
  export TODO_SH="./todo.sh -d $TODO_CFG"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# ====================================================================
# SUÍTE 1: TESTE DE STRESS DE INSERÇÃO (50 CASOS ALEATÓRIOS)
# ====================================================================
@test "Fuzzing 1: Adição e conversão de 50 datas/horas aleatórias na CLI" {
  
  for i in $(seq 1 50); do
    # Sorteia ano, mês, dia, hora e minuto usando a variável interna do Bash
    ANO=$((2020 + RANDOM % 15))
    MES=$(printf "%02d" $((1 + RANDOM % 12)))
    # Limita o dia a 28 para evitar que o gerador crie um "30 de Fevereiro" e quebre o Date nativo do Linux
    DIA=$(printf "%02d" $((1 + RANDOM % 28))) 
    HORA=$(printf "%02d" $((RANDOM % 24)))
    MINUTO=$(printf "%02d" $((RANDOM % 60)))
    
    DATA_ARG="$ANO-$MES-$DIA"
    HORA_ARG="$HORA:$MINUTO"
    
    # 1. Tenta quebrar o seu script passando os dados sorteados caoticamente
    run $TODO_SH add "Tarefa Fuzzing $i" -d "$DATA_ARG" "$HORA_ARG"
    
    # O script NÃO PODE falhar independente do que foi sorteado
    [ "$status" -eq 0 ]
    
    # 2. PROPRIEDADE MATEMÁTICA: Calculamos o gabarito no próprio teste
    TIMESTAMP_ESPERADO=$(date -d "$DATA_ARG $HORA_ARG" +%s)
    
    # Pega a última linha do TXT gerado e confere se o seu script gravou o "due:" certo
    ULTIMA_LINHA=$(tail -n 1 "$TODO_FILE")
    [[ "$ULTIMA_LINHA" == *"due:$TIMESTAMP_ESPERADO"* ]]
  done
  
  # Ao final do loop, garante que as 50 linhas estão salvas intactas no arquivo
  QTD_LINHAS=$(wc -l < "$TODO_FILE")
  [ "$QTD_LINHAS" -eq 50 ]
}

# ====================================================================
# SUÍTE 2: TESTE DE CONSISTÊNCIA DO FILTRO (50 CASOS ALEATÓRIOS)
# ====================================================================
@test "Fuzzing 2: Consistência do filtro temporal (Ocultar Passado vs Exibir Futuro)" {
  
  # Pega o Timestamp compensado por fuso (exatamente como programado no código de vocês)
  TIMESTAMP_AGORA=$(( $(date +%s) - 3 * 60 * 60 ))
  
  QTD_FUTURAS=0
  QTD_PASSADAS=0

  # Injeta 50 tarefas randômicas diretamente no banco de dados para ser rápido
  for i in $(seq 1 50); do
    
    # Força 50% de chance de gerar uma data no passado e 50% no futuro
    if [ $((RANDOM % 2)) -eq 0 ]; then
      # PASSADO (Subtrai um período aleatório de até 10 anos em segundos)
      TIMESTAMP_GERADO=$(( TIMESTAMP_AGORA - (RANDOM % 315360000) - 1000 ))
      TIPO="Expirada"
      ((QTD_PASSADAS++))
    else
      # FUTURO (Adiciona um período aleatório de até 10 anos em segundos)
      TIMESTAMP_GERADO=$(( TIMESTAMP_AGORA + (RANDOM % 315360000) + 1000 ))
      TIPO="Futura"
      ((QTD_FUTURAS++))
    fi
    
    echo "Fuzz $TIPO $i due:$TIMESTAMP_GERADO" >> "$TODO_FILE"
  done

  # Dispara o comando de Listar da sua equipe
  run $TODO_SH list
  [ "$status" -eq 0 ]
  
  # A PROVA DE FOGO 1: Nenhum vazamento!
  # É ABSOLUTAMENTE PROIBIDO que a palavra "Expirada" vaze no terminal
  [[ "$output" != *"Fuzz Expirada"* ]]

  # A PROVA DE FOGO 2: Consistência absoluta!
  # O terminal DEVE mostrar EXATAMENTE a mesma quantidade de tarefas que
  # o nosso loop sorteou pro futuro. Se sorteou 23, tem que mostrar 23.
  QTD_MOSTRADA_NO_LIST=$(echo "$output" | grep -c "Fuzz Futura" || true)
  [ "$QTD_MOSTRADA_NO_LIST" -eq "$QTD_FUTURAS" ]


  # A PROVA DE FOGO 3: O ListAll
  run $TODO_SH listall
  [ "$status" -eq 0 ]
  
  # Confere se as passadas e as futuras (as 50 totais) aparecem juntas no histórico geral
  QTD_MOSTRADA_NO_LISTALL=$(echo "$output" | grep -c "Fuzz" || true)
  [ "$QTD_MOSTRADA_NO_LISTALL" -eq 50 ]
}
