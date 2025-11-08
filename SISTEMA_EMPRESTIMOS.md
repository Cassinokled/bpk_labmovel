# Sistema de Empréstimos com QR Code

## 📋 Descrição

Sistema de gerenciamento de empréstimos que utiliza QR Code para confirmação em tempo real. O usuário gera um QR Code com os equipamentos desejados, e o atendente escaneia para confirmar o empréstimo. O sistema utiliza Firestore para sincronização em tempo real.

## 🔄 Fluxo do Sistema

### 1. **Usuário - Gerar QR Code**
```
Usuário seleciona equipamentos → Clica para gerar QR Code → Sistema salva no Firestore → QR Code é exibido
```

### 2. **Sistema Monitora Status**
```
QR Code fica na tela → Monitora mudanças no Firestore em tempo real → Aguarda confirmação
```

### 3. **Atendente - Confirmar Empréstimo**
```
Atendente abre scanner → Escaneia QR Code → Sistema busca detalhes → Confirma empréstimo no Firestore
```

### 4. **Finalização**
```
Firestore atualiza status → Usuário recebe notificação em tempo real → QR Code fecha automaticamente
```

## 📁 Arquivos Criados/Modificados

### **Novos Arquivos**
- `lib/services/emprestimo_service.dart` - Serviço para gerenciar empréstimos no Firestore
- `lib/views/pages/confirmar_emprestimo_page.dart` - Página detalhada de confirmação para atendente

### **Arquivos Modificados**
- `lib/models/emprestimo_model.dart` - Adicionado ID, status de confirmação e timestamps
- `lib/views/pages/qr_code_page.dart` - Integrado com Firestore e monitoramento em tempo real
- `lib/views/pages/qr_scanner_page.dart` - Integrado navegação para página de confirmação
- `lib/providers/carrinho_emprestimo_provider.dart` - Atualizado para usar novo modelo

## 🗄️ Estrutura do Banco de Dados (Firestore)

### Collection: `emprestimos`

```javascript
{
  "id": "auto-generated-id",           // ID do documento (gerado automaticamente)
  "userId": "user123abc",              // ID do usuário
  "equipamentos": ["5815", "5820"],    // Lista de códigos dos equipamentos
  "confirmado": false,                  // Status de confirmação
  "criadoEm": Timestamp,               // Data/hora de criação
  "confirmedoEm": Timestamp | null     // Data/hora de confirmação (null se não confirmado)
}
```

## 🔧 Funcionalidades Implementadas

### **EmprestimoService** (`lib/services/emprestimo_service.dart`)

#### Métodos Principais:
- ✅ `criarEmprestimo(emprestimo)` - Cria novo empréstimo no Firestore
- ✅ `buscarEmprestimo(id)` - Busca empréstimo por ID
- ✅ `confirmarEmprestimo(id)` - Confirma empréstimo (usado pelo atendente)
- ✅ `monitorarEmprestimo(id)` - Stream em tempo real para monitorar mudanças
- ✅ `listarEmprestimosPorUsuario(userId)` - Lista empréstimos de um usuário
- ✅ `monitorarEmprestimosPendentes()` - Stream de empréstimos não confirmados
- ✅ `deletarEmprestimo(id)` - Remove empréstimo (cancelamento)
- ✅ `limparEmprestimosAntigos()` - Remove empréstimos antigos (>24h não confirmados)

### **QR Code Page** (Usuário)

#### Funcionalidades:
- ✅ Salva empréstimo no Firestore ao gerar QR Code
- ✅ Monitora status em tempo real
- ✅ Estados visuais: Loading, Erro, Aguardando, Confirmado
- ✅ Fecha automaticamente quando confirmado
- ✅ Mostra feedback visual do status
- ✅ Indicador de "aguardando confirmação"

### **QR Scanner Page** (Atendente)

#### Funcionalidades:
- ✅ Escaneia QR Code do usuário
- ✅ Busca detalhes do empréstimo no Firestore
- ✅ Validações:
  - QR Code inválido
  - Empréstimo não encontrado
  - Empréstimo já confirmado
