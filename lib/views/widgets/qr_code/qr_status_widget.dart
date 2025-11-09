import 'package:flutter/material.dart';
import '../../../models/emprestimo_model.dart';
import '../qr_code_display.dart';

// widget pra exibir diferentes estados do qr code
class QRStatusWidget extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final EmprestimoModel? emprestimo;
  final String qrData;
  final VoidCallback? onRetry;
  final bool isDevolucao;

  const QRStatusWidget({
    super.key,
    required this.isLoading,
    this.error,
    this.emprestimo,
    required this.qrData,
    this.onRetry,
    this.isDevolucao = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoading();
    }

    if (error != null) {
      return _buildError();
    }

    // se for devolucao
    if (isDevolucao) {
      if (emprestimo?.isDevolvido == true) {
        return _buildDevolvido();
      }
      return _buildPendenteDevolucao();
    }

    // se for emprestimo normal
    if (emprestimo?.isConfirmado == true) {
      return _buildConfirmado();
    }

    if (emprestimo?.isRecusado == true) {
      return _buildRecusado();
    }

    return _buildPendente();
  }

  Widget _buildLoading() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Color.fromARGB(255, 86, 22, 36)),
        SizedBox(height: 20),
        Text(
          'Gerando QR Code...',
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 86, 22, 36),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 20),
        Text(
          error!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Tentar novamente'),
        ),
      ],
    );
  }

  Widget _buildConfirmado() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 80),
        SizedBox(height: 20),
        Text(
          'Empréstimo confirmado!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Redirecionando...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 86, 22, 36),
          ),
        ),
      ],
    );
  }

  Widget _buildRecusado() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cancel, color: Colors.red, size: 80),
        const SizedBox(height: 20),
        const Text(
          'Empréstimo recusado',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Redirecionando...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 86, 22, 36),
          ),
        ),
      ],
    );
  }

  Widget _buildPendente() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Mostre esse QR Code à bibliotecária, e assim que ela aprovar, seu empréstimo será concluído!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 86, 22, 36),
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 40),
        QRCodeDisplay(qrData: qrData),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color.fromARGB(255, 86, 22, 36),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Aguardando confirmação...',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 86, 22, 36),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendenteDevolucao() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Mostre esse QR Code à bibliotecária para devolver os equipamentos!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 86, 22, 36),
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 40),
        QRCodeDisplay(qrData: qrData),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color.fromARGB(255, 86, 22, 36),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Aguardando confirmação da devolução...',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 86, 22, 36),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDevolvido() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.assignment_turned_in, color: Colors.green, size: 80),
        SizedBox(height: 20),
        Text(
          'Devolução confirmada!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Redirecionando...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 86, 22, 36),
          ),
        ),
      ],
    );
  }
}
