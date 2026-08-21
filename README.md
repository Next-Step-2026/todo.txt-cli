
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

### 1. Adicionar Tarefa com Prazo

Sobrescrevemos o comando `add` original de forma silenciosa para suportar a flag `-d` (deadline).

* **Uso:** `./todo.sh add <texto da tarefa> -d <yyyy-mm-dd> <HH:MM>` 
* **Exemplo:** `./todo.sh add "Finalizar a documentação da API" -d 2026-08-30`
* **Comportamento:** O script intercepta a flag `-d`, converte a data para Timestamp Unix (final do dia) e repassa para a função `add` nativa.

### 2. Gerenciar Prazos (CRUD)

Novos comandos dedicados para adicionar, alterar ou remover o deadline de uma tarefa existente utilizando o seu `id` (número da linha).

* **Adicionar/Atualizar Prazo:**
* **Uso:** `./todo.sh deadline <id_task> <yyyy-mm-dd> <HH:MM>`
* **Exemplo:** `./todo.sh deadline 3 2026-08-25`
* **Comportamento:** Adiciona a tag `due:TIMESTAMP` à tarefa 3. Se a tarefa já possuía um deadline, o valor antigo é removido antes da inserção.


* **Remover Prazo:**
* **Uso:** `./todo.sh rmdeadline <id_task>`
* **Exemplo:** `./todo.sh rmdeadline 3`
* **Comportamento:** Remove de forma limpa a tag `due:` da tarefa especificada. Se não houver deadline, nada acontece.



---

## ⏰ Módulo Independente de Alarme

Preparamos um módulo de notificação visual via pop-up do sistema operacional. Ele foi construído de forma independente para ser facilmente acoplado a futuros scripts da V2 (como um daemon ou cron job).

* **Uso:** `./actions/alarme.sh "<horário>" "<mensagem do popup>"`
* **Exemplo (Horário fixo):** `./actions/alarme.sh "15:30" "Reunião de Alinhamento" &`
* **Exemplo (Tempo relativo):** `./actions/alarme.sh "+10 minutes" "Levantar e beber água" &`

*(Nota: Utilize o `&` no final do comando no terminal para que o script rode em segundo plano sem travar a aba atual).*

---

## 🔜 Próximos Passos (Backlog V2)

Para os desenvolvedores que forem assumir as próximas etapas do projeto, o escopo da V2 inclui:

* [ ] `notify_when_expired()`: Criação de um job em background que lê o arquivo `todo.txt`, procura por tags `due:` vencidas que não tenham o status `x` (done), e aciona o `alarme.sh`.
* [ ] Suporte a datas relativas na CLI (ex: `./todo.sh add Tarefa -d today`, ou `-d +2d`).
* [ ] Filtros de listagem customizados (ex: `./todo.sh ls --date <deadline>`).

---

### Como usar isso no seu projeto:

Basta copiar o texto acima, colar num arquivo chamado `README-EQUIPE.md` (ou sobrescrever/acrescentar no final do `README.md` já existente da pasta) e fazer o commit para o Git.

Se a equipe for seguir para a **V2** depois, eu estarei à disposição para ajudá-los a criar a função de letura de datas relativas (`today`, `+2d`) e o filtro de listagem!
