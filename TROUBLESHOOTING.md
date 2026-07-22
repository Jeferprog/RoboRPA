# 🔧 Troubleshooting - Keyboard Trigger

## ❌ "python: comando não encontrado" ou similar

Se você vê um erro assim ao tentar executar `python keyboard_trigger.py`:

```
'python' is not recognized as an internal or external command
python: command not found
```

### ✅ Solução: Use os arquivos executáveis

Em vez de digitar comandos no terminal, use um destes:

#### **Opção 1: Duplo-clique em `iniciar.bat` (MAIS FÁCIL)**
- Funciona direto no Windows
- Não precisa abrir terminal
- Trata erros automaticamente

#### **Opção 2: Duplo-clique em `iniciar.vbs`**
- Executa em background (sem janela preta)
- Mostra mensagem quando termina
- Totalmente silencioso

#### **Opção 3: Clique direito em `iniciar.ps1`**
- Selecione "Executar com PowerShell"
- Mais detalhado e colorido
- Bom para debug

---

## ❌ Python não está instalado

Se nenhum dos arquivos funcionar:

### ✅ Passo 1: Instalar Python

1. Acesse: **https://www.python.org/downloads/**
2. Baixe a versão mais recente (3.9+)
3. Execute o instalador
4. **IMPORTANTE:** Marque esta opção:
   ```
   ☑ Add Python to PATH
   ```
5. Clique em "Install Now"
6. Aguarde concluir

### ✅ Passo 2: Reiniciar o computador

Depois da instalação, **reinicie o computador** para Python ficar disponível.

### ✅ Passo 3: Tentar novamente

Depois, duplo-clique em `iniciar.bat` ou `iniciar.vbs`.

---

## ❌ "Python não encontrado" mesmo após instalar

Se ainda assim não funcionar:

### ✅ Verificar se Python está instalado

1. Abra **Prompt de Comando** (cmd.exe):
   - Pressione `Win + R`
   - Digite `cmd`
   - Pressione Enter

2. Digite:
   ```bash
   python --version
   ```

3. Você deve ver algo como:
   ```
   Python 3.11.5
   ```

### ✅ Se não funcionou:

**Opção A:** Instale novamente, marcando "Add Python to PATH"

**Opção B:** Descubra onde Python está instalado:
   - Abra o instalador novamente
   - Clique "Modify"
   - Veja o caminho de instalação (ex: `C:\Python311`)
   - Adicione esse caminho ao PATH do Windows

---

## ❌ "Permissão negada" ao executar `.vbs` ou `.bat`

Se Windows bloquear a execução:

### ✅ Solução:

1. **Clique direito** no arquivo (`iniciar.bat` ou `iniciar.vbs`)
2. Selecione **Propriedades**
3. Vá para a aba **Geral**
4. Marque: ☑ **Desbloquear**
5. Clique **Aplicar** e **OK**

---

## ❌ A janela fecha muito rápido

Se a janela do terminal desaparecer rapidamente:

### ✅ Solução:

Use `iniciar.bat` que pausará antes de fechar:
```bash
pause
```

Ou abra Prompt de Comando e execute manualmente:
```bash
cd C:\seu\caminho\aqui
python keyboard_trigger.py
```

---

## ❌ Hotkeys não funcionam

Se os hotkeys não forem detectados:

### ✅ Solução 1: Instalar pacote `keyboard`

```bash
pip install keyboard
```

Isso melhora MUITO a detecção de hotkeys.

### ✅ Solução 2: Verificar conflitos

- Outros programas podem estar usando os mesmos hotkeys
- Tente hotkeys diferentes (ex: `Ctrl+Alt+9`)
- Desligue programas que possam conflitar

### ✅ Solução 3: Permissões de administrador

Alguns hotkeys precisam de privilégios de admin:
- Clique direito em `iniciar.bat`
- Selecione "Executar como administrador"

---

## ❌ Nada foi digitado

Se o hotkey foi pressionado mas nada apareceu:

### ✅ Verificar:

1. **O campo está ativo?**
   - Clique no campo de texto primeiro
   - Depois pressione o hotkey

2. **Aguarde um pouco:**
   - Às vezes há delay (~500ms)
   - Tente aguardar 1 segundo após pressionar

3. **Tente outro hotkey:**
   - Pressione `Ctrl+Alt+2` ao invés de `Ctrl+Alt+1`
   - Confirme que há uma frase cadastrada para esse hotkey

4. **Verifique o JSON:**
   - Abra `phrases.json` com bloco de notas
   - Confirme que tem a frase certa
   - Se aparecer erro de JSON, use o gerenciador HTML

---

## ❌ Erro: "cscript.exe: não encontrado"

Essa é uma limitação do VBScript. Tente:

### ✅ Solução:

Use `iniciar.bat` ou `iniciar.ps1` em vez de `iniciar.vbs`

---

## 🆘 Ainda não funciona?

Se nada disso resolver:

1. **Copie a mensagem de erro** (print da tela)
2. **Verificar:**
   - Qual arquivo tentou usar? (bat, vbs, ps1)
   - Qual foi o erro exato?
   - Python está instalado? (`python --version`)
   - Python está no PATH? (tente no Prompt de Comando)

3. **Contate o suporte** com essas informações

---

## 📋 Resumo das opções

| Opção | Comando | Fácil? | Requer Terminal? |
|-------|---------|--------|------------------|
| **iniciar.bat** | Duplo-clique | ✅✅✅ | ❌ |
| **iniciar.vbs** | Duplo-clique | ✅✅✅ | ❌ |
| **iniciar.ps1** | Click direito | ✅✅ | ⚠️ (PowerShell) |
| **Terminal cmd** | `python ...` | ❌ | ✅ |

**Recomendação:** Comece com `iniciar.bat` - é o mais simples e confiável!

---

## 💡 Dicas

- ✅ Sempre use `iniciar.bat` ou `.vbs` (mais fácil que terminal)
- ✅ Se Python não funcionar, reinstale marcando "Add to PATH"
- ✅ Reinicie após instalar Python
- ✅ Use o gerenciador HTML para configurar frases (não precisa de Python)
- ✅ Se hotkeys não funcionam, instale `pip install keyboard`

---

**Tudo funcionando?** 🎉 Ótimo! Aproveite o Keyboard Trigger!
