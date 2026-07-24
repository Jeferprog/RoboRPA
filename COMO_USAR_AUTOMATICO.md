# ⚡ Como Usar o Keyboard Trigger Automaticamente

Não quer abrir manualmente toda vez? Aqui estão suas opções!

---

## 🎯 3 Formas de Usar

### **Opção 1: Auto-iniciar com o PC** (RECOMENDADO)

Keyboard Trigger inicia **automaticamente quando você liga o computador**!

#### Como ativar:

1. **Duplo-clique em:**
   ```
   criar_autoexec.bat
   ```

2. Clique "Sim" nas mensagens

3. **Pronto!** 🎉

   - A partir de agora, Keyboard Trigger vai iniciar sozinho
   - Toda vez que ligar o PC, está rodando
   - Abra a bandeja de tarefas e clique quando precisar

---

### **Opção 2: Atalho na Área de Trabalho** (MAIS FÁCIL)

Cria um atalho rápido para clicar quando quiser.

#### Como ativar:

1. **Duplo-clique em:**
   ```
   criar_atalho_desktop.bat
   ```

2. Vai criar um atalho na sua área de trabalho

3. **Sempre que quiser usar:**
   ```
   Duplo-clique no atalho "🎹 Keyboard Trigger"
   ```

---

### **Opção 3: Deixar Rodando em Background** (CONTÍNUO)

Roda continuamente esperando você usar.

#### Como usar:

1. **Duplo-clique em:**
   ```
   keyboard_trigger_background.vbs
   ```

2. Menu aparece

3. **Toda vez que precisar:**
   - Clique na janela ou bandeja de tarefas
   - Selecione a frase
   - Pronto!

4. **Deixe sempre aberto**

---

## 📊 Comparação das 3 Opções

| Opção | Auto-inicia? | Sempre rodando? | Fácil? |
|-------|-------------|-----------------|--------|
| **Auto-exec (Opção 1)** | ✅ Sim | ✅ Sim | ⭐⭐⭐ |
| **Atalho Desktop (Opção 2)** | ❌ Não | ❌ Não | ⭐⭐⭐⭐ |
| **Background (Opção 3)** | ❌ Manual | ✅ Sim | ⭐⭐⭐ |

---

## 🚀 Recomendação

### Para máquinas corporativas:

**Use AMBAS:**

1. ✅ **Opção 1** (Auto-exec)
   - Auto-inicia ao ligar
   - Você nem precisa fazer nada

2. ✅ **Opção 2** (Atalho)
   - Se preferir iniciar manualmente
   - Clique rápido na área de trabalho

---

## 📋 Passo a Passo Completo

### Primeira vez:

```
1. Duplo-clique: keyboard_trigger_manager.html
   └─ Adicione suas frases

2. Clique: "⬇️ Baixar phrases.json"
   └─ Salva na mesma pasta

3. Duplo-clique: criar_autoexec.bat
   └─ Vai auto-iniciar ao ligar

4. (Opcional) Duplo-clique: criar_atalho_desktop.bat
   └─ Cria atalho na área de trabalho
```

### Depois (sempre):

```
✅ Keyboard Trigger JÁ está rodando!

Quando precisar usar:
├─ Opção A: Clique no atalho da área de trabalho
└─ Opção B: Procure na bandeja de tarefas
   └─ Clique nele
      └─ Menu aparece
         └─ Selecione a frase
            └─ ✍️ Digitado!
```

---

## 🔧 Se não funcionar

### ❌ Auto-exec não está iniciando

**Solução:**
- Verifique se criou corretamente com `criar_autoexec.bat`
- Abra a pasta:
  ```
  %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
  ```
- Deve ter um arquivo "Keyboard Trigger.lnk"

### ❌ Atalho não foi criado

**Solução:**
- Duplo-clique novamente em `criar_atalho_desktop.bat`
- Verifique a área de trabalho

### ❌ Background não aparece

**Solução:**
- Procure na bandeja de tarefas (canto inferior direito)
- Clique nela para trazer à frente

---

## 💡 Dicas Extras

### Minimizar para bandeja:

Se quiser deixar minimizado na bandeja:

1. Abra `keyboard_trigger_background.vbs`
2. Clique no botão minimizar (não feche!)
3. Fica na bandeja, basta clicar quando precisar

### Executar sempre como você mesmo:

Se criar auto-exec com permissões especiais:
- Clique direito no atalho
- Propriedades → Avançado
- Pode configurar permissões

---

## 📞 Resumo Final

```
┌─────────────────────────────────────────┐
│  PRIMEIRA VEZ (Setup)                   │
├─────────────────────────────────────────┤
│  1. Adicione frases no HTML              │
│  2. Duplo-clique criar_autoexec.bat     │
│  3. (Opcional) criar_atalho_desktop.bat │
└─────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────┐
│  A PARTIR DE AGORA                       │
├─────────────────────────────────────────┤
│  ✅ Keyboard Trigger roda automaticamente│
│  ✅ Use quando precisar                 │
│  ✅ Sem fazer nada especial!            │
└─────────────────────────────────────────┘
```

**Pronto para começar?** 🎉

1. Execute `criar_autoexec.bat`
2. Reinicie o PC
3. Keyboard Trigger vai estar lá quando acordar!
