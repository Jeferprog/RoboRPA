# Atalho global de verdade (Ctrl+Alt+1 em qualquer lugar)

Esta e a versao com **atalhos globais reais**: voce aperta `Ctrl+Alt+1`
(ou o atalho que quiser) em **qualquer janela** e a frase e digitada
sozinha, como se voce tivesse digitado.

- Nao precisa de admin.
- Nao precisa instalar nada (usa o compilador C# que ja vem no Windows).
- Funciona com acentos e simbolos.
- Fica discreto na bandeja do sistema (perto do relogio).

## Arquivos

| Arquivo | Para que serve |
|---------|----------------|
| `KeyboardTrigger.cs` | O programa (codigo-fonte C#). |
| `compilar_e_iniciar.bat` | Compila e inicia. Use na 1a vez e sempre que mudar o `.cs`. |
| `criar_inicializacao_exe.bat` | Faz iniciar sozinho junto com o Windows. |
| `phrases.json` | Suas frases e atalhos (gere no `keyboard_trigger_manager.html`). |

## Passo a passo (1a vez)

1. Coloque numa pasta (ex: `Desktop\Meus\Frases\`) os arquivos:
   - `KeyboardTrigger.cs`
   - `compilar_e_iniciar.bat`
   - `phrases.json`  (gerado no `keyboard_trigger_manager.html`)
2. De **duplo-clique** em `compilar_e_iniciar.bat`.
   - Ele cria o `KeyboardTrigger.exe` e ja inicia o programa.
   - Vai aparecer um balaozinho: "Rodando. Atalhos ativos: N".
3. Teste: clique num campo de texto qualquer (Bloco de Notas, e-mail...)
   e aperte **Ctrl+Alt+1**. A frase e digitada.

## Para iniciar sozinho com o Windows (opcional)

- De **duplo-clique** em `criar_inicializacao_exe.bat`.
- Pronto: toda vez que entrar no Windows, o programa ja sobe.

## Dia a dia

- **Icone na bandeja** (perto do relogio) → botao direito:
  - **Ver atalhos** – lista o que esta ativo.
  - **Recarregar frases** – depois de trocar o `phrases.json`.
  - **Sair** – encerra o programa.

## Trocar/adicionar frases

1. Abra `keyboard_trigger_manager.html`, edite as frases e baixe o
   `phrases.json` novo (salve na mesma pasta, substituindo o antigo).
2. No icone da bandeja → **Recarregar frases**.

## Atalhos aceitos

- `Ctrl`, `Alt`, `Shift`, `Win` combinados com:
  - uma letra `A`-`Z` (ex: `Ctrl+Shift+A`)
  - um numero `0`-`9` (ex: `Ctrl+Alt+1`)
  - uma tecla de funcao `F1`-`F12` (ex: `Ctrl+Alt+F2`)
- Exemplos validos: `Ctrl+Alt+1`, `Ctrl+Shift+2`, `Alt+F3`.
- Se um atalho aparecer em "Com problema: ja em uso", escolha outra
  combinacao (algum outro programa ja usa aquela).

## Observacoes

- Se editar o `KeyboardTrigger.cs`, rode de novo o
  `compilar_e_iniciar.bat` (ele fecha a versao antiga e recompila).
- So roda **uma** instancia por vez (evita digitar em dobro).
