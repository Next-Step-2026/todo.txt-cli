#!/bin/bash
# Script/Função para gerar pop-ups de aviso
# Fluxo: Chamada automaticamente ao final da função 'add_deadline'
# Recebe: $1 = Timestamp (segundos Unix da data de expiração da tarefa)

HORARIO=$1

# MENSAGEM FIXA: Definida diretamente aqui temporariamente (não precisa passar via argumento)
MENSAGEM="Sua tarefa expira em 1 minuto! Verifique o prazo."

# Verifica se o timestamp de expiração foi enviado pela função add_deadline
if [ -z "$HORARIO" ]; then
    echo "Erro! Uso correto: ./alarme.sh <timestamp_expiracao>"
    exit 1
fi

# Define o disparo para exatamente 1 minuto (60 segundos) antes da expiração
ALVO=$((HORARIO - 60))
AGORA=$(date +%s)

# Calcula quantos segundos o script precisa aguardar
ESPERA=$((ALVO - AGORA))

if [ "$ESPERA" -le 0 ]; then
    echo "Erro: Esse prazo já passou ou falta menos de 1 minuto para expirar!"
    exit 1
fi

echo "Alarme configurado! O pop-up vai aparecer em $ESPERA segundos..."

# Pausa a execução silenciosamente até o momento do aviso
sleep $ESPERA

# Dispara o pop-up nativo do sistema com a mensagem fixa
notify-send "⏰ Lembrete de Tarefa" "$MENSAGEM"