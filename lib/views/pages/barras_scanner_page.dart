import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/barcode_display.dart';
import '../widgets/navbar.dart';
import 'equipamento_conf_page.dart';
import '../../services/equipamento_service.dart';
import '../../models/equipamento.dart';

class BarrasScannerPage extends StatefulWidget {
  const BarrasScannerPage({super.key});

  @override
  State<BarrasScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarrasScannerPage> {
  String _scannedCode = '';
  bool _hasScanned = false;
  final EquipamentoService _equipamentoService = EquipamentoService();

  void _onBarcodeScanned(String code) {
    if (!_hasScanned) {
      setState(() {
        _scannedCode = code;
        _hasScanned = true;
      });
      
      // verifica o equipamento no banco antes de prosseguir
      _verificarEquipamento(code);
    }
  }

  Future<void> _verificarEquipamento(String codigo) async {
    // mostra um loading enquanto verifica
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // verifica a disponibilidade do equipamento
    final resultado = await _equipamentoService.verificarDisponibilidade(codigo);

    // fecha o loading
    if (mounted) {
      Navigator.of(context).pop();
    }

    // verifica o resultado
    final bool existe = resultado['existe'] ?? false;
    final bool disponivel = resultado['disponivel'] ?? false;

    if (!mounted) return;

    if (existe && disponivel) {
      // equipamento existe e esta disponivel - prossegue pra pagina de confirmacao
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EquipamentoConfPage(bookCode: codigo),
        ),
      );
    } else {
      // equipamento nao existe ou nao esta disponivel - mostra erro
      _mostrarErro(resultado);
    }
  }

  void _mostrarErro(Map<String, dynamic> resultado) {
    final bool existe = resultado['existe'] ?? false;
    final String mensagem = resultado['mensagem'] ?? '';
    final Equipamento? equipamento = resultado['equipamento'];

    Color titleColor = existe ? Colors.orange : Colors.red;
    IconData icon = existe ? Icons.warning_amber_rounded : Icons.error_outline;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: titleColor, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                existe ? 'Equipamento Indisponível' : 'Não Encontrado',
                style: TextStyle(color: titleColor),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mensagem,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (equipamento != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Código: ${equipamento.codigo}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nome: ${equipamento.nome}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bloco: ${equipamento.bloco}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reseta o estado para permitir nova leitura
              setState(() {
                _hasScanned = false;
                _scannedCode = '';
              });
            },
            child: const Text('Tentar Novamente'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Volta para a página anterior
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Center(
            child: AppLogo(),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Scaneie o código de barras presente no equipamento:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 86, 22, 36),
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Scanner de código de barras
                BarcodeScanner(
                  onBarcodeScanned: _onBarcodeScanned,
                ),
                if (_scannedCode.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Código: $_scannedCode',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 86, 22, 36),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: const NavBar(selectedIndex: 2),
    );
  }
}
