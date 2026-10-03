# 🔐 Sistema de Licenças - Pryme OS

Sistema completo de licenciamento usando **LicenseAuth** para o Pryme OS.

---

## 🎯 Como Funciona

### **1. Usuário instala Pryme OS**
- Sistema boot normalmente
- Na primeira inicialização, aparece tela de ativação

### **2. Tela de Ativação**
- Mostra o **Hardware ID** (único por máquina)
- Pede a **chave de licença**
- Valida com LicenseAuth API

### **3. Validação**
- Sistema envia: License Key + Hardware ID
- LicenseAuth valida e retorna: ✓ ou ✗
- Se válido: salva em `/etc/pryme/license.key`

### **4. Uso Contínuo**
- A cada boot, sistema checa licença (opcional)
- Se expirar ou ser inválida: notifica usuário
- Usuário pode reativar a qualquer momento

---

## 📦 Arquivos Criados

### **No Pryme OS:**

```
system_files/desktop/shared/usr/
├── bin/
│   ├── pryme-license           ← CLI de gerenciamento
│   └── pryme-license-gui       ← GUI de ativação
├── lib/systemd/system/
│   └── pryme-license-check.service  ← Verificação no boot
└── share/applications/
    └── pryme-license-activation.desktop  ← Atalho no menu
```

### **Configuração:**
```
/etc/pryme/
├── license.key    ← Chave de licença ativada
└── hwid           ← Hardware ID da máquina
```

---

## 🛠️ Comandos Disponíveis

### **Ativar licença (Terminal):**
```bash
sudo pryme-license activate
```

### **Ativar licença (GUI):**
```bash
pryme-license-gui
```
**Ou:** Abrir menu → "Ativar Pryme OS"

### **Ver status:**
```bash
pryme-license status
```

### **Checar validade:**
```bash
pryme-license check
```

### **Ver Hardware ID:**
```bash
pryme-license hwid
```

### **Desativar:**
```bash
sudo pryme-license deactivate
```

---

## 🔑 Gerando Licenças no LicenseAuth

### **1. Acesse o painel:**
```
https://licenseauth.help
```

### **2. Login:**
- **Owner ID:** 3MrJXJ9eu5

### **3. Criar nova licença:**
1. Vá em **"Licenses"** → **"Create License"**
2. Preencha:
   - **Application:** PrymeOS
   - **Duration:** 30 dias / 1 ano / Lifetime
   - **Max Uses:** 1 (uma máquina)
3. Copie a chave gerada

### **4. Enviar para cliente:**
- Mande a chave de licença
- Cliente executa: `pryme-license activate`
- Cola a chave
- Pronto! ✅

---

## 📊 Tipos de Licença

| Tipo | Duração | Reativação | Uso |
|------|---------|------------|-----|
| **Trial** | 7-30 dias | Não | Teste gratuito |
| **Mensal** | 30 dias | Sim | Assinatura |
| **Anual** | 365 dias | Sim | Desconto |
| **Lifetime** | Ilimitado | Sim | Compra única |

---

## 🎨 Fluxo de Ativação

```
┌─────────────────────────────────────────┐
│  Usuário instala Pryme OS              │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Primeiro boot                          │
│  Sistema mostra tela de ativação       │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Mostra Hardware ID:                    │
│  "abc123def456..."                      │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Usuário cola chave de licença         │
│  Input: "PRYME-XXXX-XXXX-XXXX"         │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Sistema valida com LicenseAuth        │
│  POST https://licenseauth.help/api/1.3/ │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  ✓ Licença válida!                      │
│  Salva em /etc/pryme/license.key       │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│  Pryme OS totalmente ativado! 🎉        │
└─────────────────────────────────────────┘
```

---

## 🔒 Segurança

### **Hardware ID Binding:**
- Cada licença é vinculada ao Hardware ID
- Impossível usar mesma licença em 2 PCs
- Hardware ID baseado em: machine-id + MAC address

