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

## Dia a dia

- Icone na **bandeja** (perto do relogio) -> botao direito:
  - **Ver atalhos** - lista o que esta ativo.
  - **Recarregar frases** - depois de trocar o `phrases.json`.
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

- `@keyHoldMs` = tempo segurando cada tecla (padrao 12)
- `@charDelayMs` = pausa entre uma tecla e a proxima (padrao 8)

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
