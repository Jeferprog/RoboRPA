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

### 1. Configurar frases (`phrases.json`)

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

### 2. Rodar o sistema

```bash
python keyboard_trigger.py
```

Ou em loop infinito (Ctrl+C para parar):
```bash
python keyboard_trigger.py
```

### 3. Usar

- Coloque o cursor onde quer digitar (campo de texto, email, etc.)
- Pressione o hotkey (ex: `Ctrl+Alt+1`)
- ✍️ A frase é digitada automaticamente!

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
