/*==============================================================
  Keyboard Trigger - atalhos globais que digitam frases prontas.

  - Le as frases de phrases.json (na MESMA pasta do .exe).
  - Registra atalhos globais (ex: Ctrl+Alt+1) usando a API do
    Windows (RegisterHotKey) - funcionam em qualquer janela.
  - Ao apertar o atalho, "digita" a frase caractere a caractere
    via SendInput/Unicode (funciona com acentos e simbolos).
  - Fica na bandeja do sistema (perto do relogio). Botao direito
    para Recarregar frases, Ver atalhos ou Sair.

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

        const int INPUT_KEYBOARD = 1;
        const uint KEYEVENTF_KEYUP = 0x0002;
        const uint KEYEVENTF_UNICODE = 0x0004;
        const ushort VK_RETURN = 0x0D;

        // ---------- estado ----------
        readonly string configPath;
        readonly Dictionary<int, string> idToText = new Dictionary<int, string>();
        readonly List<string> registered = new List<string>();
        readonly List<string> failed = new List<string>();
        int nextId = 1;
        NotifyIcon tray;

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
            this.Hide();
            SetupTray();
            LoadAndRegister();
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

            if (!File.Exists(configPath))
            {
                tray.ShowBalloonTip(6000, "Keyboard Trigger",
                    "Nao encontrei phrases.json na pasta do programa. Gere no HTML, salve aqui e clique em Recarregar.",
                    ToolTipIcon.Warning);
                return;
            }

            string content;
            try { content = File.ReadAllText(configPath, Encoding.UTF8); }
            catch (Exception ex)
            {
                tray.ShowBalloonTip(6000, "Keyboard Trigger", "Erro ao ler phrases.json: " + ex.Message, ToolTipIcon.Error);
                return;
            }

            List<string[]> pairs = ParseJson(content);
            foreach (string[] kv in pairs)
            {
                string hotkey = kv[0];
                string text = kv[1];
                uint mods, vk;
                if (!TryParseHotkey(hotkey, out mods, out vk))
                {
                    failed.Add(hotkey + " (formato invalido)");
                    continue;
                }
                int id = nextId++;
                if (RegisterHotKey(this.Handle, id, mods | MOD_NOREPEAT, vk))
                {
                    idToText[id] = text;
                    registered.Add(hotkey);
                }
                else
                {
                    failed.Add(hotkey + " (ja em uso por outro programa)");
                }
            }

            string msg = "Rodando. Atalhos ativos: " + registered.Count;
            if (failed.Count > 0) msg += "  |  Com problema: " + failed.Count;
            tray.ShowBalloonTip(3500, "Keyboard Trigger", msg, ToolTipIcon.Info);
        }

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
            sb.AppendLine("Frases lidas de:");
            sb.AppendLine("  " + configPath);
            MessageBox.Show(sb.ToString(), "Keyboard Trigger");
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
                if (idToText.TryGetValue(id, out text)) TypeText(text);
            }
            base.WndProc(ref m);
        }

        // ---------- digitar o texto ----------
        void TypeText(string text)
        {
            Thread.Sleep(90); // tempo para soltar Ctrl/Alt do atalho
            text = text.Replace("\r\n", "\n").Replace("\r", "\n");
            foreach (char c in text)
            {
                if (c == '\n') SendVirtualKey(VK_RETURN);
                else SendUnicode(c);
                Thread.Sleep(3);
            }
        }

        void SendUnicode(char ch)
        {
            INPUT[] inp = new INPUT[2];
            inp[0].type = INPUT_KEYBOARD;
            inp[0].u.ki = new KEYBDINPUT { wVk = 0, wScan = ch, dwFlags = KEYEVENTF_UNICODE, time = 0, dwExtraInfo = IntPtr.Zero };
            inp[1].type = INPUT_KEYBOARD;
            inp[1].u.ki = new KEYBDINPUT { wVk = 0, wScan = ch, dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP, time = 0, dwExtraInfo = IntPtr.Zero };
            SendInput(2, inp, Marshal.SizeOf(typeof(INPUT)));
        }

        void SendVirtualKey(ushort vk)
        {
            INPUT[] inp = new INPUT[2];
            inp[0].type = INPUT_KEYBOARD;
            inp[0].u.ki = new KEYBDINPUT { wVk = vk, wScan = 0, dwFlags = 0, time = 0, dwExtraInfo = IntPtr.Zero };
            inp[1].type = INPUT_KEYBOARD;
            inp[1].u.ki = new KEYBDINPUT { wVk = vk, wScan = 0, dwFlags = KEYEVENTF_KEYUP, time = 0, dwExtraInfo = IntPtr.Zero };
            SendInput(2, inp, Marshal.SizeOf(typeof(INPUT)));
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
            bool criouNovo;
            mutex = new Mutex(true, "KeyboardTrigger_SingleInstance_9F3A2C", out criouNovo);
            if (!criouNovo) return; // ja existe uma instancia rodando

            Application.EnableVisualStyles();
            Application.Run(new MainForm());
            GC.KeepAlive(mutex);
        }
    }
}
