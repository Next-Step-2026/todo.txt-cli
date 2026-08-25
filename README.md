
# ⏱️ Extensões da Equipe: Todo.txt CLI (Backlog V1)

Este diretório contém os scripts customizados (Add-ons) criados pela nossa equipe para adicionar suporte a **Prazos (Deadlines)** e **Alarmes** ao `todo.txt-cli`.

Nós adotamos a filosofia de **nunca alterar o código-fonte original** (`todo.sh`). Todas as novas funcionalidades utilizam o sistema nativo de hooks e ações customizadas.

---

## ⚙️ Configuração do Ambiente (Para a Equipe)

Para que os seus testes locais reconheçam estes scripts versionados no Git, é necessário configurar o seu arquivo `todo.cfg` local para apontar para a nossa pasta `actions/`.

1. Abra o arquivo `todo.cfg` na raiz do projeto.
2. Encontre ou adicione a variável `TODO_ACTIONS_DIR`.
3. Defina o caminho utilizando a variável do diretório atual:
```bash
export TODO_ACTIONS_DIR="$PWD/actions"

```



---

## 🚀 Funcionalidades da V1

Os metadados de prazo são salvos no final da tarefa utilizando o formato nativo de chave-valor: `due:<timestamp_unix>`. Isso garante compatibilidade com outras interfaces de todo.txt.

Quando uma tarefa é criada com deadline, o início também é salvo como `start:<timestamp_unix>`. A cor amarela é aplicada quando o tempo restante está dentro dos 25% finais da duração da tarefa. Tarefas antigas sem `start:` usam a janela configurada em `TODOTXT_DEADLINE_SOON` como fallback.

### Como testar as cores

Use `-c` para ativar as cores na listagem. O deadline aparece em:

- **vermelho:** prazo expirado;
- **amarelo:** prazo dentro dos 25% finais da duração;
- **cor padrão:** prazo ainda distante.

Para testar as três situações sem depender de datas fixas, execute na raiz do projeto:

```bash
NOW=$(date +%s)
cat >> todo.txt <<EOF
prazo normal start:$((NOW - 3600)) due:$((NOW + 86400))
prazo proximo start:$((NOW - 4 * 3600)) due:$((NOW - 3 * 3600 + 600))
prazo expirado due:$((NOW - 3600))
EOF

./todo.sh -c list
```

O primeiro prazo deve usar a cor padrão, o segundo amarelo e o terceiro vermelho.
Para deixar a visualização sem cores, use `./todo.sh -p list`. As cores só alteram a saída; os metadados continuam salvos no `todo.txt`.

### 1. Adicionar Tarefa com Prazo

Sobrescrevemos o comando `add` original de forma silenciosa para suportar a flag `-d` (deadline). Além do formato absoluto existente, ela aceita prazos relativos em minutos (`m`), horas (`h`) e dias (`d`).

* **Uso:** `./todo.sh add <texto da tarefa> -d <yyyy-mm-dd> [HH:MM]` ou `./todo.sh add <texto da tarefa> -d m <minutos>`, `-d h <horas[:minutos]>`, `-d d <dias>`
* **Exemplo:** `./todo.sh add "Finalizar a documentação da API" -d 2026-08-30`
* **Exemplo relativo:** `./todo.sh add "Finalizar a documentação da API" -d h 1:30`
* **Comportamento:** O script intercepta a flag `-d`, converte a data para Timestamp Unix (final do dia) e repassa para a função `add` nativa.

### 2. Gerenciar Prazos (CRUD)

Novos comandos dedicados para adicionar, alterar ou remover o deadline de uma tarefa existente utilizando o seu `id` (número da linha).

* **Adicionar/Atualizar Prazo:**
* **Uso:** `./todo.sh deadline <id_task> <yyyy-mm-dd> [HH:MM]` ou `./todo.sh deadline <id_task> m <minutos>`, `h <horas[:minutos]>`, `d <dias>`
* **Exemplo:** `./todo.sh deadline 3 2026-08-25`
* **Comportamento:** Adiciona a tag `due:TIMESTAMP` à tarefa 3. Se a tarefa já possuía um deadline, o valor antigo é removido antes da inserção.


* **Remover Prazo:**
* **Uso:** `./todo.sh rmdeadline <id_task>`
* **Exemplo:** `./todo.sh rmdeadline 3`
* **Comportamento:** Remove de forma limpa a tag `due:` da tarefa especificada. Se não houver deadline, nada acontece.



---

## ⏰ Módulo de Alarme

O módulo envia uma notificação visual via pop-up do sistema operacional. A ação
`deadline` o inicia automaticamente em segundo plano após salvar o timestamp,
para exibir o aviso um minuto antes do prazo.

* **Uso automático:** `./todo.sh deadline <id_task> <yyyy-mm-dd> [HH:MM[:SS]]`
* **Uso direto:** `bash ./actions/alarme.sh "<timestamp>" "<mensagem do popup>" &`

O alarme recebe o timestamp Unix salvo na tag `due:` e usa uma mensagem padrão
quando nenhuma mensagem personalizada é informada.

---
## Padrões de commits

Para commits, usaremos o padrão de [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), em inglês

- `<type>(optional scope): <description>`


---

## 🔜 Próximos Passos (Backlog V2)

Para os desenvolvedores que forem assumir as próximas etapas do projeto, o escopo da V2 inclui:

* [ ] `notify_when_expired()`: Criação de um job em background que lê o arquivo `todo.txt`, procura por tags `due:` vencidas que não tenham o status `x` (done), e aciona o `alarme.sh`.
* [ ] Suporte a datas relativas na CLI (ex: `./todo.sh add Tarefa -d today`, ou `-d +2d`).
* [ ] Filtros de listagem customizados (ex: `./todo.sh ls --date <deadline>`).

---

### Como usar isso no seu projeto:

Basta copiar o texto acima, colar num arquivo chamado `README-EQUIPE.md` (ou sobrescrever/acrescentar no final do `README.md` já existente da pasta) e fazer o commit para o Git.
