#!/bin/bash
# Script independente para gerar pop-ups de aviso
# Uso: ./alarme.sh "+1 minute" "Mensagem de teste"

HORARIO=$1
MENSAGEM=$2

# Verifica se a equipe digitou os dois argumentos
if [ -z "$HORARIO" ] || [ -z "$MENSAGEM" ]; then
    echo "Erro! Uso correto: ./alarme.sh <horário> <mensagem>"
    exit 1
fi

# Converte o tempo pedido e o tempo atual para Segundos Unix
ALVO=$(date -d "$HORARIO" +%s)
AGORA=$(date +%s)

# Calcula quantos segundos o script precisa esperar
ESPERA=$((ALVO - AGORA))

if [ "$ESPERA" -le 0 ]; then
    echo "Erro: Esse tempo já passou!"
    exit 1
fi

echo "Alarme configurado! O pop-up vai aparecer em $ESPERA segundos..."

# Pausa o script silenciosamente até a hora chegar
sleep $ESPERA

# Dispara o pop-up (Comando nativo do Linux)
notify-send "⏰ Lembrete do Sistema" "$MENSAGEM"
