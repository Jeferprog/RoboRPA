/*==============================================================
  Keyboard Trigger - atalhos globais que digitam frases prontas.

  - Le as frases de phrases.json (na MESMA pasta do .exe).
  - Registra atalhos globais (ex: Ctrl+Alt+1) usando a API do
    Windows (RegisterHotKey) - funcionam em qualquer janela.
  - Ao apertar o atalho, "digita" a frase caractere a caractere
    via SendInput/Unicode (funciona com acentos e simbolos), ou
    "cola" via Ctrl+V (modo paste), melhor para campos com mascara.
  - Fica na bandeja do sistema (perto do relogio). Botao direito
    para Recarregar frases, Ver atalhos ou Sair.

  Ajustes opcionais no phrases.json (pares chave:valor):
    "@mode": "paste"        -> cola em vez de digitar (bom p/ Chrome)
    "@keyHoldMs": "15"      -> tempo segurando cada tecla (digitando)
    "@charDelayMs": "10"    -> pausa entre teclas (digitando)

  Nao precisa de admin nem instalar nada. Compilar com o csc.exe
  que ja vem no Windows (veja compilar_e_iniciar.bat).
==============================================================*/
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Drawing;
using System.Threading;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace KeyboardTrigger
{
    public class MainForm : Form
    {
        // ---------- Win32: atalhos globais ----------
        [DllImport("user32.dll", SetLastError = true)]
        static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);
        [DllImport("user32.dll", SetLastError = true)]
        static extern bool UnregisterHotKey(IntPtr hWnd, int id);

        const int WM_HOTKEY = 0x0312;
        const uint MOD_ALT = 0x0001, MOD_CONTROL = 0x0002, MOD_SHIFT = 0x0004, MOD_WIN = 0x0008, MOD_NOREPEAT = 0x4000;

        // ---------- Win32: SendInput (digitacao) ----------
        [StructLayout(LayoutKind.Sequential)]
        struct INPUT { public int type; public InputUnion u; }
        [StructLayout(LayoutKind.Explicit)]
        struct InputUnion
        {
            [FieldOffset(0)] public MOUSEINPUT mi;
            [FieldOffset(0)] public KEYBDINPUT ki;
            [FieldOffset(0)] public HARDWAREINPUT hi;
        }
        [StructLayout(LayoutKind.Sequential)]
        struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
        [StructLayout(LayoutKind.Sequential)]
        struct MOUSEINPUT { public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr dwExtraInfo; }
        [StructLayout(LayoutKind.Sequential)]
        struct HARDWAREINPUT { public uint uMsg; public ushort wParamL; public ushort wParamH; }

        [DllImport("user32.dll", SetLastError = true)]
        static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

        [DllImport("user32.dll")]
        static extern short GetAsyncKeyState(int vKey);

        const int INPUT_KEYBOARD = 1;
        const uint KEYEVENTF_KEYUP = 0x0002;
        const uint KEYEVENTF_UNICODE = 0x0004;
        const ushort VK_RETURN = 0x0D;
        const ushort VK_V = 0x56;

        const int VK_SHIFT = 0x10, VK_CONTROL = 0x11, VK_MENU = 0x12, VK_LWIN = 0x5B, VK_RWIN = 0x5C;

        // ---------- configuracoes de digitacao (ajustaveis no phrases.json) ----------
        int keyHoldMs = 4;      // tempo segurando cada tecla
        int charDelayMs = 4;    // pausa entre uma tecla e a proxima
        bool pasteMode = false; // true = cola via Ctrl+V em vez de digitar (instantaneo)

        // ---------- estado ----------
        readonly string configPath;
        readonly Dictionary<int, string> idToText = new Dictionary<int, string>();
        readonly List<string> registered = new List<string>();
        readonly List<string> failed = new List<string>();
        int nextId = 1;
        NotifyIcon tray;
        string captured = ""; // ultimo texto capturado da selecao (@capturar)

        // ---------- log (para diagnostico) ----------
        static string LogPath { get { return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "keyboardtrigger_log.txt"); } }
        static void Log(string s)
        {
            try { File.AppendAllText(LogPath, DateTime.Now.ToString("HH:mm:ss") + "  " + s + Environment.NewLine); }
            catch { }
        }

        public MainForm()
        {
            configPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "phrases.json");
            // janela invisivel (fora da tela) so para receber as mensagens de atalho
            this.FormBorderStyle = FormBorderStyle.FixedToolWindow;
            this.ShowInTaskbar = false;
            this.StartPosition = FormStartPosition.Manual;
            this.Location = new Point(-4000, -4000);
            this.Size = new Size(1, 1);
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            try
            {
                Log("OnLoad: iniciando. Handle criado=" + this.IsHandleCreated);
                this.Hide();
                SetupTray();
                LoadAndRegister();
                Log("OnLoad: concluido.");
            }
            catch (Exception ex)
            {
                Log("ERRO OnLoad: " + ex);
                MessageBox.Show("Erro ao iniciar: " + ex.Message, "Keyboard Trigger");
            }
        }

        void SetupTray()
        {
            tray = new NotifyIcon();
            tray.Icon = SystemIcons.Application;
            tray.Text = "Keyboard Trigger";
            tray.Visible = true;

            ContextMenuStrip menu = new ContextMenuStrip();
            menu.Items.Add("Ver atalhos", null, delegate { ShowHotkeys(); });
            menu.Items.Add("Recarregar frases", null, delegate { ReloadAll(); });
            menu.Items.Add("Abrir pasta das frases", null, delegate { OpenConfigFolder(); });
            menu.Items.Add(new ToolStripSeparator());
            menu.Items.Add("Sair", null, delegate { ExitApp(); });
            tray.ContextMenuStrip = menu;
            tray.DoubleClick += delegate { ShowHotkeys(); };
        }

        void LoadAndRegister()
        {
            idToText.Clear();
            registered.Clear();
            failed.Clear();

            // valores padrao (podem ser sobrescritos por "@..." no phrases.json)
            keyHoldMs = 4;
            charDelayMs = 4;
            pasteMode = false;

            Log("LoadAndRegister: config=" + configPath + " existe=" + File.Exists(configPath));
            if (!File.Exists(configPath))
            {
                tray.ShowBalloonTip(6000, "Keyboard Trigger",
                    "Nao encontrei phrases.json na pasta do programa. Gere no HTML, salve aqui e clique em Recarregar.",
                    ToolTipIcon.Warning);
                MessageBox.Show("Nao encontrei o arquivo phrases.json na pasta:\n\n" + configPath +
                    "\n\nGere no keyboard_trigger_manager.html, salve nesta pasta e clique em Recarregar.",
                    "Keyboard Trigger");
                return;
            }

            string content;
            try { content = File.ReadAllText(configPath, Encoding.UTF8); }
            catch (Exception ex)
            {
                Log("Erro ao ler phrases.json: " + ex);
                MessageBox.Show("Erro ao ler phrases.json: " + ex.Message, "Keyboard Trigger");
                return;
            }

            List<string[]> pairs = ParseJson(content);
            Log("Pares lidos do JSON: " + pairs.Count);
            foreach (string[] kv in pairs)
            {
                string hotkey = kv[0];
                string text = kv[1];

                // entradas comecando com "@" sao configuracoes, nao atalhos
                if (hotkey.StartsWith("@")) { ApplySetting(hotkey, text); continue; }

                uint mods, vk;
                if (!TryParseHotkey(hotkey, out mods, out vk))
                {
                    failed.Add(hotkey + " (formato invalido)");
                    continue;
                }
                int id = nextId++;
                bool ok = RegisterHotKey(this.Handle, id, mods | MOD_NOREPEAT, vk);
                Log("Registrar '" + hotkey + "' (mods=" + mods + " vk=" + vk + ") => " + (ok ? "OK" : "FALHOU"));
                if (ok)
                {
                    idToText[id] = text;
                    registered.Add(hotkey);
                }
                else
                {
                    failed.Add(hotkey + " (ja em uso por outro programa)");
                }
            }

            Log("Config: modo=" + (pasteMode ? "paste" : "type") + " keyHoldMs=" + keyHoldMs + " charDelayMs=" + charDelayMs);
            Log("Resumo: ativos=" + registered.Count + " problema=" + failed.Count);
            string aviso = "Atalhos ativos: " + registered.Count + (pasteMode ? "  (modo colar)" : "");
            if (failed.Count > 0) aviso += "  (com problema: " + failed.Count + ")";
            tray.ShowBalloonTip(3000, "Keyboard Trigger", aviso, ToolTipIcon.Info);
        }

        void ApplySetting(string key, string val)
        {
            string k = key.Trim().ToLowerInvariant();
            int num;
            if (k == "@keyholdms" && int.TryParse(val, out num)) keyHoldMs = Clamp(num, 0, 1000);
            else if (k == "@chardelayms" && int.TryParse(val, out num)) charDelayMs = Clamp(num, 0, 1000);
            else if (k == "@mode") pasteMode = (val.Trim().ToLowerInvariant() == "paste");
            Log("Config aplicada: " + key + " = " + val);
        }

        static int Clamp(int v, int lo, int hi) { return v < lo ? lo : (v > hi ? hi : v); }

        void UnregisterAll()
        {
            foreach (int id in idToText.Keys) UnregisterHotKey(this.Handle, id);
            idToText.Clear();
        }

        void ReloadAll()
        {
            UnregisterAll();
            LoadAndRegister();
        }

        void ShowHotkeys()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Atalhos ativos:");
            if (registered.Count == 0) sb.AppendLine("  (nenhum)");
            foreach (string hk in registered) sb.AppendLine("  " + hk);
            if (failed.Count > 0)
            {
                sb.AppendLine();
                sb.AppendLine("Com problema:");
                foreach (string f in failed) sb.AppendLine("  " + f);
            }
            sb.AppendLine();
            sb.AppendLine("Modo: " + (pasteMode ? "colar (Ctrl+V)" : "digitar") +
                          "   keyHoldMs=" + keyHoldMs + "  charDelayMs=" + charDelayMs);
            sb.AppendLine();
            sb.AppendLine("Frases lidas de:");
            sb.AppendLine("  " + configPath);
            MessageBox.Show(sb.ToString(), "Keyboard Trigger");
        }

        void OpenConfigFolder()
        {
            try { System.Diagnostics.Process.Start("explorer.exe", "\"" + Path.GetDirectoryName(configPath) + "\""); }
            catch (Exception ex) { Log("OpenConfigFolder falhou: " + ex.Message); }
        }

        void ExitApp()
        {
            UnregisterAll();
            if (tray != null) tray.Visible = false;
            Application.Exit();
        }

        protected override void WndProc(ref Message m)
        {
            if (m.Msg == WM_HOTKEY)
            {
                int id = m.WParam.ToInt32();
                string text;
                if (idToText.TryGetValue(id, out text)) HandleHotkey(text);
            }
            base.WndProc(ref m);
        }

        // Decide o que o atalho faz: capturar a selecao ou digitar/colar a frase
        void HandleHotkey(string text)
        {
            string t = (text ?? "").Trim();
            if (t.Equals("@capturar", StringComparison.OrdinalIgnoreCase) ||
                t.Equals("@copiar", StringComparison.OrdinalIgnoreCase))
            {
                CaptureSelection();
                return;
            }

            // frase normal: troca os marcadores pela captura, se houver
            string outText = text;
            if (outText.IndexOf("{numeros}", StringComparison.OrdinalIgnoreCase) >= 0)
                outText = ReplaceCI(outText, "{numeros}", DigitsOnly(captured));
            if (outText.IndexOf("{captura}", StringComparison.OrdinalIgnoreCase) >= 0)
                outText = ReplaceCI(outText, "{captura}", captured);

            TypeText(outText);
        }

        // Copia a selecao atual (Ctrl+C) e guarda em memoria
        void CaptureSelection()
        {
            ReleaseModifiers();
            for (int i = 0; i < 60; i++)
            {
                bool held = GetAsyncKeyState(VK_CONTROL) < 0 || GetAsyncKeyState(VK_SHIFT) < 0
                         || GetAsyncKeyState(VK_MENU) < 0 || GetAsyncKeyState(VK_LWIN) < 0 || GetAsyncKeyState(VK_RWIN) < 0;
                if (!held) break;
                Thread.Sleep(10);
            }
            Thread.Sleep(60);

            // Ctrl+C
            KeyDownVk((ushort)VK_CONTROL);
            Thread.Sleep(5);
            KeyDownVk(0x43); // tecla C
            Thread.Sleep(25);
            KeyUpVk(0x43);
            Thread.Sleep(5);
            KeyUpVk((ushort)VK_CONTROL);
            Thread.Sleep(160); // tempo para o app colocar no clipboard

            string val = "";
            try { if (Clipboard.ContainsText()) val = Clipboard.GetText(); }
            catch (Exception ex) { Log("Captura clipboard falhou: " + ex.Message); }
            captured = (val ?? "").Trim();
            Log("Capturado (" + captured.Length + " chars): " + captured);

            if (tray != null)
            {
                string aviso = captured.Length > 0
                    ? ("Capturado: " + Resumo(captured) + "   (numeros: " + DigitsOnly(captured) + ")")
                    : "Nada selecionado para capturar";
                tray.ShowBalloonTip(2500, "Keyboard Trigger", aviso, ToolTipIcon.Info);
            }
        }

        static string DigitsOnly(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            StringBuilder sb = new StringBuilder();
            foreach (char c in s) if (c >= '0' && c <= '9') sb.Append(c);
            return sb.ToString();
        }

        static string ReplaceCI(string input, string token, string val)
        {
            StringBuilder sb = new StringBuilder();
            int i = 0;
            while (i < input.Length)
            {
                if (i + token.Length <= input.Length &&
                    string.Compare(input, i, token, 0, token.Length, StringComparison.OrdinalIgnoreCase) == 0)
                {
                    sb.Append(val);
                    i += token.Length;
                }
                else { sb.Append(input[i]); i++; }
            }
            return sb.ToString();
        }

        static string Resumo(string s)
        {
            s = s.Replace("\r", " ").Replace("\n", " ");
            return s.Length > 40 ? s.Substring(0, 40) + "..." : s;
        }

        // ---------- entregar o texto (digitar ou colar) ----------
        void TypeText(string text)
        {
            // 1) solta os modificadores do atalho (Ctrl/Shift/Alt/Win)
            ReleaseModifiers();

            // 2) espera o usuario tirar o dedo das teclas fisicas (ate ~600ms)
            for (int i = 0; i < 60; i++)
            {
                bool held = GetAsyncKeyState(VK_CONTROL) < 0
                         || GetAsyncKeyState(VK_SHIFT) < 0
                         || GetAsyncKeyState(VK_MENU) < 0
                         || GetAsyncKeyState(VK_LWIN) < 0
                         || GetAsyncKeyState(VK_RWIN) < 0;
                if (!held) break;
                Thread.Sleep(10);
            }
            Thread.Sleep(80); // folga para o campo ficar pronto

            text = text.Replace("\r\n", "\n").Replace("\r", "\n");
            Log("TypeText: len=" + text.Length + " modo=" + (pasteMode ? "paste" : "type"));

            if (pasteMode) { PasteText(text); return; }

            // 3) digita segurando cada tecla um pouco (mais confiavel no navegador)
            foreach (char c in text)
            {
                if (c == '\n') TapVk(VK_RETURN);
                else TapUnicode(c);
                Thread.Sleep(charDelayMs);
            }
        }

        // ---------- modo colar ----------
        void PasteText(string text)
        {
            string backup = null;
            try { if (Clipboard.ContainsText()) backup = Clipboard.GetText(); }
            catch (Exception ex) { Log("Clipboard backup falhou: " + ex.Message); }

            try { if (text.Length > 0) Clipboard.SetText(text); }
            catch (Exception ex) { Log("Clipboard.SetText falhou: " + ex.Message); }

            Thread.Sleep(60);

            // Ctrl+V
            KeyDownVk((ushort)VK_CONTROL);
            Thread.Sleep(5);
            KeyDownVk(VK_V);
            Thread.Sleep(keyHoldMs > 0 ? keyHoldMs : 12);
            KeyUpVk(VK_V);
            Thread.Sleep(5);
            KeyUpVk((ushort)VK_CONTROL);
            Thread.Sleep(150);

            try
            {
                if (backup != null) Clipboard.SetText(backup);
                else Clipboard.Clear();
            }
            catch { }
        }

        // ---------- helpers de teclado ----------
        void ReleaseModifiers()
        {
            int[] mods = { VK_CONTROL, VK_SHIFT, VK_MENU, VK_LWIN, VK_RWIN };
            INPUT[] inp = new INPUT[mods.Length];
            for (int i = 0; i < mods.Length; i++)
            {
                inp[i].type = INPUT_KEYBOARD;
                inp[i].u.ki = new KEYBDINPUT { wVk = (ushort)mods[i], wScan = 0, dwFlags = KEYEVENTF_KEYUP, time = 0, dwExtraInfo = IntPtr.Zero };
            }
            SendInput((uint)inp.Length, inp, Marshal.SizeOf(typeof(INPUT)));
        }

        void TapUnicode(char ch)
        {
            SendOne(0, ch, KEYEVENTF_UNICODE);
            Thread.Sleep(keyHoldMs);
            SendOne(0, ch, KEYEVENTF_UNICODE | KEYEVENTF_KEYUP);
        }

        void TapVk(ushort vk)
        {
            SendOne(vk, 0, 0);
            Thread.Sleep(keyHoldMs);
            SendOne(vk, 0, KEYEVENTF_KEYUP);
        }

        void KeyDownVk(ushort vk) { SendOne(vk, 0, 0); }
        void KeyUpVk(ushort vk) { SendOne(vk, 0, KEYEVENTF_KEYUP); }

        void SendOne(ushort vk, ushort scan, uint flags)
        {
            INPUT[] a = new INPUT[1];
            a[0].type = INPUT_KEYBOARD;
            a[0].u.ki = new KEYBDINPUT { wVk = vk, wScan = scan, dwFlags = flags, time = 0, dwExtraInfo = IntPtr.Zero };
            SendInput(1, a, Marshal.SizeOf(typeof(INPUT)));
        }

        // ---------- interpretar "Ctrl+Alt+1" ----------
        static bool TryParseHotkey(string s, out uint mods, out uint vk)
        {
            mods = 0; vk = 0;
            if (string.IsNullOrEmpty(s)) return false;
            string[] parts = s.Split('+');
            for (int i = 0; i < parts.Length; i++)
            {
                string p = parts[i].Trim();
                if (p.Length == 0) return false;
                string pl = p.ToLowerInvariant();
                if (i < parts.Length - 1)
                {
                    if (pl == "ctrl" || pl == "control") mods |= MOD_CONTROL;
                    else if (pl == "alt") mods |= MOD_ALT;
                    else if (pl == "shift") mods |= MOD_SHIFT;
                    else if (pl == "win" || pl == "windows") mods |= MOD_WIN;
                    else return false;
                }
                else
                {
                    if (p.Length == 1)
                    {
                        char c = char.ToUpperInvariant(p[0]);
                        if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z')) vk = (uint)c;
                        else return false;
                    }
                    else if (pl.Length >= 2 && pl.Length <= 3 && pl[0] == 'f')
                    {
                        int fn;
                        if (int.TryParse(pl.Substring(1), out fn) && fn >= 1 && fn <= 24) vk = (uint)(0x70 + (fn - 1));
                        else return false;
                    }
                    else return false;
                }
            }
            return vk != 0;
        }

        // ---------- parser JSON simples (pares "chave":"valor") ----------
        static List<string[]> ParseJson(string json)
        {
            List<string> strings = new List<string>();
            int i = 0, n = json.Length;
            while (i < n)
            {
                if (json[i] == '"')
                {
                    StringBuilder sb = new StringBuilder();
                    i++;
                    while (i < n)
                    {
                        char c = json[i];
                        if (c == '\\' && i + 1 < n)
                        {
                            char e = json[i + 1];
                            if (e == 'n') sb.Append('\n');
                            else if (e == 't') sb.Append('\t');
                            else if (e == 'r') sb.Append('\r');
                            else if (e == '"') sb.Append('"');
                            else if (e == '\\') sb.Append('\\');
                            else if (e == '/') sb.Append('/');
                            else if (e == 'u' && i + 5 < n)
                            {
                                int code;
                                if (int.TryParse(json.Substring(i + 2, 4), NumberStyles.HexNumber, CultureInfo.InvariantCulture, out code))
                                {
                                    sb.Append((char)code);
                                    i += 4;
                                }
                            }
                            else sb.Append(e);
                            i += 2;
                        }
                        else if (c == '"') { i++; break; }
                        else { sb.Append(c); i++; }
                    }
                    strings.Add(sb.ToString());
                }
                else i++;
            }
            List<string[]> pairs = new List<string[]>();
            for (int k = 0; k + 1 < strings.Count; k += 2)
                pairs.Add(new string[] { strings[k], strings[k + 1] });
            return pairs;
        }

        // ---------- entrada ----------
        static Mutex mutex;

        [STAThread]
        static void Main()
        {
            try
            {
                Log("=== Main iniciando ===");
                bool criouNovo;
                mutex = new Mutex(true, "KeyboardTrigger_SingleInstance_9F3A2C", out criouNovo);
                Log("Instancia nova=" + criouNovo);
                if (!criouNovo) { Log("Ja havia instancia rodando; saindo."); return; }

                Application.EnableVisualStyles();
                Application.Run(new MainForm());
                GC.KeepAlive(mutex);
                Log("=== Main encerrando ===");
            }
            catch (Exception ex)
            {
                Log("FATAL Main: " + ex);
                try { MessageBox.Show("Erro fatal: " + ex.Message, "Keyboard Trigger"); }
                catch { }
            }
        }
    }
}
