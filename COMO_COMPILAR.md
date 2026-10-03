# 🏗️ Guia de Compilação - Pryme OS

## 🎯 Método Recomendado: GitHub Actions (Grátis)

### **Pré-requisitos:**
- Conta no GitHub
- GitHub Desktop (ou git)

---

## 📦 Passo 1: Subir código para GitHub

### **Via GitHub Desktop (Mais fácil):**

1. **Abra o GitHub Desktop**
2. **File → Add Local Repository**
3. Selecione: `C:\Users\LSZK\Downloads\bazzite-main\bazzite-main`
4. Se pedir para criar repositório, clique **"Create Repository"**
5. **Summary:** `Pryme OS - Initial Release`
6. Clique **"Commit to main"**
7. Clique **"Publish repository"**
   - **Name:** `pryme-os`
   - **Description:** `Pryme OS - Sistema Operacional Linux baseado em Fedora`
   - **Desmarque** "Keep this code private" (deixe público para GitHub Actions grátis)
8. Clique **"Publish Repository"**

### **Via Git CLI:**
```bash
cd C:\Users\LSZK\Downloads\bazzite-main\bazzite-main
git init
git add .
git commit -m "Pryme OS - Initial Release"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/pryme-os.git
git push -u origin main
```

---

## ⚙️ Passo 2: Configurar GitHub Actions

O Bazzite já tem workflow pronto! Só precisa ajustar:

### **2.1: Editar `.github/workflows/build.yml`**

Abra o arquivo e verifique se está assim:

```yaml
name: Build Pryme OS
on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  IMAGE_REGISTRY: ghcr.io/${{ github.repository_owner }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Build Image
        uses: redhat-actions/buildah-build@v2
        with:
          image: pryme
          tags: latest ${{ github.sha }}
          containerfiles: ./Containerfile
      
      - name: Push to Registry
        uses: redhat-actions/push-to-registry@v2
        with:
          image: pryme
          tags: latest ${{ github.sha }}
          registry: ${{ env.IMAGE_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
```

### **2.2: Commit e Push**
```bash
git add .github/workflows/build.yml
git commit -m "Configure GitHub Actions for Pryme OS"
git push
```

---

## 🎬 Passo 3: Iniciar Build

### **Via Site GitHub:**
1. Vá em: `https://github.com/SEU_USUARIO/pryme-os`
2. Clique na aba **"Actions"**
3. Clique em **"Build Pryme OS"** (workflow)
4. Clique em **"Run workflow"** → **"Run workflow"**

### **Automático:**
Toda vez que você fizer `git push`, o GitHub Actions compila automaticamente!

---

## ⏱️ Passo 4: Aguardar Build

- **Tempo:** ~1-2 horas
- **Progresso:** Veja em tempo real na aba Actions
- **Custo:** GRÁTIS (2000 minutos/mês)

---

## 📥 Passo 5: Baixar ISO (depois do build)

### **5.1: Baixar imagem do GitHub Container Registry**

Depois do build concluir, a imagem estará em:
```
ghcr.io/SEU_USUARIO/pryme:latest
```

### **5.2: Converter para ISO instalável**

No Linux (ou WSL2):
```bash
# Instalar ferramenta
sudo dnf install -y lorax podman

# Baixar imagem
podman pull ghcr.io/SEU_USUARIO/pryme:latest

# Criar ISO
sudo lorax -p Pryme -v 1.0 -r 1.0 \
  -s https://dl.fedoraproject.org/pub/fedora/linux/releases/40/Everything/x86_64/os/ \
  --isfinal \
  --nomacboot \
  --buildarch x86_64 \
  --volid Pryme-1.0 \
  /var/lib/lorax/pryme-iso/
```

### **5.3: Ou gerar ISO via GitHub Actions**

O Bazzite tem workflow separado para ISO! Edite `.github/workflows/build_iso.yml`:

```yaml
name: Build ISO
on:
  workflow_dispatch:
    inputs:
      variant:
        description: 'ISO variant'
        required: true
        default: 'gnome'
        type: choice
        options:
          - gnome
          - kde

jobs:
  build-iso:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Build ISO
        run: |
          cd installer
          sudo bash build.sh ${{ inputs.variant }}
```

Depois rode:
```
Actions → Build ISO → Run workflow → Escolha GNOME ou KDE
```

---

## 💿 Passo 6: Criar Pendrive Bootável

Quando tiver o ISO:

### **Windows:**
1. Baixe **Rufus**: https://rufus.ie/
2. Insira pendrive (8GB+)
3. Abra Rufus
4. **SELECT** → Escolha o ISO do Pryme OS
5. **Partition scheme:** GPT
6. **Target system:** UEFI
7. Clique **START**

### **Linux:**
```bash
sudo dd if=pryme-os.iso of=/dev/sdX bs=4M status=progress
sync
```

---

## 🖥️ Passo 7: Instalar Pryme OS

1. **Boot pelo pendrive** (F12/F2/DEL na inicialização)
2. Escolha **"Install Pryme OS"**
3. Siga o instalador
4. **Ative a licença** quando pedir

---

## 🔧 Compilação Local (Alternativa)

### **Requisitos:**
- Linux (Fedora 40+ recomendado)
- 100GB+ espaço livre
- 16GB+ RAM
- Docker ou Podman

### **Comandos:**
```bash
# Clone o repositório
git clone https://github.com/SEU_USUARIO/pryme-os.git
cd pryme-os

# Build com Podman
sudo podman build -t pryme:latest -f Containerfile .

# Aguarde ~1-2 horas
```

---

## 📊 Resumo de Tempo e Recursos

| Método | Tempo | Espaço | Custo | Dificuldade |
|--------|-------|--------|-------|-------------|
| **GitHub Actions** | 1-2h | 0GB (nuvem) | Grátis | ⭐ Fácil |
| **Local Linux** | 1-2h | 100GB | Grátis | ⭐⭐⭐ Médio |
| **WSL2** | 2-3h | 100GB | Grátis | ⭐⭐⭐⭐ Difícil |

---

## 🆘 Problemas Comuns

### **"Out of space" no GitHub Actions**
- Actions tem limite de 14GB
- Se der erro, compile localmente

### **"Permission denied" ao criar ISO**
- Use `sudo` nos comandos
- Verifique se tem permissão de escrita

### **Build falha no meio**
- Verifique logs no GitHub Actions
- Pode ser falta de dependência ou erro de sintaxe

---

## 🎯 Checklist Final

- [ ] Código no GitHub
- [ ] GitHub Actions configurado
- [ ] Build iniciado
- [ ] Build concluído com sucesso
- [ ] ISO gerado
- [ ] Pendrive criado
- [ ] Pryme OS instalado
- [ ] Licença ativada

---

## 📞 Próximos Passos

Depois de instalar:
1. Testar sistema completo
2. Criar licenças no LicenseAuth
3. Documentar para usuários
4. Divulgar o Pryme OS!

---

**🎉 Boa sorte com a compilação!**

**Feito com 💜 para Pryme OS**
