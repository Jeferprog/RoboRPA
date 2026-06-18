/****************************************************************
 * Cresol RPA Web - Backend Google Apps Script (GAS)
 *
 * Guarda os robôs numa Planilha Google e serve a interface (Index.html).
 * Veja o passo a passo de implantação em gas/README.md.
 ****************************************************************/

// =========================================
// CONFIGURAÇÃO (ajuste estes valores)
// =========================================

// ID da Planilha Google que servirá de banco de dados.
// (está na URL da planilha: https://docs.google.com/spreadsheets/d/ESTE_ID/edit)
// Deixe vazio ('') se o script estiver VINCULADO a uma planilha (Extensões > Apps Script).
var SHEET_ID = '';

// Nome da aba onde os robôs ficam guardados (criada automaticamente se não existir).
var SHEET_NAME = 'Robos';

// Contas autorizadas. Deixe a lista VAZIA ([]) para liberar para qualquer usuário logado
// que tenha acesso à implantação. Para restringir, coloque os e-mails permitidos.
var ALLOWED_EMAILS = [
  // 'voce@exemplo.com',
];

// =========================================
// SERVIR A INTERFACE
// =========================================
function doGet() {
  if (!isAuthorized()) {
    return HtmlService.createHtmlOutput(
      '<h2>Acesso negado</h2><p>Sua conta não tem permissão para acessar este aplicativo.</p>'
    );
  }
  return HtmlService.createHtmlOutputFromFile('Index')
    .setTitle('Cresol RPA Web')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

// =========================================
// AUTORIZAÇÃO
// =========================================
function isAuthorized() {
  if (!ALLOWED_EMAILS || ALLOWED_EMAILS.length === 0) return true;
  var email = Session.getActiveUser().getEmail();
  return email && ALLOWED_EMAILS.indexOf(email) !== -1;
}

// =========================================
// PLANILHA (banco de dados)
// =========================================
function getSheet_() {
  var ss = SHEET_ID ? SpreadsheetApp.openById(SHEET_ID) : SpreadsheetApp.getActiveSpreadsheet();
  if (!ss) {
    throw new Error('Planilha não encontrada. Preencha SHEET_ID no Code.gs ou vincule o script a uma planilha.');
  }
  var sheet = ss.getSheetByName(SHEET_NAME);
  if (!sheet) {
    sheet = ss.insertSheet(SHEET_NAME);
    sheet.appendRow(['id', 'nome', 'descricao', 'atualizado_em', 'json']);
  }
  return sheet;
}

// =========================================
// API chamada pelo front-end (google.script.run)
// =========================================

// Retorna a lista de robôs (array de objetos).
function getRobots() {
  if (!isAuthorized()) throw new Error('Não autorizado.');
  var sheet = getSheet_();
  var values = sheet.getDataRange().getValues();
  var robots = [];
  for (var i = 1; i < values.length; i++) { // pula o cabeçalho
    var json = values[i][4];
    if (json) {
      try { robots.push(JSON.parse(json)); } catch (e) { /* ignora linha inválida */ }
    }
  }
  return robots;
}

// Substitui toda a lista de robôs pela enviada pelo front-end.
function saveAll(robots) {
  if (!isAuthorized()) throw new Error('Não autorizado.');
  var lock = LockService.getScriptLock();
  lock.waitLock(20000);
  try {
    var sheet = getSheet_();
    sheet.clearContents();
    sheet.appendRow(['id', 'nome', 'descricao', 'atualizado_em', 'json']);
    var now = new Date();
    var rows = (robots || []).map(function (r) {
      return [r.id, r.name || '', r.description || '', now, JSON.stringify(r)];
    });
    if (rows.length > 0) {
      sheet.getRange(2, 1, rows.length, 5).setValues(rows);
    }
    return true;
  } finally {
    lock.releaseLock();
  }
}