### **Validação Online:**
- Checa servidor LicenseAuth
- Garante licença não foi revogada
- Impede pirataria

### **Armazenamento Seguro:**
- Licença em `/etc/pryme/license.key`
- Permissões: `600` (só root lê)
- Não pode ser copiada para outro PC

---

## 📱 Interface Gráfica

### **GNOME (Zenity):**
```
╔══════════════════════════════════════════╗
║       Pryme OS - Ativação               ║
╠══════════════════════════════════════════╣
║                                          ║
║  Bem-vindo ao Pryme OS!                 ║
║                                          ║
║  Para ativar, insira sua chave:         ║
║                                          ║
║  Hardware ID: abc123def456...           ║
║                                          ║
║  [________________________]             ║
║                                          ║
║       [Cancelar]  [Ativar]              ║
╚══════════════════════════════════════════╝
```

### **KDE (KDialog):**
Mesma interface, estilo KDE Plasma

---

## 🛡️ Modo Trial (Opcional)

Se quiser permitir uso sem licença por tempo limitado:

### **Editar:** `build_files/finalize`
```bash
# Criar trial de 30 dias
echo "$(date -d '+30 days' +%s)" > /etc/pryme/trial_expires
```

### **Editar:** `usr/bin/pryme-license`
Adicionar verificação de trial no `check_license()`

---

## 💰 Modelos de Monetização

### **1. Venda Direta:**
- Licença Lifetime: R$ 50
- Licença Anual: R$ 20
- Licença Mensal: R$ 5

### **2. Freemium:**
- Trial 30 dias grátis
- Depois: assinatura mensal

### **3. Hardware Vendor:**
- PCs com Pryme OS pré-instalado
- Licença incluída no preço

### **4. Enterprise:**
- Licença em volume (10+ PCs)
- Suporte premium incluso

---

## 🎯 Vantagens do LicenseAuth

✅ **Pronto para usar** - API já funcional  
✅ **Dashboard completo** - Gerencia licenças facilmente  
✅ **HWID Binding** - Impede pirataria  
✅ **Revogação remota** - Cancele licenças à distância  
✅ **Analytics** - Veja quantas ativações  
✅ **Expiration** - Renova automaticamente  
✅ **Grátis para começar** - Plano gratuito disponível  

---

## 📞 Suporte ao Cliente

Quando usuário tiver problema:

### **1. Verificar Hardware ID:**
```bash
pryme-license hwid
```

### **2. Ver logs:**
```bash
journalctl -u pryme-license-check.service
```

### **3. Reativar:**
```bash
sudo pryme-license deactivate
sudo pryme-license activate
```

---

## 🔧 Personalização

### **Mudar tempo de trial:**
Editar `/usr/bin/pryme-license` linha do trial

### **Forçar ativação:**
Remover "optional mode" do service e requerir licença válida

### **Customizar mensagens:**
Editar mensagens em `/usr/bin/pryme-license-gui`

---

## 🚀 Integração Completa

### **O que foi implementado:**
✅ Script CLI de gerenciamento (`pryme-license`)  
✅ Interface gráfica (GNOME + KDE)  
✅ Validação automática no boot  
✅ Atalho no menu de aplicações  
✅ Hardware ID único por máquina  
✅ Integração com LicenseAuth API  

### **Credenciais configuradas:**
✅ App Name: PrymeOS  
✅ Owner ID: 3MrJXJ9eu5  
✅ Secret: 030f1ef6...  
✅ API URL: https://licenseauth.help/api/1.3/  

---

## 📝 Próximos Passos

1. **Testar localmente:**
   ```bash
   sudo /usr/bin/pryme-license activate
   ```

2. **Criar licenças de teste** no painel do LicenseAuth

3. **Recompilar Pryme OS** com os novos arquivos

4. **Testar ativação** em VM

5. **Documentar** para seus clientes como ativar

---

**Sistema de licenciamento profissional integrado! 🎉**

**Feito com 💜 para Pryme OS**
