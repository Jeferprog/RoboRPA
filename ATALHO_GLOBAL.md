# Keyboard Trigger - atalhos globais que digitam frases prontas

Aperte um atalho (ex: `Ctrl+Shift+A`) em **qualquer janela** e a frase
cadastrada e digitada sozinha, como se voce tivesse digitado.

- Nao precisa de admin.
- Nao precisa instalar nada (usa o compilador C# que ja vem no Windows).
- Funciona com acentos e simbolos.
- Fica discreto na bandeja do sistema (perto do relogio).

## Arquivos

| Arquivo | Para que serve |
|---------|----------------|
| `KeyboardTrigger.cs` | O programa (codigo-fonte C#). |
| `compilar_e_iniciar.bat` | Compila e inicia. Use na 1a vez e sempre que trocar o `.cs`. |
| `criar_inicializacao_exe.bat` | Faz iniciar sozinho junto com o Windows. |
| `keyboard_trigger_manager.html` | Tela para cadastrar/editar frases e baixar o `phrases.json`. |
| `phrases.json` | Suas frases e atalhos (gerado pelo HTML acima). |
| `compilar_debug.bat` | (Opcional) Compila mostrando tudo e gera logs, para diagnostico. |
| `diagnostico.bat` | (Opcional) Verifica o que a maquina permite (usado no 1o setup). |

## Passo a passo (1a vez)

1. Numa pasta (ex: `Desktop\Meus\Frases\`) coloque:
   - `KeyboardTrigger.cs`
   - `compilar_e_iniciar.bat`
   - `phrases.json` (gerado no `keyboard_trigger_manager.html`)
2. De **duplo-clique** em `compilar_e_iniciar.bat`.
   - Ele cria o `KeyboardTrigger.exe` e ja inicia o programa.
3. Teste: clique num campo de texto (Bloco de Notas, e-mail...) e
   aperte o atalho cadastrado. A frase e digitada.
4. (Opcional) De **duplo-clique** em `criar_inicializacao_exe.bat` para
   ele subir sozinho toda vez que voce entrar no Windows.

## Compartilhar com colegas (1 arquivo so)

O `keyboard_trigger_manager.html` gera um **instalador unico** com o programa
ja embutido. Para preparar para um colega:

1. Abra o `keyboard_trigger_manager.html`.
2. Cadastre as frases/atalhos que ele vai usar (ou deixe as suas como base).
3. Clique em **"Baixar instalador (.bat)"** -> gera `KeyboardTrigger_Instalar.bat`.
4. Envie **esse unico arquivo** para o colega.

O colega so precisa dar **duplo-clique** no `.bat`. Ele sozinho:
- cria a pasta `%LOCALAPPDATA%\KeyboardTrigger`,
- grava o programa e as frases,
- compila com o compilador que ja vem no Windows,
- inicia na bandeja e configura para abrir junto com o Windows.

Nao precisa instalar nada, nao precisa de internet e nao precisa de admin.

Para o colega **trocar as frases** depois: icone na bandeja ->
**Abrir pasta das frases** -> editar/substituir o `phrases.json`
(ou gerar um novo no HTML) -> **Recarregar frases**.

## Dia a dia

- Icone na **bandeja** (perto do relogio) -> botao direito:
  - **Ver atalhos** - lista o que esta ativo.
  - **Recarregar frases** - depois de trocar o `phrases.json`.
  - **Abrir pasta das frases** - abre a pasta onde esta o `phrases.json`.
  - **Sair** - encerra o programa.

## Trocar / adicionar frases

1. Abra `keyboard_trigger_manager.html`, edite as frases e baixe o
   `phrases.json` novo (salve na mesma pasta, substituindo o antigo).
2. No icone da bandeja -> **Recarregar frases**.

## Atalhos aceitos

- `Ctrl`, `Alt`, `Shift`, `Win` combinados com:
  - uma letra `A`-`Z` (ex: `Ctrl+Shift+A`)
  - um numero `0`-`9` (ex: `Ctrl+Alt+1`)
  - uma tecla de funcao `F1`-`F12` (ex: `Ctrl+Alt+F2`)
- Se um atalho aparecer como "com problema / ja em uso", escolha outra
  combinacao (algum outro programa ja usa aquela).

## Capturar da tela (copiar selecao e digitar)

Da para "puxar" um texto que esta na tela (ex: um numero) e digita-lo em
outro campo, usando dois atalhos:

1. Um atalho com a frase **`@capturar`**: ao apertar, ele copia o texto
   que estiver **selecionado** (faz Ctrl+C) e guarda na memoria.
2. Outro atalho com a frase **`{numeros}`** (so os digitos) ou
   **`{captura}`** (o texto inteiro): ao apertar, digita o que foi
   capturado no campo onde esta o cursor.

Tambem da para montar modelos, ex.: uma frase `Protocolo {numeros}`.

### Tabelas: pegar colunas especificas

Ao capturar uma tabela (selecionar as linhas e Ctrl+C), as colunas vem
separadas por Tab. Use marcadores de coluna (1 = primeira coluna):

- **`{coluna:1}`** -> so a 1a coluna (um valor por linha).
- **`{colunas:1,3}`** -> a 1a e a 3a coluna, lado a lado (separadas por Tab).

Exemplo do caso "datas (col 1) e valores de Vencido (col 3)":
1. Selecione a tabela na tela -> atalho **@capturar**.
2. Clique no Excel/campo -> atalho com a frase **`{colunas:1,3}`**.

Dica: **marque o "Modo colar"** para tabelas - assim cola direto nas
celulas do Excel (Tab vira coluna, Enter vira linha). Se quiser sem o
cabecalho, selecione a tabela ja sem a linha de titulo.

Fluxo de uso:
- Selecione o numero na tela -> aperte o atalho **@capturar**.
- Clique no campo de destino -> aperte o atalho **{numeros}**.

E confiavel porque usa o texto real da selecao (nao "le" a imagem).
So funciona quando o texto e **selecionavel** (paginas, PDFs de texto...).

## Modo colar (escrita instantanea)

No `keyboard_trigger_manager.html` ha um checkbox **"Modo colar"**. Marcado,
ele inclui `"@mode": "paste"` no `phrases.json` e no instalador
automaticamente - nao precisa editar nada a mao. Recomendado para
formularios web (Chrome/Edge). Para aplicar numa instalacao existente,
gere o novo `phrases.json`/instalador e recarregue (bandeja -> Recarregar).

## Atualizar frases num PC ja instalado

Duas formas:

1. **Pelo instalador** (mais simples): gere um novo instalador no HTML e
   rode no PC. Ele **atualiza** o `phrases.json` (guardando o anterior em
   `phrases.anterior.json`) e recompila. Reinicie o programa ou use
   bandeja -> Recarregar.
2. **Sem reinstalar**: bandeja -> **Abrir pasta das frases**, substitua o
   `phrases.json` (baixado do HTML) e clique em **Recarregar frases**.

## Frase vindo cortada em site (Chrome/Edge)

Alguns campos web (principalmente com mascara de CPF/telefone, ou com
validacao em JavaScript) perdem caracteres quando a frase e digitada.
Solucao: ligar o **modo colar**, que usa Ctrl+V em vez de digitar.

Abra o `phrases.json` no Bloco de Notas e adicione a linha `"@mode": "paste",`
logo depois da primeira chave `{`. Exemplo:

```json
{
  "@mode": "paste",
  "Ctrl+Shift+A": "Jeferson Demarchi Deimling\nCresol Cooperar"
}
```

Depois, no icone da bandeja -> **Recarregar frases**. O balao vai mostrar
"(modo colar)".

Se preferir continuar **digitando** (sem colar), mas ainda vier cortado,
de para deixar mais lento com estas linhas (tambem no inicio do JSON):

```json
{
  "@keyHoldMs": "20",
  "@charDelayMs": "15",
  "Ctrl+Shift+A": "..."
}
```

- `@keyHoldMs` = tempo segurando cada tecla (padrao 4)
- `@charDelayMs` = pausa entre uma tecla e a proxima (padrao 4)

Para escrever **instantaneo**, prefira o modo colar (`"@mode": "paste"`).

## Se algo der errado

- Rode `compilar_debug.bat`: ele mostra os erros de compilacao e gera
  `compilar_log.txt` e `keyboardtrigger_log.txt` com o que aconteceu.
- Se o `KeyboardTrigger.exe` "sumir" sozinho, pode ser o antivirus
  (Seguranca do Windows > Protecao contra virus > Historico).

## Observacoes

- So roda **uma** instancia por vez (evita digitar em dobro).
- Se editar o `KeyboardTrigger.cs`, rode de novo o
  `compilar_e_iniciar.bat` (ele fecha a versao antiga e recompila).
- O `.exe` e os arquivos de log sao gerados na sua maquina e nao ficam
  no repositorio (estao no `.gitignore`).
