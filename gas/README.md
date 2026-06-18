# Cresol RPA Web — Implantação como Google Apps Script (GAS)

Este guia transforma o app (hoje um arquivo HTML offline) em um **web app do Google**,
com os robôs guardados numa **Planilha Google** — assim eles ficam **centralizados** e
podem ser **vistos e usados em qualquer máquina** (para baixar o `.vbs` e agendar localmente).

## Como funciona

```
Navegador (qualquer PC) → URL do Web App (GAS) → doGet() serve o Index.html
                                              → google.script.run lê/grava na Planilha
```

O **mesmo** arquivo `Criador Robô.html` funciona nos dois modos:
- **Aberto como arquivo local:** salva no `localStorage` do navegador (como antes).
- **Servido pelo GAS:** salva automaticamente na **Planilha Google** (detecta o ambiente sozinho).

## Passo a passo

### 1. Criar a Planilha (banco de dados)
1. Crie uma **Planilha Google** em branco (https://sheets.new).
2. Copie o **ID** da planilha (na URL: `.../spreadsheets/d/`**`ESTE_ID`**`/edit`).
3. A aba `Robos` é criada automaticamente na primeira gravação (não precisa criar à mão).

### 2. Criar o projeto Apps Script
1. Acesse https://script.google.com → **Novo projeto**.
2. No arquivo `Código.gs`, **apague o conteúdo** e cole o conteúdo de **`gas/Code.gs`** deste repositório.
3. No topo do `Code.gs`, preencha `SHEET_ID` com o ID da planilha do passo 1.
4. (Opcional) Para restringir acesso, liste os e-mails em `ALLOWED_EMAILS`.

### 3. Adicionar a interface (HTML)
1. No editor do Apps Script: **+** (Adicionar arquivo) → **HTML** → nomeie como **`Index`** (sem `.html`).
2. **Apague** o conteúdo padrão e **cole todo o conteúdo** de **`Criador Robô.html`** deste repositório.
3. Salve (💾).

> Mantemos um único código-fonte: o `Index.html` do GAS é uma cópia fiel do `Criador Robô.html`.
> Quando atualizar o app, basta colar a versão nova no arquivo `Index`.

### 4. Implantar como Web App
1. **Implantar** → **Nova implantação** → tipo **App da Web**.
2. **Executar como:** `Eu`.
3. **Quem tem acesso:** `Somente eu` (recomendado para o seu caso de uso individual).
4. **Implantar** e autorizar as permissões solicitadas.
5. Copie a **URL do app da Web** — é ela que você abre em qualquer máquina.

### 5. Usar em outros computadores
- Abra a URL do Web App, faça login com **sua conta Google autorizada**.
- Os robôs carregam da planilha (iguais em qualquer máquina).
- Selecione um robô e baixe o `.vbs` / o agendador `.bat` **naquele** computador.

## Liberar para poucas contas (além da sua)

Como a opção "Somente eu" libera apenas o dono, para incluir **outras contas**:

1. **Compartilhe a Planilha** (passo 1) com os e-mails dessas pessoas (como Editor).
2. Na implantação, use **Executar como: `Usuário que acessa`** e **Quem tem acesso: `Qualquer pessoa com Conta do Google`**.
3. Em `ALLOWED_EMAILS`, liste exatamente os e-mails permitidos (a checagem `isAuthorized()` bloqueia o resto).

> Observação: com "Executar como: Usuário que acessa", cada pessoa precisa ter acesso de
> edição à planilha, pois o script grava em nome dela.

## Observações importantes

- **Download do `.vbs`/`.bat` dentro do GAS:** a interface roda num iframe isolado. Em navegadores
  atuais o download funciona; se algum bloquear, me avise que adapto para baixar via outra técnica.
- **Backup:** os botões **Exportar/Importar JSON** continuam funcionando como cópia de segurança manual.
- **Concorrência:** a gravação usa `LockService` para evitar dois salvamentos simultâneos corromperem a lista.
- **Segurança:** os robôs (textos digitados, etc.) ficam na sua planilha — trate-a como dado sensível
  e não compartilhe além do necessário.