- ✅ Navega para página de confirmação detalhada
- ✅ Feedback visual (loading, sucesso, erro)
- ✅ Reset automático para nova leitura

### **Página de Confirmação** (Atendente)

#### Funcionalidades:
- ✅ Exibe informações completas do usuário:
  - Nome completo
  - Email
  - RA (Registro Acadêmico)
  - Curso
- ✅ Lista detalhada de equipamentos:
  - Nome do equipamento
  - Categoria (badge destacado)
  - Código de barras
  - Local/Bloco
  - Indicador visual se o equipamento foi encontrado
- ✅ Informações do empréstimo (ID, data/hora)
- ✅ Design profissional com cards
- ✅ Botões de ação (Cancelar/Confirmar)
- ✅ Atualiza status no Firestore
- ✅ Tratamento de erros completo

## 📱 Telas e Estados

### **Tela do Usuário (QR Code Page)**

#### Estados:
1. **Loading**: Gerando QR Code e salvando no banco
2. **Aguardando**: QR Code exibido, aguardando confirmação do atendente
3. **Confirmado**: Empréstimo confirmado, mostra ícone de sucesso
4. **Erro**: Erro ao gerar QR Code, opção de tentar novamente

### **Tela do Atendente (QR Scanner Page)**

#### Estados:
1. **Aguardando**: Scanner ativo, esperando QR Code
2. **QR Detectado**: QR Code lido, processando informações
3. **Processando**: Buscando detalhes no banco
4. **Confirmação**: Diálogo com detalhes do empréstimo
5. **Sucesso**: Empréstimo confirmado, feedback positivo

## 🔐 Validações de Segurança

- ✅ Validação de QR Code inválido
- ✅ Verificação de empréstimo existente
- ✅ Proteção contra confirmação duplicada
- ✅ Limpeza automática de empréstimos antigos
- ✅ Tratamento de erros em todas as operações

## 🎯 Como Usar

### **Para o Usuário:**
1. Selecione os equipamentos desejados
2. Clique em "Gerar QR Code"
3. Mostre o QR Code ao atendente
4. Aguarde a confirmação (automático)
5. A tela fecha automaticamente quando confirmado

### **Para o Atendente:**
1. Acesse a página de scanner
2. Aponte a câmera para o QR Code do usuário
3. O sistema abre uma página com todos os detalhes:
   - Nome completo do usuário
   - Email, RA, curso
   - Lista de equipamentos com nome, código e local
4. Revise as informações cuidadosamente
5. Clique em "Confirmar Empréstimo"
6. O sistema atualiza e notifica o usuário automaticamente

## 📊 Dados do QR Code

O QR Code contém apenas:
```json
{
  "emprestimoId": "auto-generated-id",
  "userId": "user123abc"
}
```

Os detalhes completos (equipamentos, etc.) são buscados do Firestore usando o `emprestimoId`.

## ⚡ Tempo Real

O sistema utiliza **Firestore Snapshots** para sincronização em tempo real:
- Usuário: Monitora `confirmado` field
- Atendente: Pode ver lista de empréstimos pendentes
- Atualização instantânea sem refresh manual

## 🧹 Manutenção

### Limpeza Automática:
```dart
await emprestimoService.limparEmprestimosAntigos();
```

Remove empréstimos:
- Não confirmados
- Criados há mais de 24 horas

**Recomendação**: Execute periodicamente (ex: Cloud Functions scheduled)

## 🚀 Próximas Melhorias (Sugestões)

1. **Notificações Push**: Notificar usuário quando confirmado
2. **Histórico**: Página de histórico de empréstimos
3. **Dashboard**: Estatísticas para atendentes
4. **Timeout**: Auto-cancelar empréstimos não confirmados após X minutos
5. **Biometria**: Adicionar autenticação biométrica para confirmação
6. **Offline Support**: Suporte para modo offline com sincronização

## 📝 Observações Importantes

- O QR Code deve ser mantido na tela até a confirmação
- A conexão com internet é necessária para o sistema funcionar
- O empréstimo é salvo no banco ANTES de exibir o QR Code
- O monitoramento em tempo real é encerrado quando a página fecha
- Empréstimos antigos devem ser limpos periodicamente para manter o banco organizado
