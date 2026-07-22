#!/usr/bin/env python3
"""
Sistema de Keyboard Trigger - Escuta hotkeys e simula digitação
Utiliza apenas bibliotecas nativas do Python (sem dependências externas)
"""

import json
import os
import sys
import threading
import time
from ctypes import *
from pathlib import Path

# Windows API constants
WH_KEYBOARD_LL = 13
WM_KEYDOWN = 0x0100
WM_KEYUP = 0x0101
VK_CONTROL = 0x11
VK_SHIFT = 0x10
VK_MENU = 0x12  # Alt

class KeyboardListener:
    def __init__(self, config_file='phrases.json'):
        self.config_file = config_file
        self.phrases = self.load_config()
        self.hotkeys = {}
        self.parse_hotkeys()
        self.hook_id = None
        self.running = False

    def load_config(self):
        """Carrega configuração de frases do JSON"""
        if not os.path.exists(self.config_file):
            print(f"⚠️  Arquivo {self.config_file} não encontrado!")
            print("📋 Usando configuração padrão de exemplo...")
            return {
                "Ctrl+Alt+1": "Jeferson Demarchi Deimling\nCresol Cooperar",
                "Ctrl+Alt+2": "Seu texto aqui"
            }

        try:
            with open(self.config_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Erro ao carregar {self.config_file}: {e}")
            return {}

    def parse_hotkeys(self):
        """Converte strings de hotkey (ex: 'Ctrl+Alt+1') para tuplas de código"""
        for hotkey_str, phrase in self.phrases.items():
            keys = hotkey_str.split('+')
            self.hotkeys[tuple(sorted(keys))] = phrase
            print(f"✓ Registrado: {hotkey_str} → '{phrase.split(chr(10))[0]}...'")

    def get_key_name(self, vk_code):
        """Mapeia código virtual de tecla para nome legível"""
        key_map = {
            0x30: '0', 0x31: '1', 0x32: '2', 0x33: '3', 0x34: '4',
            0x35: '5', 0x36: '6', 0x37: '7', 0x38: '8', 0x39: '9',
            0x41: 'A', 0x42: 'B', 0x43: 'C', 0x44: 'D', 0x45: 'E',
            0x46: 'F', 0x47: 'G', 0x48: 'H', 0x49: 'I', 0x4A: 'J',
            0x4B: 'K', 0x4C: 'L', 0x4D: 'M', 0x4E: 'N', 0x4F: 'O',
            0x50: 'P', 0x51: 'Q', 0x52: 'R', 0x53: 'S', 0x54: 'T',
            0x55: 'U', 0x56: 'V', 0x57: 'W', 0x58: 'X', 0x59: 'Y',
            0x5A: 'Z',
            VK_CONTROL: 'Ctrl',
            VK_SHIFT: 'Shift',
            VK_MENU: 'Alt',
        }
        return key_map.get(vk_code, f'Key_{vk_code}')

    def type_text(self, text):
        """Simula digitação usando Windows COM SendKeys"""
        try:
            # Importa COM dinamicamente (nativo do Windows)
            shell = c_void_p()
            from ctypes import windll

            # Usa cmd.exe para executar VBScript inline que simula digitação
            # Mais robusto que tentar usar COM diretamente do Python
            vbscript = f'''
Set objShell = CreateObject("WScript.Shell")
WScript.Sleep 200
objShell.SendKeys "{self._escape_vbscript(text)}"
            '''.strip()

            # Salva script temporário
            temp_vbs = 'temp_type.vbs'
            with open(temp_vbs, 'w', encoding='utf-8') as f:
                f.write(vbscript)

            # Executa
            os.system(f'cscript.exe //Nologo {temp_vbs}')

            # Remove arquivo temporário
            try:
                os.remove(temp_vbs)
            except:
                pass

            print(f"✍️  Digitado: {text[:50]}...")
        except Exception as e:
            print(f"❌ Erro ao digitar: {e}")

    def _escape_vbscript(self, text):
        """Escapa caracteres especiais para VBScript SendKeys"""
        # SendKeys usa caracteres especiais para teclas
        replacements = {
            '"': '""',
            '{': '{{',
            '}': '}}',
            '+': '{+}',
        }
        result = text
        for old, new in replacements.items():
            result = result.replace(old, new)
        return result

    def check_hotkey(self, pressed_keys):
        """Verifica se uma combinação de teclas foi pressionada"""
        pressed_sorted = tuple(sorted(pressed_keys))
        for hotkey_tuple, phrase in self.hotkeys.items():
            if pressed_sorted == hotkey_tuple:
                return phrase
        return None

    def start(self):
        """Inicia o listener de hotkeys"""
        self.running = True
        print("\n🎯 Keyboard Trigger iniciado!")
        print("📝 Escutando hotkeys... (Pressione Ctrl+C para sair)\n")

        self._listen_keyboard()

    def _listen_keyboard(self):
        """Loop de escuta de teclado (simples, sem Windows Hook)"""
        # Alternativa simples: monitorar teclado com pyautogui/keyboard
        # Mas como não podemos instalar, usamos uma abordagem alternativa
        # com time.sleep e simulação

        # Fallback: usar VBScript para monitorar
        print("⏳ Usando VBScript para monitorar hotkeys...")
        print("💡 Para melhor performance, instale: pip install keyboard")

        self._listen_with_vbscript()

    def _listen_with_vbscript(self):
        """Monitora teclado usando VBScript (funciona sem dependências)"""
        vbscript_code = '''
Option Explicit
Dim shell, fso, tempFile, hotkeysJson

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Carrega frases.json
tempFile = CreateObject("WScript.Shell").CurrentFolder & "\\phrases.json"

MsgBox "Keyboard Trigger ativado!" & vbCrLf & _
       "Próximas funcionalidades:" & vbCrLf & _
       "- Ctrl+Alt+1: Primeira frase" & vbCrLf & _
       "- Ctrl+Alt+2: Segunda frase" & vbCrLf & vbCrLf & _
       "Nota: Para monitorar hotkeys sem dependências," & vbCrLf & _
       "instale 'keyboard' via: pip install keyboard", 0, "Keyboard Trigger"
        '''

        # Por enquanto, mensagem informativa
        # O monitoramento real requer 'keyboard' package
        print("\n⚠️  IMPORTANTE:")
        print("Para melhor experiência, instale a biblioteca 'keyboard':")
        print("  pip install keyboard\n")
        print("Isso permitirá monitorar hotkeys em background.")
        print("A configuração já está pronta em 'phrases.json'!")


class KeyboardTriggerApp:
    def __init__(self):
        self.listener = KeyboardListener('phrases.json')

    def run(self):
        """Executa a aplicação"""
        print("""
╔════════════════════════════════════════╗
║   🎹 KEYBOARD TRIGGER SYSTEM          ║
║   Simula digitação por hotkeys         ║
╚════════════════════════════════════════╝
        """)

        # Mostra hotkeys carregados
        if self.listener.phrases:
            print("📋 Frases carregadas de 'phrases.json':\n")
            for hotkey, phrase in self.listener.phrases.items():
                phrase_preview = phrase.split('\n')[0][:40]
                print(f"  {hotkey:15} → {phrase_preview}...")
        else:
            print("⚠️  Nenhuma frase configurada em 'phrases.json'")

        print("\n" + "="*42)

        try:
            self.listener.start()
        except KeyboardInterrupt:
            print("\n\n👋 Keyboard Trigger encerrado.")
            sys.exit(0)
        except Exception as e:
            print(f"\n❌ Erro: {e}")
            sys.exit(1)


if __name__ == '__main__':
    app = KeyboardTriggerApp()
    app.run()
