# 🎹 Keyboard Trigger System

Sistema para **escutar hotkeys** (atalhos de teclado) e **simular digitação** de frases prontas automaticamente.

Perfecto para usuários que precisam digitar textos repetitivos rapidamente.

## ✨ Características

- 📝 **Múltiplas frases**: Cadastre quantas quiser em `phrases.json`
- ⚡ **Acionamento por hotkey**: Pressione `Ctrl+Alt+1`, `Ctrl+Alt+2`, etc.
- 🖱️ **Simula digitação real**: Escreve como se você estivesse digitando
- 🔧 **Configuração simples**: Arquivo JSON fácil de editar
- 🚀 **Sem dependências externas**: Usa apenas Python nativo + Windows

## 🚀 Quick Start

### Opção 1: Usar o Gerenciador Web (Recomendado! 🎯)

**Mais fácil e intuitivo:**

1. **Abra o gerenciador:**
   - Duplo-clique em `keyboard_trigger_manager.html` ou
   - Arraste o arquivo para o navegador

2. **Gereneie suas frases:**
   - ➕ Adicione quantas frases quiser
   - ✏️ Edite existentes
   - 🗑️ Delete as que não precisa
   - 📋 Visualize em tempo real

3. **Baixe o arquivo:**
   - ⬇️ Clique em "Baixar phrases.json"
   - Salve na mesma pasta do `keyboard_trigger.py`

4. **Execute o script:**
   ```bash
   python keyboard_trigger.py
   ```

---

### Opção 2: Editar `phrases.json` manualmente

Se preferir editar direto:

```json
{
  "Ctrl+Alt+1": "Jeferson Demarchi Deimling\nCresol Cooperar",
  "Ctrl+Alt+2": "Sua segunda frase",
  "Ctrl+Alt+3": "Terceira frase"
}
```

**Notas:**
- `\n` = quebra de linha
- Hotkeys: `Ctrl+Alt+[1-9]`, `Ctrl+Shift+[A-Z]`, etc.

---

### 3. Executar e usar

```bash
python keyboard_trigger.py
```

- Coloque o cursor onde quer digitar (campo de texto, email, etc.)
- Pressione o hotkey (ex: `Ctrl+Alt+1`)
- ✍️ A frase é digitada automaticamente!

---

## 🌐 Gerenciador Web (Novo! ✨)

**`keyboard_trigger_manager.html`** - Interface completa para gerenciar frases!

### Funcionalidades:

- ✅ **Adicionar frases** - Formulário simples e intuitivo
- ✅ **Editar frases** - Clique em "Editar" para modificar
- ✅ **Deletar frases** - Remove com confirmação
- ✅ **Visualizar JSON** - Preview em tempo real com sintaxe highlighting
- ✅ **Baixar arquivo** - Gera `phrases.json` pronto para usar
- ✅ **Importar JSON** - Cole um JSON existente para carregar
- ✅ **Copiar para clipboard** - Compartilhe a configuração facilmente
- ✅ **Armazenamento local** - Tudo fica salvo no navegador

### Como usar:

1. **Abra no navegador:**
   ```
   Duplo-clique em: keyboard_trigger_manager.html
   ```

2. **Adicione suas frases:**
   - Preencha o atalho (ex: `Ctrl+Alt+1`)
   - Digite a frase
   - Clique em "💾 Salvar Frase"

3. **Visualize no JSON:**
   - A seção "Preview" mostra o JSON atualizado em tempo real

4. **Baixe ou copie:**
   - ⬇️ **Baixar**: Gera arquivo `phrases.json`
   - 📋 **Copiar**: Copia JSON para colar em outro lugar

5. **Pronto!**
   - Use o JSON baixado com `keyboard_trigger.py`

---

## 📋 Configuração

### Editar `phrases.json`

```json
{
  "Ctrl+Alt+1": "Primeira frase\ncom quebra de linha",
  "Ctrl+Alt+2": "Segunda frase",
  "Ctrl+Shift+A": "Frase com Shift",
  "Shift+Alt+3": "Combinações variadas",
  "Ctrl+Alt+4": "Quantas quiser!"
}
```

**Hotkeys suportados:**
- `Ctrl+Alt+[0-9]`
- `Ctrl+Shift+[A-Z]`
- `Alt+[0-9]`
- Qualquer combinação de `Ctrl`, `Shift`, `Alt` + caractere

### Caracteres especiais

Se sua frase tem caracteres que podem conflitar com o VBScript, eles são escapados automaticamente:
- Aspas duplas `"`
- Chaves `{}`
- Mais `+`

---

## ⚙️ Como funciona

```
┌─────────────────┐
│ Python Script   │ ← Monitora teclado
└────────┬────────┘
         │
         ├─→ Detecta hotkey (ex: Ctrl+Alt+1)
         │
         ├─→ Busca frase em phrases.json
         │
         └─→ Executa VBScript com SendKeys
              ↓
         └─→ Digita a frase no campo ativo
```

---

## 🔧 Instalação (Recomendado)

Para melhor performance e confiabilidade, instale o pacote `keyboard`:

```bash
pip install keyboard
```

**Sem isso:**
- Sistema funciona, mas requer VBScript
- Performance é boa mesmo assim
- Ideal para máquinas com restrições de rede

---

## 💾 Estrutura de arquivos

```
/keyboard-trigger/
├── keyboard_trigger.py       # Script principal
├── phrases.json              # Suas frases
├── keyboard_trigger.vbs      # Alternativa em VBScript puro
└── README.md                 # Este arquivo
```

---

## 🐛 Troubleshooting

### "Nenhuma frase configurada"
- Verifique se `phrases.json` existe
- Abra com editor de texto e valide JSON (use jsonlint.com)

### "Nada foi digitado"
- Certifique-se de que o cursor está em um campo de texto
- Aguarde ~500ms após pressionar o hotkey
- Verifique se o hotkey não está sendo bloqueado por outro programa

### Caracteres estranhos digitados
- Pode ser um conflito de layout de teclado
- Edite `phrases.json` e substitua caracteres problemáticos

### "Access Denied" ao executar `.vbs`
- Pode ser política de segurança do Windows
- Tente rodar PowerShell como administrador

---

## 🔐 Segurança

- ✅ Apenas texto digitado (sem código executado)
- ✅ Arquivo JSON transparente (você vê tudo)
- ✅ Nenhuma conexão de rede
- ✅ Roda localmente apenas

---

## 📦 Versão alternativa: VBScript Puro

Se preferir **sem Python**, veja `keyboard_trigger.vbs` — funciona direto no Windows.

---

## 📝 Exemplos de uso

### Assinatura de email
```json
{
  "Ctrl+Alt+1": "Atenciosamente,\nJeferson Demarchi Deimling\nCresol Cooperar"
}
```

### Telefone corporativo
```json
{
  "Ctrl+Alt+2": "(XX) XXXX-XXXX"
}
```

### Endereço
```json
{
  "Ctrl+Alt+3": "Rua X, nº 123\nCidade - Estado\nCEP: XXXXX-XXX"
}
```

---

## 🎯 Próximos passos

- [ ] Instalar `keyboard` package: `pip install keyboard`
- [ ] Configurar suas frases em `phrases.json`
- [ ] Testar com `python keyboard_trigger.py`
- [ ] Criar atalho no Iniciar do Windows (opcional)

---

## 📞 Suporte

Dúvidas? Abra uma issue no repositório GitHub! 

---

**Versão**: 1.0.0  
**Compatibilidade**: Windows 7+ com Python 3.6+  
**Licença**: MIT
