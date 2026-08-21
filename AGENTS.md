# Instrucoes para agentes

## Escopo do repositorio

Este repositorio implementa o `todo.sh`, uma interface de linha de comando
portatil para arquivos todo.txt. O projeto e predominantemente Bash e deve
continuar funcionando em Linux, macOS e outros ambientes Unix compativeis.

## Antes de alterar

- Leia o fluxo relevante em `todo.sh`, `todo.cfg` ou `todo_completion` antes de
  modificar o comportamento.
- Consulte `USAGE.md` para confirmar a semantica esperada da acao ou opcao.
- Verifique os testes existentes mais proximos do comportamento alterado.
- Mantenha o diff pequeno e nao reescreva arquivos ou formate secoes sem
  relacao com a tarefa.

## Regras de implementacao

- Use Bash compativel com os ambientes suportados pelo projeto; evite depender
  de recursos especificos de uma distribuicao.
- Preserve a interface de linha de comando, os codigos de saida e o formato de
  saida existentes, salvo quando a tarefa pedir uma mudanca explicita.
- Novas acoes de uso geral podem ser implementadas em `todo.sh`; extensoes
  especificas devem preferencialmente ser add-ons no diretorio de acoes.
- Trate caminhos, argumentos e conteudo de tarefas com aspas adequadas.
- Preserve compatibilidade com configuracoes personalizadas e com arquivos
  todo.txt existentes.
- Nao introduza dependencias externas para resolver algo que o shell e as
  ferramentas Unix ja suportadas resolvem de forma clara.
- Evite comentarios que apenas repitam o codigo; documente somente decisoes
  ou trechos nao obvios.

## Testes

- Execute a suite completa com `make test` antes de concluir uma mudanca.
- Durante o desenvolvimento, execute um teste especifico a partir de
  `tests/`, por exemplo `cd tests && ./t1000-addlist.sh`.
- Para uma nova funcionalidade ou correcao de bug, adicione um teste em
  `tests/` seguindo o formato `tNNNN-descricao.sh` e usando `test-lib.sh`.
- Os testes podem deixar artefatos temporarios; use `make clean` quando for
  necessario limpar a arvore de trabalho.

## Build e distribuicao

- `make`: gera os arquivos de distribuicao locais.
- `make test`: executa todos os testes e remove os resultados.
- `make dist`: cria os arquivos `.tar.gz` e `.zip` de distribuicao.
- `make install`: instala o CLI, a configuracao e o completion; revise os
  caminhos antes de executar em um sistema real.
- `make clean`: remove artefatos de build e distribuicao.

## Checklist de entrega

- A mudanca esta limitada ao escopo solicitado.
- A documentacao de uso foi atualizada quando a interface mudou.
- Ha testes para o comportamento novo ou corrigido.
- `make test` passou, ou a limitacao foi registrada claramente.
- Nao foram incluidos segredos, arquivos gerados ou artefatos locais.